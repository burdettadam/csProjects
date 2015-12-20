#!/bin/bash

#SBATCH --time=0:10:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --gres=gpu:1
#SBATCH --mem-per-cpu=1024M   # memory per CPU core
#SBATCH -J "test1"   # job name

module load cuda/7.0.28


nvcc -o lab7 2dkernal.cu
./lab7