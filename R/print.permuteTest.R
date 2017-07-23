##' Print the p-value of the permutation test
##'
##' @author Landon Sego
##'
##' @method print permuteTest
##'
##' @param x an object of class \code{permuteTest} returned by \code{\link{permuteTest.glmnetLRC}}.
##'
##' @param \dots Arguments passed to \code{\link{print.default}}.
##'
##' @export
##'
##' @seealso See \code{\link{glmnetLRC}} for an example.

print.permuteTest <- function(x, ...) {
   print(x$pval, ...)
}
