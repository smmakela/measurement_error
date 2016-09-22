#!/bin/sh
# check the current status of the queue and store in status.txt
qstat -u smm2253 > status.txt

# while the status file is NOT empty, sleep for 10 min and check again
while [ -s status.txt ]
do
  #echo "not done"
  sleep 10m
  qstat -u smm2253 > status.txt
done

# once the status file IS empty (meaning all my jobs are done running),
# break out of the while loop and start the next set of jobs:
# the last 50 job and the 100s
echo "starting the 100s!"
qsub nI_50_nj_200.sh
for f in nI_100_nj_*.sh
  do
    #qsub "$f"
    echo "$f"
  done

# while the status file is NOT empty, sleep for 10 min and check again
qstat -u smm2253 > status.txt
while [ -s status.txt ]
do
  #echo "not done"
  sleep 10m
  qstat -u smm2253 > status.txt
done

# once the status file IS empty (meaning all my jobs are done running),
# break out of the while loop and start the next set of jobs:
# the 500s
echo "starting the 500s!"
for f in nI_500_nj_*.sh
  do
    #qsub "$f"
    echo "$f"
  done

# while the status file is NOT empty, sleep for 10 min and check again
qstat -u smm2253 > status.txt
while [ -s status.txt ]
do
  #echo "not done"
  sleep 10m
  qstat -u smm2253 > status.txt
done

# now that everything is done running, run the compiling code
qsub ../plot_results.sh

