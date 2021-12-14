#!/bin/bash

# how many functions do we have:
for i in {1..12}
do
 echo $i
 echo sbatch /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/bash_scripts/$1 $i 
 sbatch /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/bash_scripts/$1 $i
 sleep 5s
done


