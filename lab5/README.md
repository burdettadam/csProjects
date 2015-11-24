#hypercube parallel quicksort
---
Implement the hypercube parallel quicksort algorithm. Use random numbers to test your code. Every processor will generate n/p random integer numbers between 1 and 1000 and generate a pivot value for his piece of the problem.  A reduction will provide the global pivot value for that dimension.  Then exchange those numbers that are on the other side of the pivot across the current dimension of the hypercube using MPI.  Your algorithm is finished when each processor has a sorted list of numbers locally and the values are disjoint and contiguous as you go through the processors.
For pivot selection, try the following to see which is best in terms of execution time and balance: median of each subcube’s medians, median of each subcube root processor’s numbers, random value from the subcube root processor. To determine the best algorithm, you will need to run each test a number of times with different random numbers and using different sizes of processors and number of elements. Also, compare your results with the predicted results from this model. If your results don’t match, analyze why not and make appropriate changes to the model.

  Execution Time = MyPortionSortTime + NumSteps * (PivotSelection + Exchange + CompareData)

  Execution Time = n/p * log2(n/p) * CompareTime + log2(p) * ((latency + (1 * ElementSize)/bandwidth) + 2*(latency + (n * ElementSize)/(p*bandwidth) + (CompareTime * 2*n/p)

Record your times on the performance graphing site  for 10,000,000 integers.
Write a 1-2 page report detailing your solution and include a graph of your performance results.
Submit your report through learningsuite.You may consider the following outline:
Introduction – Define the problem
Approach – Describe your approach to the problem
Experimental Setup – Describe the differences between different pivot selection algorithms and why you think one would work better than another. 
Results – graphs, etc.
Conclusions
The following credit will be given for each part of the lab:

1. Create an MPI sorting application. (60% of your grade)
2. Compare the performance of 3 different pivot generation algorithms. (20% of your grade)
3. Create a model of your application performance and compare it to your experimental results (20%)
4. Do something creative (10% extra credit)
