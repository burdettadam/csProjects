#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <assert.h>

#define BLOCKSIZE 1024
#define TOTROWS		(BLOCKSIZE*8)
#define TOTCOLS		(BLOCKSIZE*8)

float *iplate;
float *host_matrix;
int ncols, nrows;

__global__ void InitArrays(float *ip){
	int i;
	// ncols is the same as number of threads
        // Each block gets a row, each thread will fill part of a row
	// Calculate the offset of the row
    int blockOffset = blockIdx.x * TOTCOLS; // first possion in array of the block3
        // The number of cols per thread
    int colsPerThread = TOTCOLS/blockDim.x;
        // Calculate our offset into the row for the thread
	int colStartPos = threadIdx.x * (colsPerThread); // col index 
	// position = arrayaddress + position of block + position of thread
	//int col = threadIdx.x + blockIdx.x * colsPerThread ;//* blockDim.x // I thick this is correct..
	//int col = colStartPos;
	//int row = blockIdx.x ;

	float *ippos = ip + blockOffset+ colStartPos;

	for (i = 0; i < colsPerThread; i++) {
		ippos[i] = i;
	}
}
void verify(float *h, float *d, int size) {
    for (int i = 0; i < size; i++) {
        printf("%2f ",d[i]);
        assert(h[i] == d[i]);
    }
    printf("Results match\n");
}
void Compute()
{
	int blocksize = BLOCKSIZE;
	ncols = TOTCOLS;
	nrows = TOTROWS;
	host_matrix = (float *) malloc(ncols * nrows * sizeof(float));
    for (int j = 0; j < nrows; j++) {
        for (int i = 0; i < ncols; i++) {
            host_matrix[j * ncols + i] = (j * ncols + i);
        }
    }
    //cudaMemcpy(d_A, A, (N*N)*sizeof(float), cudaMemcpyHostToDevice);
	// One block per row
	InitArrays<<< nrows, blocksize >>>(iplate);
	  // print out the result element by element
	  for(int row = 0; row < TOTROWS; ++row){
	    for(int col = 0; col < TOTCOLS; ++col){
	      printf("%2f ", iplate[row * TOTROWS + col]);
	    }
	    printf("\n");
	  }
	  printf("\n");
	 verify(host_matrix, iplate, TOTCOLS * TOTROWS);
}

int main(int argc, char *argv[])
{
	ncols = TOTCOLS;
	nrows = TOTROWS;
	cudaMalloc((void **) &iplate, nrows * ncols * sizeof(float));
	Compute();

	return 0;
}

