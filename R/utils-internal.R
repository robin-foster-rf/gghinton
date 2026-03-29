# Internal helpers (not exported)

# Compute the background rectangle extent for a Hinton panel.
# x, y: the cell-centre coordinates (original, before stat transformation)
# cell_w, cell_h: cell spacing in x and y directions
# Returns a one-row data frame with xmin, xmax, ymin, ymax.
hinton_bg_extent <- function(x, y, cell_w = 1, cell_h = 1) {
  data.frame(
    xmin = min(x) - cell_w / 2,
    xmax = max(x) + cell_w / 2,
    ymin = min(y) - cell_h / 2,
    ymax = max(y) + cell_h / 2
  )
}

# Infer cell spacing from a vector of (possibly non-consecutive) coordinate values.
# Returns the minimum gap between adjacent unique values, or 1.0 if there is
# only one unique value.
infer_cell_size <- function(coords) {
  u <- sort(unique(coords))
  if (length(u) <= 1L) return(1.0)
  min(diff(u))
}
