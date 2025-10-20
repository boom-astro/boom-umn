#!/bin/bash
#SBATCH --job-name=boom_slurm_job
#SBATCH --partition boom
#SBATCH --time=0-23:00:00
#SBATCH --ntasks=35

cd boom || exit 1
mkdir -p logs/slurm

exec >"logs/slurm/consume_ztf_daily_$(date -u "+%Y-%m-%d").out" 2>&1

./apptainer.sh start boom ztf "$(date -d "+1 day" +%Y%m%d)" public

sleep 79200 # 22h