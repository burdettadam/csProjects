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
echo "2Th_lab5"
mpirun -np 2 lab5m
echo "2Th_lab5"
mpirun -np 2 lab5m
echo "2Th_lab5"
mpirun -np 2 lab5m
echo "2Th_lab5"
mpirun -np 2 lab5m
echo "2Th_lab5"
mpirun -np 2 lab5m
echo "2Th_lab5"
mpirun -np 2 lab5m
echo "2Th_lab5"
mpirun -np 2 lab5m
echo "2Th_lab5"
mpirun -np 2 lab5m
echo "2Th_lab5"
mpirun -np 2 lab5m
echo "2Th_lab5"
mpirun -np 2 lab5m

echo "4Th_lab5"
mpirun -np 4 lab5m
echo "4Th_lab5"
mpirun -np 4 lab5m
echo "4Th_lab5"
mpirun -np 4 lab5m
echo "4Th_lab5"
mpirun -np 4 lab5m
echo "4Th_lab5"
mpirun -np 4 lab5m
echo "4Th_lab5"
mpirun -np 4 lab5m
echo "4Th_lab5"
mpirun -np 4 lab5m
echo "4Th_lab5"
mpirun -np 4 lab5m
echo "4Th_lab5"
mpirun -np 4 lab5m
echo "4Th_lab5"
mpirun -np 4 lab5m


echo "8Th_lab5"
mpirun -np 8 lab5m
echo "8Th_lab5"
mpirun -np 8 lab5m
echo "8Th_lab5"
mpirun -np 8 lab5m
echo "8Th_lab5"
mpirun -np 8 lab5m
echo "8Th_lab5"
mpirun -np 8 lab5m
echo "8Th_lab5"
mpirun -np 8 lab5m
echo "8Th_lab5"
mpirun -np 8 lab5m
echo "8Th_lab5"
mpirun -np 8 lab5m
echo "8Th_lab5"
mpirun -np 8 lab5m
echo "8Th_lab5"
mpirun -np 8 lab5m

echo "16Th_lab5"
mpirun -np 16 lab5m
echo "16Th_lab5"
mpirun -np 16 lab5m
echo "16Th_lab5"
mpirun -np 16 lab5m
echo "16Th_lab5"
mpirun -np 16 lab5m
echo "16Th_lab5"
mpirun -np 16 lab5m
echo "16Th_lab5"
mpirun -np 16 lab5m
echo "16Th_lab5"
mpirun -np 16 lab5m
echo "16Th_lab5"
mpirun -np 16 lab5m
echo "16Th_lab5"
mpirun -np 16 lab5m
echo "16Th_lab5"
mpirun -np 16 lab5m

echo "24Th_lab5"
mpirun -np 24 lab5m
echo "24Th_lab5"
mpirun -np 24 lab5m
echo "24Th_lab5"
mpirun -np 24 lab5m
echo "24Th_lab5"
mpirun -np 24 lab5m
echo "24Th_lab5"
mpirun -np 24 lab5m
echo "24Th_lab5"
mpirun -np 24 lab5m
echo "24Th_lab5"
mpirun -np 24 lab5m
echo "24Th_lab5"
mpirun -np 24 lab5m
echo "24Th_lab5"
mpirun -np 24 lab5m
echo "24Th_lab5"
mpirun -np 24 lab5m

echo "2Th_lab5"
mpirun -np 2 lab5ms
echo "2Th_lab5"
mpirun -np 2 lab5ms
echo "2Th_lab5"
mpirun -np 2 lab5ms
echo "2Th_lab5"
mpirun -np 2 lab5ms
echo "2Th_lab5"
mpirun -np 2 lab5ms
echo "2Th_lab5"
mpirun -np 2 lab5ms
echo "2Th_lab5"
mpirun -np 2 lab5ms
echo "2Th_lab5"
mpirun -np 2 lab5ms
echo "2Th_lab5"
mpirun -np 2 lab5ms
echo "2Th_lab5"
mpirun -np 2 lab5ms

echo "4Th_lab5"
mpirun -np 4 lab5ms
echo "4Th_lab5"
mpirun -np 4 lab5ms
echo "4Th_lab5"
mpirun -np 4 lab5ms
echo "4Th_lab5"
mpirun -np 4 lab5ms
echo "4Th_lab5"
mpirun -np 4 lab5ms
echo "4Th_lab5"
mpirun -np 4 lab5ms
echo "4Th_lab5"
mpirun -np 4 lab5ms
echo "4Th_lab5"
mpirun -np 4 lab5ms
echo "4Th_lab5"
mpirun -np 4 lab5ms
echo "4Th_lab5"
mpirun -np 4 lab5ms


