# get the current task id -- we'll use it to generate new populations
args <- commandArgs(FALSE)
ind <- -1*as.numeric(args[length(args)])
#ind <- 1
print(ind)
stopifnot(ind > 0)
source("/vega/stats/users/smm2253/Projects/Measurement_Error/Code/sim_master.r")
sim_master(ind, 10, 200)

