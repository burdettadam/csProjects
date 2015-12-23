#include <stdio.h>
#include <assert.h>
#include <sys/time.h>
#include <math.h>
#define MAXIT 360
#define N 1024
#define M 1024
int *lkeepgoing;
float *iplate;
float *oplate;
float *tmp;

/* Return the current time in seconds, using a double precision number.       */
double When()
{
    struct timeval tp;
    gettimeofday(&tp, NULL);
    return ((double) tp.tv_sec + (double) tp.tv_usec * 1e-6);
}

__global__ void kernel(float * d_matrix, size_t pitch) {
    int colsPerThread = 1;//32 threads per block ,256 cells in block-> 256/32
    int rowstart = blockIdx.y * blockDim.y + (threadIdx.y * colsPerThread);
    for (int j = rowstart; j < rowstart+colsPerThread; j ++) {
        float* row_d_matrix = (float*)((char*)d_matrix + j*pitch);
        int colstart = blockIdx.x * blockDim.x + (threadIdx.x * colsPerThread);
        for (int i = colstart; i < colstart + colsPerThread; i ++) {
            row_d_matrix[i] = j * M + i;
        }
    }
}

__global__ void fill(float * iplate, size_t ipitch,float * oplate, size_t opitch) {
    int index;
    int colsPerThread = 1;//32 threads per block ,256 cells in block-> 256/32
    int rowstart = blockIdx.y * blockDim.y + (threadIdx.y * colsPerThread);
    for (int j = rowstart ; j < rowstart+colsPerThread; j ++) {

        float* row_iplate = (float*)((char*)iplate + j*ipitch);
        float* row_oplate = (float*)((char*)oplate + j*opitch);

        int colstart = blockIdx.x * blockDim.x + (threadIdx.x * colsPerThread);
        for (int i = colstart; i < colstart + colsPerThread; i ++) {
           // row_iplate[i] = (j * M + i) + (j * M + i);
            index = j * M + i;
            if (index <= M || (index % (M-1)) == 0){
                row_iplate[i] = 0.0;
                row_oplate[i] = 0.0;
            }
            else if (index >= 67100672 || index == (200 * M + 500) || (index < (400*M+331) && index > (400 * M +0))){// might be one off
                row_iplate[i] = 100.0;
                row_oplate[i] = 100.0;
            }
            else{
                row_iplate[i] = 50.0;
                row_oplate[i] = 50.0;
            }
        }
    }
}
__global__ void doCalc(float * iplate, size_t ipitch,float * oplate, size_t opitch) {
    int index;
    int colsPerThread = 1;//32 threads per block ,256 cells in block-> 256/32
    float* n_row_oplate;
    float* s_row_oplate;
    int rowstart = blockIdx.y * blockDim.y + (threadIdx.y * colsPerThread);
    for (int j = rowstart ; j < rowstart+colsPerThread; j ++) {

        float* row_iplate = (float*)((char*)iplate + j*ipitch);
        float* row_oplate = (float*)((char*)oplate + j*opitch);
        if (j == 0 || j == N){
            continue;
        }
        else {
            n_row_oplate = (float*)((char*)oplate + (j-1)*opitch);
            s_row_oplate = (float*)((char*)oplate + (j+1)*opitch);
        }

        int colstart = blockIdx.x * blockDim.x + (threadIdx.x * colsPerThread);
        for (int i = colstart; i < colstart + colsPerThread; i ++) {
           // row_iplate[i] = (j * M + i) + (j * M + i);
            index = j * M + i;
            if (i == 0 || i == M){
                continue;
            }
            if (index >= 67100672 || index == (200 * M + 500) || (index < (400*M+331) && index > (400 * M +0))){// might be one off
                row_iplate[i] = 100.0;
            }
            else{
                row_iplate[i] = (( s_row_oplate[i]//bottom
                             + n_row_oplate[i]//top
                             + row_oplate[i+1]//right
                             + row_oplate[i-1])//left
                            + (4.0 * row_oplate[i])) / 8.0;
            }
        }
    }
}
__global__ void doCheck(float * iplate, size_t ipitch,float * oplate, size_t opitch,int *lkeepgoing,size_t lpitch) {
    float delta = 0.0;
    //int index;
    int colsPerThread = 1;//32 threads per block ,256 cells in block-> 256/32
    int rowstart = blockIdx.y * blockDim.y + (threadIdx.y * colsPerThread);
    for (int j = rowstart ; j < rowstart+colsPerThread; j ++) {

        float* row_iplate = (float*)((char*)iplate + j*ipitch);
        float* row_oplate = (float*)((char*)oplate + j*opitch);
        float* row_lplate = (float*)((char*)lkeepgoing + j*lpitch);
        if (j == 0 || j == N){
            continue;
        }
        int colstart = blockIdx.x * blockDim.x + (threadIdx.x * colsPerThread);
        for (int i = colstart; i < colstart + colsPerThread; i ++) {
           // index = j * M + i;
            if (i == 0 || i == M){
                continue;
            }
            delta = fabs((row_iplate[i] - row_oplate[i]));
            if (delta > 0.0500) {
                row_lplate[i] = 1; // keep going
            }else{
                row_lplate[i] = 0; // steady state
            }
        }
    }
}