echo "8Th_lab5"
mpirun -np 8 lab5ms
echo "8Th_lab5"
mpirun -np 8 lab5ms
echo "8Th_lab5"
mpirun -np 8 lab5ms
echo "8Th_lab5"
mpirun -np 8 lab5ms
echo "8Th_lab5"
mpirun -np 8 lab5ms
echo "8Th_lab5"
mpirun -np 8 lab5ms
echo "8Th_lab5"
mpirun -np 8 lab5ms
echo "8Th_lab5"
mpirun -np 8 lab5ms
echo "8Th_lab5"
mpirun -np 8 lab5ms
echo "8Th_lab5"
mpirun -np 8 lab5ms

echo "16Th_lab5"
mpirun -np 16 lab5ms
echo "16Th_lab5"
mpirun -np 16 lab5ms
echo "16Th_lab5"
mpirun -np 16 lab5ms
echo "16Th_lab5"
mpirun -np 16 lab5ms
echo "16Th_lab5"
mpirun -np 16 lab5ms
echo "16Th_lab5"
mpirun -np 16 lab5ms
echo "16Th_lab5"
mpirun -np 16 lab5ms
echo "16Th_lab5"
mpirun -np 16 lab5ms
echo "16Th_lab5"
mpirun -np 16 lab5ms
echo "16Th_lab5"
mpirun -np 16 lab5ms

echo "24Th_lab5"
mpirun -np 24 lab5ms
echo "24Th_lab5"
mpirun -np 24 lab5ms
echo "24Th_lab5"
mpirun -np 24 lab5ms
echo "24Th_lab5"
mpirun -np 24 lab5ms
echo "24Th_lab5"
mpirun -np 24 lab5ms
echo "24Th_lab5"
mpirun -np 24 lab5ms
echo "24Th_lab5"
mpirun -np 24 lab5ms
echo "24Th_lab5"
mpirun -np 24 lab5ms
echo "24Th_lab5"
mpirun -np 24 lab5ms
echo "24Th_lab5"
mpirun -np 24 lab5ms


echo "2Th_lab5"
mpirun -np 2 lab5r
echo "2Th_lab5"
mpirun -np 2 lab5r
echo "2Th_lab5"
mpirun -np 2 lab5r
echo "2Th_lab5"
mpirun -np 2 lab5r
echo "2Th_lab5"
mpirun -np 2 lab5r
echo "2Th_lab5"
mpirun -np 2 lab5r
echo "2Th_lab5"
mpirun -np 2 lab5r
echo "2Th_lab5"
mpirun -np 2 lab5r
echo "2Th_lab5"
mpirun -np 2 lab5r
echo "2Th_lab5"
mpirun -np 2 lab5r

echo "4Th_lab5"
mpirun -np 4 lab5r
echo "4Th_lab5"
mpirun -np 4 lab5r
echo "4Th_lab5"
mpirun -np 4 lab5r
echo "4Th_lab5"
mpirun -np 4 lab5r
echo "4Th_lab5"
mpirun -np 4 lab5r
echo "4Th_lab5"
mpirun -np 4 lab5r
echo "4Th_lab5"
mpirun -np 4 lab5r
echo "4Th_lab5"
mpirun -np 4 lab5r
echo "4Th_lab5"
mpirun -np 4 lab5r
echo "4Th_lab5"
mpirun -np 4 lab5r


echo "8Th_lab5"
mpirun -np 8 lab5r
echo "8Th_lab5"
mpirun -np 8 lab5r
echo "8Th_lab5"
mpirun -np 8 lab5r
echo "8Th_lab5"
mpirun -np 8 lab5r
echo "8Th_lab5"
mpirun -np 8 lab5r
echo "8Th_lab5"
mpirun -np 8 lab5r
echo "8Th_lab5"
mpirun -np 8 lab5r
echo "8Th_lab5"
mpirun -np 8 lab5r
echo "8Th_lab5"
mpirun -np 8 lab5r
echo "8Th_lab5"
mpirun -np 8 lab5r

