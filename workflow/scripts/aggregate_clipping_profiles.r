plot_read <- function(read_name, outfile){

  pdf(outfile)

  first <- TRUE

  for(i in seq_along(files)){

    file <- files[i]

    lines_file <- readLines(file)

    r1_start <- which(lines_file == "Read-1:")
    r2_start <- which(lines_file == "Read-2:")

    if(read_name == "R1"){
      data_lines <- lines_file[(r1_start+1):(r2_start-1)]
    } else {
      data_lines <- lines_file[(r2_start+1):length(lines_file)]
    }

    tab <- read.table(text=data_lines)

    read_pos <- tab$V1
    clip <- tab$V2
    nonclip <- tab$V3

    nonclip_pct <- nonclip*100/(clip+nonclip)

    if(first){

      plot(read_pos,
           nonclip_pct,
           col=cols[i],
           type="b",
           main=paste("clipping profile", read_name),
           xlab=paste("Position of read", read_name),
           ylab="Non-clipped %")

      first <- FALSE

    } else {

      lines(read_pos,
            nonclip_pct,
            col=cols[i],
            type="b")
    }
  }

  legend("bottomright",
         legend=samples,
         col=cols,
         lty=1,
         pch=1,
         cex=0.8)

  dev.off()
}


args <- commandArgs(trailingOnly = TRUE)

input_dir <- args[1]
prefix <- args[2]

files <- list.files(input_dir, pattern="\\.xls$", full.names=TRUE)

samples <- sub("\\.clipping_profile.xls$", "", basename(files))
cols <- rainbow(length(files))

plot_read("R1", paste0(prefix,".R1.pdf"))
plot_read("R2", paste0(prefix,".R2.pdf"))