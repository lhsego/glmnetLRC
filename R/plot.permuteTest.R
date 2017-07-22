##' Plot the null distribution of the permutation test
##'
##' @author Landon Sego
##' 
##' @method plot permuteTest
##'
##' @param x an object of class \code{permuteTest} returned by \code{\link{permuteTest.glmnetLRC}}.
##'
##' @param \dots Arguments passed to \code{\link{hist}} or \code{\link{print.default}}.
##'
##' @return The \code{print} method displays the p-value of the permutation test.  The \code{plot} method produces a
##' histogram of the null distribution of the loss, with a vertical line indicating the mean expected loss.
##' 
##' @export
##'
##' @seealso See \code{\link{glmnetLRC}} for an example.

plot.permuteTest <- function(x, ...) {

  # Set up the default plotting parameters
  defaultPlotArgs <- list(x = x$nullDist,
                          col = "Blue",
                          xlab = "Null distribution of loss",
                          main = paste("p-value =", round(x$pval, 5)))
    
  # Blend default with supplied arguments, giving preference to suppliedPlotArgs
  plotArgs <- list(...)
  finalPlotArgs <- blendArgs(defaultPlotArgs, plotArgs)

  # Make the plot
  do.call(hist, finalPlotArgs)
  abline(v = x$mean.ExpectedLoss, col = "Red")
    
} # plot.permuteTest

##' @method print permuteTest
##' @export

print.permuteTest <- function(x, ...) {
   print(x$pval, ...)
}
