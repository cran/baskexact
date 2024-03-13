## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----setup--------------------------------------------------------------------
#  library(baskexact)
#  design <- setupOneStageBasket(k = 3, shape1 = 1, shape2 = 1, p0 = 0.2)

## -----------------------------------------------------------------------------
#  toer(
#    design = design,
#    p1 = NULL,
#    n = 15,
#    lambda = 0.99,
#    weight_fun = weights_cpp,
#    weight_params = list(a = 2, b = 2),
#    results = "group"
#  )

## -----------------------------------------------------------------------------
#  adjust_lambda(
#    design = design,
#    alpha = 0.025,
#    p1 = NULL,
#    n = 15,
#    weight_fun = weights_cpp,
#    weight_params = list(a = 2, b = 2),
#    prec_digits = 4
#  )
#  
#  # $lambda
#  # [1] 0.991
#  #
#  # $toer
#  # [1] 0.0231528

