#!/bin/bash

# for how many views I have:
for j in {1..4}
do
  # how many functions do we have:
  for i in {1..8}
  do
     echo $i
     echo sbatch /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/bash_scripts/$1 $j $i
     sbatch /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/bash_scripts/$1 $j $i
     sleep 5s
  done
done

