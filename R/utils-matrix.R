#' Convert a matrix to a tidy data frame for use with `geom_hinton()`
#'
#' Reshapes a numeric matrix into a long-form data frame with one row per
#' matrix entry.  Row 1 of the matrix is placed at the *top* of the resulting
#' plot (highest y value), matching the visual convention of matrix notation.
#'
#' @param x A numeric matrix.
#' @param rowname_col Name of the column that will hold the row index.
#'   Default `"row"`.
#' @param colname_col Name of the column that will hold the column index.
#'   Default `"col"`.
#' @param value_col Name of the column that will hold the matrix values.
#'   Default `"weight"`.
#'
#' @return A data frame with columns named by `rowname_col`, `colname_col`,
#'   and `value_col`.  If `x` has row or column names, additional columns
#'   `row_label` and `col_label` are included.
#'
#' @examples
#' m <- matrix(c(0.8, -0.3, 0.5, -0.9, 0.1, 0.6), nrow = 2)
#' matrix_to_hinton(m)
#'
#' # Named matrix
#' rownames(m) <- c("a", "b")
#' colnames(m) <- c("x", "y", "z")
#' matrix_to_hinton(m)
#'
#' @export
matrix_to_hinton <- function(x,
                              rowname_col = "row",
                              colname_col = "col",
                              value_col   = "weight") {
  if (!is.matrix(x)) {
    cli::cli_abort("{.arg x} must be a matrix, not {.cls {class(x)}}.")
  }
  if (!is.numeric(x)) {
    cli::cli_abort("{.arg x} must be a numeric matrix.")
  }

  nr <- nrow(x)
  nc <- ncol(x)

  row_idx <- rep(seq_len(nr), times = nc)
  col_idx <- rep(seq_len(nc), each  = nr)

  # Flip rows so that row 1 of the matrix appears at the top of the plot
  # (highest y value).  y = nr + 1 - row_index.
  y_vals <- nr + 1L - row_idx

  df <- data.frame(
    row    = y_vals,
    col    = col_idx,
    weight = as.vector(x),
    stringsAsFactors = FALSE
  )

  # Rename columns to user-specified names
  names(df) <- c(rowname_col, colname_col, value_col)

  # Attach row/column labels when available
  rn <- rownames(x)
  cn <- colnames(x)

  if (!is.null(rn)) {
    df$row_label <- rn[row_idx]
  }
  if (!is.null(cn)) {
    df$col_label <- cn[col_idx]
  }

  df
}

#' Convert an object to a tidy data frame for `geom_hinton()`
#'
#' Generic function that dispatches to a method appropriate for `x`.
#' Built-in methods exist for `matrix`, `data.frame`, and `table`.
#'
#' @param x An object to convert.
#' @param ... Additional arguments passed to the method.
#'
#' @return A data frame suitable for use with [geom_hinton()].
#'
#' @examples
#' m <- matrix(c(1, -2, 3, -4), 2, 2)
#' as_hinton_df(m)
#'
#' t <- table(c("a","b","a"), c("x","y","x"))
#' as_hinton_df(t)
#'
#' @export
as_hinton_df <- function(x, ...) {
  UseMethod("as_hinton_df")
}

#' @rdname as_hinton_df
#' @export
as_hinton_df.matrix <- function(x, ...) {
  matrix_to_hinton(x, ...)
}

#' @rdname as_hinton_df
#' @param rowname_col Name of the column that holds the row index. Default
#'   `"row"`.
#' @param colname_col Name of the column that holds the column index. Default
#'   `"col"`.
#' @param value_col Name of the column that holds the matrix values. Default
#'   `"weight"`.
#' @export
as_hinton_df.data.frame <- function(x,
                                    rowname_col = "row",
                                    colname_col = "col",
                                    value_col   = "weight",
                                    ...) {
  required <- c(rowname_col, colname_col, value_col)
  missing  <- setdiff(required, names(x))
  if (length(missing) > 0L) {
    cli::cli_abort(
      "The following required columns are absent from {.arg x}: {.field {missing}}."
    )
  }
  if (!is.numeric(x[[value_col]])) {
    cli::cli_abort(
      "Column {.field {value_col}} must be numeric, not {.cls {class(x[[value_col]])}}."
    )
  }
  x
}

#' @rdname as_hinton_df
#' @export
as_hinton_df.table <- function(x, ...) {
  if (length(dim(x)) != 2L) {
    cli::cli_abort(
      "{.fn as_hinton_df.table} requires a two-dimensional table."
    )
  }
  matrix_to_hinton(unclass(x), ...)
}

#' @rdname as_hinton_df
#' @export
as_hinton_df.default <- function(x, ...) {
  # Support sparse Matrix objects without requiring Matrix in Imports
  if (inherits(x, "Matrix")) {
    if (!requireNamespace("Matrix", quietly = TRUE)) {
      cli::cli_abort(
        "The {.pkg Matrix} package is required to convert sparse matrices. \\
         Install it with {.code install.packages('Matrix')}."
      )
    }
    return(matrix_to_hinton(as.matrix(x), ...))
  }
  cli::cli_abort(
    "No {.fn as_hinton_df} method for objects of class {.cls {class(x)}}."
  )
}
