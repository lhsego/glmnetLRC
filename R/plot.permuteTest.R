##' Plot the null distribution of the permutation test
##'
##' @author Landon Sego
##'
##' @method plot permuteTest
##'
##' @param x an object of class \code{permuteTest} returned by \code{\link{permuteTest.glmnetLRC}}.
##'
##' @param \dots Arguments passed to \code{\link{hist}}
##'
##' @return Produces a histogram of the null distribution of the loss, with a vertical red
##' line indicating the mean expected loss.
##' 
##' @export
##'
##' @seealso See \code{\link{glmnetLRC}} for an example.

plot.permuteTest <- function(x, ...) {

  # Set up the default plotting parameters
  defaultPlotArgs <- list(x = x$nullDist,
                          xlim = range(x$mean.ExpectedLoss, x$nullDist),
                          xlab = "Null distribution of loss",
                          main = paste("p-value =", round(x$pval, 5)))
    
  # Blend default with supplied arguments, giving preference to suppliedPlotArgs
  plotArgs <- list(...)
  finalPlotArgs <- blendArgs(defaultPlotArgs, plotArgs)

  # Make the plot
  do.call(hist, finalPlotArgs)
  abline(v = x$mean.ExpectedLoss, col = "Red", lwd = 2)
    
} # plot.permuteTest
