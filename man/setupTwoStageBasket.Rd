% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/class.R
\name{setupTwoStageBasket}
\alias{setupTwoStageBasket}
\title{Setup TwoStageBasket}
\usage{
setupTwoStageBasket(k, shape1 = 1, shape2 = 1, p0)
}
\arguments{
\item{k}{The number of baskets.}

\item{shape1}{First common shape parameter of the beta prior.}

\item{shape2}{Second common shape parameter of the beta prior.}

\item{p0}{A common probability under the null hypothesis.}
}
\value{
An S4 object of class \code{\link{TwoStageBasket}}.
}
\description{
Creates an object of class \code{\link{TwoStageBasket}}.
}
\details{
A \code{\link{TwoStageBasket}} object contains the most important
design features of a basket trial. Currently only common prior distributions
and a common null hypothesis are supported.
}
\examples{
design <- setupTwoStageBasket(k = 3, p0 = 0.2)
}
