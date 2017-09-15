#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define F 0x2000
#define M (F/4)

int main() {
    unsigned char s = 0;
    unsigned char b = 62;
    unsigned char n = 0;
    int u = 0;
    for(int i = 0; i < F * 60; ++i) {
        if (i & M) {
//             // beat
            if ((i & (M - 1)) < M/16) {
                n -= 2;
            } else {
                n = 0;
            }
//             
//         }
//         if (i & 2) {
//             s ^= 0xA0;
        }
//         n = rand() % 10;
        s = 0;
        switch(i / (M*4)) {
            case 0:
                s += abs((i&127) - 64) << 2;
                break;
            case 1:
                s += i & 127;
                break;
            case 2:
                s += i & 64;
                break;
            default:
            case 3:
                s += 128.0*sin(2*M_PI*i/128);
        }
        s = i & 48 & i >> 8;
        s = 224 & (i*3) & i >> 9;
        s = (i * 3) & (b ^ 37 & 124) & (i >> 8);
        if ((i & 1535) == 0) {
            b <<= 1;
            b |= 1 & (b >> 7 ^ b >> 5 ^ b >> 4 ^ b >> 3 ^ 1);
            fprintf(stderr, "\n%d", (unsigned int)b);
        }
        // s = (i*3)&128;
        // s = i*(i & 146);
        s+=n;
        putchar(s);
    }
    return 0;
}
