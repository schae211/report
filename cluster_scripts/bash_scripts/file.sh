#!/bin/bash

echo "File: $FILE"
echo "View: $VIEW"
echo "Alg: $ALG"

# Append conda to PATH
source /home/bq_pschaefer/.bashrc

# Actiavte my conda environment
conda activate misty_benchmark

# Set working directory to the report
cd /net/data.isilon/ag-saez/bq_pschaefer/report

# Run Rscript
echo "Rscript /net/data.isilon/ag-saez/bq_pschaefer/report/cluster_scripts/$FILE $VIEW $ALG"
Rscript /net/data.isilon/ag-saez/bq_pschaefer/report/cluster_scripts/$FILE $VIEW $ALG