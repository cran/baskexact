# Calculates the experimentwise rejection probability
reject_prob_ew <- function(design, theta1, n, lambda, weight_mat,
                           prob = c("toer", "pwr")) {
  # Computational shortcuts don't work with unequal priors or n!
  targ <- get_targ(theta0 = design@theta0, theta1 = theta1, prob = prob)
  # Create matrix with all possible outcomes (without permutations)
  events <- arrangements::combinations(0:n, k = design@k, replace = TRUE)

  # Remove outcomes when no significant results are possible
  crit <- get_crit(design = design, n = n, lambda = lambda)
  crit_pool <- get_crit_pool(design = design, n = n, lambda = lambda)
  sel_nosig <- apply(events, 1, function(x) all(x < crit_pool))
  events <- events[!sel_nosig, ]

  # Remove outcomes where all results are significant and calculate the
  # probabilities later
  sel_sig <- apply(events, 1, function(x) all(x >= crit))
  events_sig <- events[sel_sig, ]
  events <- events[!sel_sig, ]

  # Conduct test for the remaining outcomes
  fun <- function(x) bskt_final(design = design, n = n, lambda = lambda, r = x,
    weight_mat = weight_mat)
  res <- t(apply(events, 1, fun))

  # Select outcomes with at least one rejected null hypothesis
  # and the corresponding results (including events_sig saved before)
  eff_vec <- apply(res, 1, function(x) any(x == 1))
  events_eff <- rbind(events[eff_vec, ], events_sig)
  res_eff <- rbind(
    res[eff_vec, ],
    matrix(1, nrow = nrow(events_sig), ncol = design@k)
  )

  # If all theta1 are equal each permutation has the same probability
  if ((sum(targ) == design@k) & (length(unique(theta1)) == 1)) {
    probs_eff <- apply(events_eff, 1,
      function(x) get_prob(n = n, r = x, theta = theta1))
    # Helper function that calculates the number of permutations
    perm_fun <- function(x) {
      tab <- tabulate(x + 1)
      tab <- tab[tab != 0]
      ifelse(length(unique(x)) == 1, 1,
        arrangements::npermutations(x = unique(x), freq = tab))
    }
    eff_perm <- apply(events_eff, 1, perm_fun)
    rej_prob <- sum(probs_eff * eff_perm)
  } else {
    # If not all theta1 are equal calculate probability for each permutation
    rej_prob <- numeric(nrow(res_eff))
    for (i in 1:nrow(res_eff)) {
      # If number of responses is equal in each basket, each permutation
      # has the same probability even when not all theta1 are equal
      if (length(unique(events_eff[i, ])) == 1) {
        rej_prob[i] <- get_prob(n = n, r = events_eff[i, ],
          theta = theta1)
      } else {
      events_loop <- arrangements::permutations(events_eff[i, ])
      res_loop <- arrangements::permutations(
        res_eff[i, ])[!duplicated(events_loop), ]
      events_loop <- events_loop[!duplicated(events_loop), ]
      eff_loop <- apply(res_loop, 1, function(x) any(x[targ] == 1))
      events_loop <- events_loop[eff_loop, , drop = FALSE]
      rej_prob[i] <- sum(apply(events_loop, 1, function(x) get_prob(n = n,
        r = x, theta = theta1)))
      }
    }
    rej_prob <- sum(rej_prob)
  }
  rej_prob
}

# Calculates the groupwise rejection probabilities
reject_prob_group <- function(design, theta1, n, lambda, weight_mat,
  prob = c("toer", "pwr")) {
  targ <- get_targ(theta0 = design@theta0, theta1 = theta1, prob = prob)
  # Create matrix with all possible outcomes
  events <- arrangements::permutations(0:n, k = design@k, replace = TRUE)

  # Conduct test for all possible outcomes
  fun <- function(x) bskt_final(design = design, n = n, lambda = lambda, r = x,
    weight_mat = weight_mat)
  res <- t(apply(events, 1, fun))

  eff_vec <- apply(res, 1, function(x) any(x == 1))
  eff_vec_targ <- apply(res[eff_vec, ], 1, function(x) any(x[targ] == 1))
  events_eff <- events[eff_vec, ]
  # Calculate probability of ouctomes where any null hypothesis was rejected
  probs_eff <- apply(events_eff, 1,
    function(x) get_prob(n = n, r = x, theta = theta1))
  res_eff <- res[eff_vec,]
  rej <- colSums(apply(res_eff == 1, 2, function(x) x * probs_eff))
  # Use only the probabilities of outcomes with a rejected null hypothesis
  # where a targeted basket was significant to calculate experimentwise
  # rejection probability
  rej_ew <- sum(probs_eff[eff_vec_targ])

  if (prob == "toer") {
    list(
      rejection_probabilities = rej,
      fwer = rej_ew
    )
  } else {
    list(
      rejection_probabilities = rej,
      ewp = rej_ew
    )
  }
}
