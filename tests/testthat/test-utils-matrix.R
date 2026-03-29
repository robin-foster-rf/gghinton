test_that("matrix_to_hinton returns a data frame with correct columns", {
  df <- matrix_to_hinton(signed_mat)
  expect_s3_class(df, "data.frame")
  expect_named(df, c("row", "col", "weight"), ignore.order = FALSE)
})

test_that("matrix_to_hinton has nrow * ncol rows", {
  df <- matrix_to_hinton(signed_mat)
  expect_equal(nrow(df), nrow(signed_mat) * ncol(signed_mat))
})

test_that("column name arguments are respected", {
  df <- matrix_to_hinton(signed_mat, rowname_col = "r", colname_col = "c",
                          value_col = "v")
  expect_named(df, c("r", "c", "v"), ignore.order = FALSE)
})

test_that("row 1 of matrix maps to highest y value", {
  df <- matrix_to_hinton(signed_mat)
  # Row 1 of the matrix should appear at y = nrow(mat)
  row1_y <- df$row[df$col == 1][1]  # first entry is row 1, col 1
  # Actually, entries are in column-major order.  Check all row-1 entries.
  # matrix_to_hinton stores row index as (nr + 1 - original_row)
  nr <- nrow(signed_mat)
  # Original row 1 --> y = nr + 1 - 1 = nr
  row1_entries <- df[df$row == nr, ]
  expect_true(nrow(row1_entries) > 0)
  # The values should match row 1 of the matrix
  expect_equal(sort(row1_entries$weight), sort(signed_mat[1, ]))
})

test_that("NA values are preserved", {
  m <- signed_mat
  m[2, 2] <- NA
  df <- matrix_to_hinton(m)
  expect_equal(sum(is.na(df$weight)), 1L)
})

test_that("1x1 matrix works", {
  m <- matrix(0.5, nrow = 1, ncol = 1)
  df <- matrix_to_hinton(m)
  expect_equal(nrow(df), 1L)
  expect_equal(df$weight, 0.5)
})

test_that("1-row matrix works", {
  m <- matrix(1:3, nrow = 1)
  df <- matrix_to_hinton(m)
  expect_equal(nrow(df), 3L)
})

test_that("1-column matrix works", {
  m <- matrix(1:3, ncol = 1)
  df <- matrix_to_hinton(m)
  expect_equal(nrow(df), 3L)
})

test_that("named matrix adds label columns", {
  df <- matrix_to_hinton(named_mat)
  expect_true("row_label" %in% names(df))
  expect_true("col_label" %in% names(df))
  expect_equal(sort(unique(df$row_label)), sort(rownames(named_mat)))
  expect_equal(sort(unique(df$col_label)), sort(colnames(named_mat)))
})

test_that("unnamed matrix has no label columns", {
  df <- matrix_to_hinton(signed_mat)
  expect_false("row_label" %in% names(df))
  expect_false("col_label" %in% names(df))
})

test_that("non-matrix input raises an error", {
  expect_error(matrix_to_hinton(list(1, 2, 3)), class = "rlang_error")
  expect_error(matrix_to_hinton(data.frame(x = 1)), class = "rlang_error")
})

# as_hinton_df -----------------------------------------------------------

test_that("as_hinton_df dispatches to matrix method", {
  df1 <- matrix_to_hinton(signed_mat)
  df2 <- as_hinton_df(signed_mat)
  expect_equal(df1, df2)
})

test_that("as_hinton_df.data.frame returns the input unchanged when columns match", {
  df <- matrix_to_hinton(signed_mat)
  expect_equal(as_hinton_df(df), df)
})

test_that("as_hinton_df.data.frame errors on missing column", {
  df <- matrix_to_hinton(signed_mat)
  df$weight <- NULL
  expect_error(as_hinton_df(df), class = "rlang_error")
})

test_that("as_hinton_df.table works on a 2-way table", {
  tbl <- table(
    x = c("a", "b", "a", "b"),
    y = c("p", "p", "q", "q")
  )
  df <- as_hinton_df(tbl)
  expect_s3_class(df, "data.frame")
  expect_equal(nrow(df), 4L)
  expect_true("weight" %in% names(df))
})

test_that("as_hinton_df.default errors on unsupported type", {
  expect_error(as_hinton_df(42L), class = "rlang_error")
})
