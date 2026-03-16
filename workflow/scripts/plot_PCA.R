suppressPackageStartupMessages(library(DESeq2))
suppressPackageStartupMessages(library(ggplot2))

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

parse_args <- function() {
    args <- commandArgs(trailingOnly = TRUE)

    list(
        vsd_file = args[1],
        out_dir = args[2]
    )
}

args <- parse_args()

vsd <- readRDS(args$vsd_file)
draw_pca(vsd, args$out_dir)