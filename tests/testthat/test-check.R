test_that("check_tuning works", {
  expect_error(check_tuning(epsilon = -1, tau = 0, logbase = 2))
  expect_error(check_tuning(epsilon = 1, tau = 1, logbase = 2))
  expect_error(check_tuning(epsilon = 1, tau = -1, logbase = 2))
  expect_error(check_tuning(epsilon = 1, tau = 0, logbase = 0))
})

test_that("check_p1 works", {
  design <- setupOneStageBasket(k = 3, shape1 = 1, shape2 = 1, p0 = 0.2)
  p1a <- check_p1(design = design, p1 = NULL, type = "toer")
  p1b <- check_p1(design = design, p1 = 0.5, type = "pwr")

  expect_equal(p1a, c(0.2, 0.2, 0.2))
  expect_equal(p1b, c(0.5, 0.5, 0.5))

  expect_error(check_p1(design = design, p1 = c(0.2, 0.5),
    type = "pwr"))
  expect_error(check_p1(design = design, p1 = c(0.1, 0.2, 0.5),
    type = "toer"))
  expect_error(check_p1(design = design, p1 = NULL, type = "pwr"))
  expect_error(check_p1(design = design, p1 = 0.5, type = "toer"))
})

test_that("check_params works", {
  expect_error(check_params(n = c(10, 20), lambda = 0.99))
  expect_error(check_params(n = 10, lambda = 0))
  expect_error(check_params(n = 10, lambda = 1))
})
