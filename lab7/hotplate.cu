// This example demonstrates how to launch two dimensional grids of CUDA threads.

#include <stdlib.h>
#include <stdio.h>
const int tableSize = 8192;
const int blocksize = 1024;
__global__ void sumreduct(size_t pitch, float* dev_vector, float* dev_matrix, int  columns, int N)
{
int idx = threadIdx.x + blockIdx.x * blockDim.x;
int stride = blockDim.x * gridDim.x;

while(idx<N)
{
    dev_vector[idx] = *(float *)( ((char*)dev_matrix + idx * pitch) + columns);
    idx += stride;
} 
}

__global__ void kernel(float *array, size_t pitch)
{
  // compute the two dimensional index of this particular
  // thread in the grid

  // do the usual computation separately in each dimension:
  int index_x = blockIdx.x * blockDim.x + threadIdx.x;
  int index_y = blockIdx.y * blockDim.y + threadIdx.y;

  // use the two 2D indices to compute a single linear index
  int grid_width = gridDim.x * blockDim.x;
  int index = index_y * grid_width + index_x;

  // use the two 2D block indices to compute a single linear block index
 // int result = blockIdx.y * gridDim.x + blockIdx.x;

  // write out the result
 // array[index] = result;
 // array[index] = index_x + (index_y * tableSize); // should print out index of each cell.
                                                 //                         N 
//  int C = index_x + index_y*tableSize;           // node (i,j)              |
//  int N = index_x + (index_y+1)*tableSize;       // node (i,j+1)            |
//  int S = index_x + (index_y-1)*tableSize;       // node (i,j-1)     W ---- C ---- E
//  int E = (index_x+1) + index_y*tableSize;       // node (i+1,j)            |
//  int W = (index_x-1) + index_y*tableSize;       //                         |
                                                 //                         S 
 // for (int i = blockIdx.x * blockDim.x + threadIdx.x; i < (blocksize / 2); i += blockDim.x * gridDim.x){
 //       y[i] = a * x[i] + y[i];
 //   }
  for (int j = blockIdx.y * blockDim.y + threadIdx.y; j < tableSize; j += blockDim.y * gridDim.y) {
      float* row_d_matrix = (float*)((char*)array + j*pitch);
      for (int i = blockIdx.x * blockDim.x + threadIdx.x; i < tableSize; i += blockDim.x * gridDim.x) {
          row_d_matrix[i] = i;
         // row_d_matrix[i] = (j * tableSize + i) + (j * tableSize + i);
      }
  }
}
/*
__global__ void fillPlateWithTemperature( int *current,int *old)
{
  int index_x = blockIdx.x * blockDim.x + threadIdx.x;
  int index_y = blockIdx.y * blockDim.y + threadIdx.y;
  int grid_width = gridDim.x * blockDim.x;
  int index = index_y * grid_width + index_x;

    for (int row = 0 ; row < tableSize; row++ ) {
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
        }
    }
    for (int col = 0; col < 331 ; col++) {
        current[400][col]=100.0;
        old[400][col]=100.0;
    }
    current[200][500]=100.0;
    old[200][500]=100.0;


    
}
*/
int iDivUp(int a, int b){ return ((a % b) != 0) ? (a / b + 1) : (a / b); }


int main(void)
{
  int num_elements_x = tableSize;
  int num_elements_y = tableSize;

  int num_bytes = num_elements_x * num_elements_y * sizeof(int);

  float *device_array = 0;
  float host_array [tableSize][tableSize];
  size_t pitch;
  // cudaMalloc a device array
  cudaMallocPitch(&device_array, &pitch, tableSize * sizeof(float), tableSize * sizeof(float));
  cudaMemcpy2D(device_array,pitch,host_array,tableSize * sizeof(float),tableSize * sizeof(float),tableSize, cudaMemcpyHostToDevice);


  // create 512x512 thread blocks
  dim3 block_size;
  block_size.x = blocksize/2;
  block_size.y = blocksize/2;

  // configure a two dimensional grid as well
  dim3 grid_size;
  grid_size.x = iDivUp( num_elements_x , block_size.x);
  grid_size.y = iDivUp( num_elements_y , block_size.y);

  // grid_size & block_size are passed as arguments to the
  // triple chevrons as usual
  kernel<<<grid_size,block_size>>>( device_array, pitch );

  // download and inspect the result on the host:
  cudaMemcpy2D(host_array, pitch , device_array,  tableSize * sizeof(float),tableSize * sizeof(float),tableSize, cudaMemcpyDeviceToHost);
  cudaMemcpy(host_array, device_array, num_bytes, cudaMemcpyDeviceToHost);

  // print out the result element by element
  for(int row = 0; row < num_elements_y; ++row)
  {
    for(int col = 0; col < num_elements_x; ++col)
    {
      printf("%2d ", host_array[row * num_elements_x + col]);
    }
    printf("\n");
  }
  printf("\n");

  // deallocate memory
  free(host_array);
  cudaFree(device_array);
}