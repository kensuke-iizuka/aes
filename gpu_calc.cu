#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "calculation.h"

#define NB (4)
#define NBb (16)

#define NK (4)
#define NR (10)
#define FILESIZE (16*128*13*16*512)
#define STREAM_NUM (32)

__device__ void gpuSubBytes(int *,int *);
__device__ void gpuShiftRows(int *);
__device__ int gpumul(int,int);
__device__ int gpudataget(void*, int);
__device__ void gpuMixColumns();
__device__ void gpuAddRoundKey(int *, int *, int);
__device__ void PrintPlainText(int *);
__device__ void gpuMixColumns(int *);
__device__ void ComputeTBoxes(int *,int *,int *,int *,int *);
__device__ unsigned long ConCat(unsigned char, unsigned char, unsigned char, unsigned char);
__device__ unsigned char GFMult(unsigned char , unsigned char );
__device__ void TBoxLUP(int *, int *, int *, int *);
__device__ void gpuCipher(int *, int *,int *);
__device__ void gpuCipher2(int *state, int *rkey, int *sbox, int *Tbox0, int *Tbox1, int *Tbox2, int *Tbox3);
__global__ void device_aes_encrypt(unsigned char *pt, int *rkey, unsigned char *ct, long int size){
    __shared__ int shareSbox[256];
    __shared__ int TBox0[256];
    __shared__ int TBox1[256];
    __shared__ int TBox2[256];
    __shared__ int TBox3[256];

    int gpuSbox[256] = {
         0x63,0x7c,0x77,0x7b,0xf2,0x6b,0x6f,0xc5,0x30,0x01,0x67,0x2b,0xfe,0xd7,0xab,0x76,
         0xca,0x82,0xc9,0x7d,0xfa,0x59,0x47,0xf0,0xad,0xd4,0xa2,0xaf,0x9c,0xa4,0x72,0xc0,
         0xb7,0xfd,0x93,0x26,0x36,0x3f,0xf7,0xcc,0x34,0xa5,0xe5,0xf1,0x71,0xd8,0x31,0x15,
         0x04,0xc7,0x23,0xc3,0x18,0x96,0x05,0x9a,0x07,0x12,0x80,0xe2,0xeb,0x27,0xb2,0x75,
         0x09,0x83,0x2c,0x1a,0x1b,0x6e,0x5a,0xa0,0x52,0x3b,0xd6,0xb3,0x29,0xe3,0x2f,0x84,
         0x53,0xd1,0x00,0xed,0x20,0xfc,0xb1,0x5b,0x6a,0xcb,0xbe,0x39,0x4a,0x4c,0x58,0xcf,
         0xd0,0xef,0xaa,0xfb,0x43,0x4d,0x33,0x85,0x45,0xf9,0x02,0x7f,0x50,0x3c,0x9f,0xa8,
         0x51,0xa3,0x40,0x8f,0x92,0x9d,0x38,0xf5,0xbc,0xb6,0xda,0x21,0x10,0xff,0xf3,0xd2,
         0xcd,0x0c,0x13,0xec,0x5f,0x97,0x44,0x17,0xc4,0xa7,0x7e,0x3d,0x64,0x5d,0x19,0x73,
         0x60,0x81,0x4f,0xdc,0x22,0x2a,0x90,0x88,0x46,0xee,0xb8,0x14,0xde,0x5e,0x0b,0xdb,
         0xe0,0x32,0x3a,0x0a,0x49,0x06,0x24,0x5c,0xc2,0xd3,0xac,0x62,0x91,0x95,0xe4,0x79,
         0xe7,0xc8,0x37,0x6d,0x8d,0xd5,0x4e,0xa9,0x6c,0x56,0xf4,0xea,0x65,0x7a,0xae,0x08,
         0xba,0x78,0x25,0x2e,0x1c,0xa6,0xb4,0xc6,0xe8,0xdd,0x74,0x1f,0x4b,0xbd,0x8b,0x8a,
         0x70,0x3e,0xb5,0x66,0x48,0x03,0xf6,0x0e,0x61,0x35,0x57,0xb9,0x86,0xc1,0x1d,0x9e,
         0xe1,0xf8,0x98,0x11,0x69,0xd9,0x8e,0x94,0x9b,0x1e,0x87,0xe9,0xce,0x55,0x28,0xdf,
         0x8c,0xa1,0x89,0x0d,0xbf,0xe6,0x42,0x68,0x41,0x99,0x2d,0x0f,0xb0,0x54,0xbb,0x16
    };
    memcpy(shareSbox, gpuSbox, sizeof(int) * 256);
    __syncthreads();
    ComputeTBoxes(shareSbox, TBox0, TBox1, TBox2, TBox3);
    __syncthreads();
    //This kernel executes AES encryption on a GPU.
    //Please modify this kernel!!

    int data[NBb];
    int thread_id = blockDim.x * blockIdx.x + threadIdx.x;
    memcpy(data, pt+16*thread_id, NBb); //With NB, 16 bytes are defined as 4 words.

    gpuCipher2(data, rkey, shareSbox, TBox0, TBox1, TBox2, TBox3);
    memcpy(ct+16*thread_id, data, NBb);
}


