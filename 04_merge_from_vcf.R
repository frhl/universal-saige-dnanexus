#!/usr/bin/env Rscript
library(data.table)
library(argparse)


main <- function(args){

    print(args)

    input_dir <- args$input_dir
    gene_map_path <- args$gene_map_path
    column_info <- args$column_info
    column_info_names <- args$column_info_names
    pattern <- args$pattern
    out_prefix <- args$out_prefix

    # dnanexus being weird, we are manually subbing this
    pattern <- gsub("STAR","\\*", pattern)

    files <- list.files(input_dir, full.names=TRUE, pattern=pattern)
    print(files)
    stopifnot(length(files)>=22)
    fread_saige_alt <- function(path){return(fread(path))}
    lst <- lapply(files, fread_saige_alt)
    merged <- do.call(rbind, lst)
    
    # get hgnc symbol
    if (!is.null(gene_map_path)){
        map_df <- fread(gene_map_path)
        ensgid_to_hgnc <- map_df$hgnc_symbol
        names(ensgid_to_hgnc) <- map_df$ensembl_gene_id  
        merged$hgnc_symbol <- ensgid_to_hgnc[merged$MarkerID] 
    } 
    
    # add extra columns with info annotations
    if (!is.null(column_info)) { 
        vector_info_cols <- unlist(strsplit(column_info_names, split="\\|")) 
        vector_info_content <- unlist(strsplit(column_info, split="\\|"))
        stopifnot(length(vector_info_cols) == length(vector_info_content))
        for (idx in 1:length(vector_info_cols)){
            info_col <- vector_info_cols[idx]
            info_content <- vector_info_content[idx]
            merged[[info_col]] <- info_content 
        }
    }
    
    out_file <- paste0(out_prefix, ".txt.gz")
    fwrite(merged, out_file, sep = "\t")
}


# add arguments
parser <- ArgumentParser()
parser$add_argument("--input_dir", default=NULL, required = TRUE, help = "path to input directory")
parser$add_argument("--pattern", default=NULL, required = TRUE, help = "pattern for input")
parser$add_argument("--gene_map_path", default=NULL, required = FALSE, help = "path gene map, e.g. 20524_hgnc_ensg_enst_chr_pos.txt.gz")
parser$add_argument("--column_info", default=NULL, required = FALSE, help = "Add a column with content")
parser$add_argument("--column_info_names", default=NULL, required = FALSE, help = "Names to be assigned")
parser$add_argument("--out_prefix", default=NULL, required = TRUE, help = "Where should the results be written?")
args <- parser$parse_args()

main(args)

