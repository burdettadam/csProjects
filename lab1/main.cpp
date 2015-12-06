//
//  main.cpp
//  object_hotplate
//
//  Created by Adam Burdett on 9/11/15.
//  Copyright (c) 2015 Adam Burdett. All rights reserved.
//

#include <iostream>
#include "hotPlateSimulator.h"
int main(int argc, const char * argv[]) {
    // insert code here...
    Simulator simulator;
    double start =0.0, end = 0.0,time=0.0;
    start = simulator.When();
    int iterations = 0 , greaterThanFifty = 0, cnt = 0 ;
    float delta = 3.0;
    vector< vector<float> > currentMatrix(tableSize, vector<float> (tableSize,50))
    , lastMatrix (tableSize, vector<float> (tableSize,50));//, tempMatrix (tableSize, vector<float> (tableSize,50));
    simulator.fillPlateWithTemperature(currentMatrix,lastMatrix);
    while (delta > 0.0500) {
        //printf("%f %d\n",delta,iterations);
        //tempMatrix = lastMatrix;
        //lastMatrix = currentMatrix;
        //currentMatrix =tempMatrix;
        currentMatrix.swap(lastMatrix);// do I need to pass as reference?
        simulator.steadyState(currentMatrix, lastMatrix);
        delta = simulator.checkSteadyState(currentMatrix, lastMatrix);
        iterations++;
        greaterThanFifty = simulator.countGreaterFifty(currentMatrix);
        if (cnt == 360-1){
            delta = 0.025 ;
        }
        cnt ++;
    }
  
    end = simulator.When();
    time = end - start;
    
    printf("ran in %f seconds, %d iterations, with %d cells > 50 degrees.\n",time,iterations,greaterThanFifty);
    
    return 0;
}
