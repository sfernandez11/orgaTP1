#ifndef VALIDATE_H_
#define VALIDATE_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <getopt.h>

#include "stack.h"

extern const char** errmsg;

int validate(char *text, char **errmsg);

#endif /* VALIDATE_H_ */
