/*
 * stack.h
 *
 *  Created on: 2/10/2014
 *      Author: matias
 */

#ifndef STACK_H_
#define STACK_H_

#include <stdio.h>
#include <stdlib.h>

struct stack{
	char* tag;
	struct stack* next;
};

struct stack *top;

void push(char* tag);
char* pop();
void imprimir();

#endif /* STACK_H_ */
