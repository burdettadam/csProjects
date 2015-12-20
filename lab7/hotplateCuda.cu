#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#define BLOCKSIZE 1024
#define MAXIT 1
#define TOTROWS		(BLOCKSIZE*8)
#define TOTCOLS		(BLOCKSIZE*8)
#define NOTSETLOC       -1 // for cells that are not fixed

#define QMAX(x,y) (((x) > (y))? (x): (y))


int *lkeepgoing;
float *iplate;
float *oplate;
float *fixed;
float *tmp;
int ncols, nrows;

double When();
void Compute();


int main(int argc, char *argv[])
{
	double start;
	ncols = TOTCOLS;
	nrows = TOTROWS;

	cudaMalloc((void **) &lkeepgoing, nrows * ncols * sizeof(int));
	cudaMalloc((void **) &iplate, nrows * ncols * sizeof(float));
	cudaMalloc((void **) &oplate, nrows * ncols * sizeof(float));
	cudaMalloc((void **) &fixed,  nrows * ncols * sizeof(float));
	fprintf(stderr,"Memory allocated\n");

	start = When();
	/* Now proceed with the Jacobi algorithm */
	Compute();

	printf("Total Time is: %lf sec.\n", (When() - start));

	return 0;
}

__global__ void InitArrays(float *ip, float *op, float *fp, int *kp, int ncols)
{
	int i;
	// ncols is the same as number of threads
        // Each block gets a row, each thread will fill part of a row
	// Calculate the offset of the row
    int blockOffset = blockIdx.x * ncols; // first possion in array of the block3
        // The number of cols per thread
    int colsPerThread = ncols/blockDim.x;
        // Calculate our offset into the row for the thread
	int colStartPos = threadIdx.x * (colsPerThread); // col index 
	// position = arrayaddress + position of block + position of thread
	//int col = threadIdx.x + blockIdx.x * colsPerThread ;//* blockDim.x // I thick this is correct..
	int col = colStartPos;
	int row = blockIdx.x ;
	float *ippos = ip + blockOffset+ colStartPos;
	float *fppos = fp + blockOffset+ colStartPos;
	float *oppos = op + blockOffset+ colStartPos;
	int *kppos = kp + blockOffset+ colStartPos;

	for (i = 0; i < colsPerThread; i++) {
		fppos[i] = NOTSETLOC; // Not Fixed
		ippos[i] = 50;
		oppos[i] = 50;
	    kppos[i] = 1; // Keep Going
	}
        // set the rest of the boundary and fixed positions
	for (i = 0; i < colsPerThread; i++) {
		col += i;
        if (row == 0 || col == 0 || col == ncols-1 ){
            ippos[i] = 0.0;
            oppos[i] = 0.0;
        }
        else if (row == (TOTCOLS - 1) ){
            ippos[i] = 100.0;
            oppos[i] = 100.0;
        }
	}
	if (row == 400 ){
		col = colStartPos;
	    for ( i = 0; i < colsPerThread; i++) {
			col += i;
	    	if (col < 331){
		        ippos[i]=100.0;
		        oppos[i]=100.0;
		    }else{
		    	break;
		    }
	    }

	}
	else if (row == 200){
		col = colStartPos;
		if ( col <= 500 && (col + ncols) >= 500 ){
			ippos[500]=100.0;
	    	oppos[500]=100.0;	
		}
		
	}
}
__global__ void doCalc(float *iplate, float *oplate, int ncols)
{//This is called non-uniform indexing
	/* Compute the 5 point stencil for my region *///??????????????
	int i;
	// ncols is the same as number of threads
        // Each block gets a row, each thread will fill part of a row
	// Calculate the offset of the row
    int blockOffset = blockIdx.x * ncols; // first possion in array of the block3
        // The number of cols per thread
    int colsPerThread = ncols/blockDim.x;
        // Calculate our offset into the row for the thread
	int colStartPos = threadIdx.x * (colsPerThread); // col index 
	// position = arrayaddress + position of block + position of thread
	//int col = threadIdx.x + blockIdx.x * colsPerThread ;//* blockDim.x // I thick this is correct..
	int col = colStartPos;
	int row = blockIdx.x ;
	int rowup,rowdown;
	if(blockIdx.x == 0){
		rowup = 0;
	}else{
		rowup = blockIdx.x - 1 ;
	}
	if(blockIdx.x == ncols-1){
		return;
	}
	rowdown = blockIdx.x + 1;

	float *ippos = iplate + blockOffset+ colStartPos;
	float *oppos = oplate + blockOffset+ colStartPos;
	for (i = 0; i < colsPerThread; i++) {
		col += i;
		if (col == 0 || col == ncols){
			continue;
		}else{
 			ippos[i] =(( oppos[rowdown][col]//bottom
                             + oppos[rowup[col]//top
                             + oppos[row][col+1]//right
                             + oppos[row][col-1])//left
                            + (4.0 * oppos[row][col])) / 8.0;
		}
  	}
    if (row == 400 ){
		col = colStartPos;
	    for ( i = 0; i < colsPerThread; i++) {
			col += i;
	    	if (col < 331){
		        ippos[i]=100.0;
		        oppos[i]=100.0;
		    }else{
		    	break;
		    }
	    }

	}
	else if (row == 200){
		col = colStartPos;
		if ( col <= 500 && (col + ncols) >= 500 ){
			ippos[500]=100.0;
    		oppos[500]=100.0;
		}

	}
}

__global__ void doCheck(float *iplate, float *oplate, float *fixed, int *lkeepgoing, int ncols)
{
	// Calculate keepgoing array
		int i,col;
	// ncols is the same as number of threads
        // Each block gets a row, each thread will fill part of a row
	// Calculate the offset of the row
    int blockOffset = blockIdx.x * ncols; // first possion in array of the block3
        // The number of cols per thread
    int colsPerThread = ncols/blockDim.x;
        // Calculate our offset into the row for the thread
	int colStartPos = threadIdx.x * (colsPerThread); // col index 
	// position = arrayaddress + position of block + position of thread
	//int col = threadIdx.x + blockIdx.x * colsPerThread ;//* blockDim.x // I thick this is correct..
	int col = colStartPos;
	int row = blockIdx.x ;
	float *ippos = iplate + blockOffset+ colStartPos;
	float *fppos = fixed + blockOffset+ colStartPos;
	float *oppos = oplate + blockOffset+ colStartPos;
	int kppos = lkeepgoing + blockOffset+ colStartPos;
	float delta = 0.0;
    float averageNabor =0.0;
    for (i = 0; i < colsPerThread; i++) {
		col += i;
		if (col == 0 || col == ncols){
			continue;
		}else{
		    delta = fabs((ippos[col] - oppos[col]));
            if (delta > 0.0500) {
                kppos[col] = 1; // keep going
            }else{
            	kppos[col] = 0; // steady state
            }
        }
	}
}

__global__ void reduceSingle(int *idata, int *single, int nrows)
{
	// Reduce rows to the first element in each row
	int i;
        int rowStartPos;
        int colsPerThread;
	extern __shared__ int parts[];
	
        // Each block gets a row, each thread will reduce part of a row

        // Calculate our offset into the row
	rowStartPos = threadIdx.x * (nrows/blockDim.x);
        // The number of cols per thread
        colsPerThread = nrows/blockDim.x;

	// Sum my part of one dimensional array and put it shared memory
	parts[threadIdx.x] = 0;
	for (i = threadIdx.x; i < nrows; i+=blockDim.x) {
		parts[threadIdx.x] += idata[i];
	}
	int tid = threadIdx.x;
        if (tid < 512) { parts[tid] += parts[tid + 512];}  
        __syncthreads();
        if (tid < 256) { parts[tid] += parts[tid + 256];}
        __syncthreads();
        if (tid < 128) { parts[tid] += parts[tid + 128];}
        __syncthreads();
        if (tid < 64) { parts[tid] += parts[tid + 64];}
        __syncthreads();
        if (tid < 32) { parts[tid] += parts[tid + 32];}
        __syncthreads();
	if(threadIdx.x == 0) {
		*single = 0;
		for(i = 0; i < 32; i++) {
			*single += parts[i];
		}
	}
}
__global__ void reduceSum(int *idata, int *odata, unsigned int ncols)
{
	// Reduce rows to the first element in each row
	int i;
        int blockOffset;
        int rowStartPos;
        int colsPerThread;
        int *mypart;
	
        // Each block gets a row, each thread will reduce part of a row

	// Calculate the offset of the row
        blockOffset = blockIdx.x * ncols;
        // Calculate our offset into the row
	rowStartPos = threadIdx.x * (ncols/blockDim.x);
        // The number of cols per thread
        colsPerThread = ncols/blockDim.x;

	mypart = idata + blockOffset + rowStartPos;

	// Sum all of the elements in my thread block and put them 
        // into the first column spot
	for (i = 1; i < colsPerThread; i++) {
		mypart[0] += mypart[i];
	}
	__syncthreads(); // Wait for everyone to complete
        // Now reduce all of the threads in my block into the first spot for my row
	if(threadIdx.x == 0) {
		odata[blockIdx.x] = 0;
		for(i = 0; i < blockDim.x; i++) {
			odata[blockIdx.x] += mypart[i*colsPerThread];
		}
	}
	// We cant synchronize between blocks, so we will have to start another kernel
}
	
void Compute()
{
	int *keepgoing_single;
	int *keepgoing_sums;
	int keepgoing;
	int blocksize = BLOCKSIZE;
	int iteration;
	double t0, tottime;

	ncols = TOTCOLS;
	nrows = TOTROWS;

	// One block per row
	InitArrays<<< nrows, blocksize >>>(iplate, oplate, fixed, lkeepgoing, ncols);
	cudaMalloc((void **)&keepgoing_single, 1 * sizeof(int));
	keepgoing = 1;
	cudaMalloc((void **)&keepgoing_sums, nrows * sizeof(int));
 	int *peek = (int *)malloc(nrows*sizeof(int));

	for (iteration = 0; (iteration < MAXIT) && keepgoing; iteration++)
	{
		doCalc<<< nrows, blocksize >>>(iplate, oplate, ncols);
		doCheck<<< nrows, blocksize >>>(iplate, oplate, fixed, lkeepgoing, ncols);
		reduceSum<<< nrows, blocksize>>>(lkeepgoing, keepgoing_sums, ncols);
		//reduce1<<<nrows, blocksize>>>((lkeepgoing, keepgoing_sums, ncols));
		//reduce2<<<nrows, blocksize>>>((lkeepgoing, keepgoing_sums, ncols));
		//reduce3<<<nrows, blocksize>>>((lkeepgoing, keepgoing_sums, ncols));
		cudaMemcpy(peek, keepgoing_sums, nrows*sizeof(int), cudaMemcpyDeviceToHost);
//		fprintf(stderr, "after cudaMemcpy \n");
//		int i;
 //		for(i = 0; i < nrows; i++) {
//			fprintf(stderr, "%d, ",peek[i]);
//		}
		// Now we have the sum for each row in the first column, 
		//  reduce to one value
		t0 = When();
 		int timeit;
		for(timeit = 0; timeit < 10000; timeit++){
			reduceSingle<<<1, blocksize, blocksize*sizeof(int)>>>(keepgoing_sums, keepgoing_single, nrows);
		}
		tottime = When()-t0;
		
		keepgoing = 0;
		cudaMemcpy(&keepgoing, keepgoing_single, 1 * sizeof(int), cudaMemcpyDeviceToHost);
		fprintf(stderr, "keepgoing = %d time %f\n", keepgoing, tottime);

		/* swap the new value pointer with the old value pointer */
		tmp = oplate;
		oplate = iplate;
		iplate = tmp;
	}
	free(peek);
	cudaFree(keepgoing_single);
	cudaFree(keepgoing_sums);
	fprintf(stderr,"Finished in %d iterations\n", iteration);
}
__global__ void reduce1(int *g_idata, int *g_odata,int nrows) {
	extern __shared__ int sdata[];
	// each thread loads one element from global to shared mem
	unsigned int tid = threadIdx.x;
	int rowStartPos = threadIdx.x * (nrows/blockDim.x);
    int colsPerThread = nrows/blockDim.x;
	unsigned int i = blockIdx.x*colsPerThread + threadIdx.x;
	sdata[tid] = g_idata[i];
	__syncthreads();
	// do reduction in shared mem
	for(unsigned int s=1; s < colsPerThread; s *= 2) {
		if (tid % (2*s) == 0) {
		sdata[tid] += sdata[tid + s];
		}
		__syncthreads();
	}
	// write result for this block to global mem
	if (tid == 0) g_odata[blockIdx.x] = sdata[0];
}
__global__ void reduce2(int *g_idata, int *g_odata,int nrows) {
	extern __shared__ int sdata[];
	// each thread loads one element from global to shared mem
	unsigned int tid = threadIdx.x;
	int rowStartPos = threadIdx.x * (nrows/blockDim.x);
    int colsPerThread = nrows/blockDim.x;
	unsigned int i = blockIdx.x*colsPerThread + threadIdx.x;
	sdata[tid] = g_idata[i];
	__syncthreads();
	// do reduction in shared mem
	for(unsigned int s=1; s < colsPerThread; s *= 2) {
		int index = 2 * s * tid;
		if (index < colsPerThread) {
			sdata[index] += sdata[index + s];
		}
		__syncthreads();
	}
	// write result for this block to global mem
	if (tid == 0) g_odata[blockIdx.x] = sdata[0];
}
__global__ void reduce3(int *g_idata, int *g_odata,int nrows) {
	extern __shared__ int sdata[];
	// each thread loads one element from global to shared mem
	unsigned int tid = threadIdx.x;
	int rowStartPos = threadIdx.x * (nrows/blockDim.x);
    int colsPerThread = nrows/blockDim.x;
	unsigned int i = blockIdx.x*colsPerThread + threadIdx.x;
	sdata[tid] = g_idata[i];
	__syncthreads();
	// do reduction in shared mem
	for (unsigned int s=colsPerThread/2; s>0; s>>=1) {
		if (tid < s) {
			sdata[tid] += sdata[tid + s];
		}
		__syncthreads();
	}
	// write result for this block to global mem
	if (tid == 0) g_odata[blockIdx.x] = sdata[0];
}
/* Return the current time in seconds, using a double precision number.       */
double When()
{
    struct timeval tp;
    gettimeofday(&tp, NULL);
    return ((double) tp.tv_sec + (double) tp.tv_usec * 1e-6);
}
