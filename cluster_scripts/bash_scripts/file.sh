#!/bin/bash

echo "File: $FILE"
echo "View: $VIEW"
echo "Alg: $ALG"

# Append conda to PATH
source /home/bq_pschaefer/.bashrc

# Actiavte my conda environment
conda activate misty_benchmark

# Run Rscript
echo "Rscript /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/$FILE $VIEW $ALG"
Rscript /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/$FILE $VIEW $ALG