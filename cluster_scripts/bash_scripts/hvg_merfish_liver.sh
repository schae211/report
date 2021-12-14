#!/bin/bash
#SBATCH --job-name=mer_liver
#SBATCH -t 23:30:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --partition=single
#SBATCH --output=/net/data.isilon/ag-saez/bq_pschaefer/LOGS/mer_liver_%j.log

# Append conda to PATH
source /home/bq_pschaefer/.bashrc
export PATH="/net/data.isilon/ag-saez/bq_pschaefer/SOFTWARE/miniconda3/bin:$PATH"

# Actiavte my conda environment
conda activate misty_benchmark

# Run Rscript
Rscript /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/benchmark/hvg_merfish_liver.R $1

