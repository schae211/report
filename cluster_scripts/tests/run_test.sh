#!/bin/bash
#SBATCH --job-name=test
#SBATCH -t 10:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --partition=single
#SBATCH --output=/net/data.isilon/ag-saez/bq_pschaefer/LOGS/test_%j.log
#SBATCH --error=/net/data.isilon/ag-saez/bq_pschaefer/ERROR/test_%j.err

# Append conda to PATH
source /home/bq_pschaefer/.bashrc
export PATH="/net/data.isilon/ag-saez/bq_pschaefer/SOFTWARE/miniconda3/bin:$PATH"

# Actiavte my conda environment
conda activate misty_benchmark

# Run Rscript
Rscript /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/tests/$1
