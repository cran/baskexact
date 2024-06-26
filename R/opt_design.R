#' @include class.R
NULL

#' Optimize a Basket Design
#'
#' Finds the optimal tuning parameters using grid search.
#'
#' @template design
#' @template dotdotdot
#'
#' @details \code{opt_design} finds the optimal combination of tuning parameter
#' values from a the set of tuning paramters that is passed to the function.
#' The objective function for the optimization is the mean of the expected
#' number of correct decisions (ECD) under the passed scenarios, with the
#' constraint that the type 1 error under the global null hypothesis must be
#' below \code{alpha}.
#'
#' @return A matrix with the ECDs under all scenarios and the mean ECD for
#' all combinations of tuning parameter values. The matrix is sorted
#' decreasingly by the mean ECD.
#' @export
#'
#' @examples
#' \donttest{
#' design <- setupOneStageBasket(k = 3, p0 = 0.2)
#' opt_design(design = design, n = 10, alpha = 0.05,
#'   weight_fun = weights_fujikawa, weight_params = list(epsilon = c(1, 2),
#'   tau = c(0, 0.5)), scenarios = get_scenarios(design, 0.5), prec_digits = 3)
#' }
setGeneric("opt_design",
  function(design, ...) standardGeneric("opt_design")
)

#' @describeIn opt_design Optimize a single-stage basket design.
#'
#' @template design
#' @template n
#' @template alpha
#' @template weights
#' @template globalweights
#' @template scenarios
#' @template prec_digits
#' @template dotdotdot
setMethod("opt_design", "OneStageBasket",
  function(design, n, alpha, weight_fun, weight_params = list(),
           globalweight_fun = NULL, globalweight_params = list(),
           scenarios, prec_digits, ...) {
    all_params <- c(weight_params, globalweight_params)
    grid <- expand.grid(all_params)
    if (length(all_params) == 0) {
      lgrid <- 1
    } else {
      lgrid <- nrow(grid)
    }

    l1 <- length(weight_params)
    l2 <- length(globalweight_params)
    lambdas <- numeric(lgrid)
    p <- progressr::progressor(steps = lgrid)

    ecd_res <- foreach(i = 1:lgrid, .combine = 'rbind',
                       .options.future = list(seed = TRUE)) %dofuture% {
      res_loop <- numeric(ncol(scenarios) + 1)
      if (l1 >= 1) {
        ploop1 <- as.list(grid[i, 1:l1, drop = FALSE])
      } else {
        ploop1 <- list()
      }
      if (l2 >= 1) {
        ploop2 <- as.list(grid[i, (l1 + 1):(l1 + l2), drop = FALSE])
      } else {
        ploop2 <- list()
      }

      l <- do.call(adjust_lambda, args = c(design = list(design), n = n,
        p1 = NULL, alpha = alpha, weight_fun = weight_fun,
        weight_params = list(ploop1), globalweight_fun = globalweight_fun,
        globalweight_params = list(ploop2), prec_digits = prec_digits, ...))
      res_loop[1] <- l$lambda

      for (j in 1:ncol(scenarios)) {
        res_loop[j + 1] <- do.call(ecd, args = c(design = list(design),
          p1 = list(scenarios[, j]), n = n, lambda = l$lambda,
          weight_fun = weight_fun, weight_params = list(ploop1),
          globalweight_fun = globalweight_fun,
          globalweight_params = list(ploop2), ...))
      }
      p()
      res_loop
    }
    if (lgrid == 1) {
      names(ecd_res) <- c("Lambda", colnames(scenarios))
      ecd_res <- c(ecd_res, "Mean_ECD" = mean(ecd_res[-1]))
      as.data.frame(t(ecd_res))
    } else {
      colnames(ecd_res) <- c("Lambda", colnames(scenarios))
      ecd_res <- cbind(grid, ecd_res, "Mean_ECD" = rowMeans(ecd_res[, -1]))
      ecd_res <- ecd_res[order(ecd_res[, ncol(ecd_res)], decreasing = TRUE), ]
      rownames(ecd_res) <- NULL
      ecd_res
    }
  })

