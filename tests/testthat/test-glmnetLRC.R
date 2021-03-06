context("Verify glmnetLRC() and associated methods perform correctly")

saveComparitors <- FALSE

# Set the seed
set.seed(20)

# A response variable
response <- factor(rep(c("a", "b"), each = 20))

# Convert response to 0,1:  a = 0, b = 1
y <- as.numeric(response) - 1

# Create 2 predictors that depend somewhat on the response
preds <- matrix(c(rnorm(40, 0, 0.5) + y, rnorm(40, 2, 0.5) + y),
                ncol = 2, dimnames = list(NULL, c("x1", "x2")))

# Set alpha
alpha <- 0.7

# Get a single fit of the data
gfit <- glmnetLRC(response, preds, alphaVec = alpha, tauVec = 0.5, cvFolds = 3,
                  cvReps = 2, standardize = FALSE, estimateLoss = TRUE)

test_that("0-1 matrix is created as expected", {

   m <- lossMatrix(c("a", "a", "b", "b"), c("a", "b", "a", "b"), c(0, 1, 1, 0))

   expect_equal(gfit$lossMat, m)

})

test_that("Order of loss matrix specification doesn't make a difference", {

   gfitNewLoss <- glmnetLRC(response, preds,
                            lossMat = lossMatrix(c("a", "b", "a", "b"), c("b", "a", "a", "b"), c(1, 1, 0, 0)),
                            alphaVec = alpha, tauVec = 0.5, cvFolds = 3,
                            cvReps = 2, standardize = FALSE, estimateLoss = TRUE)

   expect_equal(coef(gfitNewLoss), coef(gfit))

   # Get the printed objects
   g1 <- print(gfit, verbose = FALSE)
   g2 <- print(gfitNewLoss, verbose = FALSE)

   expect_equal(g1, g2)

})


test_that("Final glmnet model matches manual fitting", {

  # Get optimal parms
  lambda <- print(gfit, verbose = FALSE)[,"lambda"]

  # Get lambdaVec
  lambdaVec <- gfit$lambda

  # Fit the glmnet
  gfit1 <- glmnet::glmnet(preds, response, family = "binomial", alpha = alpha, lambda = lambdaVec, standardize = FALSE)

  # Get the coefs with the optimal lambda
  c1 <- coef(gfit)
  names(c1) <- NULL
  c2 <- as.vector(coef(gfit1, s = lambda))

  # Create an objective function that should match results from glmnet
  f <- function(beta, n = nrow(preds), lambda = 1, alpha = alpha) {

    # Name the regression parameters for easier readability
    beta0 <- beta[1]
    beta1 <- beta[2]
    beta2 <- beta[3]

    # The linear combination of regression parameters and predictors
    xb <- beta0 + beta1 * preds[,1] + beta2 * preds[,2]

    # The unpenalized binomial log-likelihood
    ll <- sum(y * xb - log(1 + exp(xb))) / n

    # The elastic-net penalty
    penalty <- lambda * (0.5 * (1 - alpha) * (beta1^2 + beta2^2) + alpha * (abs(beta1) + abs(beta2)))

    # The objective to minimize
    return(penalty - ll)

  } # f()

  # Fit the parameters manually
  c3 <- optim(c(-3, 1, 1), f, alpha = alpha, n = nrow(preds), lambda = lambda)$par

  # Tests
  expect_equal(c1, c2)
  expect_that(c1, not(equals(c3)))
  expect_true(max(abs(c3 - c1)) < 0.001)

})


