#' A clean ggplot2 theme for Hinton diagrams
#'
#' Removes grid lines, axis ticks, and panel background, all of which
#' visually interfere with the squares in a Hinton diagram.  The grey
#' background for signed diagrams is drawn by [geom_hinton()] itself and is
#' not affected by this theme.
#'
#' @param base_size Base font size, in pts.  Default `11`.
#' @param base_family Base font family.  Default `""` (the ggplot2 default).
#'
#' @return A ggplot2 theme object.
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
theme_hinton <- function(base_size = 11, base_family = "") {
  theme_minimal(base_size = base_size, base_family = base_family) +
    theme(
      panel.grid       = element_blank(),
      axis.ticks       = element_blank(),
      panel.background = element_blank(),
      plot.background  = element_blank()
    )
}
