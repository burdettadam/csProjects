//
//  main.cpp
//  object_hotplate
//
//  Created by Adam Burdett on 9/11/15.
//  parellel structured after this tutorial
//  http://www.mathcs.emory.edu/~cheung/Courses/561/Syllabus/91-pthreads/common-prog-stru.html
//

#include <iostream>
#include <sys/time.h>

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include "pthread.h"
pthread_mutex_t mutexA;
//#define tableSize 16384
#define MAXTHREADS 24
#define num_threads 2
//#define tableSize 8192
#define tableSize 2048
//#define tableSize 1024
//#define tableSize 512



std::vector< std::vector<float> > currentMatrix(tableSize, std::vector<float> (tableSize,50))
, lastMatrix (tableSize, std::vector<float> (tableSize,50));//, tempMatrix (tableSize, vector<float> (tableSize,50));
double count[tableSize];     // Contain the count found by each thread
//#include <omp.h>

extern std::vector< std::vector<float> > currentMatrix, lastMatrix;
extern double count[tableSize];


class Simulator{
public:
    void fillPlateWithTemperature( std::vector< std::vector<float> >& current,std::vector< std::vector<float> >& old);
    void steadyState();
    float checkSteadyState( std::vector< std::vector<float> >& current,std::vector< std::vector<float> >& old);
    int countGreaterFifty(std::vector< std::vector<float> >& current);
    double When();
};


int main(int argc, const char * argv[]) {
    // insert code here...
    Simulator simulator;
    double start =0.0, end = 0.0,time=0.0;
    start = simulator.When();
    int iterations = 0 , greaterThanFifty = 0 ;
    float delta = 3.0;
    pthread_mutex_init(&mutexA, NULL);
    
    simulator.fillPlateWithTemperature(currentMatrix,lastMatrix);
    
    while (delta > 0.0500) {
        //printf("%f %d\n",delta,iterations);
        //tempMatrix = lastMatrix;
        //lastMatrix = currentMatrix;
        //currentMatrix =tempMatrix;
        currentMatrix.swap(lastMatrix);// do I need to pass as reference?
        simulator.steadyState();
        delta = simulator.checkSteadyState(currentMatrix, lastMatrix);
        iterations++;
        greaterThanFifty = simulator.countGreaterFifty(currentMatrix);
    }
    //pthread_mutex_destroy(&mutexA);
    
    end = simulator.When();
    time = end - start;
    
    
    printf("ran in %f seconds, %d iterations, with %d cells > 50 degrees.\n",time,iterations,greaterThanFifty);
    
    return 0;
}






/// hotplate.cpp


double Simulator::When()
{
    struct timeval tp;
    gettimeofday(&tp, NULL);
    return ((double) tp.tv_sec + (double) tp.tv_usec * 1e-6);
}

