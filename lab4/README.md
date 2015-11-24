1. Redo the Hot Plate program using MPI with a 16384x16384 matrix.  The elements on the bottom row have a fixed temperature of 100 degrees. The elements on the top row and leftmost and rightmost columns have temperature of zero degrees, but there are no other constant cells.  But you still need to compute every non-constant cell and include every cell in your termination condition.  You dont need to compute the number of cells over 50 degrees for this lab.
2. Run your OpenMP, PThreads, and MPI programs on fsl.byu.edu and compare the results.
3. When running mpi jobs on fsl, the batch system will automatically set up the number of nodes and the machine list.  You just have to requestion a number of nodes instead of cores (--nodes=4).
4. Record your times on the performance graphing site .
5. Write a report describing the performance differences you noticed. You will be graded on your results as well as your writeup. Thus your report should be well written. You may consider the following outline:
  - Introduction – Define the problem
  - Approach – Describe your approach to each of the programs
  - Experimental Setup – Describe the machine environment you chose to run on and the performance analysis metrics you will use. Also what rules did you follow to eliminate noise in the performance analysis.
  - Results – graphs, etc.
  - Conclusions


Submit your report through learningsuite along with the url for the git repository with your code.
The following credit will be given for each part of the lab:

1. Create an MPI hotplate application. (60% of your grade)
2. Compare your performance to your openmp and pthreads code. (40% of your grade)
3. Do something creative (10% extra credit)
4. Rather than partitioning based on 1 dimension (rows), partition based on two dimensions (blocks).  Or do a non-blocking receive. (20% extra credit)
