#' Colour scale for Hinton diagrams
#'
#' Maps the sign-encoding produced by [stat_hinton()] to the conventional
#' Hinton colour scheme: white for positive values, black for negative values.
#' For unsigned data (all non-negative), all squares are drawn in black.
#'
#' This scale is a thin wrapper around [scale_fill_manual()] with the default
#' legend suppressed.  Pass `guide = "legend"` to restore the legend, or
#' override the `values` argument to use custom colours.
#'
#' @param values Named character vector of colours for `"positive"`,
#'   `"negative"`, and `"unsigned"` fill values.  Override individual colours
#'   by passing a partial named vector, e.g.
#'   `values = c(negative = "grey50")` merges with the defaults.
#' @param guide Legend guide.  Defaults to `"none"` (no legend).
#' @param ... Additional arguments passed on to [scale_fill_manual()].
#'
#' @return A ggplot2 scale object.
#'
#' @examples
#' library(ggplot2)
#' m <- matrix(c(0.8, -0.3, 0.5, -0.9, 0.1, 0.6), 2, 3)
#' df <- matrix_to_hinton(m)
#'
#' ggplot(df, aes(x = col, y = row, weight = weight)) +
#'   geom_hinton() +
#'   scale_fill_hinton() +
#'   theme_hinton()
#'
#' @export
scale_fill_hinton <- function(...,
                              values = NULL,
                              guide  = "none") {
  defaults <- c(positive = "white", negative = "black", unsigned = "black")
  resolved <- if (is.null(values)) defaults else {
    defaults[names(values)] <- values
    defaults
  }
  scale_fill_manual(values = resolved, guide = guide, ...)
}
