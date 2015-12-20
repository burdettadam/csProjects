#include <stdio.h>
#include <assert.h>
#define row 11
#define col 11
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
            printf("%2d ",host_matrix)
        }
    }
    size_t pitch;
    cudaMallocPitch(&device_matrix, &pitch, col * sizeof(float), row);
    dim3 block;
    block.x = row;
    block.y = col;
    dim3 grid;
    grid_size.x = row / block.x;
    grid_size.y = col / block.y;
    kernel<<<grid, block>>>(device_matrix, pitch);
    cudaMemcpy2D(deviceCopy_matrix, col * sizeof(float), device_matrix, pitch, col * sizeof(float), row, cudaMemcpyDeviceToHost);
    verify(host_matrix, deviceCopy_matrix, col * row);
    free(host_matrix);
    cudaFree(device_matrix);
    free(deviceCopy_matrix);
}