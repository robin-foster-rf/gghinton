#' @rdname geom_hinton
#' @format NULL
#' @usage NULL
#' @export
StatHinton <- ggproto("StatHinton", Stat,

  required_aes = c("x", "y", "weight"),

  # setup_params runs once on ALL data (all panels combined).
  # We use it to compute the global maximum when scale_by = "global".
  setup_params = function(self, data, params) {
    if (identical(params$scale_by, "global")) {
      params$global_max_abs <- max(abs(data$weight), na.rm = TRUE)
    } else {
      params$global_max_abs <- NULL
    }
    params
  },

  # compute_panel runs once per panel (already split by facet).
  # We use compute_panel rather than compute_group so that normalization
  # is consistent across all groups within a panel.
  compute_panel = function(self, data, scales,
                           scale_by       = "panel",
                           global_max_abs = NULL,
                           na.rm          = FALSE) {

    if (na.rm) {
      data <- data[!is.na(data$weight), , drop = FALSE]
    }

    # Determine the reference maximum for scaling
    if (!is.null(global_max_abs) && identical(scale_by, "global")) {
      max_abs <- global_max_abs
    } else {
      max_abs <- max(abs(data$weight), na.rm = TRUE)
    }

    # Edge case: all-zero (or all-NA) panel
    if (is.na(max_abs) || max_abs == 0) {
      data$xmin <- data$x
      data$xmax <- data$x
      data$ymin <- data$y
      data$ymax <- data$y
      data$fill         <- "unsigned"
      data$hinton_signed <- FALSE
      data$cell_w        <- 1
      data$cell_h        <- 1
      return(data)
    }

    # Compute square half-side: area proportional to |weight|
    # => side proportional to sqrt(|weight|)
    # The largest value gets half_side = 0.5 (fills a unit cell exactly)
    half_side <- sqrt(abs(data$weight) / max_abs) / 2

    data$xmin <- data$x - half_side
    data$xmax <- data$x + half_side
    data$ymin <- data$y - half_side
    data$ymax <- data$y + half_side

    # Determine sign encoding:
    # If ANY weight is strictly negative, use signed encoding.
    # Otherwise treat as unsigned (all magnitudes, no sign).
    is_signed <- any(data$weight < 0, na.rm = TRUE)
    if (is_signed) {
      data$fill <- ifelse(data$weight >= 0, "positive", "negative")
    } else {
      data$fill <- "unsigned"
    }

    # Store sign flag as a non-aesthetic column so GeomHinton can still
    # detect signed data after scale_fill_hinton() has replaced "negative"
    # with "black" (by which point checking data$fill == "negative" is too late).
    data$hinton_signed <- is_signed

    # Store cell spacing so GeomHinton can size the background rectangle
    data$cell_w <- infer_cell_size(data$x)
    data$cell_h <- infer_cell_size(data$y)

    data
  }
)


#' Hinton diagrams for ggplot2
#'
#' `geom_hinton()` draws a Hinton diagram: a grid of squares whose area is
#' proportional to the magnitude of each value.  For signed data, positive
#' values are shown as white squares and negative values as black squares on
#' a grey background.  For unsigned (non-negative) data the background is
#' omitted and squares are drawn in black.
#'
#' @section Aesthetics:
#' `geom_hinton()` understands the following aesthetics (required aesthetics
#' are in **bold**):
#'
#' - **`x`**: column position (numeric or factor)
#' - **`y`**: row position (numeric or factor)
#' - **`weight`**: the value to display; determines square size and colour
#' - `alpha`
#' - `colour` (border colour; `NA` by default, no border)
#' - `fill` (overrides the automatic sign-based colour)
#' - `linewidth`
#' - `linetype`
#'
#' @section Computed variables:
#' `stat_hinton()` adds the following columns to the data:
#'
#' \describe{
#'   \item{`xmin`, `xmax`, `ymin`, `ymax`}{Rectangle bounds for each square.}
#'   \item{`fill`}{`"positive"`, `"negative"`, or `"unsigned"`.}
#'   \item{`hinton_signed`}{Logical; `TRUE` when the panel contains any negative
#'     values.  Read by `GeomHinton` to decide whether to draw the grey
#'     background (after `scale_fill_hinton()` has already replaced the fill
#'     labels, making `fill == "negative"` checks unreliable).}
#'   \item{`cell_w`, `cell_h`}{Inferred cell spacing used to size the background.}
#' }
#'
#' @param mapping Set of aesthetic mappings created by [aes()].
#' @param data The data to be displayed in this layer.
#' @param stat The statistical transformation to use.  For `geom_hinton()` the
#'   default is `"hinton"`.
#' @param geom The geometric object to use when drawing.  For `stat_hinton()`
#'   the default is `"hinton"`.
#' @param position Position adjustment.
#' @param ... Other arguments passed on to [layer()].
#' @param scale_by `"panel"` (default) normalises each panel independently so
#'   the largest value in a panel fills its cell.  `"global"` uses the
#'   largest value across all panels, enabling cross-panel magnitude comparison.
#' @param background Logical.  Draw a grey background rectangle for signed
#'   data?  Default `TRUE`.  Set to `FALSE` to suppress the background.
#' @param na.rm If `TRUE`, rows where `weight` is `NA` are silently dropped
#'   before computing square sizes.  If `FALSE` (default), they are dropped
#'   without a warning (ggplot2 will not render rectangles whose required
#'   aesthetics are `NA`).
#' @param show.legend Logical.  Should this layer be included in the legend?
#' @param inherit.aes If `FALSE`, overrides the default aesthetics rather than
#'   combining with them.
#'
#' @return A ggplot2 layer that can be added to a [ggplot()] object.
#'
#' @section Aspect ratio:
#' For squares to appear as squares on screen, add `coord_fixed()` to your
#' plot.  Without it, the cells may appear rectangular if the plot's x and y
#' axes have different scales.
#'
#' @examples
#' library(ggplot2)
#' m <- matrix(c(0.8, -0.3, 0.5, -0.9, 0.1, 0.6, 0.4, -0.7, 0.2), 3, 3)
#' df <- matrix_to_hinton(m)
#'
#' ggplot(df, aes(x = col, y = row, weight = weight)) +
#'   geom_hinton() +
#'   scale_fill_hinton() +
#'   coord_fixed() +
#'   theme_hinton()
#'
#' @export
geom_hinton <- function(mapping     = NULL,
                        data        = NULL,
                        stat        = "hinton",
                        position    = "identity",
                        ...,
                        scale_by    = c("panel", "global"),
                        background  = TRUE,
                        na.rm       = FALSE,
                        show.legend = NA,
                        inherit.aes = TRUE) {
  scale_by <- match.arg(scale_by)
  layer(
    geom        = GeomHinton,
    stat        = StatHinton,
    data        = data,
    mapping     = mapping,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = rlang::list2(
      scale_by   = scale_by,
      background = background,
      na.rm      = na.rm,
      ...
    )
  )
}


#' @rdname geom_hinton
#' @export
stat_hinton <- function(mapping     = NULL,
                        data        = NULL,
                        geom        = "hinton",
                        position    = "identity",
                        ...,
                        scale_by    = c("panel", "global"),
                        na.rm       = FALSE,
                        show.legend = NA,
                        inherit.aes = TRUE) {
  scale_by <- match.arg(scale_by)
  layer(
    stat        = StatHinton,
    geom        = GeomHinton,
    data        = data,
    mapping     = mapping,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = rlang::list2(
      scale_by = scale_by,
      na.rm    = na.rm,
      ...
    )
  )
}
