# Helper: rename matrix_to_hinton output so it looks like what ggplot2 passes
# to the stat (after resolving aes(x=col, y=row, weight=weight) mappings).
hinton_aes_data <- function(m) {
  df <- matrix_to_hinton(m)
  names(df)[names(df) == "row"] <- "y"
  names(df)[names(df) == "col"] <- "x"
  df
}

test_that("StatHinton$compute_panel produces required columns", {
  df <- hinton_aes_data(signed_mat)
  result <- StatHinton$compute_panel(df, scales = list())
  expect_true(all(c("xmin", "xmax", "ymin", "ymax", "fill") %in% names(result)))
})

test_that("largest absolute value produces half_side = 0.5", {
  df <- hinton_aes_data(signed_mat)
  result <- StatHinton$compute_panel(df, scales = list())
  max_half <- max((result$xmax - result$xmin) / 2)
  expect_equal(max_half, 0.5, tolerance = 1e-10)
})

test_that("zero weight produces zero-size rect", {
  m <- matrix(c(1, 0), 1, 2)
  df <- hinton_aes_data(m)
  result <- StatHinton$compute_panel(df, scales = list())
  zero_row <- result[result$weight == 0, ]
  expect_equal(zero_row$xmin, zero_row$xmax)
  expect_equal(zero_row$ymin, zero_row$ymax)
})

test_that("all-positive data produces 'unsigned' fill", {
  df <- hinton_aes_data(unsigned_mat)
  result <- StatHinton$compute_panel(df, scales = list())
  expect_true(all(result$fill == "unsigned"))
})

test_that("signed data produces 'positive' and 'negative' fill", {
  df <- hinton_aes_data(signed_mat)
  result <- StatHinton$compute_panel(df, scales = list())
  expect_true("positive" %in% result$fill)
  expect_true("negative" %in% result$fill)
  expect_false("unsigned" %in% result$fill)
})

test_that("positive weights get fill='positive'", {
  df <- hinton_aes_data(signed_mat)
  result <- StatHinton$compute_panel(df, scales = list())
  pos <- result[result$weight > 0, ]
  expect_true(all(pos$fill == "positive"))
})

test_that("negative weights get fill='negative'", {
  df <- hinton_aes_data(signed_mat)
  result <- StatHinton$compute_panel(df, scales = list())
  neg <- result[result$weight < 0, ]
  expect_true(all(neg$fill == "negative"))
})

test_that("all-zero matrix returns zero-size rects without error", {
  m <- matrix(0, 2, 2)
  df <- hinton_aes_data(m)
  result <- StatHinton$compute_panel(df, scales = list())
  expect_equal(result$xmin, result$xmax)
  expect_equal(result$ymin, result$ymax)
})

test_that("na.rm = TRUE removes NA weights silently", {
  m <- signed_mat
  m[1, 1] <- NA
  df <- hinton_aes_data(m)
  expect_no_warning(
    result <- StatHinton$compute_panel(df, scales = list(), na.rm = TRUE)
  )
  expect_equal(nrow(result), nrow(df) - 1L)
})

test_that("na.rm = FALSE preserves NA rows", {
  m <- signed_mat
  m[1, 1] <- NA
  df <- hinton_aes_data(m)
  result <- StatHinton$compute_panel(df, scales = list(), na.rm = FALSE)
  expect_equal(nrow(result), nrow(df))
})

test_that("scale_by = 'global' uses global_max_abs", {
  # Two panels with very different ranges
  df1 <- hinton_aes_data(matrix(c(1, 0.1), 1, 2))
  df2 <- hinton_aes_data(matrix(c(10, 1), 1, 2))
  all_data <- rbind(df1, df2)
  global_max <- max(abs(all_data$weight))  # 10

  r1 <- StatHinton$compute_panel(df1, scales = list(),
                                   scale_by       = "global",
                                   global_max_abs = global_max)
  r2 <- StatHinton$compute_panel(df2, scales = list(),
                                   scale_by       = "global",
                                   global_max_abs = global_max)

  # In panel 1, the max value is 1; with global_max=10, half_side = sqrt(1/10)/2
  expected_half_1 <- sqrt(1 / 10) / 2
  actual_half_1   <- max((r1$xmax - r1$xmin) / 2)
  expect_equal(actual_half_1, expected_half_1, tolerance = 1e-10)

  # In panel 2, the max value is 10; half_side = sqrt(10/10)/2 = 0.5
  actual_half_2 <- max((r2$xmax - r2$xmin) / 2)
  expect_equal(actual_half_2, 0.5, tolerance = 1e-10)
})

test_that("squares are symmetric (xmin/xmax centred on x, ymin/ymax on y)", {
  df <- hinton_aes_data(signed_mat)
  result <- StatHinton$compute_panel(df, scales = list())
  x_centre <- (result$xmin + result$xmax) / 2
  y_centre <- (result$ymin + result$ymax) / 2
  expect_equal(x_centre, result$x, tolerance = 1e-10)
  expect_equal(y_centre, result$y, tolerance = 1e-10)
})

test_that("squares are always square (equal width and height)", {
  df <- hinton_aes_data(signed_mat)
  result <- StatHinton$compute_panel(df, scales = list())
  widths  <- result$xmax - result$xmin
  heights <- result$ymax - result$ymin
  expect_equal(widths, heights, tolerance = 1e-10)
})
