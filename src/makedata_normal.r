makedata_normal <- function(seed, N_lo, N_hi, J, mu, tau, gamma0, gamma1, gamma2, sigma_a, beta, sigma_y) {
# NOTE that this version uses rho_j (NOT p_j) in the data generating process
library(plyr)

# set seed
  set.seed(seed)

# draw PSU sizes
  N_j <- sample(c(N_lo:N_hi), size = J, replace = TRUE) # number of hhs in each psu

# make N-vector of PSU ids
  psuid <- rep(c(1:J), N_j)

# draw rho_j ~ N(mu, tau^2)
  logit_rho <- rnorm(n = J, mean = mu, sd = tau)
  
# do inverse logit to get rho_j's on probability scale
  rho_j <- exp(logit_rho) / (1 + exp(logit_rho))
  
# rep to get rho_j[i] vector
  rho_j_rep <- rep(rho_j, times = N_j)
  
# draw z_i ~ Bern(rho_j[i])
  zfun <- function(p, n) {
    rbinom(n = n, size = 1, prob = p)
  }
  z <- sapply(rho_j_rep, zfun, n = 1)
 
# calculate p_j
  #dat <- data.frame(psuid, z)
  #dat2 <- ddply(dat, .(psuid), summarise, p_j = mean(z))
  #p_j <- dat2$p_j

# add a covariate that is correlated with log(N_j), r = .75
#  x1 <- log(N_j)
#  n_corr <- length(N_j)
#  rho_corr <- .75
#  corr_covar <- gen_corr_covar(x1, n_corr, rho_corr) 
   corr_covar <- log(N_j)

# draw alpha_j ~ N(gamma0 + gamma1 * rho_j + gamma2 * corr_covar, sigma^2_a)
  alphamean <- gamma0 + gamma1*rho_j + gamma2*corr_covar
  alpha_j <- rnorm(alphamean, mean = alphamean, sd = sigma_a)
  alpha_j_rep <- rep(alpha_j, times = N_j)
  
# draw y_i ~ N(alpha_j[i] + beta * z_i)
  ymean <- alpha_j_rep + beta*z
  y <- rnorm(ymean, mean = ymean, sd = sigma_y)

# make hhid vector
  xfun <- function(x) {
    y <- c(1:x)
    return(y)
  }
  unitid <- unlist(sapply(N_j, xfun))

# return data
print("y length:")
print(length(y))
print("z length:")
print(length(z))
print("rho_j_rep length:")
print(length(rho_j_rep))
print("unitid length")
print(length(unitid))
  unitlevel_data <- data.frame(y = y, z = z, psuid = psuid, unitid = unitid, N_j = rep(N_j, times = N_j))
#  psulevel_data <- data.frame(alpha_j = alpha_j, rho_j = rho_j, p_j = p_j, corr_covar = corr_covar, psuid = c(1:J), N_j = N_j)
  psulevel_data <- data.frame(alpha_j = alpha_j, rho_j = rho_j, corr_covar = corr_covar, psuid = c(1:J), N_j = N_j)
  res <- list(unitlevel_data = unitlevel_data, psulevel_data = psulevel_data)
  return(res)
}
