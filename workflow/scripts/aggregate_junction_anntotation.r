plot_read <- function(files, samples, prefix, cols) {

    all_data <- lapply(files,
                    read.delim,
                    header = TRUE,
                    sep = "\t"
                )



    junction_ratio <- lapply(all_data, function(df) {
        counts <- table(df$annotation)
        counts / sum(counts)
    })

    event_ratio  <- lapply(all_data, function(df) { 
        counts <- tapply(df$read_count,df$annotation,sum)
        counts / sum(counts)
    })
    
    pdf(paste0(prefix, ".splice_events.pdf"), width = 12, height = 10)
    par(mfrow = c(3, 2), mar = c(2, 2, 3, 2))
    
    for (i in seq_along(event_ratio)) {
        
        vals <- event_ratio[[i]]
        vals
        labels <- paste0(
            names(vals), " ",
            round(vals * 100), "%"
        )
        pie(
            vals,
            col = c(4, 3, 2),
            init.angle = 30,
            density = c(70, 70, 70),
            main = samples[i],
            labels = labels
        )
    }

    dev.off()

    pdf(paste0(prefix, ".splice_junction.pdf"), width = 12, height = 10)
    par(mfrow = c(3, 2), mar = c(2, 2, 3, 2))

    for (i in seq_along(junction_ratio)) {
        
        vals <- junction_ratio[[i]]
        
        labels <- paste0(
            names(vals), " ",
            round(vals * 100), "%"
        )
        pie(
            vals,
            col = c(4, 3, 2),
            init.angle = 30,
            density = c(70, 70, 70),
            main = samples[i],
            labels = labels
        )
    }

    dev.off()
    
}



args <- commandArgs(trailingOnly = TRUE)

input_dir <- args[1]
prefix <- args[2]

files <- list.files(input_dir, pattern="\\.xls$", full.names=TRUE)
samples <- sub("\\.junction.xls$", "", basename(files))

plot_read(files, samples, prefix)