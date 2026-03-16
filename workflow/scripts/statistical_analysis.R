suppressPackageStartupMessages(library(DESeq2))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(pheatmap))
suppressPackageStartupMessages(library(ggrepel))


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
args <- commandArgs(trailingOnly = TRUE)

deseq_obj_file <- args[1]
out_dir <- args[2]

dds <- readRDS(deseq_obj_file)
vsd <- vst(dds, blind = FALSE)
norm_counts <- assay(vsd)

draw_heatmap(norm_counts, out_dir)