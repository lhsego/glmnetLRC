% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/glmnetLRC-package.R
\docType{package}
\name{glmnetLRC-package}
\alias{glmnetLRC-package}
\title{Lasso and elastic-net logistic regression classification with an arbitrary loss function}
\description{
Lasso and elastic-net logistic regression classification (LRC) with an arbitrary, discrete loss function
for the classification error
}
\details{
\pkg{glmnetLRC} extends the \pkg{glmnet} package for training elastic-net LRCs with a user-specified
discrete loss function used to measure the classification error.  Tuning parameters are selected to
minimize the expected loss calculated by cross validation.  There are a handful of functions
you'll need (along with their associated methods): \code{\link{lossMatrix}}, \code{\link{glmnetLRC}}, 
and \code{\link{predict.glmnetLRC}}

\tabular{ll}{
Package: \tab glmnetLRC\cr
Type: \tab Package\cr
Version: \tab 0.1.9\cr
Date: \tab 2017-06-07\cr
License: \tab file LICENSE\cr }
}
\author{
Landon Sego, Alex Venzin, John Ramey
}