__device__ void gpuSubBytes(int *state, int *gpuSbox){
    int i, j;
    unsigned char *cb=(unsigned char*)state;
#pragma unroll
    for(i=0; i<NBb; i+=4){
        for(j=0; j<4; j++){
            cb[i+j] = gpuSbox[cb[i+j]];
        }
    }
}

// __device__ void gpuShiftRows(int *state){
//   int i, j, i4;
//   unsigned char *cb = (unsigned char*)state;
//   unsigned char cw[NBb];
//   memcpy(cw, cb, sizeof(cw));
//
//   for(i = 0;i < NB; i+=4){
//     i4 = i*4;
// #pragma unroll
//     for(j = 1; j < 4; j++){
//       cw[i4+j+0*4] = cb[i4+j+((j+0)&3)*4];
//       cw[i4+j+1*4] = cb[i4+j+((j+1)&3)*4];
//       cw[i4+j+2*4] = cb[i4+j+((j+2)&3)*4];
//       cw[i4+j+3*4] = cb[i4+j+((j+3)&3)*4];
//     }
//   }
//   memcpy(cb,cw,sizeof(cw));
// }
__device__ void gpuShiftRows(int *state){
  unsigned char *cb = (unsigned char*)state;
  unsigned char cw[NBb];
  memcpy(cw, cb, sizeof(cw));
  cw[1] = cb[5];
  cw[5] = cb[9];
  cw[9] = cb[13];
  cw[13] = cb[1];
  cw[2] = cb[10];
  cw[6] = cb[14];
  cw[10] = cb[2];
  cw[14] = cb[6];
  cw[3] = cb[15];
  cw[7] = cb[3];
  cw[11] = cb[7];
  cw[15] = cb[11];

  memcpy(cb,cw,sizeof(cw));
}

__device__ int gpumul(int dt,int n){
  int i, x = 0;
#pragma unroll
  for(i = 8; i > 0; i >>= 1)
    {
      x <<= 1;
      if(x & 0x100)
        x = (x ^ 0x1b) & 0xff;
      if((n & i))
        x ^= dt;
    }
  return(x);
}

__device__ int gpudataget(void* data, int n){
  return(((unsigned char*)data)[n]);
}

__device__ void gpuMixColumns(int *state){
  int i, i4, x;
  for(i = 0; i< NB; i++){
    i4 = i*4;
    x  =  gpumul(gpudataget(state,i4+0),2) ^
          gpumul(gpudataget(state,i4+1),3) ^
          gpumul(gpudataget(state,i4+2),1) ^
          gpumul(gpudataget(state,i4+3),1);
    x |= (gpumul(gpudataget(state,i4+1),2) ^
          gpumul(gpudataget(state,i4+2),3) ^
          gpumul(gpudataget(state,i4+3),1) ^
          gpumul(gpudataget(state,i4+0),1)) << 8;
    x |= (gpumul(gpudataget(state,i4+2),2) ^
          gpumul(gpudataget(state,i4+3),3) ^
          gpumul(gpudataget(state,i4+0),1) ^
          gpumul(gpudataget(state,i4+1),1)) << 16;
    x |= (gpumul(gpudataget(state,i4+3),2) ^
          gpumul(gpudataget(state,i4+0),3) ^
          gpumul(gpudataget(state,i4+1),1) ^
          gpumul(gpudataget(state,i4+2),1)) << 24;
    state[i] = x;
  }
}

