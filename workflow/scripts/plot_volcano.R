suppressPackageStartupMessages(library(DESeq2))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(ggrepel))

parse_args <- function() {
    args <- commandArgs(trailingOnly = TRUE)

    list(
        dds_file = args[1],
        out_dir = args[2]
    )
}

prepare_shrunk_df <- function(dds) {
    res_shrunk <- lfcShrink(
        dds,
        coef = "status_cancer_vs_healthy",
        type = "apeglm"
    )

    res_df <- res_shrunk %>%
        as.data.frame() %>%
        rownames_to_column("gene") %>%
        mutate(
            significance = case_when(
                !is.na(padj) & padj < 0.05 & log2FoldChange > 1  ~ "Up",
                !is.na(padj) & padj < 0.05 & log2FoldChange < -1 ~ "Down",
                TRUE ~ "NS"
            ),
            significance = factor(significance, levels = c("Up", "Down", "NS"))
        ) %>%
        arrange(padj)

    return(res_df)
}

draw_volcano <- function(res_df, out_dir) {
    plot_df <- res_df %>%
        filter(!is.na(padj), !is.na(log2FoldChange))

    label_df <- plot_df %>%
        filter(significance != "NS", abs(log2FoldChange) > 2) %>%
        group_by(significance) %>%
        slice_min(order_by = padj, n = 5, with_ties = FALSE) %>%
        ungroup()

    p <- ggplot(plot_df, aes(x = log2FoldChange, y = -log10(padj))) +
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
            segment.color = "grey50",
            max.overlaps = 50
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

args <- parse_args()

dds <- readRDS(args$dds_file)
res_df <- prepare_shrunk_df(dds)

draw_volcano(res_df, args$out_dir)