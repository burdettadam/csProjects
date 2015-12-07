//
//  main.cpp
//
//  Created by Adam Burdett on 9/29/15.
//
// the spec says to do some different nodes, only do power of 2 node structure.

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <mpi.h>
#include <math.h>
#include <string.h>
#include <stdbool.h>
#define VECSIZE 1408 // numbers on each node?
bool mediansPivot = false;
bool medianPivot = false;
bool randomPivot = true;
bool meanPivot = false;
//http://rosettacode.org/wiki/Array_concatenation#C
#define ARRAY_CONCAT(TYPE, A, An, B, Bn) \
  (TYPE *)array_concat((const void *)(A), (An), (const void *)(B), (Bn), sizeof(TYPE));

int cmpfunc (const void * a, const void * b)
{
   return ( *(int*)a - *(int*)b );
}

void *array_concat(const void *a, size_t an, const void *b, size_t bn, size_t s)
{
  char *p = malloc(s * (an + bn));
  memcpy(p, a, an*s);
  memcpy(p + an*s, b, bn*s);
  return p;
}
//https://en.wikiversity.org/wiki/C_Source_Code/Find_the_median_and_mean
float mean(int m, int a[]) {
    int sum=0, i;
    for(i=0; i<m; i++)
        sum+=a[i];
    return((float)sum/m);
}
int median(int n,  int x[]) {
   // printf("\n\n\n n = %d, \n\n\n",n);
    int pivot;
    if ( n == 1 ){
        pivot = x[0];
    }
    else if ( n == 0){
        pivot = 0.0;
    }
    else{
  //      for(int i=0; i<n; i++)
  //          printf("[%d]=%ld ",i,x[i]);
        if(n%2==0) {
            // if there is an even number of elements, return mean of the two elements in the middle
            pivot = ((x[n/2] + x[n/2 - 1]) / 2.0 );
        } else {
            // else return the element in the middle
            pivot = x[n/2];
        }
    }
//    printf("pivot %ld\n",pivot );
    return pivot;
}

double When()
{
    struct timeval tp;
    gettimeofday(&tp, NULL);
    return ((double) tp.tv_sec + (double) tp.tv_usec * 1e-6);
}

int main(int argc, char *argv[])
{
    // mpi book keeping -----------
    int iproc, i, iter;
    int nproc;
    int number_amount;
    int membershipKey;
    int rank1,rank2,newSize;
    int rank;
    int numdim;
    int pivot;
    char host[255], message[55];
    MPI_Status status;
    
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &nproc);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    
    gethostname(host,253);
    switch(nproc) {
        case 32: numdim = 5;break;
        case 16: numdim = 4;break;
        case 8: numdim = 3;break;
        case 4: numdim = 2;break;
        case 2: numdim = 1;break;
        case 1: numdim = 0;break;
    }
    // -------
    // Execution Time = MyPortionSortTime + NumSteps * (PivotSelection + Exchange + CompareData)
    // each process has an array of VECSIZE double: ain[VECSIZE]
     int ain[VECSIZE], *buf, *c = (int *) malloc(VECSIZE * sizeof(int));
    int size = VECSIZE;
    int alower[2*VECSIZE], aupper[2*VECSIZE];

    int myrank, root = 0;
    
    /* Intializes random number generator */
    srand(rank+5);
    double start = When(),MyPortionSortTime,randomfill = When(),randomfillend, MyPortionSortTimeend, MyPortion =0 , NumSteps = numdim, PivotSelection,PivotSel =0 ,PivotSelectionend,Exchange,Exchan = 0,Exchangeend,CompareData,CompareDa = 0,CompareDataend;