__device__ void gpuAddRoundKey(int *state, int *w, int n){
    int i;
#pragma unroll
    for(i = 0; i < NB; i++) {
        state[i] ^= w[i + NB * n];
    }
}
__device__ void PrintPlainText(int *state){
  int i;
  unsigned char *cdt = (unsigned char *)state;
  for (i = 0; i < 16; i++) {
    printf("%02x", cdt[i]);
  }
  printf("\n");
}
// __device__ void gpudatadump(const char *c, void *dt, int len){
//   int i;
//   unsigned char *cdt = (unsigned char *)dt;
//   printf("%s", c);
//   for(i = 0; i < len*4;i++){
//     printf("%02x", cdt[i]);
//   }
//   printf("\n");
// }

// concatenate four byte to a dword
__device__ unsigned long ConCat(unsigned char b0, unsigned char b1, unsigned char b2, unsigned char b3){
	unsigned long dwDword = 0;
	dwDword += b0;
	dwDword = (dwDword << 8);
	dwDword += b1;
	dwDword = (dwDword << 8);
	dwDword += b2;
	dwDword = (dwDword << 8);
	dwDword += b3;
	return dwDword;
}

// multiply in GF 2^8 and reduce by AES polynom if necessary
__device__ unsigned char GFMult(unsigned char bFac1, unsigned char bFac2) {
	unsigned char p = 0;
	unsigned char counter;
	unsigned char hi_bit_set;
	for(counter = 0; counter < 8; counter++) {
		if((bFac2 & 1) == 1)
			p ^= bFac1;
		hi_bit_set = (bFac1 & 0x80);
		bFac1 <<= 1;
		if(hi_bit_set == 0x80)
			bFac1 ^= 0x1b;
		bFac2 >>= 1;
	}
	return p;
}
__device__ void ComputeTBoxes(int *Sbox, int *TBox0, int *TBox1, int *TBox2, int *TBox3){
	for(int i = 0; i < 256; i++){
		TBox0[i] = ConCat( GFMult(Sbox[i], 02), Sbox[i], Sbox[i], GFMult(Sbox[i], 03) );
		TBox1[i] = ConCat( GFMult(Sbox[i], 03), GFMult(Sbox[i], 02), Sbox[i], Sbox[i] );
		TBox2[i] = ConCat( Sbox[i], GFMult(Sbox[i], 03), GFMult(Sbox[i], 02), Sbox[i] );
		TBox3[i] = ConCat( Sbox[i], Sbox[i], GFMult(Sbox[i], 03), GFMult(Sbox[i], 02) );
	}
}

