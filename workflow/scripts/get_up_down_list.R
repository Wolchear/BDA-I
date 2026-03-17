get_list <- function(deg, genes_num) {
    deg_sorted <- deg[order(deg$log2FoldChange), ]
    
    top_down <- head(deg_sorted, genes_num)
    top_up <- tail(deg_sorted, genes_num)

    return(
        list(
            up = top_up,
            down = top_down
        )
    )
}

save_lists <- function(top_genes, out_file) {
    up <- top_genes$up
    down <- top_genes$down

    up$direction <- "up"
    down$direction <- "down"

    combined <- rbind(up, down)

    write.table(
        combined,
        out_file,
        sep = "\t",
        quote = FALSE,
        row.names = TRUE,
        col.names = NA
    )
}

parse_args <- function() {
    args <- commandArgs(trailingOnly = TRUE)

    list(
        deg_file = args[1],
        out_file = args[2],
        genes_num = as.numeric(args[3])
    )
}
args <- parse_args()

deg <- read.csv(args$deg_file, row.names = 1)
top_genes <- get_list(deg, args$genes_num)
save_lists(top_genes, args$out_file)