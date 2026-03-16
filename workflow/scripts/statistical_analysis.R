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

prepare_shrunk_df <- function(dds) {
    res_shrunk <- lfcShrink(
        dds,
        coef="status_cancer_vs_healthy",
        type="apeglm"
    )
    res_df <- res_shrunk %>%
        as.data.frame() %>%
        rownames_to_column("gene") %>%
        arrange(padj) %>%
        mutate(
            significance = case_when(
            padj < 0.05 & log2FoldChange >  1 ~ "Up",
            padj < 0.05 & log2FoldChange < -1 ~ "Down",
            TRUE ~ "NS"  # Not Significant
            ),
            significance = factor(significance, levels = c("Up", "Down", "NS"))
        )
    return(res_df)
}

draw_volcano <- function(res_df, out_dir) {
    label_df <- res_df %>%
        filter(padj < 0.001 & abs(log2FoldChange) > 3)


    p <- ggplot(res_df, aes(x = log2FoldChange, y = -log10(padj))) +
        geom_point(aes(color = significance), alpha = 0.7, size = 1.8) +
        scale_color_manual(
            values = c(
                "Up" = "firebrick",
                "Down" = "steelblue",
                "NS" = "grey70"
            )
        ) +
        geom_text_repel(
            data = label_df,
            aes(label = gene),
            size = 3,
            box.padding = 0.5,
            point.padding = 0.3,
            segment.color = "grey50"
        ) + 
        geom_vline(xintercept = c(-1, 1), linetype = "dashed", color = "black") +
        geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "black") +
        labs(
            title = "Volcano plot",
            x = "Shrunken log2 fold change",
            y = expression(-log[10](adjusted~p-value)),
            color = "Category"
        ) +
        theme_minimal(base_size = 12) +
        theme(
            plot.title = element_text(hjust = 0.5),
            legend.position = "right"
        )

    ggsave(
        filename = file.path(out_dir, "volcano_plot.png"),
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

res_df <- prepare_shrunk_df(dds)
draw_volcano(res_df, out_dir)
draw_ma(dds, out_dir)