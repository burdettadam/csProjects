Reprogram the Hot Plate solution with 16k by 16k grid using PThreads, shared memory, and synchronization primitives. Run your solution on marylou and determine the execution time for 1, 2, 4, 8, and 16 processors (24 if you can get it).  In addition to the other criteria, set every 20th row to 100 degrees and every 20th column to 0 degrees.  You cant assume that a cell will remain in steady state once it has reached steady state.  

You need to compute the number of cells over 50 degrees for every iteration and create a figure plotting the number of cells over 50 degrees for each iteration in your report.

Make sure you use volatile variables for spin loops where one thread will be modifying a variable that another thread is reading.  Otherwise, the compiler may optimize out the read.

This sample code may help you to develop your barriers.

Credit
The following credit will be given for each part of the lab:

Compare your performance to your OpenMP Solution. (60% of your grade)
Compare your performance using the phthread_barrier, a linear barrier and a log barrier. (20% of your grade)
Create a more efficient barrier and compare your performance (20% of your grade)
Deliverables
Report your times on the plotting page
Write a 1-2 page report detailing your solution and include a graph of your performance results.
Title, Author centered and bold
Introduction - What are you trying to do, and how do you interpret the assignment?
Methods - How did you do it and what did you try.  Include things that didnt work and reasoning for why you took a particular approach.
Results - Graphs of your performance under each strategy you tried.  Discuss why different design decisions resulted in the performance you achieved.
Creative Contribution - What did you try and what were the performance results?
Conclusions - What do you conclude about parallel programming from your experiences in this lab?
Submit your report through learningsuite along with the URL for the git repository for your code.
