#!/usr/bin/env Rscript
library(data.table)
library(argparse)
library(ggplot2)
library(ggrepel)
library(ggrastr)
library(gridExtra)

# Get expected P-value based on uniform quantiles
get_expected_p <- function(observed_p, na.rm = FALSE){
    stopifnot(is.numeric(observed_p))
    stopifnot(any(observed_p >= 0))
    sum_na <- sum(is.na(observed_p))
    if (sum_na > 0){
           if (na.rm){
                observed_p <- observed_p[!is.na(observed_p)]
           } else {
                warning("NAs detected in P-values. Set na.rm = TRUE to remove them.")
           }
    }
    n <- length(observed_p)
    observed_rank <- rank(observed_p)
    uniform <- (1:n)/(n+1)
    uniform <- uniform[observed_rank]
    return(uniform)
}

#' calculate lambda squared inflation statistic
calc_inflation <- function(P){
    return(median(qchisq(1-P,1)) / qchisq(0.5, 1))
}


# function to extract annotation, af, pp and mode
str_extract_annotation <- function(x){
    return(stringr::str_extract(x, pattern=("(pLoF_damaging_missense)|(pLoF)|(damaging_missense)|(synonymous)|(non_coding)")))
}

# extract AF cutoff
str_extract_af <- function(x){
    return(as.numeric(gsub("af","",stringr::str_extract(x, pattern=("af(0\\.)?[0-9]+"))))/100)
}

# extract mode 
str_extract_mode <- function(x){
    return(stringr::str_extract(x, pattern=("(recessive)|(additive)")))
}

# extract pp-value
str_extract_pp <- function(x){
  return(as.numeric(gsub("pp","",stringr::str_extract(x, pattern=("pp(0\\.)?[0-9]+")))))
}

# get index of basename
str_extract_basename_index <- function(x, index, delim="\\."){
  return(unlist(strsplit(basename(x), split=delim))[index])
}



main <- function(args){

    print(args)

    input_dir <- args$input_dir
    out_prefix <- args$out_prefix
    ribbon_p <- as.numeric(args$ribbon_p)
    min_allele2_ac <- as.numeric(args$min_allele2_ac)

    regex_mode <- args$regex_mode
    regex_annotation <- args$regex_annotation
    regex_af_cutoff <- args$regex_af_cutoff
    regex_pp_cutoff <- args$regex_pp_cutoff
   

    # get files to iterate over
    files <-  list.files(input_dir, pattern=".txt.gz", full.names=TRUE)
    stopifnot(length(files)>0)

    # subset files
    if (!is.null(regex_mode)) files <- files[grepl(x=files,pattern=regex_mode)]
    if (!is.null(regex_annotation)) files <- files[grepl(x=files,pattern=regex_annotation)]
    if (!is.null(regex_af_cutoff)) files <- files[grepl(x=files,pattern=regex_af_cutoff)]
    if (!is.null(regex_pp_cutoff)) files <- files[grepl(x=files,pattern=regex_pp_cutoff)]
    stopifnot(length(files)>0)

    lst <- list()
    outfile <- paste0(out_prefix, ".pdf")
    pdf(outfile, onefile=TRUE, width=10, height=8)
    for (file in files){
        
        # read in file
        write(file, stderr()) 
        d <- fread(file)

        # subset to relevant cutoff
        d <- d[d$AC_Allele2 >= min_allele2_ac,]

        # get expected/obseved P on log-scale
        d <- d[order(d$p.value),]
        n <- nrow(d)
        d$p.value.expt <- get_expected_p(observed_p=d$p.value)
        d$p.obs.log10 <- -log10(d$p.value)
        d$p.expt.log10 <- -log10(d$p.value.expt)
        d$clower = -log10(qbeta(p = (1 - ribbon_p) / 2, shape2 = n:1, shape1 = 1:n))
        d$cupper = -log10(qbeta(p = (1 + ribbon_p) / 2, shape2 = n:1, shape1 = 1:n))

        # We plot the labels of genes with FDR < 0.25
        d$fdr <- p.adjust(d$p.value, method='fdr')
        d$significant <- d$fdr<0.25
        d$label <- d$hgnc_symbol
        d$label[!d$significant] <- NA

        # get various attributes to plot
        pp_cutoff <- str_extract_pp(file)
        af_cutoff <- str_extract_af(file)
        annotation <- str_extract_annotation(file)
        mode <- str_extract_mode(file)
        trait <- str_extract_basename_index(file, 2)
        min_hap_affected <-min(d$AC_Allele2)
        inflation <- round(calc_inflation(d$p.value),4)

        # setup titles
        title <- paste0(trait, " (", mode, ")")
        subtitle <- paste0(annotation,", PP>", pp_cutoff, ", AF<", af_cutoff, "\nmin(haplotypes)=",min_hap_affected,", genes=",n,", \u03BB=", inflation)

        plt <- ggplot(d, aes(x=p.expt.log10, y=p.obs.log10, ymax=clower, ymin=cupper, label=label)) +
            geom_ribbon(data=d, fill="grey80", alpha = 0.7) +
            geom_point_rast(data=d[!d$significant,], size = 2.50, alpha = 0.9, color="#BE1E2D") +
            geom_point(data=d[d$significant,], size = 3.00, alpha = 0.9, color="#BE1E2D") +
            geom_text_repel(color="black", max.overlaps = Inf, point.padding = 0.15, box.padding = 1) +
            geom_abline(color = "black") + 
            scale_x_continuous(breaks=scales::pretty_breaks(n=5)) +
            scale_y_continuous(breaks=scales::pretty_breaks(n=5)) +
            xlab(expression(paste(-log[10],'(Expected P-value)' ))) +
            ylab(expression(paste(-log[10],'(Observed P-value)' ))) +
            theme_classic() +
            theme(
                axis.text=element_text(size=15),
                axis.title=element_text(size=15,face="bold"),
                axis.title.x = element_text(margin=ggplot2::margin(t=16)),
                axis.title.y = element_text(margin=ggplot2::margin(r=16)),
                plot.title = element_text(hjust=0.5),
                plot.subtitle = element_text(hjust=0.5),
                legend.text=element_text(size=15),
                legend.position="top"
            ) + ggtitle(title, subtitle)

        print(plt)
    }
    dev.off()

}


# add arguments
parser <- ArgumentParser()
parser$add_argument("--input_dir", default=NULL, required = TRUE, help = "path to input directory")
parser$add_argument("--regex_mode", default=NULL, required = FALSE, help = "")
parser$add_argument("--regex_annotation", default=NULL, required = FALSE, help = "")
parser$add_argument("--regex_pp_cutoff", default=NULL, required = FALSE, help = "")
parser$add_argument("--regex_af_cutoff", default=NULL, required = FALSE, help = "")
parser$add_argument("--min_allele2_ac", default=10, required = FALSE, help = "")
parser$add_argument("--ribbon_p", default=0.95, required = FALSE, help = "")
parser$add_argument("--out_prefix", default=NULL, required = TRUE, help = "Where should the results be written?")
args <- parser$parse_args()

main(args)