test_that("Testing non-intercept model with manual fitting", {

  # Get a single fit of the data
  gfit <- glmnetLRC(response, preds, alphaVec = alpha, tauVec = 0.5, cvFolds = 3, cvReps = 2,
                    standardize = FALSE, intercept = FALSE)

  # Get optimal parms
  lambda <- print(gfit, verbose = FALSE)[,"lambda"]

  # Get lambdaVec
  lambdaVec <- gfit$lambda

  # Fit the glmnet
  gfit1 <- glmnet::glmnet(preds, response, family = "binomial", alpha = alpha, lambda = lambdaVec,
                          standardize = FALSE, intercept = FALSE)

  # Get the coefs with the optimal lambda
  c1 <- coef(gfit)
  names(c1) <- NULL
  c2 <- as.vector(coef(gfit1, s = lambda))

  expect_equal(c2[1], 0)

  c2 <- c2[-1]

  # Create an objective function that should match results from glmnet
  f <- function(beta, n = nrow(preds), lambda = 1, alpha = alpha) {

    # Name the regression parameters for easier readability
    beta1 <- beta[1]
    beta2 <- beta[2]

    # The linear combination of regression parameters and predictors
    xb <- beta1 * preds[,1] + beta2 * preds[,2]

    # The unpenalized binomial log-likelihood
    ll <- sum(y * xb - log(1 + exp(xb))) / n

    # The elastic-net penalty
    penalty <- lambda * (0.5 * (1 - alpha) * (beta1^2 + beta2^2) + alpha * (abs(beta1) + abs(beta2)))

    # The objective to minimize
    return(penalty - ll)

  } # f()

  # Fit the parameters manually
  c3 <- optim(c(0.5, 0), f, alpha = alpha, n = nrow(preds), lambda = lambda)$par

  # Tests
  expect_equal(c1, c2)
  expect_that(c1, not(equals(c3)))
  expect_true(max(abs(c3 - c1)) < 0.001)

})


test_that("Our understanding of the standardization process is correct", {

  # Get a single fit of the data
  gfit <- glmnetLRC(response, preds, alphaVec = alpha, tauVec = 0.5, cvFolds = 3, cvReps = 2,
                    standardize = TRUE)

  # Get optimal parms
  lambda <- print(gfit, verbose = FALSE)[,"lambda"]

  # Get lambdaVec
  lambdaVec <- gfit$lambda

  # Fit the glmnet
  gfit1 <- glmnet::glmnet(preds, response, family = "binomial", alpha = alpha, lambda = lambdaVec,
                          standardize = TRUE)

  # Get the coefs with the optimal lambda
  c1 <- coef(gfit)
  names(c1) <- NULL
  c2 <- as.vector(coef(gfit1, s = lambda))

  # The standardizing function
  s <- function(x) sqrt(var(x) * (length(x) - 1) / length(x))

  # Standarize the predictors
  s1 <- s(preds[,1])
  s2 <- s(preds[,2])

  # Create an objective function that should match results from glmnet
  f <- function(beta, n = nrow(preds), lambda = 1, alpha = alpha) {

    # Name the regression parameters for easier readability
    beta0 <- beta[1]
    beta1 <- beta[2]
    beta2 <- beta[3]

    # The linear combination of regression parameters and predictors
    xb <- beta0 + beta1 * preds[,1] / s1 + beta2 * preds[,2] / s2

    # The unpenalized binomial log-likelihood
    ll <- sum(y * xb - log(1 + exp(xb))) / n

    # The elastic-net penalty
    penalty <- lambda * (0.5 * (1 - alpha) * (beta1^2 + beta2^2) + alpha * (abs(beta1) + abs(beta2)))

    # The objective to minimize
    return(penalty - ll)

  } # f()

  # Fit the parameters manually and backtransform
  c3 <- optim(c(-3, 1, 1), f, alpha = alpha, n = nrow(preds), lambda = lambda)$par
  c3[2] <- c3[2] / s1
  c3[3] <- c3[3] / s2

  # Tests
  expect_equal(c1, c2)
  expect_that(c1, not(equals(c3)))
  expect_true(max(abs(c3 - c1)) < 0.002)

})