#' @describeIn opt_design Optimize a two-stage basket design.
#'
#' @template design
#' @template n
#' @template n1
#' @template alpha
#' @template interim
#' @template weights
#' @template globalweights
#' @template scenarios
#' @template prec_digits
#' @template dotdotdot
setMethod("opt_design", "TwoStageBasket",
  function(design, n, n1, alpha, interim_fun, interim_params = list(),
           weight_fun, weight_params = list(), globalweight_fun = NULL,
           globalweight_params = list(), scenarios, prec_digits, ...) {
    all_params <- c(weight_params, globalweight_params, interim_params)
    grid <- expand.grid(all_params)
    if (length(all_params) == 0) {
      lgrid <- 1
    } else {
      lgrid <- nrow(grid)
    }

    l1 <- length(weight_params)
    l2 <- length(globalweight_params)
    l3 <- length(interim_params)
    lambdas <- numeric(lgrid)
    p <- progressr::progressor(steps = lgrid)

    ecd_res <- foreach(i = 1:lgrid, .combine = 'rbind',
      .options.future = list(seed = TRUE)) %dofuture% {
        res_loop <- numeric(ncol(scenarios) + 1)
        if (l1 >= 1) {
          ploop1 <- as.list(grid[i, 1:l1, drop = FALSE])
        } else {
          ploop1 <- list()
        }
        if (l2 >= 1) {
          ploop2 <- as.list(grid[i, (l1 + 1):(l1 + l2), drop = FALSE])
        } else {
          ploop2 <- list()
        }
        if (l3 >= 1) {
          ploop3 <- as.list(grid[i, (l1 + l2 + 1):(l1 + l2 + l3), drop = FALSE])
        } else {
          ploop3 <- list()
        }

        l <- do.call(adjust_lambda, args = c(design = list(design), n = n,
          n1 = n1, p1 = NULL, alpha = alpha, interim_fun = interim_fun,
          interim_params = list(ploop3), weight_fun = weight_fun,
          weight_params = list(ploop1), globalweight_fun = globalweight_fun,
          globalweight_params = list(ploop2), prec_digits = prec_digits, ...))
        res_loop[1] <- l$lambda

        for (j in 1:ncol(scenarios)) {
          res_loop[j + 1] <- do.call(ecd, args = c(design = list(design),
            p1 = list(scenarios[, j]), n = n, n1 = n1, lambda = l$lambda,
            interim_fun = interim_fun, interim_params = list(ploop3),
            weight_fun = weight_fun, weight_params = list(ploop1),
            globalweight_fun = globalweight_fun,
            globalweight_params = list(ploop2), ...))
        }
        p()
        res_loop
      }
    if (lgrid == 1) {
      names(ecd_res) <- c("Lambda", colnames(scenarios))
      ecd_res <- c(ecd_res, "Mean_ECD" = mean(ecd_res[-1]))
      as.data.frame(t(ecd_res))
    } else {
      colnames(ecd_res) <- c("Lambda", colnames(scenarios))
      ecd_res <- cbind(grid, ecd_res, "Mean_ECD" = rowMeans(ecd_res[, -1]))
      ecd_res <- ecd_res[order(ecd_res[, ncol(ecd_res)], decreasing = TRUE), ]
      rownames(ecd_res) <- NULL
      ecd_res
    }
  })

#' Create a Scenario Matrix
#'
#' Creates a default scenario matrix.
#'
#' @template design
#' @param p1 Probabilitiy under the alternative hypothesis.
#'
#' @details \code{get_scenarios} creates a default scenario matrix
#' that can be used for \code{\link{opt_design}}. The function creates
#' \code{k + 1} scenarios, from a global null to a global alternative scenario.
#'
#' @return A matrix with \code{k} rows and \code{k + 1} columns.
#' @export
#'
#' @examples
#' design <- setupOneStageBasket(k = 3, p0 = 0.2)
#' get_scenarios(design = design, p1 = 0.5)
get_scenarios <- function(design, p1) {
  scen_mat <- matrix(nrow = design@k, ncol = design@k + 1)
  for (i in 0:design@k) {
    scen_mat[, (i + 1)] <- c(rep(design@p0, design@k - i),
      rep(p1, i))
  }
  colnames(scen_mat) <- paste(0:design@k, "Active")
  scen_mat
}
