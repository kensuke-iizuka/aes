#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(){

    unsigned char output[16];
    unsigned char src[16] = {
	0x00, 0x01, 0x02, 0x03, 
	0x10, 0x11, 0x12, 0x13, 
	0x20, 0x21, 0x22, 0x23, 
	0x30, 0x31, 0x32, 0x33, 
	
    };

    int dst[4];

    printf("%d\n", src);
    memcpy(dst, src, 16);
    for (int i = 0; i < 4; i++){
	printf("----dst----");
	printf("%02x\n",dst[i]);
    }
    memcpy(output, dst, 16);
    for (int i = 0; i < 16; i++){
	printf("----output----");
	printf("%02x\n",output[i]);
    }
    return 0;
}