test_that("Errors for argument checking are working as expected", {

  expect_error(glmnetLRC(rep(1, 2,each = 20), preds, alphaVec = alpha, tauVec = 0.5, cvFolds = 3,
                         cvReps = 1.5, standardize = FALSE, estimateLoss = TRUE),
               "'truthLabels' must be a factor")

  expect_error(glmnetLRC(response, preds, alphaVec = alpha, tauVec = 0.5, cvFolds = 3,
                         cvReps = 1.5, standardize = FALSE, estimateLoss = TRUE),
               "'cvReps' must be an integer")

  expect_error(glmnetLRC(response, preds, alphaVec = alpha, tauVec = 0.5, cvFolds = 3,
                         cvReps = 2, stadardize = FALSE, estimateLoss = TRUE),
               "following do not match the arguments in glmnet")

  expect_error(glmnetLRC(response, preds, alphaVec = alpha, tauVec = 0.5, cvFolds = 3,
                         cvReps = 2, standardize = FALSE, family = "poisson", estimateLoss = TRUE),
               "and should not be supplied to")

  expect_error(glmnetLRC(response, preds, lossMat = 7, alphaVec = alpha,
                         tauVec = 0.5, cvFolds = 3, cvReps = 2),
               "'lossMat' must be either '0-1' or an object of class 'lossMat'")

  expect_error(glmnetLRC(response, preds, lossMat = c("a", "b"), alphaVec = alpha,
                         tauVec = 0.5, cvFolds = 3, cvReps = 2),
               "'lossMat' must be either '0-1' or an object of class 'lossMat'")

  expect_error(glmnetLRC(response, preds, lossMat = "1-0", alphaVec = alpha,
                         tauVec = 0.5, cvFolds = 3, cvReps = 2),
               "'lossMat' must be either '0-1' or an object of class 'lossMat'")

})


# Get data to pass into glmnetLRC()
data(traindata, package = "glmnetLRC")

predictors <- as.matrix(traindata[,9:96])

response <- factor(traindata$Curated_Quality,
                   levels = c("good", "poor"),
                   labels = c("good", "poor"))

lM <- lossMatrix(c("good","good","poor","poor"),
                 c("good","poor","good","poor"),
                 c(     0,     1,     5,     0))

data(testdata, package = "glmnetLRC")

data(glmnetLRC_fit, package = "glmnetLRC")


# Test how predict handles data frames and matrices
test_that("predict.glmnetLRC() handles data frames and matrices equivalently", {

   o1 <- predict(glmnetLRC_fit, testdata)
   o2 <- predict(glmnetLRC_fit, as.matrix(testdata[,9:96]))

   expect_identical(o1, o2)
   expect_identical(summary(o1), summary(o2))
    
})

# Create a set of static checks
test_that("Objects returned by glmnetLRC() remains unchanged", {

  gp <- glmnetLRC(response, predictors, alphaVec = c(0.8, 1),
                  tauVec = c(0.4, 0.5, 0.6), cvReps = 2,
                  lossMat = lM, nJobs = 2, masterSeed = 6,
                  estimateLoss = TRUE)

  if (saveComparitors) {
    save(gp, file = "../datasets/gp.Rdata")
  }
  
  gp.c <- Smisc::loadObject("../datasets/gp.Rdata")

  # Tests
  expect_equal(gp.c, gp)
  expect_equal(print(gp.c, verbose = FALSE), print(gp, verbose = FALSE))
  expect_equal(coef(gp.c), coef(gp))
  expect_equal(extract(gp.c), extract(gp))

  # Test the predict method with a truth col
  np <- predict(gp, testdata, truthCol = "Curated_Quality")
  np.c <- predict(gp.c, testdata, truthCol = "Curated_Quality")

  expect_equal(np, np.c)
  expect_equal(summary(np), summary(np.c))


  # Create another static object for comparison
  gp1 <- glmnetLRC(response, predictors, alphaVec = c(0.5, 0.7),
                   tauVec = c(0.3, 0.7), cvReps = 2,
                   nJobs = 2, masterSeed = 4, stratify = TRUE)

  if (saveComparitors) {  
   save(gp1, file = "../datasets/gp1.Rdata")
  }
  gp1.c <- Smisc::loadObject("../datasets/gp1.Rdata")

  # Tests
  expect_equal(gp1.c, gp1)
  expect_equal(print(gp1.c, verbose = FALSE), print(gp1, verbose = FALSE))
  expect_equal(coef(gp1.c), coef(gp1))
  expect_equal(extract(gp1.c), extract(gp1))

  # Test the predict method with a truth col
  np1 <- predict(gp1, testdata, truthCol = "Curated_Quality")
  np1.c <- predict(gp1.c, testdata, truthCol = "Curated_Quality")

  expect_equal(np1, np1.c)
  expect_equal(summary(np1), summary(np1.c))

})


