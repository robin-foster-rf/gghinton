test_that("scale_fill_hinton() returns a Scale object", {
  s <- scale_fill_hinton()
  expect_s3_class(s, "Scale")
})

test_that("scale_fill_hinton() correctly maps positive/negative/unsigned", {
  # Build a minimal plot with known fill values and check the built layer data
  df <- data.frame(
    x = c(1, 2, 3), y = c(1, 1, 1),
    xmin = c(0.75, 1.75, 2.75), xmax = c(1.25, 2.25, 3.25),
    ymin = c(0.75, 0.75, 0.75), ymax = c(1.25, 1.25, 1.25),
    fill = c("positive", "negative", "unsigned")
  )
  p <- ggplot2::ggplot(df) +
    ggplot2::geom_rect(
      ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
                   fill = fill)
    ) +
    scale_fill_hinton()
  built <- ggplot2::ggplot_build(p)
  fill_vals <- built$data[[1]]$fill
  expect_true("white" %in% fill_vals)
  expect_true("black" %in% fill_vals)
})

test_that("scale_fill_hinton() works in a complete hinton plot pipeline", {
  p <- make_hinton_plot(signed_mat)
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("scale_fill_hinton() guide is none by default", {
  s <- scale_fill_hinton()
  expect_equal(s$guide, "none")
})

test_that("scale_fill_hinton() passes ... to scale_fill_manual", {
  # Providing a name argument should work without error
  expect_no_error(scale_fill_hinton(name = "sign"))
})

test_that("scale_fill_hinton() values argument merges with defaults", {
  df <- data.frame(
    x = c(1, 2, 3), y = c(1, 1, 1),
    xmin = c(0.75, 1.75, 2.75), xmax = c(1.25, 2.25, 3.25),
    ymin = c(0.75, 0.75, 0.75), ymax = c(1.25, 1.25, 1.25),
    fill = c("positive", "negative", "unsigned")
  )
  p <- ggplot2::ggplot(df) +
    ggplot2::geom_rect(
      ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
                   fill = fill)
    ) +
    scale_fill_hinton(values = c(negative = "grey50"))
  built <- ggplot2::ggplot_build(p)
  fills <- built$data[[1]]$fill
  # negative overridden; positive and unsigned keep their defaults
  expect_true("grey50" %in% fills)
  expect_true("white"  %in% fills)
  expect_true("black"  %in% fills)
})

test_that("scale_fill_hinton() guide can be overridden", {
  s <- scale_fill_hinton(guide = "legend")
  expect_equal(s$guide, "legend")
})
