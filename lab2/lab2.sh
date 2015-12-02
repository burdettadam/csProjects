#!/bin/bash

#SBATCH --time=02:00:00   # walltime
#SBATCH --ntasks=24   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=1024M   # memory per CPU core
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

# Set the max number of threads to use for programs using OpenMP. Should be <= ppn. Does nothing if the program doesn't use OpenMP.
export OMP_NUM_THREADS=16

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
echo "LinearB_1Th_lab2"
./LinearB_1Th_lab2
echo "LinearB_2Th_lab2"
./LinearB_2Th_lab2
echo "LinearB_4Th_lab2"
./LinearB_4Th_lab2
echo "LinearB_8Th_lab2"
./LinearB_8Th_lab2
echo "LinearB_16Th_lab2"
./LinearB_16Th_lab2
echo "LinearB_24Th_lab2"
./LinearB_24Th_lab2

echo "LogB_1Th_lab2"
./LogB_1Th_lab2
echo "LogB_1Th_lab2"
./LogB_2Th_lab2
echo "LogB_1Th_lab2"
./LogB_4Th_lab2
echo "LogB_1Th_lab2"
./LogB_8Th_lab2
echo "LogB_1Th_lab2"
./LogB_16Th_lab2
echo "LogB_1Th_lab2"
./LogB_24Th_lab2

echo "SysB_1Th_lab2"
./SysB_1Th_lab2
echo "SysB_2Th_lab2"
./SysB_2Th_lab2
echo "SysB_4Th_lab2"
./SysB_4Th_lab2
echo "SysB_8Th_lab2"
./SysB_8Th_lab2
echo "SysB_16Th_lab2"
./SysB_16Th_lab2
echo "SysB_24Th_lab2"
./SysB_24Th_lab2