suppressPackageStartupMessages(library(DESeq2))

get_matrix <- function(matrix_file) {
    fc <- read.table(
        matrix_file,
        header = TRUE,
        sep = "\t",
        comment.char = "#",
        check.names = FALSE
    )
    
    counts <- fc[,7:ncol(fc)]
    rownames(counts) <- fc$Geneid

    colnames(counts) <- basename(colnames(counts))
    colnames(counts) <- sub("\\.sorted\\.bam$", "", colnames(counts))

    return(counts)
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

prepare_dseq_obj <- function(count_matrix, metadata) {
    metadata <- metadata[colnames(count_matrix), , drop = FALSE]
    dds <- DESeqDataSetFromMatrix(
        countData = count_matrix,
        colData = metadata,
        design = ~ status
    )
    dds$status <- relevel(dds$status, ref = "healthy")
    dds <- dds[rowSums(counts(dds)) > 10, ]
    return(DESeq(dds))
}

save_degs <- function(res, out_dir) {
    stat_diff_deg <- res[!is.na(res$padj) & res$padj < 0.05, ]
    write.csv(
        as.data.frame(stat_diff_deg),
        file.path(out_dir, "DEG_stat_diff.csv"),
        row.names = TRUE
    )

    bio_diff_deg <- stat_diff_deg[abs(stat_diff_deg$log2FoldChange) > 1, ]
    write.csv(
        as.data.frame(bio_diff_deg),
        file.path(out_dir, "DEG_biological_diff.csv"),
        row.names = TRUE
    )
    cat("Statistically significant DEGs:", nrow(stat_diff_deg), "\n")
    cat("Biologically significant DEGs:", nrow(bio_diff_deg), "\n")
}

save_gsea_list <- function(res, out_dir) {
    res_gsea <- res[!is.na(res$stat), ]
    res_ordered <- res_gsea[order(res_gsea$stat, decreasing = TRUE), ]
    gsea_table <- data.frame(
        gene = rownames(res_ordered),
        stat = res_ordered$stat
    )

    write.table(
        gsea_table,
        file.path(out_dir, "GSEA_list.rnk"),
        sep = "\t",
        quote = FALSE,
        row.names = FALSE,
        col.names = FALSE
    )
}

save_normalized_counts <- function(dds, out_dir) {
    vsd <- vst(dds, blind = FALSE)
    norm_counts <- assay(vsd)

    write.csv(
        as.data.frame(norm_counts),
        file.path(out_dir, "normalized_counts_vst.csv"),
        row.names = TRUE
    )
}


args <- commandArgs(trailingOnly = TRUE)

count_matrix_file <- args[1]
meta_file <- args[2]
out_dir <- args[3]

matrix <- get_matrix(count_matrix_file)
metadata <- read_meta(meta_file)
dds <- prepare_dseq_obj(matrix, metadata)

res <- results(dds)

save_degs(res, out_dir)
save_gsea_list(res, out_dir)
save_normalized_counts(dds, out_dir)