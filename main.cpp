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
#include "calculation.h"
#include "toolkit.h"
#include "timer.h"


void cpu_aes_encrypt(unsigned char *pt, int *rk, unsigned char *ct, long int size, wtime_t &time){
  start_timer();
  launch_cpu_aes(pt, rk, ct, size);
  stop_timer();
  time = elapsed_millis();
}

void gpu_aes_encrypt(unsigned char *pt, int *rk, unsigned char *ct, long int size, wtime_t &time){
  start_timer();
  launch_aes_kernel(pt, rk, ct, size);
  stop_timer();
  time = elapsed_millis();
}



int main(int argc, char **argv){

  unsigned char keys[] = {0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,
                          0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f};

  unsigned char key[16];
  int w[44];  /* FIPS 197 P.19 5.2 Key Expansion */

  unsigned char * plaintext;
  unsigned char * ciphertext;
  unsigned char * ciphertext2;
  wtime_t cpu_time, gpu_time;

  printf("initialize..\n");
  //malloc
  plaintext   = (unsigned char*)malloc(sizeof(unsigned char)*FILESIZE);
  ciphertext  = (unsigned char*)malloc(sizeof(unsigned char)*FILESIZE);
  ciphertext2 = (unsigned char*)malloc(sizeof(unsigned char)*FILESIZE);

  // set plaintext with random numbers
  srand((unsigned)time(NULL));
  for(int i = 0; i < FILESIZE; i++){
    plaintext[i] = rand()&0xff;
    ciphertext[i] = 0;
    ciphertext2[i]= 0;
  }

  //Only initial 16 bytes are given fixed data.
  plaintext[0]  = 0x00;
  plaintext[1]  = 0x11;
  plaintext[2]  = 0x22;
  plaintext[3]  = 0x33;
  plaintext[4]  = 0x44;
  plaintext[5]  = 0x55;
  plaintext[6]  = 0x66;
  plaintext[7]  = 0x77;
  plaintext[8]  = 0x88;
  plaintext[9]  = 0x99;
  plaintext[10] = 0xaa;
  plaintext[11] = 0xbb;
  plaintext[12] = 0xcc;
  plaintext[13] = 0xdd;
  plaintext[14] = 0xee;
  plaintext[15] = 0xff;

  plaintext[16] = 0x00;
  plaintext[17] = 0x01;
  plaintext[18] = 0x02;
  plaintext[19] = 0x03;
  plaintext[20] = 0x04;
  plaintext[21] = 0x05;
  plaintext[22] = 0x06;
  plaintext[23] = 0x07;
  plaintext[24] = 0x08;
  plaintext[25] = 0x09;
  plaintext[26] = 0x0a;
  plaintext[27] = 0x0b;
  plaintext[28] = 0x0c;
  plaintext[29] = 0x0d;
  plaintext[30] = 0x0e;
  plaintext[31] = 0x0f;
  
  /* FIPS 197  P.35 Appendix C.1 AES-128 Test */
  memcpy(key, keys, 16);
  KeyExpansion(key, w); //Preparation of round keys for AES encryption

  create_timer();  

  cpu_aes_encrypt(plaintext, w, ciphertext, FILESIZE, cpu_time);
  gpu_aes_encrypt(plaintext, w, ciphertext2, FILESIZE, gpu_time);
  verification(ciphertext, ciphertext2, FILESIZE);
  
  print_time(cpu_time, gpu_time);
  print_initial_16bytes(plaintext, ciphertext, ciphertext2);
  
  destroy_timer();

  free(plaintext);
  free(ciphertext);
  free(ciphertext2);
  
  return 0;
}

