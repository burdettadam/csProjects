#!/bin/bash

#SBATCH --time=00:20:00   # walltime
#SBATCH --ntasks=24   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=2024M   # memory per CPU core
#SBATCH -J "lab1"   # job name
#SBATCH --mail-user=burdettadam@gmail.com   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# Compatibility variables for PBS. Delete if not needed.
export PBS_NODEFILE=`/fslapps/fslutils/generate_pbs_nodefile`
export PBS_JOBID=$SLURM_JOB_ID
export PBS_O_WORKDIR="$SLURM_SUBMIT_DIR"
export PBS_QUEUE=batch

# Set the max number of threads to use for programs using OpenMP. Should be <= ppn. Does nothing if the program doesn't use OpenMP.
export OMP_NUM_THREADS=2

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
# makes sure to compile with -O3  and -fopenmp like this g++ -fopenmp -O3 main.cpp hotPlateSimulator.h hotPlateSimulator.cpp
./lab1
export OMP_NUM_THREADS=4
./lab1
export OMP_NUM_THREADS=8
./lab1
export OMP_NUM_THREADS=16
./lab1
export OMP_NUM_THREADS=24
./lab1