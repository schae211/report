#!/bin/bash
#SBATCH --job-name=merfish_preoptic
#SBATCH -t 23:30:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=24
#SBATCH --partition=single
#SBATCH --output=/net/data.isilon/ag-saez/bq_pschaefer/LOGS/merfish_preoptic_%j.log

# Append conda to PATH
source /home/bq_pschaefer/.bashrc
export PATH="/net/data.isilon/ag-saez/bq_pschaefer/SOFTWARE/miniconda3/bin:$PATH"

# Actiavte my conda environment
conda activate misty_benchmark

# Run Rscript
Rscript /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/benchmark/std_merfish_preoptic.R $1

