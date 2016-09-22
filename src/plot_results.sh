#!/bin/sh

#Torque directives
#PBS -N plot_results
#PBS -W group_list=yetistats
#PBS -l nodes=1,walltime=01:00:00,mem=8g
#PBS -V

#set output and error directories
#PBS -o localhost:/vega/stats/users/smm2253/Projects/Measurement_Error/Code/outfiles
#PBS -e localhost:/vega/stats/users/smm2253/Projects/Measurement_Error/Code/outfiles

#Command to execute R code
R CMD BATCH --no-save --vanilla plot_results.r outfiles/$PBS_JOBNAME.routput
#End of script
