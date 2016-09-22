# Purpose: 


####################################################################################
### Setup of directories
####################################################################################

  rootdir <- "/vega/stats/users/smm2253/Projects/Measurement_Error/"
  Sys.setenv(HOME = rootdir)
  libdir <- "/vega/stats/users/smm2253/rpackages/"
  .libPaths(libdir)
  
  library(plyr)
  library(rstan)
  library(ggplot2)

  rootdir <- "/vega/stats/users/smm2253/Projects/Measurement_Error/"
  figdir <- paste(rootdir, "Figures", sep = "")
  resdir <- paste(rootdir, "Results", sep = "")

####################################################################################
### Load results
####################################################################################
  fils1 <- list.files(resdir, pattern = "posterior_info_.*THIS.RData")
  #fils2 <- list.files(resdir, pattern = "posterior_info_.*_nI_50_.*THIS.RData")
  #fils3 <- list.files(resdir, pattern = "posterior_info_.*_nI_100_.*THIS.RData")
#  fils2 <- list.files(resdir, pattern = "posterior_info.*_nJ_100_nhhs_200_")  
#print(fils1)
#print(fils2)
  #fils <- c(fils1, fils2, fils3)
  fils <- fils1
  #parlist <- c("beta", "gamma2", "gamma1", "gamma0")
  allres <- data.frame()
  for (f in 1:length(fils)) {
    fil <- fils[f]
    cat("Working on ", fil, ", file", f, "of ", length(fils), "files", "\n")
    tt <- file.info(paste(resdir, "/", fil, sep = ""))
    fdate <- tt$mtime
    fdate <- substr(fdate, 1, 10)
    fsize <- tt$size
    #if (fdate != "2015-08-10") {
    #  next
    #}
    nam <- gsub("posterior_info_", "", fil)
    nam <- gsub("nI_", "", nam)
    nam <- gsub("nj_", "", nam)
    nam <- gsub("sim_", "", nam)
    nam <- gsub("THIS.RData", "", nam)
    namsplit <- unlist(strsplit(nam, "_"))
    len <- length(namsplit)
    model <- paste(namsplit[1:(len-3)], collapse = "_")
    n_I <- as.numeric(namsplit[len-2])
    n_j <- as.numeric(namsplit[len-1])
    simno <- as.numeric(namsplit[len])
    load(paste(resdir, fil, sep = "/"))
    #cat("filename: ", fil, "\n")
    #cat("dim of posterior_info:", dim(posterior_info), "\n")
#cat(str(posterior_info))
#cat(rownames(posterior_info))
#cat(fil)
    if (is.null(posterior_info)) {
      next
    }
    df <- data.frame(posterior_info, model, n_I, n_j, simno, param = rownames(posterior_info))
    #df <- data.frame(postmean = posterior_info["mean"],
    #                 post25 = posterior_info["25%"],
    #                 post50 = posterior_info["50%"],
    #                 post75 = posterior_info["75%"],
    #                 post_lci = posterior_info["2.5%"],
    #                 post_uci = posterior_info["97.5%"],
    #                 neff = posterior_info["n_eff"],
    #                 Rhat = posterior_info["Rhat"],
    #                 param = "gamma1",
    #                 param = "beta",
    #                 model, n_I, n_j, simno)
    #df <- data.frame(postmean = posterior_info[, "mean"],
    #                 post25 = posterior_info[, "25%"],
    #                 post50 = posterior_info[, "50%"],
    #                 post75 = posterior_info[, "75%"],
    #                 post_lci = posterior_info[, "2.5%"],
    #                 post_uci = posterior_info[, "97.5%"],
    #                 neff = posterior_info[, "n_eff"],
    #                 Rhat = posterior_info[, "Rhat"],
    #                 param = rownames(posterior_info),
    #                 model, n_I, n_j, simno)
    allres <- rbind(allres, df)
  }
today <- Sys.Date()
today <- sub("-", "_", today)
save(allres, file = paste(resdir, "/combined_post_means_", today, ".RData", sep = ""))
print(str(allres))
#load(file = paste(resdir, "/combined_post_means.RData", sep = ""))
#allres <- allres[allres$param %in% c("beta", "gamma0", "gamma1"),]
####################################################################################
### Plot results
####################################################################################
#  true.beta <- 1
#  true.gamma0 <- 1
#  true.gamma1 <- 2
#
#  pdf(file = paste(figdir, "/true_vs_est_params.pdf", sep = ""),
#      width = 15, height = 10)
#
#  ggplot(allres, aes(x = postmean , colour = n)) +
#    geom_line(aes(linetype = model), stat = "density") +
#    facet_wrap(~param) +
#    xlab("Estimate") +
#    ylab("Posterior Density") +
#    scale_colour_continuous(name = "n", guide = guide_legend()) +
#    scale_linetype_discrete(name = "Model", guide = guide_legend()) +
#    theme_bw() + 
#    theme(legend.position = "bottom")
#
#  dev.off()

