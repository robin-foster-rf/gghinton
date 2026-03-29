test_that("geom_hinton() returns a ggplot2 layer", {
  layer <- geom_hinton()
  expect_s3_class(layer, "LayerInstance")
})

test_that("geom_hinton() can be added to a ggplot without error", {
  df <- matrix_to_hinton(signed_mat)
  p <- ggplot2::ggplot(df, ggplot2::aes(x = col, y = row, weight = weight)) +
    geom_hinton()
  expect_s3_class(p, "gg")
})

test_that("minimal hinton plot builds without error", {
  p <- make_hinton_plot(signed_mat)
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("unsigned hinton plot builds without error", {
  p <- make_hinton_plot(unsigned_mat)
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("tiny 2x2 plot builds without error", {
  p <- make_hinton_plot(tiny_mat)
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("all-zero matrix plot builds without error", {
  m <- matrix(0, 3, 3)
  p <- make_hinton_plot(m)
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("stat_hinton() can be used as an alternative to geom_hinton()", {
  df <- matrix_to_hinton(signed_mat)
  p <- ggplot2::ggplot(df, ggplot2::aes(x = col, y = row, weight = weight)) +
    stat_hinton() +
    scale_fill_hinton()
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("grey background is drawn for signed data (regression: scale ate fill labels)", {
  # The bug: scale_fill_hinton() replaces "negative" -> "black" before
  # draw_panel runs, so checking data$fill == "negative" always returned FALSE.
  # Fix: StatHinton now stores hinton_signed as a non-aesthetic column.
  df <- matrix_to_hinton(signed_mat)
  p <- ggplot2::ggplot(df, ggplot2::aes(x = col, y = row, weight = weight)) +
    geom_hinton(background = TRUE) +
    scale_fill_hinton()
  built <- ggplot2::ggplot_build(p)
  # hinton_signed should be TRUE in the built layer data
  expect_true(isTRUE(built$data[[1]]$hinton_signed[1]))
})

test_that("background = FALSE suppresses the background grob for signed data", {
  df <- matrix_to_hinton(signed_mat)
  p_bg_true  <- ggplot2::ggplot(df, ggplot2::aes(x = col, y = row, weight = weight)) +
    geom_hinton(background = TRUE) + scale_fill_hinton()
  p_bg_false <- ggplot2::ggplot(df, ggplot2::aes(x = col, y = row, weight = weight)) +
    geom_hinton(background = FALSE) + scale_fill_hinton()

  # background = FALSE must be stored in geom_params (the mechanism that was broken)
  expect_false(p_bg_false$layers[[1]]$geom_params$background)
  expect_true(p_bg_true$layers[[1]]$geom_params$background)

  # Both should build without error
  expect_no_error(ggplot2::ggplot_build(p_bg_true))
  expect_no_error(ggplot2::ggplot_build(p_bg_false))
})

test_that("faceted plot with scale_by='global' builds without error", {
  df1 <- cbind(matrix_to_hinton(signed_mat), panel = "A")
  df2 <- cbind(matrix_to_hinton(signed_mat * 2), panel = "B")
  df  <- rbind(df1, df2)
  p <- ggplot2::ggplot(df, ggplot2::aes(x = col, y = row, weight = weight)) +
    geom_hinton(scale_by = "global") +
    scale_fill_hinton() +
    ggplot2::facet_wrap(~panel)
  expect_no_error(ggplot2::ggplot_build(p))
})