__global__ void reduceSum(int *lkeepgoing, size_t lpitch, int *odata) {
    int colsPerThread = 1;//32 threads per block ,256 cells in block-> 256/32
    if(threadIdx.x == 0) {
        odata[blockIdx.x] = 0;
        int rowstart = blockIdx.y * blockDim.y + (threadIdx.y * colsPerThread);
        for (int j = rowstart ; j < rowstart+blockDim.y; j ++) {
            
            float* row_lplate = (float*)((char*)lkeepgoing + j*lpitch);
            if (j == 0 || j == N){
                continue;
            }
            int colstart = blockIdx.x * blockDim.x + (threadIdx.x * colsPerThread);
            for (int i = colstart; i < colstart + blockDim.x; i ++) {
                odata[blockIdx.x] +=  row_lplate[i];
            }
        }
    }
   
}
__global__ void reduce1(int *g_idata, int *g_odata) {
    extern __shared__ int sdata[];
    // each thread loads one element from global to shared mem
    unsigned int tid = threadIdx.x;
    unsigned int i = blockIdx.x*blockDim.x + threadIdx.x;
    sdata[tid] = g_idata[i];
    __syncthreads();
    // do reduction in shared mem
    for(unsigned int s=1; s < blockDim.x; s *= 2) {
        if (tid % (2*s) == 0) {
        sdata[tid] += sdata[tid + s];
        }
        __syncthreads();
    }
    // write result for this block to global mem
    if (tid == 0) g_odata[blockIdx.x] = sdata[0];
}
__global__ void reduce2(int *g_idata, int *g_odata) {
    extern __shared__ int sdata[];
    // each thread loads one element from global to shared mem
    unsigned int tid = threadIdx.x;
    unsigned int i = blockIdx.x*blockDim.x + threadIdx.x;
    sdata[tid] = g_idata[i];
    __syncthreads();
    // do reduction in shared mem
    for(unsigned int s=1; s < blockDim.x; s *= 2) {
        int index = 2 * s * tid;
        if (index < blockDim.x) {
            sdata[index] += sdata[index + s];
        }
        __syncthreads();
    }
    // write result for this block to global mem
    if (tid == 0) g_odata[blockIdx.x] = sdata[0];
}
__global__ void reduce3(int *g_idata, int *g_odata) {
    extern __shared__ int sdata[];
    // each thread loads one element from global to shared mem
    unsigned int tid = threadIdx.x;
    unsigned int i = blockIdx.x*blockDim.x + threadIdx.x;
    sdata[tid] = g_idata[i];
    __syncthreads();
    // do reduction in shared mem
    for (unsigned int s = (blockDim.x/2) ; s>0; s>>=1) {
        if (tid < s) {
            sdata[tid] += sdata[tid + s];
        }
        __syncthreads();
    }
    // write result for this block to global mem
    if (tid == 0) g_odata[blockIdx.x] = sdata[0];
}

