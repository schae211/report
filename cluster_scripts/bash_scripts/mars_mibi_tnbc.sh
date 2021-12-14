#!/bin/bash
#SBATCH --job-name=mars_hyper
#SBATCH -t 23:50:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=24
#SBATCH --partition=single
#SBATCH --output=/net/data.isilon/ag-saez/bq_pschaefer/LOGS/mars_hyper%j.log

# Append conda to PATH
source /home/bq_pschaefer/.bashrc
export PATH="/net/data.isilon/ag-saez/bq_pschaefer/SOFTWARE/miniconda3/bin:$PATH"

# Actiavte my conda environment
conda activate misty_benchmark

# Run Rscript
Rscript /net/data.isilon/ag-saez/bq_pschaefer/SCRIPTS/hyperparameter/mars_mibi_tnbc.R $1

