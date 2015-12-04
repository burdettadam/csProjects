//
//  hotPlateSimulator.cpp
//  object_hotplate
//
//  Created by Adam Burdett on 9/11/15.
//  Copyright (c) 2015 Adam Burdett. All rights reserved.
//

#include <sys/time.h>
#include "hotPlateSimulator.h"
#include <math.h>
double Simulator::When()
{
    struct timeval tp;
    gettimeofday(&tp, NULL);
    return ((double) tp.tv_sec + (double) tp.tv_usec * 1e-6);
}

void Simulator::fillPlateWithTemperature( vector< vector<float> >& current,vector< vector<float> >& old)
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
    for (int row = 0 ; row < tableSize; row++ ) {
        for (int col = 20 ; col < tableSize; col+=20) {
            current[row][col] = 0.0;
            old[row][col] = 0.0;
        }
    }
    vector<float> hundred (tableSize,100);
    for (int row = 20 ; row < tableSize; row+=20 ) {
        current[row] = hundred;
        old[row]= hundred;
    }
    
    for (int col = 0; col < 331 ; col++) {
        current[400][col]=100.0;
        old[400][col]=100.0;
    }
    current[200][500]=100.0;
    old[200][500]=100.0;


    
}
void Simulator::steadyState( vector< vector<float> >& current,vector< vector<float> >& old){
  
#pragma omp parallel for
    
    for (int row = 1 ; row < tableSize-1; row++ ) {
        for (int col = 1 ; col < tableSize-1; col++) {
            current[row][col] =(( old[row+1][col]//bottom
                                 + old[row-1][col]//top
                                 + old[row][col+1]//right
                                 + old[row][col-1])//left
                                + (4.0 * old[row][col])) / 8.0;
            //xi,j (t) = ( xi+1,j (t-1) + xi-1,j(t-1) + xi,j+1(t-1) + xi,j-1(t-1) + 4 * xi,j(t-1))/8
        }
    }
    
    for (int col = 0; col < 331 ; col++) {
        current[400][col]=100.0;

    }
    current[200][500]=100.0;

}
float Simulator::checkSteadyState( vector< vector<float> >& current,vector< vector<float> >& old){
    float delta = 0.0;
    float averageNabor =0.0;
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
int Simulator::countGreaterFifty(vector< vector<float> >& vector1){
    int greaterNfith = 0;
    for (int row = 1 ; row < tableSize-1; row++ ) {
        for (int col = 1 ; col < tableSize-1; col++) {
            if (vector1[row][col] > 50.0)
            {
                greaterNfith++;
            }
        }
    }
    greaterNfith+=tableSize+1; // edge on row 400 is 100 + last row is 100
    return greaterNfith;
}
