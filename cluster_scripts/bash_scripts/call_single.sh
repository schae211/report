#!/bin/bash

FILE=$1
ARG1=$2
ARG2=$3
echo "File: $FILE"
echo "Argument 1: $ARG1"
echo "Argument 2: $ARG2"

# Check whether the number of CPUs is given
if [[ $# -eq 4 ]]
then
    CPU=$4
else
    CPU=16
fi

echo "CPUs: $CPU"

 LOGGING=${FILE////-}
 echo "sbatch --job-name="$LOGGING-$ARG1-$ARG2" --time=23:30:00 --nodes=1 --cpus-per-task=$CPU --partition=single --output="/net/data.isilon/ag-saez/bq_pschaefer/LOGS/$LOGGING-$VIEW-$ALG-%j.log" --export=FILE=$FILE,ARG1=$ARG1,ARG2=$ARG2 /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/bash_scripts/file_single.sh"
 sbatch --job-name="$LOGGING-$ARG1-$ARG2" --time=23:30:00 --nodes=1 --cpus-per-task=$CPU --partition=single --output="/net/data.isilon/ag-saez/bq_pschaefer/LOGS/$LOGGING-$ARG1-$ARG2-%j.log" --export=FILE=$FILE,ARG1=$ARG1,ARG2=$ARG2 /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/bash_scripts/file_single.sh


# Example: Running synthetic for the first view and second algorithm with 24 CPUs
# bash /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/bash_scripts/call_single.sh benchmark/synthetic.R 1 2 24


