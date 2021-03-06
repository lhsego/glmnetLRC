% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot.LRCpred.R
\name{plot.LRCpred}
\alias{plot.LRCpred}
\title{Plot the predictions of logistic regression classifier}
\usage{
\method{plot}{LRCpred}(x, pch = c(1, 2), col = c("Blue", "Red"),
  scale = 1, seed = 1, parArgs = NULL, legendArgs = NULL,
  lineArgs = NULL, textArgs = NULL, ...)
}
\arguments{
\item{x}{an object of class \code{LRCpred} returned by \code{\link{predict.glmnetLRC}}.}

\item{pch}{A vector of at most length 2 indicating the plotting symbols to be used to differentiate the two true classes.  If
\code{truthCol} was not specified in the call to \code{\link{predict.glmnetLRC}}, only the first element is used. This is passed to
\code{\link{plot}}.}

\item{col}{A vector of at most length 2 indicating the colors of the plotted points in order to differentiate the two true classes.
If \code{truthCol} was not specified in the call to \code{\link{predict.glmnetLRC}}, only the first element is used. This is
passed to \code{\link{plot}}.}

\item{scale}{A numeric value in (0, 1] that controls scaling of the horizontal axis.  A value of 1 corresponds to the standard,
linear scale.  Values closer to 0 symetrically 'zoom-in' the axis near 0 and 1 while 'zooming-out' the axis in the neighborhood
of 0.5. Values of \code{scale} closer to 0 are useful if most of the probability predictions are piled up near 0 and 1.}

\item{seed}{Single numeric value that sets the seed for the random jitter of the vertical axis of the plot.}

\item{parArgs}{If desired, a list of named arguments that will be passed to \code{\link{par}} which is called prior to making
the plot.}

\item{legendArgs}{If desired, a list of named arguments that will be passed to \code{\link{legend}}. If
\code{truthCol} was not specified in the call to \code{\link{predict.glmnetLRC}}, no legend is drawn.}

\item{lineArgs}{If desired, a list of named arguments that will be passed to \code{\link{abline}} governing the vertical line that
indicates the value of \eqn{\tau}.}

\item{textArgs}{If desired, a list of named arguments that will be passed to \code{\link{text}} governing the text indicating the
value of \eqn{\tau}.}

\item{\dots}{Arguments passed to \code{\link{plot.default}}.}
}
\value{
A plot showing the predicted probabilities of the logisitic regression classifier, with a vertical bar
showing the value of the probability threshold, \eqn{\tau}.
}
\description{
Plot the predictions of logistic regression classifier
}
\seealso{
See \code{\link{glmnetLRC}} for an example.
}
\author{
Landon Sego
}
