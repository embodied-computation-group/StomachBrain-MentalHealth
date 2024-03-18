#!/bin/bash  
#SBATCH --array=0-71 #specify how many times you want a job to run, we have a total of 7 array spaces
# everything below this line is optional, but are nice to have quality of life things  
#SBATCH --output=logs/gastro%A_%a.out
#SBATCH --error=logs/gastro%A_%a.err
#SBATCH --job-name=gastro3  # a nice readable name to give your job so you know what it is when you see it in the queue, instead of just numbers
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --time=0-01:30:00


echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
python reslice_smooth.py $SLURM_ARRAY_TASK_ID
python reslice_brainmask.py $SLURM_ARRAY_TASK_ID
