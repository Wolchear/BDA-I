suppressPackageStartupMessages(library(DESeq2))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(patchwork))

create_box_plot <- function(counts, metadata, title) {

    df <- as.data.frame(counts)
    df$gene <- rownames(df)

    df <- tidyr::pivot_longer(
        df,
        cols = -gene,
        names_to = "sample",
        values_to = "count"
    )

    df$status <- metadata[df$sample, "status"]

    df$sample <- factor(df$sample, levels = colnames(counts))

    plot <- ggplot(df, aes(x = sample, y = log2(count + 1), fill = status)) +
        geom_boxplot(outlier.size = 0.2) +
        scale_fill_manual(
            values = c(
                healthy = "#66C2A5",
                cancer = "#FC8D62"
            )
        ) +
        theme_bw() +
        labs(
            title = title,
            x = "Sample",
            y = "log2(count + 1)"
        ) +
        theme(
            axis.text.x = element_text(angle = 45, hjust = 1)
        )

    return(plot)
}
create_bar_plot <- function(counts, metadata, title) {
    library_size <- colSums(counts)

    df <- data.frame(
        sample = names(library_size),
        library_size = library_size,
        status = metadata[names(library_size), "status"]
    )

    plot <- ggplot(df, aes(x = sample, y = library_size, fill = status)) +
        geom_col() +
        scale_fill_manual(
            values = c(
                healthy = "#66C2A5",
                cancer = "#FC8D62"
            )
        ) +
        labs(
            title = title,
            x = "Sample",
            y = "Library size"
        ) +
        theme(
            axis.text.x = element_text(angle = 45, hjust = 1)
        )
    return(plot)
}

combine_plots <- function(bar_plot, box_plot, outdir, name) {
    combined_plot <- bar_plot / box_plot +
        plot_layout(heights = c(1, 2))
    
    ggsave(
        filename = file.path(outdir, name),
        plot = combined_plot,
        width = 12,
        height = 10,
        dpi = 300
    )
}

read_meta <- function(meta_file) {
    meta <- read.table(
        meta_file,
        header = TRUE,
        sep = "\t",
        row.names = 1 
    )
    meta$status <- factor(meta$status)
    
    return(meta)
}

parse_args <- function() {
    args <- commandArgs(trailingOnly = TRUE)

    list(
        dds_file = args[1],
        out_dir = args[2],
        metadata = args[3]
    )
}

args <- parse_args()

dds <- readRDS(args$dds_file)
metadata <- read_meta(args$metadata)

raw_counts <- counts(dds, normalized = FALSE)
normalized_counts <- counts(dds, normalized = TRUE)
raw_lib_size <- create_bar_plot(raw_counts, metadata, 'Raw lib size')
normalized_lib_size <- create_bar_plot(normalized_counts, metadata, 'Normalized lib size')

raw_boxplot <- create_box_plot(raw_counts, metadata, 'Raw counts')
normalized_boxplot <- create_box_plot(normalized_counts, metadata, 'Normalized counts')

combine_plots(raw_lib_size, raw_boxplot, args$out_dir,'raw_counts.png')
combine_plots(normalized_lib_size, normalized_boxplot,args$out_dir, 'normalized_counts.png')