#!/bin/bash

#SBATCH --time=00:10:00   # walltime
#SBATCH --nodes=256   # number of nodes
#SBATCH --mem-per-cpu=2024M   # memory per CPU core
#SBATCH -J "lab6"   # job name
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
mpicc -o lab6 mendels2Mpi.cpp  -O3
echo "2Th_lab6"
mpirun -np 2 lab6
echo "4Th_lab6"
mpirun -np 4 lab6
echo "8Th_lab6"
mpirun -np 8 lab6
echo "16Th_lab6"
mpirun -np 16 lab6
echo "24Th_lab6"
mpirun -np 24 lab6
echo "32Th_lab6"
mpirun -np 32 lab6
echo "64Th_lab6"
mpirun -np 64 lab6
echo "128Th_lab6"
mpirun -np 128 lab6
echo "256Th_lab6"
mpirun -np 256 lab6