void Simulator::fillPlateWithTemperature( std::vector< std::vector<float> >& current,std::vector< std::vector<float> >& old)
{
    
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
    
    
    //new standard
    // for (int row = 0 ; row < tableSize; row++ ) {
    //     for (int col = 20 ; col < tableSize; col+=20) {
    //         current[row][col] = 0.0;
    //         old[row][col] = 0.0;
    //     }
    // }
    // vector<float> hundred (tableSize,100);
    // for (int row = 20 ; row < tableSize; row+=20 ) {
    //     current[row] = hundred;
    //     old[row]= hundred;
    // }
    
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


void *steadyStateWorker(void *arg)
{
    int s;
    int n, start, stop;
    int my_count = 0 ;
    
    n = (tableSize-1)/num_threads;	// number of elements to handle
    
    /* ------------------------------------
     Get thread's ID (value = 0 or 1 or 2..)
     ------------------------------------ */
    s = * (int *) arg;
    
    /* ---------------------------------
     Locate the starting index
     --------------------------------- */
    start = s * n;		// Starting index
    
    /* ---------------------------------
     Locate the ending index
     --------------------------------- */
    if ( s != (num_threads-1) )
    {
        stop = start + n;	// Ending index
    }
    else
    {
        stop = tableSize-1;		// Ending index // out of bounds error??
    }
    
    if (start == 0) {
        start = 1;
    }
    
    for (int row = start ; row < stop ;row ++) {
        for (int col = 1 ; col < tableSize-1; col++) {
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
    
    return(NULL);     /* Thread exits (dies) */
}



void Simulator::steadyState( ){
    int    start[tableSize-1];   // Contain starting array index of each thread
    pthread_t threadStructs[MAXTHREADS];
    
    // -----------------------------------
    // Create worker threads....
    // -----------------------------------
    for (int i = 0; i < num_threads; i = i + 1)
    {
        start[i] = i;     // Pass ID to thread in a private variable
        
        if ( pthread_create(&threadStructs[i], NULL, steadyStateWorker, (void *)&start[i]) )
        {
            printf( "Cannot create thread\n");
            exit(1);
        }
    }
    
    // -----------------------------------
    // Wait for worker threads to end....
    // -----------------------------------
    for (int i = 0; i < num_threads; i = i + 1){
        pthread_join(threadStructs[i], NULL);
    }
    
    
    // ----------------------------------------
    // Post processing: set easy cells
    // ----------------------------------------
    for (int col = 0; col < 331 ; col++) {
        currentMatrix[400][col]=100.0;
        
    }
    currentMatrix[200][500]=100.0;
    
}
float Simulator::checkSteadyState( std::vector< std::vector<float> >& current,std::vector< std::vector<float> >& old){
    float delta = 0.0;
    for (int row = 1 ; row < tableSize-1; row++ ) {
        for (int col = 1 ; col < tableSize-1; col++) {
            //     printf("%f ",current[row][col]);
            delta = fabs((current[row][col] - old[row][col]));
            
            if (delta > 0.0500) {
                break;
            }
        }
        if (delta > 0.0500) {
            break;
        }
    }
    return delta;
}


void *countWorker(void *arg){
    int s;
    int n, start, stop;
    int my_count = 0 ;
    
    n = (tableSize-1)/num_threads;	// number of elements to handle
    
    /* ------------------------------------
     Get thread's ID (value = 0 or 1 or 2..)
     ------------------------------------ */
    s = * (int *) arg;
    
    // Locate the starting index
    start = s * n;		// Starting index
    
    // Locate the ending index
    if ( s != (num_threads-1) )
    {
        stop = start + n;	// Ending index
    }
    else
    {
        stop = tableSize;		// Ending index // out of bounds error??
    }
    
     // Find count above 50 in my section of array

    
    for (int row = start ; row < stop; row++ ) {
        for (int col = 1 ; col < tableSize-1; col++) {
            if (currentMatrix[row][col] > 50.0)
            {
                my_count++;
            }
        }
    }
    count[s] = my_count; // store my_count in private slot
    return(NULL);     /* Thread exits (dies) */
}
int Simulator::countGreaterFifty(std::vector< std::vector<float> >& vector1){
    // block worked reduction I believe.
    /* Shared Variables */
    //vector1   // Must be SHARED (accessed by worker threads !!)
    int    start[tableSize];   // Contain starting array index of each thread
    
    
    pthread_t threadStructs[MAXTHREADS];
    // Create worker threads....
    for (int i = 0; i < num_threads; i++)
    {
        start[i] = i;     // Pass ID to thread in a private variable
        
        if ( pthread_create(&threadStructs[i], NULL, countWorker, (void *)&start[i]) )
        {
            printf( "Cannot create thread\n");
            exit(EXIT_FAILURE);
        }
    }
    
    // Wait for worker threads to end....
    for (int i = 0; i < num_threads; i++)
        pthread_join(threadStructs[i], NULL);
    
    
    // Post processing: Find actual count
    
    int sum_of_elems =0;
    for (int i = 0; i < num_threads; i++){
        sum_of_elems = sum_of_elems + count[i];
    }
    
    return sum_of_elems;
}
