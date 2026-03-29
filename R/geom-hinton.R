#' @rdname geom_hinton
#' @format NULL
#' @usage NULL
#' @export
GeomHinton <- ggproto("GeomHinton", GeomRect,

  required_aes = c("xmin", "xmax", "ymin", "ymax"),

  # background is a geom-level param (not an aesthetic), so it must be listed
  # in extra_params so ggplot2::layer() doesn't warn about an unknown parameter.
  extra_params = c("na.rm", "background"),

  default_aes = aes(
    colour    = NA,
    fill      = "black",
    linewidth = 0,
    linetype  = 1,
    alpha     = NA
  ),

  draw_key = draw_key_rect,

  # draw_panel handles the background grey rectangle (for signed data) and
  # the squares.  We delegate square drawing to the parent GeomRect so we
  # benefit from its coord transformation and gpar handling without
  # reimplementing or calling any ggplot2::: internals.
  draw_panel = function(self, data, panel_params, coord,
                        background = TRUE) {

    # Determine whether this is signed data.
    # We use the hinton_signed column set by StatHinton rather than inspecting
    # data$fill, because scale_fill_hinton() has already replaced "negative"
    # with "black" by the time draw_panel is called.
    is_signed <- background &&
      isTRUE(data$hinton_signed[1L])

    bg_grob <- if (is_signed) {
      # Use stored cell spacing to compute the background extent.
      # cell_w / cell_h are set by StatHinton; fall back to 1 if absent.
      cell_w <- if ("cell_w" %in% names(data)) data$cell_w[[1L]] else 1
      cell_h <- if ("cell_h" %in% names(data)) data$cell_h[[1L]] else 1

      # Recover original cell-centre coords from the rect bounds
      x_centres <- (data$xmin + data$xmax) / 2
      y_centres <- (data$ymin + data$ymax) / 2

      bg_df <- hinton_bg_extent(x_centres, y_centres, cell_w, cell_h)
      bg_df$colour    <- NA_character_
      bg_df$fill      <- "#AAAAAA"
      bg_df$linewidth <- 0
      bg_df$linetype  <- 1L
      bg_df$alpha     <- NA_real_

      ggproto_parent(GeomRect, self)$draw_panel(bg_df, panel_params, coord)
    } else {
      grid::nullGrob()
    }

    # Draw the squares: remove stat-computed helper columns that GeomRect
    # doesn't understand (cell_w, cell_h, hinton_signed) to avoid gpar warnings.
    sq_data <- data
    sq_data$cell_w        <- NULL
    sq_data$cell_h        <- NULL
    sq_data$hinton_signed <- NULL

    squares_grob <- ggproto_parent(GeomRect, self)$draw_panel(
      sq_data, panel_params, coord
    )

    grid::grobTree(bg_grob, squares_grob)
  }
)
