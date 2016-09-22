do_sampling <- function(n_I, n_j, psulevel_data, unitlevel_data) {

####################################################################################
### Sample data using current sim parameters
####################################################################################
  # change seed here so we get different samples across sims
    #set.seed(Sys.time())
rm(.Random.seed, envir=.GlobalEnv)
  # sample n_J psus PPS
    sampled_psus <- sort(sample(psulevel_data$psuid, size = n_I, replace = FALSE, prob = psulevel_data$N_j))

  # then within each sampled psu, sample n_j units
    sampled_data <- data.frame()
    for (i in 1:n_I) {
      curr_psu <- sampled_psus[i]
      curr_data <- unitlevel_data[unitlevel_data$psuid == curr_psu, ]
      sampled_units <- sort(sample(curr_data$unitid, size = n_j, replace = FALSE))
      tmp <- curr_data[curr_data$unitid %in% sampled_units, ]
      tmp$new_psuid <- i # we will need the new psu/hh id's for stan
      tmp$new_unitid <- c(1:n_j)
      sampled_data <- rbind(sampled_data, tmp)
    }
  return(sampled_data)
}
