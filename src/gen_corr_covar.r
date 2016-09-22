gen_corr_covar <- function(x1, n, rho) {
  #  Purpose: given a fixed vector x1 of length n, generate a random vector
  #    x such that cor(x1, x) = rho
  #  x1 = fixed vector
  #  n = length of x1
  #  rho = desired correlation

  theta <- acos(rho)             # corresponding angle
  x2    <- rnorm(n, 2, 0.5)      # new random data
  X     <- cbind(x1, x2)         # matrix
  Xctr  <- scale(X, center=TRUE, scale=FALSE)   # centered columns (mean 0)
  
  Id   <- diag(n)                               # identity matrix
  Q    <- qr.Q(qr(Xctr[ , 1, drop=FALSE]))      # QR-decomposition, just matrix Q
  P    <- tcrossprod(Q)          # = Q Q'       # projection onto space defined by x1
  x2o  <- (Id-P) %*% Xctr[ , 2]                 # x2ctr made orthogonal to x1ctr
  Xc2  <- cbind(Xctr[ , 1], x2o)                # bind to matrix
  Y    <- Xc2 %*% diag(1/sqrt(colSums(Xc2^2)))  # scale columns to length 1
  
  x <- Y[ , 2] + (1 / tan(theta)) * Y[ , 1]     # final new vector
  x <- x - mean(x) + mean(x1)                   # so that mean(x) = mean(x1)
  cor(x1, x)                                    # check correlation = rho
  return(x)
}
