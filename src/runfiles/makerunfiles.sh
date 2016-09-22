#!/bin/sh
for n_I in 10 50 100 500
  do
  for n_j in 2 20 200
  do
    echo "# get the current task id -- we'll use it to generate new populations" >> "nI_${n_I}_nj_${n_j}_normal.r"
    echo "args <- commandArgs(FALSE)" >> "nI_${n_I}_nj_${n_j}_normal.r"
    echo "ind <- -1*as.numeric(args[length(args)])" >> "nI_${n_I}_nj_${n_j}_normal.r"
    echo "print(ind)" >> "nI_${n_I}_nj_${n_j}_normal.r"
    echo "stopifnot(ind > 0)" >> "nI_${n_I}_nj_${n_j}_normal.r"
    echo "source(\"/vega/stats/users/smm2253/Projects/Measurement_Error/Code/sim_master.r\")" >> "nI_${n_I}_nj_${n_j}_normal.r"
    echo "sim_master(ind, $n_I, $n_j)" >> "nI_${n_I}_nj_${n_j}_normal.r"
    echo -en "\n" >> "nI_${n_I}_nj_${n_j}_normal.r"
  done
done
