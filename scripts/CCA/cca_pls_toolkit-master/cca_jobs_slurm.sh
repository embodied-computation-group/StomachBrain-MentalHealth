#!/bin/bash

# This is a template batch script to run a Matlab serial job under SLURM in 
# the cluster.
# ------------------------------------------------------------------------
# can run it as:
# sbatch cca_jobs_slurm.sh <matlab script>
# sbatch cca_jobs_slurm.sh RunCCA
#
# NB matlab script should have no extension
# ---------------------------------------------------
#  for more information on SLURM scheduling visit
#  https://slurm.schedmd.com/documentation.html 

# 1. Define a job name
#SBATCH --job-name=pls-cca

# 2. Define a name and location for your log files
#SBATCH --output=/home/leah/Git/connectivity_tools/toolboxes/matlab/cca_pls_toolkit-master/slurm_log/StomachBrainCCA/log_%A.out

# 3. Specify computational resources 
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=2G
#SBATCH --time=02:00:00

# 4. Specify the number of jobs to run (should be in an array)
#SBATCH --array=1-100

# 6. change working directory to toolbox folder
#    you don't need to do this if this file is still within the toolbox folder
cd /home/leah/Git/connectivity_tools/toolboxes/matlab/cca_pls_toolkit-master/

# 7. finally run the script
matlab -nodisplay -nodesktop -nojvm -nosplash -singleCompThread -r "$1"

