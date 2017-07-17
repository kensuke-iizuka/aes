#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "calculation.h"


__global__ void device_aes_encrypt(unsigned char *pt, int *rkey, unsigned char *ct, long int size){

  //This kernel executes AES encryption on a GPU.
  //Please modify this kernel!!
  int thread_id = blockDim.x * blockIdx.x + threadIdx.x;
  int data[16];
  memcpy(data, pt, 16);
  if(thread_id == 0)
    printf("size = %ld\n", size);

  printf("You can use printf function to eliminate bugs in your kernel.\n");
  printf("This thread ID is %d.\n", thread_id);

  //...
  PrintText(*data);
}


__device__ void SubBytes(){

}

__device__ void ShiftRows(){

}

__device__ void MixColumns(){

}

__device__ void AddRoundKey(){

}
__device__ void PrintText(int *state){
  for (int i = 0; i < 16; i++) {
    printf("%d ", state[i]);
  }
  printf("\n");
}
__device__ void Cipher(int *state, int *rkey){
  // int rnd;
  // int i;
  //
  // AddRoundKey();
  //
  // for(rnd = 1; rnd < NR; rnd++){
  //   SubBytes(state);
  //   ShiftRows(state);
  //   MixColumns(state);
  //   AddRoundKey(state, rkey, rnd);
  // }
  //
  // SubBytes(state);
  // ShiftRows(state);
  // AddRoundKey(state, rkey, rnd);
  //
  // return 0;
}

void launch_aes_kernel(unsigned char *pt, int *rk, unsigned char *ct, long int size){

  //This function launches the AES kernel.
  //Please modify this function for AES kernel.
  //In this function, you need to allocate the device memory and so on.

  unsigned char *d_pt, *d_ct;
  int *d_rkey;

  dim3 dim_grid(FILESIZE/16,1,1), dim_block(1,1,1);

  cudaMalloc((void **)&d_pt, sizeof(unsigned char)*size);
  cudaMalloc((void **)&d_rkey, sizeof(int)*44);
  cudaMalloc((void **)&d_ct, sizeof(unsigned char)*size);

  cudaMemset(d_pt, 0, sizeof(unsigned char)*size);
  cudaMemcpy(d_pt, pt, sizeof(unsigned char)*size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_rkey, rk, sizeof(int)*44, cudaMemcpyHostToDevice);

  device_aes_encrypt<<<dim_grid, dim_block>>>(d_pt, d_rkey, d_ct, size);

  cudaMemcpy(ct, d_ct, sizeof(unsigned char)*size, cudaMemcpyDeviceToHost);

  cudaFree(d_pt);
  cudaFree(d_ct);
}
