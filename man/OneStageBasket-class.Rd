% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/class.R
\docType{class}
\name{OneStageBasket-class}
\alias{OneStageBasket-class}
\alias{OneStageBasket}
\title{Class OneStageBasket}
\description{
OneStageBasket is an S4 class. An object of this class contains the most
important design features of a single-stage basket trial.
}
\details{
This class implements a single-stage basket trial based on the design
proposed by Fujikawa et al. In this design, at first separate posterior
distributions are calculated for each basket based on a beta-binomial model.
Information is then borrowed between baskets by calculating weights that
reflect the similarity between the basket and computing posterior
distributions for each basket where the parameters of the beta posterior are
calculated as a weighted sum of the individual posterior distributions.
The weight between two baskets i and j is found as (1 - JSD(i, j))^epsilon
where JSD(i, j) is the Jensen-Shannon divergence between basket i and j.
A small value of epsilon results in stronger borrowing also across baskets
with heterogenous results. If epsilon is large then information is only
borrowed between baskets with similar results. If a weight is smaller than
tau it is set to 0, which results in no borrowing. If for a basket
the posterior probability that \eqn{\theta} > theta0 is greater than
lambda, then the null hypothesis is rejected.

Currently only common prior distributions and a common null
hypothesis are supported.
}
\section{Slots}{

\describe{
\item{\code{k}}{The number of baskets.}

\item{\code{shape1}}{First common shape parameter of the beta prior.}

\item{\code{shape2}}{Second common shape parameter of the beta prior.}

\item{\code{theta0}}{A common probability under the null hypothesis.}
}}

\references{
Fujikawa, K., Teramukai, S., Yokota, I., & Daimon, T. (2020).
A Bayesian basket trial design that borrows information across strata based
on the similarity between the posterior distributions of the response
probability. Biometrical Journal, 62(2), 330-338.
}
