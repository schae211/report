#!/bin/bash

echo "File: $FILE"
echo "Argument 1: $ARG1"
echo "Argument 2: $ARG2"

# Append conda to PATH
source /home/bq_pschaefer/.bashrc

# Actiavte my conda environment
conda activate misty_benchmark

# Set working directory to the report
cd /net/data.isilon/ag-saez/bq_pschaefer/report

# Run Rscript
echo "Rscript /net/data.isilon/ag-saez/bq_pschaefer/cluster_scripts/$FILE $ARG1 $ARG2"
Rscript /net/data.isilon/ag-saez/bq_pschaefer/cluster_scripts/$FILE $ARG1 $ARG2