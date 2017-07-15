/**************************************/
/* You don't have to change this code */
/* Please modify the "gpu_calc.cu"    */
/**************************************/

#include <cuda_runtime.h>
#include "timer.h"

static cudaEvent_t start, stop;

void create_timer(){
  cudaEventCreate(&start);
  cudaEventCreate(&stop);
}

void destroy_timer(){
  cudaEventDestroy(start);
  cudaEventDestroy(stop);
}

void start_timer(){
  cudaEventRecord(start, 0);
}

void stop_timer(){
  cudaEventRecord(stop, 0);
}

wtime_t elapsed_millis(){
  wtime_t elapsed;
  cudaEventSynchronize(stop);
  cudaEventElapsedTime(&elapsed, start, stop);
  return elapsed;
}
