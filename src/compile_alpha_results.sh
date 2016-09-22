#!/bin/sh

#Torque directives
#PBS -N compile_alpha
#PBS -W group_list=yetistats
#PBS -l nodes=1,walltime=01:00:00,mem=4g
#PBS -V

#set output and error directories
#PBS -o localhost:/vega/stats/users/smm2253/Projects/Measurement_Error/Code/outfiles
#PBS -e localhost:/vega/stats/users/smm2253/Projects/Measurement_Error/Code/outfiles

#Command to execute R code
R CMD BATCH --no-save --vanilla compile_alpha_results.r outfiles/$PBS_JOBNAME.routput
#End of script
