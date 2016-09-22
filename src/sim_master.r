sim_master <- function(ind, n_I, n_j) {
#  PURPOSE: run simulations
#  INPUTS:
#    ind -- index of current simulation
#    n_I -- number of PSUs to sample
#    n_j -- number of units per PSU to sample

print("####################################################################################")
print(Sys.time())
print("####################################################################################")

####################################################################################
### Setup of directories
####################################################################################

  rootdir <- "/vega/stats/users/smm2253/Projects/Measurement_Error/"
  Sys.setenv(HOME = rootdir)
  libdir <- "/vega/stats/users/smm2253/rpackages/"
  .libPaths(libdir)
  
  library(plyr)
  library(rstan)
  set_cppo("fast")
  library(parallel)

  source("/vega/stats/users/smm2253/Projects/Measurement_Error/Code/makedata_normal.r")
  source("/vega/stats/users/smm2253/Projects/Measurement_Error/Code/do_sampling.r")
  source("/vega/stats/users/smm2253/Projects/Measurement_Error/Code/gen_corr_covar.r")

####################################################################################
### Make data
####################################################################################
  # manipulate ind to know whether to make new pop
    simno <- ind
    indmod <- ind %% 100
    inddiv <- ind / 100
    inddiv_floor <- floor(inddiv)

  # set parameters
    seed <- 12345 + inddiv_floor # this will be 12345 + 0 for ind = 1, ..., 99; 12345 + 1 for ind = 101, ..., 199, etc
    # if we are on ind 100/200/300/etc, reset the seed to seed * (inddiv + 1) so we draw a new population
    #if (indmod == 0) {
    #  stopifnot(ceiling(inddiv) == inddiv) # make sure inddiv is an integer!
    #  seed <- seed * (inddiv + 1)
    #}
    J <- 5000
    N_lo <- 200
    N_hi <- 500
    sigma_a <- 0.5
    sigma_y <- 1
    beta <- 4
    gamma0 <- 1
    gamma1 <- 2
    gamma2 <- 1/20
    mu <- 0
    tau <- 1
 
  # run code to make data
    alldata <- makedata_normal(seed, N_lo, N_hi, J, mu, tau, gamma0, gamma1, gamma2, sigma_a, beta, sigma_y)
    unitlevel_data <- alldata[["unitlevel_data"]]
    psulevel_data <- alldata[["psulevel_data"]]
 
print("####################################################################################")
print(Sys.time())
print("####################################################################################")
  # check to make sure set.seed() is working correctly -- should have the SAME pop for ALL sims
   # print(seed)
   print(str(unitlevel_data))
   print(str(psulevel_data))

####################################################################################
### Sample data using current sim parameters
####################################################################################
  sampled_data <- do_sampling(n_I, n_j, psulevel_data, unitlevel_data)
  sampled_data_psu <- unique(sampled_data[, c("new_psuid", "psuid", "N_j")])
print("####################################################################################")
print(Sys.time())
print("####################################################################################")
# this should be different across sims!!!
print("sampled data:")
print(str(sampled_data))

  # make data for both models
    sum_z_dat <- ddply(sampled_data, .(new_psuid), summarise, sum_z = sum(z))
    sum_z_dat$p_j_star <- sum_z_dat$sum_z / n_j
    #standata_naive_u_normal <- list(n_I = n_I, n = n_j*n_I, n_j = n_j, y = sampled_data$y,
    #                                z = sampled_data$z, p_j_star = p_j_star_dat$p_j_star,
    #                                psuids = sampled_data$new_psuid)


    standata_naive_u_normal <- list(n_I = n_I, n = n_j*n_I, 
                                    y = sampled_data$y,z = sampled_data$z,
                                    p_j_star = sum_z_dat$p_j_star,
                                    psuids_samp_new_rep = sampled_data$new_psuid)
    standata_naive_k_normal <- list(n_I = n_I, n = n_j*n_I, 
                                    y = sampled_data$y,z = sampled_data$z,
                                    log_N_j = log(sampled_data_psu$N_j),
                                    p_j_star = sum_z_dat$p_j_star,
                                    psuids_samp_new_rep = sampled_data$new_psuid)

    #standata_full_u_normal <- list(n_I = n_I, n = n_j*n_I, n_j = n_j, y = sampled_data$y,
    #                               z = sampled_data$z,
    #                               psuids = sampled_data$new_psuid)
#logit <- function(x) {
#  logit_x <- log(x / (1-x))
#  return(logit_x)
#}
#psuid_map <- unique(sampled_data[, c("psuid", "new_psuid")])
#print("str(psuid_map):")
#print(str(psuid_map))
#sampled_data_psulevel <- merge(psuid_map, psulevel_data[, c("psuid", "rho_j", "alpha_j", "N_j")], by = "psuid")
#print("str(sampled_data_psulevel):")
#print(str(sampled_data_psulevel))
#sampled_data_psulevel$logit_rho <- logit(sampled_data_psulevel$rho_j)
    standata_full_k_normal <- list(n_I = n_I, n = n_j*n_I,
                                   y = sampled_data$y, z = sampled_data$z,
                                   log_N_j = log(sampled_data_psu$N_j),
                                   psuids_samp_new_rep = sampled_data$new_psuid,
                                   sum_z = sum_z_dat$sum_z)
                                   #logit_rho = sampled_data_psulevel$logit_rho)
    standata_full_u_normal <- list(n_I = n_I, n = n_j*n_I,
                                   y = sampled_data$y, z = sampled_data$z,
                                   psuids_samp_new_rep = sampled_data$new_psuid,
                                   sum_z = sum_z_dat$sum_z)
  # delete full data to save space
    rm(alldata, unitlevel_data, psulevel_data)

####################################################################################
### Run stan
####################################################################################
  niter <- 10000
  nchains <- 4

  rng_seed <- as.numeric(Sys.time())
  model_list <- c("full_k_normal", "naive_k_normal", "full_u_normal", "naive_u_normal")
  #model_list <- "naive_k_normal"
  for (model in model_list) {
    # check if the results already exist for this sim -- if yes then move on
    resfil <- paste("/vega/stats/users/smm2253/Projects/Measurement_Error/Results/posterior_info_",
                      model, "_nI_", n_I, "_nj_", n_j, "_sim_", simno, "THIS.RData", sep = "")
    if (file.exists(resfil)) {
      resfil2 <- paste("posterior_info_", model, "_nI_", n_I, "_nj_", n_j, "_sim_", simno, "THIS.RData", sep = "")
      print(paste(resfil2, " already exists! moving on", sep = ""))
      next
    }
    dataname <- paste("standata_", model, sep = "")
    print(str(get(dataname)))
    if ((n_I == 10) | (n_I == 50) | (n_I == 100 & (n_j == 2) | (n_j == 200)) | (n_I == 500 & (n_j == 20 | n_j == 200))) {
      # added 500,200 because it fails with the parallel way -- vectors too big to pass from worker nodes to master node
      fit <- stan(file = paste("/vega/stats/users/smm2253/Projects/Measurement_Error/Code/", model, ".stan", sep = ""),
                  data = get(dataname), chains = nchains, iter = niter)
    } else {
      stan_init <- stan(file = paste("/vega/stats/users/smm2253/Projects/Measurement_Error/Code/", model, ".stan", sep = ""),
                        data = get(dataname), chains = 0)
      sflist <- 
        mclapply(1:nchains, mc.cores = nchains, 
                 function(i) stan(fit = stan_init, data = get(dataname), 
                                  seed = rng_seed, iter = niter,
                                  chains = 1, chain_id = i, 
                                  refresh = -1))
      fit <- sflist2stanfit(sflist)
      rm(sflist, stan_init)
    }
    print("####################################################################################")
    print(Sys.time())
    print("####################################################################################")
    res <- summary(fit)$summary
    rm(fit)
    res_df <- data.frame(res)
    rm(res)
    posterior_info <- res_df[rownames(res_df) %in% c("beta", "gamma0", "gamma1", "gamma2", "sigma_a", "mu", "tau"), ]
    rm(res_df)
    posterior_info$param <- rownames(posterior_info)
    #print("str(posterior_info:")
    #print(str(posterior_info))
    true_vals_df <- data.frame(param = c("beta", "gamma0", "gamma1", "gamma2"), true_val = c(beta, gamma0, gamma1, gamma2))
    #print("str(true_vals_df):")
    #print(str(true_vals_df))
    posterior_info <- merge(posterior_info, true_vals_df, by = "param")
    #print("str(posterior_info:")
    #print(str(posterior_info))
    save(posterior_info,
         file = paste("/vega/stats/users/smm2253/Projects/Measurement_Error/Results/posterior_info_",
                      model, "_nI_", n_I, "_nj_", n_j, "_sim_", simno, "THIS.RData", sep = ""))
    rm(posterior_info)
    #rho_res <- res[grep("rho", rownames(res)), ]
    #rho_res$new_psuid <- c(1:n_I)
    #print(str(rho_res))
    #rho_res <- merge(rho_res, psulevel_data[, ("new_psuid", "rho_j")], by = "new_psuid")
    #print(str(rho_res))
    #save(rho_res,
    #     file = paste("/vega/stats/users/smm2253/Projects/Measurement_Error/Results/rho_res_",
    #                  model, "_nI_", n_I, "_nj_", n_j, "_sim_", simno, "THIS.RData", sep = ""))
    #print("rownames(res):")
    #print(rownames(res))
    #print("str(res):")
    #print(str(res))
    #print("grep alpha:")
    #print(grep("alpha", rownames(res)))
    #print("data.frame res:")
    #print(str(data.frame(res)))
    #res_df <- data.frame(res)
    #alpha_res <- res_df[grep("alpha", rownames(res)), ]
    #alpha_res$new_psuid <- c(1:n_I) # the alpha_j's will be in this order already
    #print("str(alpha_res):")
    #print(str(alpha_res))
    #alpha_res <- merge(alpha_res, sampled_data_psulevel[, c("new_psuid", "alpha_j")], by = "new_psuid")
    #alpha_res$true_vals <- alpha_res$alpha_j
    #alpha_res$alpha_j <- NULL
    #print("str(alpha_res):")
    #print(str(alpha_res))
    #save(alpha_res,
    #     file = paste("/vega/stats/users/smm2253/Projects/Measurement_Error/Results/alpha_res_",
    #                  model, "_nI_", n_I, "_nj_", n_j, "_sim_", simno, "THIS.RData", sep = ""))
    #rm(fit, alpha_res)
  }
}
