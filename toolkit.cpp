/**************************************/
/* You don't have to change this code */
/* Please modify the "gpu_calc.cu"    */
/**************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <malloc.h>
#include <time.h>
#include "timer.h"


void verification(unsigned char *ct, unsigned char *ct2, long int size){
  printf("Verification finished... Overall data size: %ld bytes\n", size);
  for(int i = 0; i < size; i++)
    if(ct[i] != ct2[i]){
      fprintf(stderr,"\nVerification error detected. Position %d. cpu 0x%x, gpu 0x%x \n",	i, ct[i], ct2[i]);
      exit(1);
    }
  printf(" OK.\n");
}


void print_time(wtime_t cpu_time, wtime_t gpu_time){
  printf("Elapsed time on CPU: %.6f [msec]\n", cpu_time);
  printf("Elapsed time on GPU: %.6f [msec]\n", gpu_time);

  printf("Acceleration rate  : %f times faster than the CPU\n", cpu_time/gpu_time);
}


void print_initial_16bytes(unsigned char *plaintext, unsigned char *ciphertext, unsigned char *ciphertext2){

  printf("######### The case of initial 16 bytes (for error check) #######\n");
  printf("Plaintext        : ");
  for(int i = 0; i < 16; i++){
    printf("%02x", plaintext[i]);
  }
  printf("\n");  

  printf("Ciphertext on CPU: ");
  for(int i = 0; i < 16; i++){
    printf("%02x", ciphertext[i]);
  }
  printf("\n");

  printf("Ciphertext on GPU: ");
  for(int i = 0; i < 16; i++){
    printf("%02x", ciphertext2[i]);
  }
  printf("\n");
}
