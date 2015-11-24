Implement a parallel program to calculate the Mandelbrot set over a given range. You should center your image at
. Your image should be 28,000 pixels by 28,000 pixels.
. Your implementation should:
Use a master-worker paradigm with one node of the MPI group being a master and the rest being workers
Have each worker request more work from the master when he has completed his given work.
Experiment with different amounts of work given per request.
Report on speedup as the number of nodes increases for your optimal amount of work and put your results on the graphing site.
You may want to start with the code at https://github.com/danyshaanan/mandelbrot/blob/master/cpp/mandelbrot.cpp
I fixed a few bugs and you can find the modified code here
You should reduce all computed values to one node where you will write the image out to disk.  You dont need to include the disk writing time in your total time.
Write a 1-2 page report detailing your solution and include a graph of your performance results.
Submit your report through learningsuite along with the url for the git repository with your code.  You may consider the following outline:
Introduction – Define the problem
Approach – Describe your approach to the problem
Experimental Setup – Describe the differences between using MPI and MPI/openmp and why you think one would work better than another. 
Results – graphs, etc.
Conclusions
The following credit will be given for each part of the lab:

Create an MPI mandelbrot application. (60% of your grade)
Use Master Worker paradigm (30%)
Compare performance of different allocations from the master (10%)
Do something creative (10% extra credit)


