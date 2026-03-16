suppressPackageStartupMessages(library(DESeq2))
suppressPackageStartupMessages(library(pheatmap))


draw_heatmap <- function(norm_counts, out_dir) {
    correlation_matrix <- cor(norm_counts, method = "pearson")

    pheatmap(
        correlation_matrix,
        display_numbers = TRUE,
        number_format = "%.2f",
        clustering_distance_rows = "euclidean",
        clustering_distance_cols = "euclidean",
        clustering_method = "complete",
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
        out_dir = args[2]
    )
}

args <- parse_args()

vsd <- readRDS(args$vsd_file)
norm_counts <- assay(vsd)
draw_heatmap(norm_counts, args$out_dir)