// Distribute the items evenly to all of the nodes.
        // fill with random numbers
        for(i = 0; i < VECSIZE; i++) {
            ain[i] = (rand()%1000)+1;
            //          printf("init proc %d [%d]=%d\n",myrank,i,ain[i]);
        }
        memcpy(c,ain,sizeof(ain));

        qsort(c, size, sizeof(int), cmpfunc); // Each node sorts the items it has using quicksort.
    
    
    MPI_Comm comm1 = MPI_COMM_WORLD, comm2, intercomm;
    rank2 = rank ;
    int lowerSize = 0 ,upperSize = 0;
    int *sub_avgs = NULL;
    randomfillend = When();
    for(int curdim = 0; curdim < numdim; curdim++ ) {
        PivotSelection = When();
        membershipKey = rank2 % 2; // creates two groups o and 1.
        MPI_Comm_split(comm1, membershipKey, rank2, &comm2);  // Break up the cube into two subcubes:
        MPI_Comm_rank(comm2,&rank2);
        

        if ( mediansPivot  ){
            if (rank == 0 ){
                sub_avgs =(int *) malloc(sizeof( int) * nproc);

            }
                pivot = median(size,c);
                MPI_Gather(&pivot, 1, MPI_INT, sub_avgs, 1, MPI_INT, 0, MPI_COMM_WORLD);
                if ( rank == 0){
                    pivot = median(nproc,sub_avgs);
                    free(sub_avgs);
                }
        }
        else if ( rank2 == 0 && (medianPivot || meanPivot || randomPivot)){// Node 0 broadcasts its median key K to the rest of the cube.
            if (meanPivot  ){
                pivot = mean(size,c);
            }
            else if (medianPivot ){
                pivot = median(size,c);
            }
            else if (randomPivot ){
            int randompiv = rand()%size ;
                pivot = c[randompiv];
            }
        }
        MPI_Bcast(&pivot,1,MPI_INT, 0, comm2);
        PivotSelectionend = When();
    CompareData = When();

        lowerSize = 0;
        upperSize = 0;
        for(i = 0; i < size; i++) {// Each node separates its items into two arrays : 
            if (c[i] <= pivot){//        keys <= K and 
                alower[lowerSize] = c[i];
                lowerSize ++;
            }
            else{//        keys > K
                aupper[upperSize] = c[i];
                upperSize ++;
            }
        }
    CompareDataend = When();

        Exchange = When();

        if (membershipKey == 0 ){ // lower world (left)
        MPI_Intercomm_create(comm2, 0, comm1, 1, 99, &intercomm);
//    Each node in the lower subcube sends its items whose keys are > K to its adjacent node in the upper subcube
            MPI_Send(aupper, upperSize, MPI_INT, rank2, 0, intercomm ); 
              MPI_Probe(rank2, 0, intercomm, &status);
              MPI_Get_count(&status, MPI_INT, &number_amount);
              buf = (int*)malloc(sizeof(int) * number_amount);
              MPI_Recv(buf, number_amount, MPI_INT, rank2, 0, intercomm, &status);
              free(buf);
              //Each node now merges together the group it just received 
            //    with the one it kept so that its items are one again sorted.
            free(c);
            c = ARRAY_CONCAT(int, alower, lowerSize, buf,number_amount);
            size = number_amount+lowerSize;
        }else{
        MPI_Intercomm_create(comm2, 0, comm1, 0, 99, &intercomm);
      //    Each node in the upper subcube sends its items whose keys are <= K to its adjacent node in the lower subcube
              MPI_Send(alower, lowerSize, MPI_INT, rank2, 0, intercomm ); 
              MPI_Probe(rank2, 0, intercomm, &status); // dinamically recive
              MPI_Get_count(&status, MPI_INT, &number_amount);
              buf = (int*)malloc(sizeof(int) * number_amount);
              MPI_Recv(buf, number_amount, MPI_INT, rank2, 0, intercomm, &status);
              free(buf);
            //Each node now merges together the group it just received 
            //    with the one it kept so that its items are one again sorted.
            free(c);
            c = ARRAY_CONCAT(int, aupper, upperSize, buf,number_amount);
            size = number_amount+upperSize;
        }
        Exchangeend = When();

        MyPortionSortTime = When();
        qsort(c, size, sizeof(int), cmpfunc); // Each node sorts the items it has using quicksort.
        MyPortionSortTimeend = When();
        comm1 = comm2; 
        MyPortion += MyPortionSortTimeend -MyPortionSortTime ;
        PivotSel += PivotSelectionend  - PivotSelection ;
        Exchan += Exchangeend - Exchange ;
        CompareDa += CompareDataend - CompareData ;
    }
    //   reduces answer not required for the lab

    MPI_Finalize(); // does not pass till everyone else as made it there...
    if(rank == root) {
        double end = When();
        printf("Time %f\n",end-start);
        printf("randomfill:%f MyPortionSortTime:%f  NumSteps:%f (PivotSelection:%f Exchange:%f CompareData:%f \n", randomfillend - randomfill, MyPortion/NumSteps , NumSteps ,PivotSel / NumSteps , Exchan / NumSteps , CompareDa / NumSteps );

    }
}
