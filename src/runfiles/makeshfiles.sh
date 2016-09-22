#!/bin/sh
for n_I in 10 50 100 500
  do
  for n_j in 2 20 200
  do
    echo "#!/bin/sh" >> "nI_${n_I}_nj_${n_j}_normal.sh"
    echo "#Torque directives" >> "nI_${n_I}_nj_${n_j}_normal.sh"
    echo "#PBS -N nI_${n_I}_nj_${n_j}_normal" >> "nI_${n_I}_nj_${n_j}_normal.sh"
    echo "#PBS -W group_list=yetistats" >> "nI_${n_I}_nj_${n_j}_normal.sh"
    echo "#PBS -l nodes=1,walltime=04:00:00,mem=4gb" >> "nI_${n_I}_nj_${n_j}_normal.sh"
    echo "#PBS -V" >> "nI_${n_I}_nj_${n_j}_normal.sh"
    echo "#PBS -t 1-500" >> "nI_${n_I}_nj_${n_j}_normal.sh"
    echo "#PBS -o localhost:/vega/stats/users/smm2253/Projects/Measurement_Error/Code/outfiles" >> "nI_${n_I}_nj_${n_j}_normal.sh"
    echo "#PBS -e localhost:/vega/stats/users/smm2253/Projects/Measurement_Error/Code/outfiles" >> "nI_${n_I}_nj_${n_j}_normal.sh"
    echo "outdir=\"/vega/stats/users/smm2253/Projects/Measurement_Error/Code/outfiles\"" >> "nI_${n_I}_nj_${n_j}_normal.sh"
    echo "export CCACHE_DISABLE=1" >> "nI_${n_I}_nj_${n_j}_normal.sh"
    echo "R CMD BATCH --no-save --vanilla -\${PBS_ARRAYID} \$PBS_O_WORKDIR/nI_${n_I}_nj_${n_j}_normal.r \$outdir/\$PBS_JOBNAME.routput" >> "nI_${n_I}_nj_${n_j}_normal.sh"
    echo -en "\n" >> "nI_${n_I}_nj_${n_j}_normal.sh"
  done
done
