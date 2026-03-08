plot_read <- function(files, samples, outfile, cols) {
  pdf(outfile, width = 10, height = 7)

  all_data <- list()
  x_min <- Inf
  x_max <- -Inf
  y_max <- -Inf

  for (i in seq_along(files)) {
    sample_data <- read.delim(
      files[i],
      header = FALSE,
      sep = "\t",
      col.names = c("start", "end", "count")
    )

    total <- sum(sample_data$count)
    bin_width <- sample_data$end - sample_data$start
    density_y <- sample_data$count / (total * bin_width)

    sample_data$density <- density_y
    all_data[[i]] <- sample_data

    x_min <- min(x_min, min(sample_data$start))
    x_max <- max(x_max, max(sample_data$end))
    y_max <- max(y_max, max(density_y))
  }

  plot(
    NA, NA,
    xlim = c(x_min, x_max),
    ylim = c(0, y_max * 1.05),
    xlab = "Inner distance",
    ylab = "Density",
    main = "Inner distance distribution across samples"
  )

  for (i in seq_along(all_data)) {
    d <- all_data[[i]]

    rect(
      xleft = d$start,
      ybottom = 0,
      xright = d$end,
      ytop = d$density,
      col = adjustcolor(cols[i], alpha.f = 0.2),
      border = NA
    )

    lines(
      x = (d$start + d$end) / 2,
      y = d$density,
      col = cols[i],
      lwd = 1.5
    )
  }

  legend(
    "topright",
    legend = samples,
    fill = adjustcolor(cols, alpha.f = 0.2),
    border = cols,
    bty = "n",
    cex = 0.8
  )

  dev.off()
}


args <- commandArgs(trailingOnly = TRUE)

input_dir <- args[1]
prefix <- args[2]

files <- list.files(
  input_dir,
  pattern = "\\.inner_distance_freq\\.txt$",
  full.names = TRUE
)
samples <- sub("\\.inner_distance_freq.txt$", "", basename(files))
cols <- rainbow(length(files))

plot_read(files, samples, paste0(prefix, ".inner_distance_plot.pdf"), cols)