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

draw_pca <- function(vsd, out_dir) {
    pca_data <- plotPCA(vsd, intgroup = "status", returnData = TRUE)
    percentVar <- round(100 * attr(pca_data, "percentVar"))

    p <- ggplot(pca_data, aes(x = PC1, y = PC2, color = status)) +
            geom_point(size =3) +
            xlab(paste0("PC1: ", percentVar[1], "% variance")) +
            ylab(paste0("PC2: ", percentVar[2], "% variance")) +
            coord_fixed() +
            ggtitle("PCA with VST data")
    
    ggsave(
        filename = file.path(out_dir, "PCA_plot.png"),
        plot = p,
        width = 8,
        height = 7,
        dpi = 300
    )
}

draw_ma <- function(dds, out_dir) {
    res_shrunk <- lfcShrink(
        dds,
        coef = "status_cancer_vs_healthy",
        type = "apeglm"
    )

    png(file.path(out_dir, "MA_plot.png"), width = 1800, height = 1400, res = 200)
    plotMA(res_shrunk, ylim = c(-5, 5))
    dev.off()
}

args <- commandArgs(trailingOnly = TRUE)

deseq_obj_file <- args[1]
out_dir <- args[2]

dds <- readRDS(deseq_obj_file)
vsd <- vst(dds, blind = FALSE)
norm_counts <- assay(vsd)

draw_heatmap(norm_counts, out_dir)
draw_pca(vsd, out_dir)

draw_ma(dds, out_dir)