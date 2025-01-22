#!/bin/bash
#SBATCH --nodes=1					                            # Requires a single node
#SBATCH --ntasks=1					                            # Run a single serial task
#SBATCH --cpus-per-task=16
#SBATCH --mem=20000
#SBATCH --time=600:00:00				                            # Time limit hh:mm:ss
#SBATCH -e /mnt/raid0/scratch/jobs/Leah_HeartBrain/error_batch_HeartBrain_-%A.log	            # Log error
#SBATCH -o /mnt/raid0/scratch/jobs/Leah_HeartBrain/output_batch_HeartBrain_-%A.log	            # Log output
#SBATCH --job-name=HeartBrain      			                    # Descriptive job name
##### END OF JOB DEFINITION  #####


matlab -batch "HeartBrain_spm_wrapper.m" -logfile batch_HeartBrain.log

# Run using screen
# screeen     open screen session
# screen
# sudo sbatch batch_HeartBrain.sh
# ** note screen ID
#
# To disconnect:
# screen -d screenID
#
# To reconnect:
# screen -r screenID