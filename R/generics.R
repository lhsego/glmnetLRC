##' Generics for \code{extract}, \code{missingpreds}, and \code{permuteTest} methods
##'
##' @aliases missingpreds permuteTest
##'
##' @usage extract(object, ...)
##' missingpreds(object, ...)
##' permuteTest(object, ...)
##'
##' @param object The object on which the generic operates
##' @param \dots Arguments passed to specific methods
##'
##' @rdname generics
##'
##' @export
extract <- function (object, ...) {
  UseMethod("extract", object)
}

##' @export
missingpreds <- function (object, ...) {
  UseMethod("missingpreds", object)
}
##' @export
permuteTest <- function (object, ...) {
  UseMethod("permuteTest", object)
}
