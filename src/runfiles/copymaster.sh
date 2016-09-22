#!/bin/sh
for j in 10 50 100 500
  do
  for n in 2 20 200
    do
    if [[ j != 10 && n != 2 ]]; then
      cp master_nJ_10_nhhs_2_normal.r master_nJ_${j}_nhhs_${n}_normal.r
    fi
  done
done
