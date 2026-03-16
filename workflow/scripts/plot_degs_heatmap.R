suppressPackageStartupMessages(library(RColorBrewer))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(pheatmap))

get_genes_subset <- function(deg_file, genes_num) {
    deg <- read.csv( deg_file, row.names = 1 )
    
    top_genes <- deg %>%
        filter(!is.na(padj)) %>%
        arrange(padj) %>%
        head(genes_num) %>%
        rownames()
        
    return(top_genes)
}

get_vst_subset <- function(top_genes, vst_file) {
    vst_mat <- read.csv( vst_file, row.names = 1 )
    vst_subset <- vst_mat[top_genes, ]
    
    vst_z <- t(scale(t(vst_subset)))
    
    return(vst_z)
}

read_meta <- function(meta_file) {
    meta <- read.table(
        meta_file,
        header = TRUE,
        sep = "\t",
        row.names = 1 
    )
    meta$status <- factor(meta$status)
    
    return(meta)
}

draw_heatmap <- function(vst_z, metadata, out_file, genes_num) {
    pheatmap(
        vst_z,
        annotation_col = metadata,
        color = colorRampPalette(rev(brewer.pal(11, "RdBu")))(50), 
        cluster_rows = TRUE, 
        cluster_cols = TRUE, 
        show_rownames = TRUE, 
        fontsize_row = 8, 
        border_color = NA, 
        main = paste("Top", genes_num, "DE genes"), 
        filename = out_file, 
        width = 10, 
        height = 12 
    ) 
}

parse_args <- function() {
    args <- commandArgs(trailingOnly = TRUE)

    list(
        vst_file = args[1],
        deg_file = args[2],
        meta_file = args[3],
        out_file = args[4],
        genes_num = as.numeric(args[5])
    )
}

args <- parse_args()

vst_z <- get_genes_subset(args$deg_file, args$genes_num) %>%
    get_vst_subset(args$vst_file)

meta <- read_meta(args$meta_file)
meta <- meta[colnames(vst_z), , drop = FALSE]

draw_heatmap(vst_z, meta, args$out_file, args$genes_num)