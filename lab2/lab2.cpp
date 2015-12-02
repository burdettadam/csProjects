#include <cstdlib>
#include <iostream>
#include <sys/time.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <pthread.h>
pthread_mutex_t mutexA;
//#define tableSize 16384
#define MAXTHREADS 24
#define num_threads 2
//#define tableSize 8192
#define tableSize 2048
//#define tableSize 1024
//#define tableSize 512
#define EPSILON  0.1
pthread_barrier_t   barrier; // barrier synchronization object
float** currentMatrix;
float** lastMatrix;
float** tmp;
int iterations;
int converged;

double count[tableSize];     // Contain the count found by each thread

typedef struct barrier_node {
        pthread_mutex_t count_lock;
        pthread_cond_t ok_to_proceed_up;
        int count;
} mylib_barrier_t_internal;

using namespace std;
double When()
{
    struct timeval tp;
    gettimeofday(&tp, NULL);
    return ((double) tp.tv_sec + (double) tp.tv_usec * 1e-6);
}
float fabs(float f)
{
    return (f > 0.0)? f : -f ;
}
void fillplate(float** current,float** old,){
   for (int row = 0 ; row < tableSize; row++ ) {
        for (int col = 0 ; col < tableSize; col++) {
            // the checks will slow you down alot....
            if (row == 0 || col == 0 || col == tableSize-1 ){
                current[row][col] = 0.0;
                old[row][col] = 0.0;
            }
            else if (row == (tableSize - 1) ){
                current[row][col] = 100.0;
                old[row][col] = 100.0;
            }
        }
    }
    
    for (int col = 0; col < 331 ; col++) {
        current[400][col]=100.0;
        old[400][col]=100.0;
    }

    
    // Every 20 rows = 100
    for(int row = 0; row < tableSize; row++) {
        if(( row % 20) == 0) {
            for(int col = 0; col < tableSize; col++) {
                current[row][col] = 100;
                old[row][col]=100;
            }
        }
    }
    // Every 20 cols = 0
    for(int col = 0; col < tableSize; col++) {
        if((col % 20) == 0) {
            for(int row = 0; row < tableSize; row++) {
                current[row][col] = 0;
                old[row][col]=0;
            }
        }
    }
    current[200][500]=100.0;
    old[200][500]=100.0;
}

void update(float** lastMatrix, float** currentMatrix, int start, int end) {
    int row,col;
    for ( row = start ; row < end ;row ++) {
      for ( col = 1 ; col < tableSize-1; col++) { // skip edges... could be a bug!!!!!!!!!!!!!
         pthread_mutex_lock (&mutexA);
         currentMatrix[row][col] =(( lastMatrix[row+1][col]//bottom
              + lastMatrix[row-1][col]//top
              + lastMatrix[row][col+1]//right
              + lastMatrix[row][col-1])//left
             + (4.0 * lastMatrix[row][col])) / 8.0;
         //xi,j (t) = ( xi+1,j (t-1) + xi-1,j(t-1) + xi,j+1(t-1) + xi,j-1(t-1) + 4 * xi,j(t-1))/8
         pthread_mutex_unlock(&mutexA);
        }
    }
}
void graterThanCount(int id , int start, int stop, float** currentMatrix ,float** lastMatrix){
   int my_count = 0 ;
   float average;
   for (int row = start ; row < stop; row++ ) {
        for (int col = 1 ; col < tableSize-1; col++) {
            average = (currentMatrix[i+1][j] + currentMatrix[i-1][j] + currentMatrix[i][j+1] + currentMatrix[i][j-1]) / 4;
            if (fabs(average - currentMatrix[row][col]) >= EPSILON )
            {
                my_count++;
            }
        }
   }
   count[id] = my_count; // store my_count in private slot
}

void *HotPlate(void *threadid)
{
  printf( "hi Im thread %d \n",(long)threadid );

   long tid;

   // get my part of array
    int s;
    int n, start, stop;
    int my_count = 0 ;
    
    n = (tableSize-1)/num_threads;  // number of elements to handle
   // Get thread's ID (value = 0 or 1 or 2..)
    //s = * (int *) threadid;
    tid = (long)threadid;
    s = tid;
    
   //  Locate the starting index
    start = s * n;      // Starting index
    
   //  Locate the ending index
    if ( s != (num_threads-1) )
    {
        stop = start + n;  // Ending index
    }
    else
    {
        stop = tableSize-1;      // Ending index // out of bounds error??
    }
    
    if (start == 0) {
        start = 1;
    }
  
   for (int i = 0; i < iterations; ++i)
   {
      pthread_barrier_wait (&barrier);
      update(lastMatrix, currentMatrix, start, stop);
      pthread_barrier_wait (&barrier);
      //check
      graterThanCount(tid, start, stop, currentMatrix, lastMatrix);
      pthread_barrier_wait (&barrier);
      /* Swap the pointers */
      if (tid == 0){
        tmp = currentMatrix;
        currentMatrix = lastMatrix;
        lastMatrix = tmp;
      }
   }
  pthread_barrier_wait (&barrier);
   //cout << "Hello World! Thread ID, " << tid << endl;
   pthread_exit(NULL);
}

int main()
{
   pthread_t threads[num_threads];
   int rc;
   long i;
   int counter;
   int fifCount;
   pthread_barrier_init (&barrier, NULL, num_threads);
  printf( "creating threads \n");
  currentMatrix = (float **)malloc((theSize + 2) * sizeof(float*));
  lastMatrix = (float **)malloc((theSize + 2) * sizeof(float*));
  for (i = 0; i < SIZE; i++) {
      currentMatrix[i] = (float*)malloc(SIZE * sizeof(float));
      lastMatrix[i] = (float*)malloc(SIZE * sizeof(float));
  }
  fillplate(&currentMatrix,&lastMatrix);
  iterations = 97;
  converged = 0;
   for( i=0; i < num_threads; i++ ){
      if(rc = pthread_create( &threads[i], NULL, HotPlate, (void *)i))
         {
            printf( "Cannot create thread\n");
            exit(1);
         }
   }
  //reduce count of > EPSILON 
  fifCount = 0;
  for(counter =0; counter< num_threads; counter++) {
    fifCount += count[counter];
  }
  end = When();
  printf("Total iterations: %d with %d > EPSILON\n", iterations, fifCount);
  printf("Total time: %d\n", (end - start));
  pthread_exit(NULL);
}
