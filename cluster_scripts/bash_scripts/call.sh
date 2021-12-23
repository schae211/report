#!/bin/bash

FILE=$1
echo "File: $FILE"
echo "View Iterations: $2"
echo "Alg Iterations: $3"

# Check whether the number of CPUs is given
if [[ $# -eq 4 ]]
then
    CPU=$4
else
    CPU=16
fi

echo "CPUs: $CPU"

# for how many views I have:
for VIEW in $(seq 1 $2)
do
  # how many functions do we have:
  for ALG in $(seq 1 $3)
  do
     LOGGING=${FILE////-}
     echo "sbatch --job-name="$LOGGING-$VIEW-$ALG" --time=23:30:00 --nodes=1 --cpus-per-task=$CPU --partition=single --output="/net/data.isilon/ag-saez/bq_pschaefer/LOGS/$LOGGING-$VIEW-$ALG-%j.log" --export=FILE=$FILE,VIEW=$VIEW,ALG=$ALG /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/bash_scripts/file.sh"
     sbatch --job-name="$LOGGING-$VIEW-$ALG" --time=23:30:00 --nodes=1 --cpus-per-task=$CPU --partition=single --output="/net/data.isilon/ag-saez/bq_pschaefer/LOGS/$LOGGING-$VIEW-$ALG-%j.log" --export=FILE=$FILE,VIEW=$VIEW,ALG=$ALG /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/bash_scripts/file.sh
     sleep 5s
  done
done

# Example: Running synthetic for 3 views and each time with 8 algorithms with 24 CPUs
# bash /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/bash_scripts/call.sh benchmark/synthetic.R 3 8 24

# Check this test out
# FILE=benchmark/synthetic.R;VIEW=1;ALG=1;CPU=16
# LOGGING=${FILE////-}
# working: sbatch --job-name="$FILE-$VIEW-$ALG-%j" --time=23:30:00 --nodes=1 --cpus-per-task=$CPU --partition=single --error="%j.err" --output="%j.log" --export=FILE=$FILE,VIEW=$VIEW,ALG=$ALG /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/bash_scripts/file.sh
# sbatch --job-name="$FILE-$VIEW-$ALG-%j" --time=23:30:00 --nodes=1 --cpus-per-task=$CPU --partition=single --output="$FILE.log" --export=FILE=$FILE,VIEW=$VIEW,ALG=$ALG /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/bash_scripts/file.sh
# sbatch --job-name=test --time=23:30:00 --nodes=1 --cpus-per-task=16 --partition=single --error="/net/data.isilon/ag-saez/bq_pschaefer/LOGS/test.err" --output="/net/data.isilon/ag-saez/bq_pschaefer/LOGS/test.log" --export=FILE=$FILE,VIEW=$VIEW,ALG=$ALG /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/bash_scripts/test.sh

