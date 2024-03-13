test_that("ecd works with various weights", {
  skip_on_cran()

  design <- setupOneStageBasket(k = 3, p0 = 0.15)
  cppres1 <- ecd(design, n = 15, lambda = 0.98, weight_fun = weights_cpp,
    weight_params = list(a = 1, b = 1))
  cppres2 <- ecd_loop(design, p1 = rep(0.15, 3), n = 15, lambda = 0.98,
    weight_fun = weights_cpp, weight_params = list(a = 1, b = 1))

  expect_equal(cppres1, cppres2)

  mmlres1 <- ecd(design, n = 15, lambda = 0.98, weight_fun = weights_mml)
  mmlres2 <- ecd_loop(design, p1 = rep(0.15, 3), n = 15, lambda = 0.98,
    weight_fun = weights_mml)

  expect_equal(mmlres1, mmlres2)

  cppnexres1 <- ecd(design, n = 15, lambda = 0.95, weight_fun = weights_cpp,
    weight_params = list(a = 1, b = 1), globalweight_fun = globalweights_fix,
    globalweight_params = list(w = 0.3))
  cppnexres2 <- ecd_loop(design, p1 = rep(0.15, 3), n = 15, lambda = 0.95,
    weight_fun = weights_cpp, weight_params = list(a = 1, b = 1),
    globalweight_fun = globalweights_fix, globalweight_params = list(w = 0.3))

  expect_equal(cppnexres1, cppnexres2)
})

test_that("toer works with various weights", {
  skip_on_cran()

  design <- setupOneStageBasket(k = 3, p0 = 0.2)

  # CPP weights
  cppres1 <- toer(design = design, n = 17, lambda = 0.98,
    weight_fun = weights_cpp, weight_params = list(a = 0.5, b = 0.5))
  cppres2 <- reject_single_loop(design = design, p1 = rep(0.2, 3), n = 17,
    lambda = 0.98, weight_fun = weights_cpp,
    weight_params = list(a = 0.5, b = 0.5), prob = "toer")$fwer

  expect_equal(cppres1, cppres2)

  # CPP weights with a fixed global weight
  cppfixres1 <- toer(design = design, n = 17, lambda = 0.98,
    weight_fun = weights_cpp, weight_params = list(a = 0.5, b = 0.5),
    globalweight_fun = globalweights_fix, globalweight_params = list(w = 0.5))
  cppfixres2 <- reject_single_loop(design = design, p1 = rep(0.2, 3), n = 17,
    lambda = 0.98, weight_fun = weights_cpp,
    weight_params = list(a = 0.5, b = 0.5),
    globalweight_fun = globalweights_fix, globalweight_params = list(w = 0.5),
    prob = "toer")$fwer

  expect_equal(cppfixres1, cppfixres2)

  # CPP weights with pruning
  cpppruneres1 <- toer(design = design, n = 17, lambda = 0.98,
    weight_fun = weights_cpp,
    weight_params = list(a = 0.5, b = 0.5, prune = TRUE),
    globalweight_fun = globalweights_fix,
    globalweight_params = list(w = 0.5))
  cpppruneres2 <- reject_single_loop(design = design, p1 = rep(0.2, 3), n = 17,
    lambda = 0.98, weight_fun = weights_cpp,
    weight_params = list(a = 0.5, b = 0.5, prune = TRUE),
    globalweight_fun = globalweights_fix, globalweight_params = list(w = 0.5),
    prob = "toer")$fwer

  expect_equal(cpppruneres1, cpppruneres2)
  expect_true(cpppruneres1 != cppfixres1)

  # MML weights
  mmlres1 <- toer(design = design, n = 17, lambda = 0.98,
    weight_fun = weights_mml)
  mmlres2 <- reject_single_loop(design = design, p1 = rep(0.2, 3), n = 17,
    lambda = 0.98, weight_fun = weights_mml, weight_params = list(),
    prob = "toer")$fwer

  expect_equal(mmlres1, mmlres2)

  # MML weights with pruning
  mmlpruneres1 <- toer(design = design, n = 17, lambda = 0.98,
    weight_fun = weights_mml,
    weight_params = list(prune = TRUE)
  )
  mmlpruneres2 <- reject_single_loop(design = design, p1 = rep(0.2, 3), n = 17,
    lambda = 0.98, weight_fun = weights_mml,
    weight_params = list(prune = TRUE),
    prob = "toer")$fwer

  expect_equal(mmlpruneres1, mmlpruneres2)
  expect_true(mmlres1 != mmlpruneres1)
})

test_that("get_crit_pool works with various weights", {
  skip_on_cran()

  fun <- function(x) bskt_final(design = design, n = 20, lambda = 0.95, r = x,
    weight_mat = weight_mat)
  design <- setupOneStageBasket(k = 3, shape1 = 1, shape2 = 1, p0 = 0.2)

  # CPP Weights
  weight_mat <- weights_cpp(design = design, n = 20, a = 0.5, b = 0.5)
  crit_pool <- get_crit_pool(design = design, n = 20, lambda = 0.95,
    weight_mat = weight_mat)
  events <- arrangements::combinations(0:(crit_pool - 1),
    k = design@k, replace = TRUE)
  res_cpp <- t(apply(events, 1, fun))

  expect_equal(sum(res_cpp), 0)

  # CPP Weights with Fixed Global Weight
  fun2 <- function(x) bskt_final(design = design, n = 20, lambda = 0.95, r = x,
    weight_mat = weight_mat, globalweight_fun = globalweights_fix,
    globalweight_params = list(w = 0.3))

  crit_pool <- get_crit_pool(design = design, n = 20, lambda = 0.95,
    weight_mat = weight_mat, globalweight_fun = globalweights_fix,
    globalweight_params = list(w = 0.3))
  events <- arrangements::combinations(0:(crit_pool - 1),
    k = design@k, replace = TRUE)

  res_cpp_fix <- t(apply(events, 1, fun2))

  expect_equal(sum(res_cpp_fix), 0)

  # MML Weights
  weight_mat <- weights_mml(design = design, n = 20)

  crit_pool <- get_crit_pool(design = design, n = 20, lambda = 0.95,
    weight_mat = weight_mat)
  events <- arrangements::combinations(0:(crit_pool - 1),
    k = design@k, replace = TRUE)
  res_mml <- t(apply(events, 1, fun))

  expect_equal(sum(res_mml), 0)
})