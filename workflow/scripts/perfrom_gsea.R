suppressPackageStartupMessages(library(clusterProfiler))
suppressPackageStartupMessages(library(org.Hs.eg.db))
suppressPackageStartupMessages(library(msigdbr))
suppressPackageStartupMessages(library(enrichplot))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(dplyr))

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

transform_ids <- function(ranked_list) {
    symbol_map <- bitr(
        names(ranked_list),
        fromType = "ENSEMBL",
        toType   = "SYMBOL",
        OrgDb    = org.Hs.eg.db
    )

    symbol_map <- symbol_map[!is.na(symbol_map$SYMBOL), ]

    ranked_symbol <- ranked_list[symbol_map$ENSEMBL]
    names(ranked_symbol) <- symbol_map$SYMBOL

    ranked_symbol <- sort(ranked_symbol, decreasing = TRUE)
    ranked_symbol <- ranked_symbol[!duplicated(names(ranked_symbol))]

    return(ranked_symbol)
}

perform_over_mig_db <- function(converted_list) {
    msig_df <- msigdbr(
        species = "Homo sapiens",
        category = "H"
    )[, c("gs_name", "gene_symbol")]

    msig_df <- msig_df[!is.na(msig_df$gene_symbol) & msig_df$gene_symbol != "", ]

    gsea_msig <- GSEA(
        geneList     = converted_list,
        TERM2GENE    = msig_df,
        pvalueCutoff = 0.05,
        minGSSize    = 10,
        maxGSSize    = 500,
        verbose      = FALSE
    )
    return(gsea_msig)
}

draw_gsea_top_plot <- function(gsea_obj, out_file) {
    p <- gseaplot2(
        gsea_obj,
        geneSetID = 1,
        title = as.data.frame(gsea_obj)$Description[1]
    )

    ggsave(out_file, p, width = 10, height = 7)
}

draw_gsea_dotplot <- function(gsea_obj, out_file, title_text) {
    p <- dotplot(gsea_obj, showCategory = 20) +
        labs(title = title_text) +
        theme_minimal()

    ggsave(out_file, p, width = 10, height = 7)
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
transformed_list <- transform_ids(ranked_list)

go_res <- perform_over_go(ranked_list)
msig_res <- perform_over_mig_db(transformed_list)

go_df <- as.data.frame(go_res)
msig_df <- as.data.frame(msig_res)


draw_gsea_dotplot(go_res, file.path(args$out_dir, "gsea_go_dotplot.png"), "GO GSEA dotplot")
draw_gsea_top_plot(go_res, file.path(args$out_dir, "gsea_go_top1.png"))

draw_gsea_dotplot(msig_res, file.path(args$out_dir, "gsea_msigdb_dotplot.png"), "MSigDB GSEA dotplot")
draw_gsea_top_plot(msig_res, file.path(args$out_dir, "gsea_msigdb_top1.png"))