int main() {


    //h_matrix = (float *) malloc(M * N * sizeof(float));
    //dc_matrix = (float *) malloc(M * N * sizeof(float));
    double t0, tottime, start = When();
    size_t ipitch;
    size_t opitch;
    size_t lpitch;
    cudaMallocPitch(&iplate, &ipitch, M * sizeof(float), N);
    cudaMallocPitch(&oplate, &opitch, M * sizeof(float), N);
    cudaMallocPitch(&lkeepgoing, &lpitch, M * sizeof(float), N);
   // cudaMallocPitch(&d_matrix, &pitch, M * sizeof(float), N);

    dim3 threadsPerBlock(32, 32, 1); // number of threads per block 
    dim3 numBlocks(N/threadsPerBlock.x,M/threadsPerBlock.y, 1); // number of blocks in grid 16x16
    fill<<<numBlocks, threadsPerBlock>>>(iplate, ipitch, oplate, opitch);
    cudaDeviceSynchronize();
    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess) {
        printf("%s\n",cudaGetErrorString(error));
        return 0;
    }
    int *keepgoing_single;
    int *keepgoing_sums;
    int keepgoing;
    int iteration;
    cudaMalloc((void **)&keepgoing_single, 1 * sizeof(int));
    keepgoing = 1;
    cudaMalloc((void **)&keepgoing_sums, M * sizeof(int));
    float totaltime = 0.0;
    for (iteration = 0; (iteration < MAXIT) && keepgoing; iteration++)
    {
        doCalc<<< numBlocks, threadsPerBlock >>>(iplate, ipitch, oplate, opitch);
        cudaDeviceSynchronize();
        error = cudaGetLastError();
        if(error != cudaSuccess) {
            printf("%s\n",cudaGetErrorString(error));
            return 0;
        }
        doCheck<<< numBlocks, threadsPerBlock >>>(iplate, ipitch, oplate, opitch, lkeepgoing, lpitch);
        cudaDeviceSynchronize();
        error = cudaGetLastError();
        if(error != cudaSuccess) {
            printf("%s\n",cudaGetErrorString(error));
            return 0;
        }
        reduceSum<<< numBlocks, threadsPerBlock>>>(lkeepgoing,lpitch, keepgoing_sums );
        cudaDeviceSynchronize();
        error = cudaGetLastError();
        if(error != cudaSuccess) {
            printf("%s\n",cudaGetErrorString(error));
            return 0;
        }

        // Now we have the sum for each row in the first column, 
        //  reduce to one value
        t0 = When();
        int timeit;
        for(timeit = 0; timeit < 10000; timeit++){
            //reduce1<<<1, 1024, 1024*sizeof(int)>>>(keepgoing_sums, keepgoing_single);
            //reduce2<<<1, 1024, 1024*sizeof(int)>>>(keepgoing_sums, keepgoing_single);
            reduce3<<<1, 1024, 1024*sizeof(int)>>>(keepgoing_sums, keepgoing_single);
            cudaDeviceSynchronize();
            error = cudaGetLastError();
            if(error != cudaSuccess) {
                printf("%s\n",cudaGetErrorString(error));
                return 0;
            }
        }
        tottime = When()-t0;
        
        keepgoing = 0;
        cudaMemcpy(&keepgoing, keepgoing_single, 1 * sizeof(int), cudaMemcpyDeviceToHost);
        totaltime += (tottime/10000);
        /* swap the new value pointer with the old value pointer */
        tmp = oplate;
        oplate = iplate;
        iplate = tmp;
    }
    totaltime = totaltime/ iteration;
    cudaFree(iplate); 
    cudaFree(oplate); 
    cudaFree(keepgoing_single); 
    cudaFree(keepgoing_sums);
    printf("Finished in %d iterations at %f, with reduce average time in %f.\n", iteration,When()-start,totaltime);
}
