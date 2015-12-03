//
//  main.cpp
//  classNotesBcast
//
//  Created by Adam Burdett on 9/29/15.
//  Copyright (c) 2015 Adam Burdett. All rights reserved.
//
// the spec says to do some different nodes, only do power of 2 node structure.
#include <stdio.h>
//#include <stdlib.h>
#include <sys/time.h>
#include <mpi.h>
#include <math.h>

#define VECSIZE 20480 // numbers on each node?
#define ITERATIONS 100 //
struct node{
    double val;
    int   rank;
};

// Broadcast value to all nodes
//dim is dimesion of highper cube
// everyone has there own copy of everything
// everyone blocks on recieves and send so we do not need a barrier in our loop
/*  highper cube in class example
                        iterations
 notparticipating | 011        | 001        | 000 (everybody is in now)
 bitmask          | 100        | 010        | 001
 curdim           | 0          | 1          | 2
 -------------------------------------------------
 rank
 000              | send 100   | send 010   | send 001
 001                x          | x          | recv 000
 010                x          | recv 000   | send 011
 011                x          | x          | recv 010
 100                recv 000   | send 110   | send 101
 101                x          | x          | recv 100
 110                x          | recv 100   | send 111
 111                x          | x          | recv 110
 
 */// Broadcast value to all nodes
// everyone blocks on recieves before they send.
void Bcast(struct node* value, int count , MPI_Datatype datatype, MPI_Comm communicator, int numdim)
{
    int myrank;
    //get rank so we dont have to pass as parameter.
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
    int rank = myrank;

    int notparticipating = pow(2,numdim-1)-1; // set up to coralate to a highper cube of powers of 2

    int bitmask = pow(2,numdim-1); // set up to coralate to a highper cube of powers of 2

    int curdim;
    for(curdim = 0; curdim < numdim; curdim++) {
        if ((rank & notparticipating) == 0) {
            if ((rank & bitmask) == 0) {
                int msg_dest = rank ^ bitmask;//^ is xor

                MPI_Send(value, count, datatype , msg_dest, 0 , communicator );
            } else {
                int msg_src = rank ^ bitmask;
                MPI_Recv(value, count, datatype , msg_src, 0 , communicator , MPI_STATUS_IGNORE);
            }
        }
        notparticipating >>= 1;
        bitmask >>=1;
    }
}


//Reduce
/*  hyper cube in class example for reduce
 
    110 --- 111
    /|      /|
   / |     / |
  010|--- 011|
  | 100 ---|101
  | /      |/
  |/       |
 000 --- 001
 iterations
            (everybody is in now)
 
 notparticipating | 000         | 001       | 011
 bitmask          | 001         | 010       | 100
 curdim(dimension)| 000         | 1         | 2
 -------------------------------------------------
 rank
 000              | recv 001    | recv 010  | recv 100
 001                send 000    | x         | x
 010                recv 011    | send 000  | x
 011                send 010    | x         | x
 100                recv 101    | recv 110  | send 000
 101                send 100    | x         | x
 110                recv 111    | send 100  | x
 111                send 110    | x         | x
 */
// Reduce values to one node
// we will want to use max and not sum
 void ReduceMax(struct node* send_data, struct node* recv_data, int count, MPI_Datatype datatype, MPI_Op op, int root, MPI_Comm communicator, int numdim)
 {
    int myrank;
    //get rank so we dont have to pass as parameter.
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
    int rank = myrank;

    int notparticipating = 0;
    int bitmask = 1;
    int curdim ;
    int i;
    struct node newvalue[count];
    MPI_Status status;
    
    for( curdim = 0; curdim < numdim; curdim++ ) {
        if ((rank & notparticipating) == 0) {
            if ((rank & bitmask) != 0) {
                int msg_dest = rank ^ bitmask; // XOR
                MPI_Send(send_data, count, datatype ,msg_dest, 0 , communicator );
            } else {
                int msg_src = rank ^ bitmask;
                MPI_Recv(&newvalue, count, datatype , msg_src, 0 , communicator , &status );
             //         printf("rank %d MPI_Recv from %d with %f" ,rank,msg_src,newvalue[0].val);
              //        printf(" self  %f ",send_data[0].val);
                for (i =0 ; i < count; i ++){

                    if (send_data[i].val > newvalue[i].val){
                        recv_data[i] = send_data[i];

                    }
                    else{
                        recv_data[i] = newvalue[i];
                    }
                    send_data[i] = recv_data[i];
                }
               //     printf(" max  %f \n",recv_data[0].val);
            }
        }
        notparticipating = notparticipating ^ bitmask;
        bitmask <<=1;
    }
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
    int iproc, nproc,i, iter;
    int numdim;
    char host[255], message[55];
    MPI_Status status;
    
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &nproc);
    MPI_Comm_rank(MPI_COMM_WORLD, &iproc);
    
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
    
    printf("I am proc %d of %d running on %s\n", iproc, nproc,host);
    // each process has an array of VECSIZE double: ain[VECSIZE]
    double ain[VECSIZE], aout[VECSIZE];
    int  ind[VECSIZE];
    //struct {
    //    double val;
    //    int   rank;
    //} in[VECSIZE], out[VECSIZE];
    struct node in[VECSIZE], out[VECSIZE];
    int myrank, root = 0;
    
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank);
    // Start time here
    /* Intializes random number generator */ // what should myrank be at beginng
    srand(myrank+5);
    double start = When();
    for(iter = 0; iter < ITERATIONS; iter++) {
        // fill with random numbers-----------?
        for(i = 0; i < VECSIZE; i++) {
            ain[i] = rand();
        //              printf("init proc %d [%d]=%f\n",myrank,i,ain[i]);
        }
        for (i = 0; i < VECSIZE; ++i) {
            in[i].val = ain[i];
            in[i].rank = myrank;
        }
        //MPI_Reduce( in, out, VECSIZE, MPI_DOUBLE_INT, MPI_MAXLOC, root, MPI_COMM_WORLD);

        ReduceMax(in, out, VECSIZE, MPI_DOUBLE_INT, MPI_MAXLOC, root, MPI_COMM_WORLD, numdim);
       
        
        // At this point, the answer resides on process root
        if (myrank == root) {
            /* read ranks out
             */
            for (i=0; i<VECSIZE; ++i) {
             //                   printf("root out[%d] = %f from process %d\n",i,out[i].val,out[i].rank);
                aout[i] = out[i].val;
                ind[i] = out[i].rank;
            }
        }


        // Now broadcast this max vector to everyone else.
       // MPI_Bcast(out, VECSIZE, MPI_DOUBLE_INT, root, MPI_COMM_WORLD);

        Bcast(out, VECSIZE, MPI_DOUBLE_INT, MPI_COMM_WORLD, numdim);

      //  for(i = 0; i < VECSIZE; i++) {
      //                printf("final proc %d [%d]=%f from %d\n",myrank,i,out[i].val,out[i].rank);
      //  }
    }
    MPI_Finalize(); // does not pass till everyone else as made it there...
    double end = When();

    if(myrank == root) {
        printf("vector size %d\n",VECSIZE);
        printf("Time %f\n",end-start);
    }
}
