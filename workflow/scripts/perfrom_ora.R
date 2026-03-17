suppressPackageStartupMessages(library(clusterProfiler))
suppressPackageStartupMessages(library(org.Hs.eg.db))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(dplyr))

perform_ego <- function(deg) {

    sig_genes <- gsub("\\..*$", "", rownames(deg))
    ego <- enrichGO(
        gene          = sig_genes,
        OrgDb         = org.Hs.eg.db,
        keyType       = "ENSEMBL",
        ont           = "ALL",
        pAdjustMethod = "BH",
        pvalueCutoff  = 0.05,
        qvalueCutoff  = 0.05,
        readable      = TRUE
    )
    return(ego)
}

draw_barplot <- function(ego_df, out_dir) {
    p <- ggplot(
        ego_df,
        aes(x = reorder(Description, Count), y = Count, fill = p.adjust)
    ) +
        geom_col() +
        scale_fill_viridis_c(option = "plasma") +
        coord_flip() +
        labs(
            title = "GO ORA barplot",
            x = "",
            y = "Count"
        ) +
        theme_minimal()

    ggsave(file.path(out_dir, "ora_barplot.png"), p, width = 10, height = 7)
}

draw_dotplot <- function(ego_df, out_dir) {

    ego_df$GeneRatio <- sapply(ego_df$GeneRatio, function(x) eval(parse(text = x)))
    
    p <- ggplot(
        ego_df,
        aes(x = GeneRatio, y = reorder(Description, GeneRatio))
    ) +
        geom_point(aes(size = Count, color = p.adjust)) +
        scale_color_viridis_c(option = "plasma") +
        labs(
            title = "GO ORA dotplot",
            x = "GeneRatio",
            y = ""
        ) +
        theme_minimal()

    ggsave(file.path(out_dir, "ora_dotplot.png"), p, width = 10, height = 7)
}


parse_args <- function() {
    args <- commandArgs(trailingOnly = TRUE)

    list(
        deg_file = args[1],
        out_dir = args[2],
        go_num = as.numeric(args[3])
    )
}
args <- parse_args()

deg <- read.csv(args$deg_file, row.names = 1)
ego_df <- perform_ego(deg) %>%
    as.data.frame() %>%
    arrange(p.adjust) %>%
    head(args$go_num)

draw_barplot(ego_df, args$out_dir)
draw_dotplot(ego_df, args$out_dir)