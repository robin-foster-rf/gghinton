# Shared test fixtures

# A 3x3 signed matrix
signed_mat <- matrix(
  c(0.5, -0.3, 0.8,
   -0.1,  0.9, -0.7,
    0.2, -0.4,  0.6),
  nrow = 3, ncol = 3
)

# All-positive (unsigned) matrix
unsigned_mat <- abs(signed_mat)

# 2x2 identity-like matrix
tiny_mat <- matrix(c(1, 0, 0, 1), nrow = 2, ncol = 2)

# Named matrix
named_mat <- signed_mat
rownames(named_mat) <- c("r1", "r2", "r3")
colnames(named_mat) <- c("c1", "c2", "c3")

# Helper: build a ggplot and return it without printing
make_hinton_plot <- function(m = signed_mat) {
  df <- matrix_to_hinton(m)
  ggplot2::ggplot(df, ggplot2::aes(x = col, y = row, weight = weight)) +
    geom_hinton() +
    scale_fill_hinton() +
    theme_hinton()
}