echo "16Th_lab5"
mpirun -np 16 lab5r
echo "16Th_lab5"
mpirun -np 16 lab5r
echo "16Th_lab5"
mpirun -np 16 lab5r
echo "16Th_lab5"
mpirun -np 16 lab5r
echo "16Th_lab5"
mpirun -np 16 lab5r
echo "16Th_lab5"
mpirun -np 16 lab5r
echo "16Th_lab5"
mpirun -np 16 lab5r
echo "16Th_lab5"
mpirun -np 16 lab5r
echo "16Th_lab5"
mpirun -np 16 lab5r
echo "16Th_lab5"
mpirun -np 16 lab5r

echo "24Th_lab5"
mpirun -np 24 lab5r
echo "24Th_lab5"
mpirun -np 24 lab5r
echo "24Th_lab5"
mpirun -np 24 lab5r
echo "24Th_lab5"
mpirun -np 24 lab5r
echo "24Th_lab5"
mpirun -np 24 lab5r
echo "24Th_lab5"
mpirun -np 24 lab5r
echo "24Th_lab5"
mpirun -np 24 lab5r
echo "24Th_lab5"
mpirun -np 24 lab5r
echo "24Th_lab5"
mpirun -np 24 lab5r
echo "24Th_lab5"
mpirun -np 24 lab5r


echo "2Th_lab5"
mpirun -np 2 lab5mn
echo "2Th_lab5"
mpirun -np 2 lab5mn
echo "2Th_lab5"
mpirun -np 2 lab5mn
echo "2Th_lab5"
mpirun -np 2 lab5mn
echo "2Th_lab5"
mpirun -np 2 lab5mn
echo "2Th_lab5"
mpirun -np 2 lab5mn
echo "2Th_lab5"
mpirun -np 2 lab5mn
echo "2Th_lab5"
mpirun -np 2 lab5mn
echo "2Th_lab5"
mpirun -np 2 lab5mn
echo "2Th_lab5"
mpirun -np 2 lab5mn

echo "4Th_lab5"
mpirun -np 4 lab5mn
echo "4Th_lab5"
mpirun -np 4 lab5mn
echo "4Th_lab5"
mpirun -np 4 lab5mn
echo "4Th_lab5"
mpirun -np 4 lab5mn
echo "4Th_lab5"
mpirun -np 4 lab5mn
echo "4Th_lab5"
mpirun -np 4 lab5mn
echo "4Th_lab5"
mpirun -np 4 lab5mn
echo "4Th_lab5"
mpirun -np 4 lab5mn
echo "4Th_lab5"
mpirun -np 4 lab5mn
echo "4Th_lab5"
mpirun -np 4 lab5mn


echo "8Th_lab5"
mpirun -np 8 lab5mn
echo "8Th_lab5"
mpirun -np 8 lab5mn
echo "8Th_lab5"
mpirun -np 8 lab5mn
echo "8Th_lab5"
mpirun -np 8 lab5mn
echo "8Th_lab5"
mpirun -np 8 lab5mn
echo "8Th_lab5"
mpirun -np 8 lab5mn
echo "8Th_lab5"
mpirun -np 8 lab5mn
echo "8Th_lab5"
mpirun -np 8 lab5mn
echo "8Th_lab5"
mpirun -np 8 lab5mn
echo "8Th_lab5"
mpirun -np 8 lab5mn

echo "16Th_lab5"
mpirun -np 16 lab5mn
echo "16Th_lab5"
mpirun -np 16 lab5mn
echo "16Th_lab5"
mpirun -np 16 lab5mn
echo "16Th_lab5"
mpirun -np 16 lab5mn
echo "16Th_lab5"
mpirun -np 16 lab5mn
echo "16Th_lab5"
mpirun -np 16 lab5mn
echo "16Th_lab5"
mpirun -np 16 lab5mn
echo "16Th_lab5"
mpirun -np 16 lab5mn
echo "16Th_lab5"
mpirun -np 16 lab5mn
echo "16Th_lab5"
mpirun -np 16 lab5mn

echo "24Th_lab5"
mpirun -np 24 lab5mn
echo "24Th_lab5"
mpirun -np 24 lab5mn
echo "24Th_lab5"
mpirun -np 24 lab5mn
echo "24Th_lab5"
mpirun -np 24 lab5mn
echo "24Th_lab5"
mpirun -np 24 lab5mn
echo "24Th_lab5"
mpirun -np 24 lab5mn
echo "24Th_lab5"
mpirun -np 24 lab5mn
echo "24Th_lab5"
mpirun -np 24 lab5mn
echo "24Th_lab5"
mpirun -np 24 lab5mn
echo "24Th_lab5"
mpirun -np 24 lab5mn