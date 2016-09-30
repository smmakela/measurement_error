sim_function <- function(n) {
  # Purpose: make data for simulation
  #
  # Arguments:
  #  n -- number of observations
  #
  # Returns:
  #  df -- data frame with observed outcomes (y), latent outcomes (u), treatment
  #    indicators (T), and whether outcome is observed or latent
  
  # Coefficients
  a <- rnorm(n = 1, mean = 0, sd = 1)
  b <- rnorm(n = 1, mean = 0, sd = 1)
  c <- rnorm(n = 1, mean = 1, sd = .1)
  d <- rnorm(n = 1, mean = 0, sd = 1)
  #sigma_y <- abs(rnorm(n = 1, mean = 0, sd = .05))
  sigma_u <- abs(rnorm(n = 1, mean = 0, sd = .1))
  sigma_y <- sigma_u
  
  # Pre-treatment
  u_i0 <- rnorm(n, mean = 0, sd = 1)
  y_i0 <- u_i0 + rnorm(n, mean = 0, sd = sigma_y)
  
  # Treatment assignment
  treat.inds <- sample.int(n, size = n/2, replace = FALSE)
  T_i <- rep(0, times = n)
  T_i[treat.inds] <- 1
  
  # Post-treatment
  u_i1 <- a + b * u_i0 + c * T_i + d * u_i0 * T_i + rnorm(n, mean = 0, sd = sigma_u)
  y_i1 <- u_i1 + rnorm(n, mean = 0, sd = sigma_y)
  
  # Make data
  df <- data.frame(T_i, u_i0, u_i1, y_i0, y_i1)
  true_coefs <- list(a = a, b = b, c = c, d = d, sigma_y = sigma_y, sigma_u = sigma_u)
  
  return(list(df = df, true_coefs = true_coefs))
}