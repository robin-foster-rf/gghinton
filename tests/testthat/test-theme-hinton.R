test_that("theme_hinton() returns a ggplot2 theme", {
  t <- theme_hinton()
  expect_s3_class(t, "theme")
})

test_that("theme_hinton() sets panel.grid to element_blank", {
  t <- theme_hinton()
  expect_s3_class(t$panel.grid, "element_blank")
})

test_that("theme_hinton() can be added to a ggplot without error", {
  p <- make_hinton_plot(signed_mat)
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("base_size argument is accepted", {
  expect_no_error(theme_hinton(base_size = 14))
})