# Compare parallel and non-parallel processing
test_that("Compare parallel and non-parallel processing", {

  # A non-parallel version of gp
  gnp <- glmnetLRC(response, predictors, alphaVec = c(0.8, 1),
                   tauVec = c(0.4, 0.5, 0.6), cvReps = 2,
                   lossMat = lM, nJobs = 1, masterSeed = 6,
                   estimateLoss = TRUE)

  gp <- Smisc::loadObject("../datasets/gp.Rdata")

  # Test the objects
  expect_equal(gp, gnp)

  # Test the methods
  expect_equal(print(gp, verbose = FALSE), print(gnp, verbose = FALSE))
  expect_equal(coef(gp), coef(gnp))
  expect_equal(extract(gp), extract(gnp))

  # Test the predict method with a truth col
  np <- predict(gp, testdata, truthCol = "Curated_Quality")
  npp <- predict(gnp, testdata, truthCol = "Curated_Quality")

  expect_equal(np, npp)
  expect_equal(summary(np), summary(npp))

  # Test the predict method without a truth col
  np1 <- predict(gp, testdata, keepCols = 2)
  npp1 <- predict(gnp, testdata, keepCols = "Instrument")

  expect_equal(np1, npp1)
  expect_equal(summary(np1), summary(npp1))

})


test_that("Test the behavior of the predict method", {

  gp <- Smisc::loadObject("../datasets/gp.Rdata")

  # Add in a few extra columns for prediction that do not exist in the model
  tmp <- testdata[,25:30]
  colnames(tmp) <- paste(colnames(tmp), "extra", sep = "_")
  tdata <- cbind(testdata, tmp)

  # These two predictions should be the same
  np1 <- predict(gp, tdata, keepCols = 2)
  np2 <- predict(gp, testdata, keepCols = 2)

  expect_equal(np1, np2)

  # And if we're missing some of the columns in the model
  expect_error(predict(gp, testdata[,-c(22:30)]), "predictors that are required by 'object' but", fixed = TRUE)
  expect_error(predict(gp, testdata[,-24]), "There is 1 predictor required by 'object' that", fixed = TRUE)

  # Insert some missing values in testdata.  Notice that if one of the coefficients is 0, is can be missing
  tdata <- testdata

  # These predictors have non-zero coefs
  tdata[5, "P_2C"] <- NA
  tdata[27, "MS2_Density_Q1"] <- NA

  # These predictors have zero coef
  tdata[50, "IS_3C"] <- NA
  tdata[89, "MS2_4D"] <- NA

  # But we only have 2 missing predictions
  np3 <- predict(gp, tdata)
  expect_equal(sum(is.na(np3$Prob)), 2)
  expect_equal(sum(is.na(np3$PredictClass)), 2)

  # Predictions of non-missing values should be the same
  np4 <- predict(gp, testdata, truthCol = 8, keepCols = 2)
  np5 <- predict(gp, tdata, truthCol = "Curated_Quality", keepCols = 2)

  expect_equal(nrow(np4), nrow(np5))

  # After accounting for NA's, verify they're equal
  cc <- complete.cases(np5)
  expect_equal(np4[cc,], np5[cc,])

})

test_that("Loss weights perform as expected", {

  # Refit with larger weights
  gp <- glmnetLRC(response, predictors, alphaVec = c(0.8, 1),
                  tauVec = c(0.4, 0.5, 0.6), cvReps = 2,
                  lossMat = lM, lossWeight = rep(7, length(response)),
                  nJobs = 2, masterSeed = 6,
                  estimateLoss = TRUE)

  gp.c <- Smisc::loadObject("../datasets/gp.Rdata")

  expect_equal(gp, gp.c)

  # Refit with different weights
  gp1 <- glmnetLRC(response, predictors, alphaVec = c(0.8, 1),
                   tauVec = c(0.4, 0.5, 0.6), cvReps = 2,
                   lossMat = lM,
                   lossWeight = rpois(length(response), lambda = 10),
                   nJobs = 2, masterSeed = 6,
                   estimateLoss = TRUE)

  expect_that(gp1, not(equals(gp.c)))

})

test_that("Seeds make a difference", {

  # Refit with different seed
  gp <- glmnetLRC(response, predictors, alphaVec = c(0.8, 1),
                  tauVec = c(0.4, 0.5, 0.6), cvReps = 2,
                  lossMat = lM, nJobs = 2, masterSeed = 6 + 20,
                  estimateLoss = TRUE)

  gp.c <- Smisc::loadObject("../datasets/gp.Rdata")

  expect_that(gp, not(equals(gp.c)))

})


