library("mixexp")
library("Ternary")

# Create dataframe with experimental data
design <- SLD(3, 2)

y <- c(
  11.0,
  15.0,
  8.8,
  17.7,
  10.0,
  16.8,
  12.4,
  14.8,
  10.0,
  16.4,
  9.7,
  16.0,
  NaN,
  16.1,
  NaN,
  16.8,
  11.8,
  NaN
)
full_experiment <- rbind(design, design, design)
full_experiment$y <- y

rsm <- lm(
  y ~ -1 + x1 + x2 + x3 + x1:x2 + x1:x3 + x2:x3,
  data = full_experiment,
)

rsm_function <- function(a, b, c) {
  (rsm$coefficients[1] * a) +
    (rsm$coefficients[2] * b) +
    (rsm$coefficients[3] * c) +
    (rsm$coefficients[4] * a * b) +
    (rsm$coefficients[5] * a * c) +
    (rsm$coefficients[6] * b * c)
}

plot_rsm <- function(
  data = full_experiment,
  contour = FALSE,
  rsm = rsm_function,
  title
) {
  TernaryPlot(
    alab = "Polyethylene",
    blab = "Polystyrene",
    clab = "Polypropylene",
  )

  if (contour == TRUE) {
    TernaryContour(rsm, filled = TRUE, nlevels = 10)
  }

  title(main = title)

  TernaryPoints(
    data[1:6, c("x1", "x2", "x3")],
    cex = 1.5, # Point size
    col = "red", # Point colour
    pch = 1 # Plotting symbol (1 = empty circle)
  )

  TernaryPoints(
    data[1:6, c("x1", "x2", "x3")],
    cex = 1, # Point size
    col = "red", # Point colour
    pch = 16 # Plotting symbol (16 = filled circle)
  )
}

svg("design_points_base.svg")
plot_rsm(contour = FALSE, title = "{3,2} mixture design")
dev.off()

svg("rsm_base.svg")
plot_rsm(contour = TRUE, title = "Polymer mixture response surface")
dev.off()
