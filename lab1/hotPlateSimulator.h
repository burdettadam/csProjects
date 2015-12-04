//
//  hotPlateSimulator.h
//  object_hotplate
//
//  Created by Adam Burdett on 9/11/15.
//  Copyright (c) 2015 Adam Burdett. All rights reserved.
//

#ifndef __object_hotplate__hotPlateSimulator__
#define __object_hotplate__hotPlateSimulator__
#define tableSize 16384
//#define tableSize 8192
//#define tableSize 2048
//#define tableSize 1024
//#define tableSize 512
#include <stdio.h>
#include <vector>
//#include <omp.h>
using namespace std;

class Simulator{
public:
    void fillPlateWithTemperature( vector< vector<float> >& current,vector< vector<float> >& old);
    void steadyState( vector< vector<float> >& current,vector< vector<float> >& old);
    float checkSteadyState( vector< vector<float> >& current,vector< vector<float> >& old);
    int countGreaterFifty(vector< vector<float> >& current);
    double When();
};

#endif /* defined(__object_hotplate__hotPlateSimulator__) */