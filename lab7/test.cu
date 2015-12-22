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

#define N 160
#define M 160

__global__ void kernel(float * d_matrix, size_t pitch) {
    for (int j = blockIdx.y * blockDim.y + threadIdx.y; j < N; j += blockDim.y * gridDim.y) {
        float* row_d_matrix = (float*)((char*)d_matrix + j*pitch);
        for (int i = blockIdx.x * blockDim.x + threadIdx.x; i < M; i += blockDim.x * gridDim.x) {
            row_d_matrix[i] = (j * M + i) + (j * M + i);
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

    float *h_matrix;
    float *d_matrix;
    float *dc_matrix;

    h_matrix = (float *) malloc(M * N * sizeof(float));
    dc_matrix = (float *) malloc(M * N * sizeof(float));

    for (int j = 0; j < N; j++) {
        for (int i = 0; i < M; i++) {
            h_matrix[j * M + i] = (j * M + i) + (j * M + i);
        }
    }

    size_t pitch;
    cudaMallocPitch(&d_matrix, &pitch, M * sizeof(float), N);

    dim3 grid((N/16),(M/16), 1); // number of blocks in grid
    dim3 block((1024/2), (1024/2), 1); // number of threads per block

    kernel<<<grid, block>>>(d_matrix, pitch);

    cudaMemcpy2D(dc_matrix, M * sizeof(float), d_matrix, pitch, M * sizeof(float), N, cudaMemcpyDeviceToHost);

    verify(h_matrix, dc_matrix, M * N);

    free(h_matrix);
    cudaFree(d_matrix);
    free(dc_matrix);
}