#ifndef __CALCULATION_H_INCLUDED__
#define __CALCULATION_H_INCLUDED__

#define NB (4)                        /* 128bit 固定としての規格(データの長さ) */
#define NBb (16)

#define NK (4)                        /* 128-bit鍵モードでの鍵の長さ */
#define NR (10)                       /* ラウンド数 */

/********************************************************************************/
// You have to set FILESIZE to "16*128*13*16*512" at the time of your submission.
// Please do not modify the other parts in this file.
/*******************************************************************************/
//#define FILESIZE (32)
#define FILESIZE (16*128*13*16*512)

void SubBytes(int *);                 /* FIPS 197  P.16 Figure  6 */
void ShiftRows(int *);                /* FIPS 197  P.17 Figure  8 */
void MixColumns(int *);               /* FIPS 197  P.18 Figure  9 */
void AddRoundKey(int *, int *, int);  /* FIPS 197  P.19 Figure 10 */
int SubWord(int in);                  /* FIPS 197  P.20 Figure 11 */ /* FIPS 197  P.19  5.2 */
int RotWord(int in);                  /* FIPS 197  P.20 Figure 11 */ /* FIPS 197  P.19  5.2 */
void KeyExpansion(void *, int *);     /* FIPS 197  P.20 Figure 11 */
void Cipher(int *, int *);            /* FIPS 197  P.15 Figure  5 */

void launch_cpu_aes(unsigned char *in, int *rkey, unsigned char *out, long int size);
void launch_aes_kernel(unsigned char *pt, int *rk, unsigned char *ct, long int size);

#endif /* __CALCULATION_H_INCLUDED__ */
