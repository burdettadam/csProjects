#!/bin/bash

#SBATCH --time=00:10:00   # walltime
#SBATCH --nodes=24   # number of nodes
#SBATCH --mem-per-cpu=2024M   # memory per CPU core
#SBATCH -J "lab2"   # job name
#SBATCH --mail-user=burdettadam@gmail.com   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# Compatibility variables for PBS. Delete if not needed.
export PBS_NODEFILE=`/fslapps/fslutils/generate_pbs_nodefile`
export PBS_JOBID=$SLURM_JOB_ID
export PBS_O_WORKDIR="$SLURM_SUBMIT_DIR"
export PBS_QUEUE=batch


# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
echo "2Th_lab4"
mpirun -np 2 lab4
echo "4Th_lab4"
mpirun -np 4 lab4
echo "8Th_lab4"
mpirun -np 8 lab4
echo "16Th_lab4"
mpirun -np 16 lab4
echo "24Th_lab4"
mpirun -np 24 lab4