__device__ void TBoxLUP(int *state, int *TBox0, int *TBox1, int *TBox2, int *TBox3) {

    unsigned char *cb = (unsigned char*)state;
    unsigned long e0 = TBox0[cb[0]] ^ TBox1[cb[5]] ^ TBox2[cb[10]] ^ TBox3[cb[15]];
    unsigned long e1 = TBox0[cb[4]] ^ TBox1[cb[9]] ^ TBox2[cb[14]] ^ TBox3[cb[3]];
    unsigned long e2 = TBox0[cb[8]] ^ TBox1[cb[13]] ^ TBox2[cb[2]] ^ TBox3[cb[7]];
    unsigned long e3 = TBox0[cb[12]] ^ TBox1[cb[1]] ^ TBox2[cb[6]] ^ TBox3[cb[11]];
    cb[0] = (e0 >> 24) & 0xff;
    cb[1] = (e0 >> 16) & 0xff;
    cb[2] = (e0 >> 8) & 0xff;
    cb[3] = e0 & 0xff;
    cb[4] = (e1 >> 24) & 0xff;
    cb[5] = (e1 >> 16) & 0xff;
    cb[6] = (e1 >> 8) & 0xff;
    cb[7] = e1 & 0xff;
    cb[8] = (e2 >> 24) & 0xff;
    cb[9] = (e2 >> 16) & 0xff;
    cb[10] = (e2 >> 8) & 0xff;
    cb[11] = e2 & 0xff;
    cb[12] = (e3 >> 24) & 0xff;
    cb[13] = (e3 >> 16) & 0xff;
    cb[14] = (e3 >> 8) & 0xff;
    cb[15] = e3 & 0xff;
}
__device__ void gpuCipher(int *state, int *rkey, int *sbox){
  int rnd;

  gpuAddRoundKey(state, rkey, 0);

#pragma unroll
  for(rnd = 1; rnd < NR; rnd++){
    gpuSubBytes(state, sbox);
    gpuShiftRows(state);
    gpuMixColumns(state);
    gpuAddRoundKey(state, rkey, rnd);
  }

  gpuSubBytes(state, sbox);
  gpuShiftRows(state);
  gpuAddRoundKey(state, rkey, rnd);

  //return 0;
}
__device__ void gpuCipher2(int *state, int *rkey, int *sbox, int *TBox0, int *TBox1, int *TBox2, int *TBox3){
  int rnd;

  gpuAddRoundKey(state, rkey, 0);

#pragma unroll
  for(rnd = 1; rnd <NR; rnd++){
    TBoxLUP(state, TBox0, TBox1, TBox2, TBox3);
    gpuAddRoundKey(state, rkey, rnd);
  }
  gpuSubBytes(state, sbox);
  gpuShiftRows(state);
  gpuAddRoundKey(state, rkey, rnd);
  //return 0;
}
void launch_aes_kernel(unsigned char *pt, int *rk, unsigned char *ct, long int size){

  //This function launches the AES kernel.
  //Please modify this function for AES kernel.
  //In this function, you need to allocate the device memory and so on.

  unsigned char *d_pt, *d_ct;
  int *d_rkey;
  unsigned int length = FILESIZE / STREAM_NUM;
  //unsigned int char_ptr = sizeof(unsigned char) * length;
  cudaMalloc((void **)&d_pt, sizeof(unsigned char)*size);
  cudaMalloc((void **)&d_rkey, sizeof(int)*44);
  cudaMalloc((void **)&d_ct, sizeof(unsigned char)*size);


// TODO:Using Stream
  dim3 dim_grid(FILESIZE/16/512/STREAM_NUM,1,1), dim_block(512,1,1);
  cudaStream_t streams[STREAM_NUM];
  cudaMemcpy(d_rkey, rk, sizeof(int)*44, cudaMemcpyHostToDevice);

  for (int i = 0; i < STREAM_NUM; i++){
      cudaStreamCreate(&streams[i]);
  }

  for (int i = 0; i < STREAM_NUM; i++){
      const int curStream = i;
      int pt_d = i * length;

      cudaMemcpyAsync(d_pt + pt_d, pt+ pt_d, sizeof(unsigned char)*length, cudaMemcpyHostToDevice, streams[curStream]);
      device_aes_encrypt<<<dim_grid, dim_block, 0, streams[curStream]>>>(d_pt + pt_d, d_rkey, d_ct + pt_d, size);
  }

  for (int i = 0; i < STREAM_NUM; i++){
      int pt_d = i * length;
      cudaMemcpyAsync(ct + pt_d, d_ct+ pt_d, sizeof(unsigned char)*length, cudaMemcpyDeviceToHost, streams[i]);
  }

  for (int i = 0; i < STREAM_NUM; i++){
      cudaStreamSynchronize(streams[i]);
      cudaStreamDestroy(streams[i]);
  }

  //Normal Mode
  // dim3 dim_grid(FILESIZE/16/512,1,1), dim_block(512,1,1);

  // cudaMalloc((void **)&d_pt, sizeof(unsigned char)*size);
  // cudaMalloc((void **)&d_rkey, sizeof(int)*44);
  // cudaMalloc((void **)&d_ct, sizeof(unsigned char)*size);

  // cudaMemset(d_pt, 0, sizeof(unsigned char)*size);
  // cudaMemcpy(d_pt, pt, sizeof(unsigned char)*size, cudaMemcpyHostToDevice);
  // cudaMemcpy(d_rkey, rk, sizeof(int)*44, cudaMemcpyHostToDevice);

  // device_aes_encrypt<<<dim_grid, dim_block>>>(d_pt, d_rkey, d_ct, size);

  // cudaMemcpy(ct, d_ct, sizeof(unsigned char)*size, cudaMemcpyDeviceToHost);

  //cudaFree(d_pt);
  //cudaFree(d_ct);
}
