################################################################################
#
CUDA_PATH = /usr/local/cuda/7.0
#
################################################################################
#
CC       = gcc
CXX      = g++
NVCC     = ${CUDA_PATH}/bin/nvcc
RM       = /bin/rm
AR       = ar
#
################################################################################
#
CFLAGS   += -O3 -Wall
CFLAGS   += -g
LDFLAGS  += -L -lm
LDFLAGS  += -L${CUDA_PATH}/lib64 -lcudart -lcudadevrt
NFLAGS   += -arch sm_52
NFLAGS   += -O3
NFLAGS   += -dc
# NFLAGS   += --ptxas-options=-v
#
################################################################################
#
PROG      = aes
OBJS	  = timer.o toolkit.o cpu_calc.o gpu_calc.o main.o
#
################################################################################

aes: ${OBJS}
	$(NVCC) -o $(PROG) $(LDFLAGS) -arch sm_52 $^

.SUFFIXES: .cpp .c .cu

.cpp.o:
	${CXX} -c ${LDFLAGS} ${CFLAGS} $<
.c.o:
	${CXX} -c ${LDFLAGS} ${CFLAGS} $<
.cu.o:
	${NVCC} -c -lm ${NFLAGS} $<

data: data.c
	${CC} -o $@ $^ -lm

clean :
	${RM} -f ${PROG} *.o *.out *~ data

update :
	make clean; make