#!/bin/sh
#Torque directives
#PBS -N nI_10_nj_200_normal
#PBS -W group_list=yetistats
#PBS -l nodes=1,walltime=06:00:00,mem=8gb
#PBS -V
#PBS -t 1-500
#PBS -o localhost:/vega/stats/users/smm2253/Projects/Measurement_Error/Code/outfiles
#PBS -e localhost:/vega/stats/users/smm2253/Projects/Measurement_Error/Code/outfiles
outdir="/vega/stats/users/smm2253/Projects/Measurement_Error/Code/outfiles"
export CCACHE_DISABLE=1
R CMD BATCH --no-save --vanilla -${PBS_ARRAYID} $PBS_O_WORKDIR/nI_10_nj_200_normal.r $outdir/$PBS_JOBNAME.routput

