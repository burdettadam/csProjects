/*#include <stdio.h>
#include <assert.h>
#define row 22
#define col 22
__global__ void kernel(float * device_matrix, size_t pitch) {
    for (int j = blockIdx.y * blockDim.y + threadIdx.y; j < row; j += blockDim.y * gridDim.y) {
        float* row_device_matrix = (float*)((char*)device_matrix + j*pitch);
        for (int i = blockIdx.x * blockDim.x + threadIdx.x; i < col; i += blockDim.x * gridDim.x) {
            row_device_matrix[i] = (j * col + i) + (j * col + i);
        }
    }
}
void verify(float *h, float *d, int size) {
    for (int i = 0; i < size; i++) {
        printf("%2f ",d[i]);
        assert(h[i] == d[i]);
    }
    printf("Results match\n");
}
int main() {
    float *host_matrix;
    float *device_matrix;
    float *deviceCopy_matrix;
    host_matrix = (float *) malloc(col * row * sizeof(float));
    deviceCopy_matrix = (float *) malloc(col * row * sizeof(float));
    for (int j = 0; j < row; j++) {
        for (int i = 0; i < col; i++) {
            host_matrix[j * col + i] = (j * col + i) + (j * col + i);
            printf("%2d,%2f ", (j * col + i) , host_matrix[j * col + i] );
        }
    }
    size_t pitch;
    cudaMallocPitch(&device_matrix, &pitch, col * sizeof(float), row);
    dim3 block;
    block.x = (1024/2);
    block.y = (1024/2);
    dim3 grid;
    grid.x = row / block.x;
    grid.y = col / block.y;
    kernel<<<grid, block>>>(device_matrix, pitch);
    cudaMemcpy2D(deviceCopy_matrix, col * sizeof(float), device_matrix, pitch, col * sizeof(float), row, cudaMemcpyDeviceToHost);
    verify(host_matrix, deviceCopy_matrix, col * row);
    free(host_matrix);
    cudaFree(device_matrix);
    free(deviceCopy_matrix);
}
*/
#include <stdio.h>
#include <assert.h>

#define N 8192
#define M 8192

__global__ void kernel(float * d_matrix, size_t pitch) {
    int colsPerThread = 8;//32 threads per block ,256 cells in block-> 256/32
    int rowstart = blockIdx.y * blockDim.y + (threadIdx.y * colsPerThread);
    for (int j = rowstart; j < rowstart+colsPerThread; j ++) {
        float* row_d_matrix = (float*)((char*)d_matrix + j*pitch);
      //  int colstart = blockIdx.x * blockDim.x + (threadIdx.x * colsPerThread);
      //  for (int i = colstart; i < colstart + colsPerThread; i ++) {
      //      row_d_matrix[i] = i;
      //  }
    }
}

void verify(float *h, float *d, int size) {
    for (int i = 0; i < size; i++) {
        //printf("h: %f,d: %f ",h[i],d[i]);
        printf("%d",i);
        assert(h[i] == d[i]);
    }
    printf("Results match\n");
}
__global__ void fill(float * d_matrix, size_t pitch) {
    int index ;
    for (int j = blockIdx.y * blockDim.y + threadIdx.y; j < N; j += blockDim.y * gridDim.y) {
        float* row_d_matrix = (float*)((char*)d_matrix + j*pitch);
        for (int i = blockIdx.x * blockDim.x + threadIdx.x; i < M; i += blockDim.x * gridDim.x) {
           // row_d_matrix[i] = (j * M + i) + (j * M + i);
            index = j * M + i;
            if (index <= M || (index % (M-1)) == 0){
                row_d_matrix[i] = 0.0;
            }
            else if (index >= 67100672){// might be one off
                row_d_matrix[i] = 100.0;
            }
        }
    }
   /* row = blockIdx.y * blockDim.y + threadIdx.y;
    if (row == 400 ){
        float* row_d_matrix = (float*)((char*)d_matrix + j*pitch);
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
*/
}


int main() {

    float *h_matrix;
    float *d_matrix;
    float *dc_matrix;

    h_matrix = (float *) malloc(M * N * sizeof(float));
    dc_matrix = (float *) malloc(M * N * sizeof(float));

    for (int j = 0; j < N; j++) {
        for (int i = 0; i < M; i++) {
            h_matrix[j * M + i] = (j * M + i);
        }
    }

/*
    int index;
    for (int j = 0 ; j < N; j++ ) {
        for (int i = 0 ; i < M; i++) {
            index = j * M + i;
            if (index <= M || (index % (M-1)) == 0){
                h_matrix[j * M + i] = 0.0;
            }
            else if (index >= 67100672){// might be one off
                h_matrix[j * M + i] = 100.0;
            }
        }
    }
*/
    size_t pitch;
    cudaMallocPitch(&d_matrix, &pitch, M * sizeof(float), N);

    //dim3 threadsPerBlock((1024/4), (1024/4), 1); // number of threads per block 256x256
    //dim3 numBlocks((N/threadsPerBlock.x),(M/threadsPerBlock.y), 1); // number of blocks in grid 32x32
    dim3 threadsPerBlock(32, 32, 1); // number of threads per block 
    dim3 numBlocks(N/threadsPerBlock.x,M/threadsPerBlock.y, 1); // number of blocks in grid 16x16

    kernel<<<numBlocks, threadsPerBlock>>>(d_matrix, pitch);

    cudaError_t error = cudaGetLastError();
    if(error != cudaSuccess) {
        printf("%s\n",cudaGetErrorString(error));
        return 0;
    }
    cudaMemcpy2D(dc_matrix, M * sizeof(float), d_matrix, pitch, M * sizeof(float), N, cudaMemcpyDeviceToHost);
    error = cudaGetLastError();
    if(error != cudaSuccess) {
        printf("%s\n",cudaGetErrorString(error));
        return 0;
    }
    verify(h_matrix, dc_matrix, M * N);

    free(h_matrix);
    cudaFree(d_matrix);
    free(dc_matrix);
}