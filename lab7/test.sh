#!/bin/bash

#SBATCH --time=0:05:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --gres=gpu:1
#SBATCH --mem-per-cpu=22G   # memory per CPU core
#SBATCH -J "test1"   # job name

module load cuda/7.0.28


nvcc -o test test.cu
./test
