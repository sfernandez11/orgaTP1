#ifndef VALIDATE_H_
#define VALIDATE_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <getopt.h>
#include "mymalloc.h"

extern int validate(char* text, char** errmsg);
extern int analizarTag(char* text, char* tagEncontrado, int pos, int *contadorLineas);


#endif /* VALIDATE_H_ */
