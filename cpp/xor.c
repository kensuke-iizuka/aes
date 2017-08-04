#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(){

    int weight = 0x3020100;
    int act = 0x00112233;
    int out = weight ^ act;
    printf("%02x\n", out);
    return 0;
}
