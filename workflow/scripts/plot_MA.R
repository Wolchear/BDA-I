suppressPackageStartupMessages(library(DESeq2))

draw_ma <- function(dds, out_dir) {
    res_shrunk <- lfcShrink(
        dds,
        coef = "status_cancer_vs_healthy",
        type = "apeglm"
    )

    png(file.path(out_dir, "MA_plot.png"), width = 1800, height = 1400, res = 200)
    plotMA(res_shrunk)
    dev.off()
}

parse_args <- function() {
    args <- commandArgs(trailingOnly = TRUE)

    list(
        dds_file = args[1],
        out_dir = args[2]
    )
}


args <- parse_args()

dds <- readRDS(args$dds_file)
draw_ma(dds, args$out_dir)