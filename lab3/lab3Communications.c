#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
int main( int argc, char **argv)
{
    MPI_Comm newcomm;
    int rank,nproc,numdim;
    int rank1,rank2,newSize;
    int pivot;
    int membershipKey;
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &nproc);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

        switch(nproc) {
        case 32: numdim = 5;break;
        case 16: numdim = 4;break;
        case 8: numdim = 3;break;
        case 4: numdim = 2;break;
        case 2: numdim = 1;break;
        case 1: numdim = 0;break;
    }
    pivot = rank; // find midpoint of data
    rank2 = rank ;
    newcomm = MPI_COMM_WORLD ;
    MPI_Comm comm1 = MPI_COMM_WORLD, comm2, intercomm;
    int val = rank, buf;
    MPI_Status status;
    for(int curdim = 0; curdim < numdim; curdim++ ) {

        membershipKey = rank2 % 2; // creates two groups o and 1.
        MPI_Comm_split(comm1, membershipKey, rank2, &comm2);
        MPI_Comm_rank(comm2,&rank2);
        MPI_Comm_size(newcomm,&newSize);   
        //printf("rank %d, rank2 %d, pivot%d, size %d\n",rank, rank2, pivot,newSize);
        pivot = rank; // find midpoint of data
        //MPI_Bcast(&pivot,1,MPI_INT, 0, comm2);
        
        if (membershipKey == 0 ){ // lower world (left)
        MPI_Intercomm_create(comm2, 0, comm1, 1, 99, &intercomm);
            val = 4;
              MPI_Send(&val, 1, MPI_INT, rank2, 0, intercomm ); 

              printf("%d %d: %s subcube; sent value = %d\n", curdim, rank2, "left", val);
              
              MPI_Recv(&buf, 1, MPI_INT, rank2, 0, intercomm, &status);

              printf("%d %d: %s subcube; received value = %d\n", curdim, rank2, "left", buf);

               // printf("comm1, %d upper sendto %d on comm2   \n",comm1, comm2 );
               // printf("comm1, %d lower recivefrom %d on comm2 \n",rank1, rank2 );
 
        }else{
        MPI_Intercomm_create(comm2, 0, comm1, 0, 99, &intercomm);
            val = 8;
              MPI_Send(&val, 1, MPI_INT, rank2, 0, intercomm ); 

              printf("%d %d: %s subcube; sent value = %d\n", curdim, rank2, "right", val);
              
              MPI_Recv(&buf, 1, MPI_INT, rank2, 0, intercomm, &status);

              printf("%d %d: %s subcube; received value = %d\n", curdim, rank2, "right", buf);
                //printf("comm2, %d lower sendto %d on comm1   \n",rank2, rank1 );
                //printf("comm2, %d upper recivefrom %d on comm1 \n",rank2, rank1 );

        }
        comm1 = comm2; 
    }
   // printf("rank %d, newrank %d, pivot %d\n",rank, newrank, pivot);
    
    MPI_Finalize();
}
/*

        MPI_Comm comm1, comm2;

        int rank;
        int newrank1, newrank2;
        int membershipKey;
        MPI_Init(&argc, &argv);
        MPI_Comm_rank(MPI_COMM_WORLD, &rank);
        membershipKey = rank % 2;
        MPI_Comm_split(MPI_COMM_WORLD, membershipKey, rank, &comm1);
        MPI_Comm_rank(comm1,&newrank1);
        pivot1 = rank; // find midpoint of data// pick pivit 
        MPI_Bcast(&pivot1,1,MPI_INT, 0, comm1);// mpi_Bcast pivit
        //printf("rank %d, newrank1 %d, pivot1 %d\n",rank, newrank1, pivot1);
        
        membershipKey = newrank1 % 2;
        MPI_Comm_split(comm1, membershipKey, newrank1, &comm2);
        MPI_Comm_rank(comm2,&newrank2);
        pivot2 = rank;
        MPI_Bcast(&pivot2,1,MPI_INT, 0, comm2);
        printf("rank %d, newrank1 %d, pivot1 %d, newrank2 %d, pivot2 %d\n",rank, newrank1, pivot1, newrank2, pivot2);
      */
