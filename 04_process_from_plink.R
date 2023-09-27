#!/usr/bin/env Rscript
library(data.table)
library(argparse)


main <- function(args){

    print(args)

    input_path <- args$input_path
    gene_map_path <- args$gene_map_path
    column_info <- args$column_info
    column_info_names <- args$column_info_names
    out_prefix <- args$out_prefix

    # read input path
    merged <- fread(input_path)
    merged <- do.call(rbind, lst)

    # add chr to CHR column
    merged$CHR <- paste0("chr",merged$CHR)
    merged$Allele1 <- NULL
    merged$Allele2 <- NULL

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
parser$add_argument("--input_path", default=NULL, required = TRUE, help = "path to input directory")
parser$add_argument("--gene_map_path", default=NULL, required = FALSE, help = "path gene map, e.g. 20524_hgnc_ensg_enst_chr_pos.txt.gz")
parser$add_argument("--column_info", default=NULL, required = FALSE, help = "Add a column with content")
parser$add_argument("--column_info_names", default=NULL, required = FALSE, help = "Names to be assigned")
parser$add_argument("--out_prefix", default=NULL, required = TRUE, help = "Where should the results be written?")
args <- parser$parse_args()

main(args)

