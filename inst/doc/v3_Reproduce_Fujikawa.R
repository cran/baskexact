## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, eval=FALSE--------------------------------------------------------
#  library(baskexact)
#  design1 <- setupOneStageBasket(k = 3, shape1 = 1, shape2 = 1, p0 = 0.2)

## ----eval=FALSE---------------------------------------------------------------
#  basket_test(design1, n = 15, r = c(1, 5, 7), lambda = 0.99,
#    weight_fun = weights_fujikawa, weight_params = list(epsilon = 2, tau = 0.5,
#      logbase = exp(1)))
#  
#  # $weights
#  #          Basket 1  Basket 2  Basket 3
#  # Basket 1        1 0.0000000 0.0000000
#  # Basket 2        0 1.0000000 0.7832585
#  # Basket 3        0 0.7832585 1.0000000
#  #
#  # $post_dist_noborrow
#  #        Basket 1 Basket 2 Basket 3
#  # shape1        2        6        8
#  # shape2       15       11        9
#  #
#  # $post_dist_borrow
#  #        Basket 1 Basket 2 Basket 3
#  # shape1        2 12.26607 12.69955
#  # shape2       15 18.04933 17.61584
#  #
#  # $post_prob_noborrow
#  #  Basket 1  Basket 2  Basket 3
#  # 0.1407375 0.9183121 0.9929964
#  #
#  # $post_prob_borrow
#  #  Basket 1  Basket 2  Basket 3
#  # 0.1407375 0.9942795 0.9965258

## ----eval=FALSE---------------------------------------------------------------
#  ## p = (0.2, 0.2, 0.2)
#  # Proposed design (i)
#  toer(
#    design = design1, n = 24, lambda = 0.99,
#    weight_fun = weights_fujikawa, weight_params = list(epsilon = 2, tau = 0,
#    logbase = exp(1)), results = "group"
#  )
#  
#  # $rejection_probabilities
#  # [1] 0.02158174 0.02158174 0.02158174
#  #
#  # $fwer
#  # [1] 0.03600149
#  
#  # Proposed design (ii)
#  toer(
#    design = design1, n = 24, lambda = 0.99,
#    weight_fun = weights_fujikawa, weight_params = list(epsilon = 2, tau = 0.5,
#    logbase = exp(1)), results = "group"
#  )
#  
#  # $rejection_probabilities
#  # [1] 0.03239555 0.03239555 0.03239555
#  #
#  # $fwer
#  # [1] 0.06315308

## ----eval=FALSE---------------------------------------------------------------
#  design2 <- setupTwoStageBasket(k = 3, shape1 = 1, shape2 = 1, p0 = 0.2)

## ----eval = FALSE-------------------------------------------------------------
#  ## p = (0.2, 0.2, 0.2)
#  # Proposed design (i)
#  toer(
#    design = design2, n = 24, n1 = 15, lambda = 0.99,
#    interim_fun = interim_postpred, interim_params = list(prob_futstop = 0.1,
#      prob_effstop = 0.9), weight_fun = weights_fujikawa,
#    weight_params = list(logbase = exp(1), tau = 0, epsilon = 2),
#    results = "group"
#  )
#  
#  # $rejection_probabilities
#  # [1] 0.01703198 0.01703198 0.01703198
#  #
#  # $fwer
#  # [1] 0.03722851
#  
#  ess(
#    design = design2, n = 24, n1 = 15, lambda = 0.99,
#    interim_fun = interim_postpred, interim_params = list(prob_futstop = 0.1,
#      prob_effstop = 0.9), weight_fun = weights_fujikawa,
#    weight_params = list(logbase = exp(1), tau = 0, epsilon = 2)
#  )
#  
#  # [1] 16.06847 16.06847 16.06847
#  
#  # Proposed design (ii)
#  toer(
#    design = design2, n = 24, n1 = 15, lambda = 0.99,
#    interim_fun = interim_postpred, interim_params = list(prob_futstop = 0.1,
#      prob_effstop = 0.9), weight_fun = weights_fujikawa,
#    weight_params = list(logbase = exp(1), tau = 0.5, epsilon = 2),
#    results = "group"
#  )
#  
#  # $rejection_probabilities
#  # [1] 0.02175429 0.02175429 0.02175429
#  #
#  # $fwer
#  # [1] 0.04955128
#  
#  ess(
#    design = design2, n = 24, n1 = 15, lambda = 0.99,
#    interim_fun = interim_postpred, interim_params = list(prob_futstop = 0.1,
#      prob_effstop = 0.9), weight_fun = weights_fujikawa,
#    weight_params = list(logbase = exp(1), tau = 0.5, epsilon = 2)
#  )
#  
#  # [1] 16.22526 16.22526 16.22526

