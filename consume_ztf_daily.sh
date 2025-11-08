#!/bin/bash
#SBATCH --job-name=boom_slurm_job
#SBATCH --partition boom
#SBATCH --time=23:00:00
#SBATCH --ntasks=35
#SBATCH --output=/dev/null

# replace xxxxxxx with your user name
#SBATCH --chdir=/users/3/xxxxxxx/boom

mkdir -p logs/slurm
exec >"logs/slurm/consume_ztf_daily_$(date -u "+%Y-%m-%d").out" 2>&1

if ! "apptainer/scripts/healthcheck/valkey-healthcheck.sh" 3; then
    exit 1
fi

./apptainer.sh start boom ztf "$(date -d "+1 day" +%Y%m%d)" public
./apptainer.sh start consumer ztf "$(date -d "+1 day" +%Y%m%d)" partnership
./apptainer.sh start consumer ztf "$(date -d "+1 day" +%Y%m%d)" caltech

sleep 79200 # 22h