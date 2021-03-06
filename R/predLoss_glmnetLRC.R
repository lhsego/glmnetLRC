## Prediction function for the elastic net logistic regression classifier
##
## Prediction function for the elastic net logistic regression classifier
## for a variety of thresholds and calculate
## the associated loss
##
## Let \code{z} represent class denoted by the last level of \code{truthLabels}.
## Then the probability returned by \code{predict(glmnetFit, newData, type = 'response')}
## is the probability that the observations belong to class z.  If this probabilty
## exceeds \code{tau}, we will classify the observation as belonging to \code{z}.
##
## @author Landon Sego
##
## @param glmnetFit The glmnet fitted object (returned from \code{glmnet}
## that inherits from the \code{lognet} and \code{glmnet} classes.
##
## @param newData A matrix or dataframe of new instances that match the
## predictors in \code{glmnetFit}
##
## @param truthDataLabels A factor vector containing the corresponding truth
## labels in \code{newData}.
##
## @param lossMat A loss matrix of class \code{lossMat}, returned by
## \code{lossMatrix}
##
## @param tauVec A numeric sequence of threshold values for the binary
## classification.
##
## @param lossWeight A numeric vector indicating the relative weight to ascribe
## to each row of \code{newData}
##
## @param lambdaVec A numeric vector of lambda values for which the loss will
## be calculated.
##
## @return A data frame containing \code{weightedSumLoss} (the sum of the
## product of the weights and the loss) and \code{sumWeights}
## (the sum of the weights) for each value of \code{tau} and \code{lambda}.  The
## loss (for \code{newData}) is given by \code{weightedSumLoss} divided by
## \code{sumWeights}.

predLoss_glmnetLRC <- function(glmnetFit, newData, truthLabels, lossMat,
                               tauVec = seq(0.1, 0.9, by = 0.1), 
                               lossWeight = rep(1, NROW(newData)),
                               lambdaVec = NULL) {

  # Force the lossWeight to resolve to avoid any issues with lazy evaluation
  force(lossWeight)

  # Check inputs
  Smisc::stopifnotMsg(
      
    # Ensure the object is of the correct class
    inherits(glmnetFit, "lognet"), "'glmnetFit' must inherit from the 'lognet' class",
    inherits(glmnetFit, "glmnet"), "'glmnetFit' must inherit from the 'glmnet' class",

    # Check truthLabels
    if (is.factor(truthLabels)) {
      nlevels(truthLabels) == 2
    } else FALSE,
    "'truthLabels' must be a factor with 2 levels",

    # Verify lengths match
    length(lossWeight) == NROW(newData),
    "the length of 'lossWeight' must be the same as the number of rows in 'newData'")

  # Ensure factors were constructed the same way for
  # the training data and the newdata.  This is important
  # to ensure our labels don't get messed up
  if (!all(glmnetFit$classnames == levels(truthLabels))) {
    stop("Factor levels in 'glmnetFit' object do not match the levels of 'truthLabels'")
  }
  
  # For each lambda, make probabality predictions that the instance is an
  # element of the class with the largest factor level
  preds <- predict(glmnetFit, newData, s = lambdaVec, type = "response")

  # Let Z be the last level of the response (Z = levels(truthLabels)[2])
  # The preds matrix returned by predict(glmnet, ...) is  P(x elem Z)
  # The rule will be:  If P(x elem Z) > tau --> x is assigned to Z
  # Create a logical matrix of whether x is assigned to Z for a given tau

  # Calculate the loss over the lambdas for a given tau
  calcLossOverLambda <- function(x, tau = 0.5) {

    # x is the probabilty returned by predict(glmnetFit, ...), i.e.,
    # it is P(x elem Z)

    # Dichotomize the prediction for tau
    predLabels <- factor(x > tau, levels = c(FALSE, TRUE),
                         labels = glmnetFit$classnames)

    # Calculate the loss
    cl <- calcLoss(truthLabels, predLabels, lossMat, lossWeight = lossWeight)

    return(cl)

  } # calcClossOverLambda

  # Calculate the loss over the taus
  calcLossOverTau <- function(x) {
      
    # x is a value of tau
      
    out <- Smisc::list2df(apply(preds, 2, calcLossOverLambda, tau = x))
    out$tau <- x

    # if lambdaVec was supplied, then preditions were made using lambdaVec
    if (!is.null(lambdaVec)) {
      out$lambda <- lambdaVec
    }
    # otherwise predictions would have been made using the lambdas in the
    # fitted glmnet object
    else {
      out$lambda <- glmnetFit$lambda
    }

    return(out)

  } # calcClossOverTau

  # Calculate the weighted sum of the loss and the sum of the weights
  # (aggregated over the observations provided in 'newData') for
  # each combination of tau and lambda
  return(Smisc::list2df(lapply(tauVec, calcLossOverTau)))

} # predLoss_glmnetLRC
