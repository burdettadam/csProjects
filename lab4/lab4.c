#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>


//#define SIZE     4096
#define SIZE     16384
#define EPSILON  0.1

float f_abs(float f){
    return (f > 0.0)? f : -f ;
}
/* Return the correct time in seconds, using a double precision number.       */
double
When(){
    struct timeval tp;
    gettimeofday(&tp, NULL);
    return ((double) tp.tv_sec + (double) tp.tv_usec * 1e-6);
}
int EPSILONcheck(float** currentMatrix,float** old, int start, int end) {
    int i,j;
    float average;
    float delta = 0.0;
    for (i = start; i < end; i++) {
        for (j = 1; j < SIZE - 1; j++) {
          //  average = (currentMatrix[i+1][j] + currentMatrix[i-1][j] + currentMatrix[i][j+1] + currentMatrix[i][j-1]) / 4;
          //  if (f_abs(average - currentMatrix[i][j]) >= EPSILON) {
          //      return 0;
          //  }
            delta = f_abs((currentMatrix[i][j] - old[i][j]));
        
            if (delta > 0.0500) {
                return 0;
            }
        }
    }
    return 1;
}
void update(float** lastMatrix, float** currentMatrix, int start, int end) {
    int row,col;
    for ( row = start ; row < end ;row ++) {
      for ( col = 1 ; col < SIZE - 1; col++) { // skip edges... could be a bug!!!!!!!!!!!!!
         currentMatrix[row][col] =(( lastMatrix[row+1][col]//bottom
              + lastMatrix[row-1][col]//top
              + lastMatrix[row][col+1]//right
              + lastMatrix[row][col-1])//left
             + (4.0 * lastMatrix[row][col])) / 8.0;
         //xi,j (t) = ( xi+1,j (t-1) + xi-1,j(t-1) + xi,j+1(t-1) + xi,j-1(t-1) + 4 * xi,j(t-1))/8
        }
    }
}
void fillplate(float** current,float** old, int num_rows_assigned,int iproc){
    int row = 0 ;
    int diff = (iproc * num_rows_assigned);
    int tableSize = SIZE;
   for (int rowi = 1 ; rowi < num_rows_assigned+1; rowi++ ) {
        row = rowi-1 + diff;
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
            else{
                current[row][col] = 50.0;
                old[row][col] = 50.0;
            }
        }
    }

    /* no constant cells so I dont need to fill these cells
    if (diff >= 400 && ((iproc+1)* num_rows_assigned) >  )
    for (int col = 0; col < 331 ; col++) {
        current[400][col]=100.0;
        old[400][col]=100.0;
    }

    current[200][500]=100.0;
    old[200][500]=100.0;
    */
}

int main(int argc, char *argv[])
{
    // varibles 
    float **currentMatrix, **lastMatrix, **tmp;
    int i, done, reallydone;
    int cnt;
    int start, end;
    int theSize;

    double starttime;

    int nproc, iproc;
    MPI_Status status;
    MPI_Request request;
    // mpi init stuff
    MPI_Init(&argc, &argv);
    starttime = When(); // start timmer 

    MPI_Comm_size(MPI_COMM_WORLD, &nproc);
    MPI_Comm_rank(MPI_COMM_WORLD, &iproc);
    // say hello 
    fprintf(stderr,"%d: Hello from %d of %d\n", iproc, iproc, nproc);
    
    /* Determine how much I should be doing and allocate the arrays*/
    theSize = SIZE / nproc;
    currentMatrix = (float **)malloc((theSize + 2) * sizeof(float*));
    lastMatrix = (float **)malloc((theSize + 2) * sizeof(float*));
    for (i = 0; i < SIZE; i++) {
        currentMatrix[i] = (float*)malloc(SIZE * sizeof(float));
        lastMatrix[i] = (float*)malloc(SIZE * sizeof(float));
    }
    start = 1;
    end = theSize + 1;
    /* Initialize the cells */
    fillplate(currentMatrix,lastMatrix, theSize, iproc);


    if (iproc == 0)
    {
        start = 2;
    }
    if (iproc == nproc - 1)
    {
        end = theSize;
    }

    /* Now run the relaxation */
    reallydone = 0;
    for(cnt = 0; !reallydone; cnt++)
    {
        /* First, I must get my neighbors boundary values */
        if (iproc != 0)
        {
            // non blocking send
            MPI_Isend(lastMatrix[1], SIZE, MPI_FLOAT, iproc - 1, 0, MPI_COMM_WORLD, &request);
            MPI_Recv(lastMatrix[0], SIZE, MPI_FLOAT, iproc - 1, 0, MPI_COMM_WORLD, &status);
        }
        if (iproc != nproc - 1)
        {
            // non blocking send
            MPI_Isend(lastMatrix[theSize], SIZE, MPI_FLOAT, iproc + 1, 0, MPI_COMM_WORLD, &request);
            MPI_Recv(lastMatrix[theSize+1], SIZE, MPI_FLOAT, iproc + 1, 0, MPI_COMM_WORLD, &status);
        }


        /* Do the calculations */
        update(lastMatrix, currentMatrix,start,end);

        /* Check to see if we are done */
        done = EPSILONcheck(currentMatrix, lastMatrix ,start,end);

        /* Do a reduce to see if everybody is done */
        MPI_Allreduce(&done, &reallydone, 1, MPI_INT, MPI_MIN, MPI_COMM_WORLD);

        /* Swap the pointers */
        tmp = currentMatrix;
        currentMatrix = lastMatrix;
        lastMatrix = tmp;
        if (cnt == 360-1){
            reallydone = 1 ;
        }
    }
//    for( int i =0; i < SIZE; i++) {
 //       free(currentMatrix[i]);
//        free(lastMatrix[i]);
//      }
//      free(currentMatrix);
//      free(lastMatrix);

    /* print out the number of iterations to relax */
    if (iproc == 0) {
        printf("%d: Iterations: %d\n", iproc, cnt);
        printf("%d: Total time: %f\n", iproc, (When() - starttime));
    }
    //MPI_FicurrentMatrixlize(); // what is this for ?????
    MPI_Finalize();
}
    


