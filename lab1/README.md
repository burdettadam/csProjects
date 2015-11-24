The problem is to determine the temperature distribution on a two-dimensional plate with constant boundary conditions. Use a 8192 X 8192 grid. The elements on the boundaries have fixed temperatures. The elements on the bottom row have a fixed temperature of 100 degrees. The elements on the top row and leftmost and rightmost columns have temperature of zero degrees. Additionally, row 400 columns 0 through 330 are fixed at 100 degrees. A cell at row 200, column 500 also is fixed at 100 degrees. All other cells start with a temperature of 50 degrees. The job of the algorithm is to find the steady-state temperature distribution of the interior elements. “Steady state means that the temperature of any cell is equal to the average of the temperatures of its four neighbors on the north, south, east, and west directions. We will say that they are equal if the difference is less than .1 degree. Use single precision floating point values for your temperatures.
Report your absolute time for execution of the program. Additionally, report the number of iterations necessary to come to a steady state and the number of cells that had a temperature greater than 50 degrees in the steady state.
To calculate the new temperature value of a cell at time t, use the following formula:
xi,j(t) = (xi+1,j(t-1) + xi-1,j(t-1) + xi,j+1(t-1) + xi,j-1(t-1) + 4 * xi,j(t-1))/8
(Notice that you will need two copies of the array in order to perform this computation.  You can swap them each iteration.)
Use the following condition for steady state:

ABS(xi,j(t) – (xi+1,j(t) + xi-1,j(t) + xi,j+1(t) + xi,j-1(t))/4 ) < 0.1

Timing calls should be made as the first and nearly last executable lines of code in your program.
The following steps should be followed to complete the lab.
1. Program a serial solution to the Hot Plate problem and then email the TA (byu.cs484ta@gmail.com) the number of iterations it takes to reach a steady state. Do not proceed until the TA responds, telling you that you have a correct serial implementation.
2. Parallelize your solution using OpenMP directives. Run your solution on fsl.byu.edu and determine the execution time for 1, 2, 4, 8, and 16 cores. Schedule your job on a node with 16 cores,  and then export OMP_NUM_THREADS=16 and run your program and then export OMP_NUM_THREADS=8 and run your program, etc. all in the same slurm script.
3. Try something of your own design in addition to the lab requirements.  
4. 20% of your lab points will come from the creative part of the lab.  For example:
  experiment with different parallelization strategies.  
  Try different ways of allocating a 2 dimensional array.  
  Try different scheduling strategies (dynamic vs static)

Write a 1-2 page report detailing your solution and include a graph of your performance results. Your report should include the following sections
Title, Author centered and bold
Introduction - What are you trying to do, and how do you interpret the assignment?
- Methods - How did you do it and what did you try.  Include things that didnt work and reasoning for why you took a particular approach.
- Results - Graphs of your performance under each strategy you tried.  Discuss why different design decisions resulted in the performance you achieved.
- Creative Contribution - What did you try and what were the performance results?
- Conclusions - What do you conclude about parallel programming from your experiences in this lab?
Submit this report through learningsuite along with the url for the git repository with your code.
