suppressPackageStartupMessages(library(clusterProfiler))
suppressPackageStartupMessages(library(org.Hs.eg.db))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(DOSE))
suppressPackageStartupMessages(library(aPEAR))
suppressPackageStartupMessages(library(htmlwidgets))
suppressPackageStartupMessages(library(plotly))


get_ranked_list <- function(rank_file) {
    ranked_df <- read.table(rank_file, row.names = 1)
    colnames(ranked_df) <- "score"

    rownames(ranked_df) <- gsub("\\..*$", "", rownames(ranked_df))

    ranked_list <- ranked_df$score
    names(ranked_list) <- rownames(ranked_df)

    ranked_list <- sort(ranked_list, decreasing = TRUE)
    return(ranked_list)
}

perform_over_go <- function(ranked_list) {
    gsea <- gseGO(
        geneList     = ranked_list,
        OrgDb        = org.Hs.eg.db,
        keyType      = "ENSEMBL",
        ont          = "ALL",
        minGSSize    = 10,
        maxGSSize    = 500,
        pvalueCutoff = 0.05,
        verbose      = FALSE
    )

    return(gsea)
}

get_pear_plot <- function(gsea) {
    p <- enrichmentNetwork(
            gsea@result,
            drawEllipses = TRUE,
            fontSize = 2.5
        )

    return(p)
}



parse_args <- function() {
    args <- commandArgs(trailingOnly = TRUE)

    list(
        rank_file = args[1],
        out_dir = args[2]
    )
}

args <- parse_args()

ranked_list <- get_ranked_list(args$rank_file)
go_res <- perform_over_go(ranked_list)

p <- get_pear_plot(go_res)
ggsave(file.path(args$out_dir, "gsea_pear.png"), p)

p_int <- ggplotly(p, tooltip = c("ID", "Cluster", "Cluster size"))
saveWidget(p_int, file.path(args$out_dir, "gsea_pear.html"))