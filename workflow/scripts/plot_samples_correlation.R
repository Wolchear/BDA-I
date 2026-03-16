suppressPackageStartupMessages(library(DESeq2))
suppressPackageStartupMessages(library(pheatmap))

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

draw_heatmap <- function(norm_counts, out_dir, metadata) {
    correlation_matrix <- cor(norm_counts, method = "pearson")

    pheatmap(
        correlation_matrix,
        display_numbers = TRUE,
        number_format = "%.2f",
        annotation_col = metadata,
        annotation_row = metadata,
        annotation_colors = list(
            status = c(
                'healthy' = '#66C2A5',
                'cancer' = '#FC8D62'
            )
        ),
        main = "Pearson correlation between samples",
        filename = file.path(out_dir, "sample_correlation_heatmap.png"),
        width = 8,
        height = 7
    )
}

parse_args <- function() {
    args <- commandArgs(trailingOnly = TRUE)

    list(
        vsd_file = args[1],
        out_dir = args[2],
        metadata = args[3]
    )
}

args <- parse_args()

metadata <- read_meta(args$metadata)

vsd <- readRDS(args$vsd_file)
norm_counts <- assay(vsd)
metadata <- metadata[colnames(norm_counts), , drop = FALSE]

draw_heatmap(norm_counts, args$out_dir, metadata)