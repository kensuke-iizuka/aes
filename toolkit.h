#ifndef __TOOLKIT_H_INCLUDED__
#define __TOOLKIT_H_INCLUDED__

#include "timer.h"

void print_time(wtime_t cpu_time, wtime_t gpu_time);
void print_initial_16bytes(unsigned char *pt, unsigned char *ct, unsigned char *ct2);
void verification(unsigned char *ct, unsigned char *ct2, long int size);

#endif /* __TOOLKIT_H_INCLUDED__ */
