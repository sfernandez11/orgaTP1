#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <getopt.h>

extern const unsigned char hexa[];

extern const char* b16_errmsg[];

typedef enum {ENCODE, DECODE, INVALIDA} Action;

int posicion(unsigned char caracter);

int encode(int infd, int outfd);  

int decode(int infd, int outfd);

