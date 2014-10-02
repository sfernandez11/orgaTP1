/*
 * stack.c
 *
 *  Created on: 2/10/2014
 *      Author: matias
 */

#include "stack.h"

void push(char* tag){

	struct stack *temp;
	temp = (struct stack*)malloc(sizeof(struct stack));
	temp->tag = tag;
	temp->next=0;

	if(top == 0) {
		top = temp;
	} else {
		temp->next=top;
		top = temp;
	}

}
char* pop() {

	char* tag;
    struct stack *ptr;

     if(top == 0){
	  	printf("\n Stack is empty");
     } else {
		tag = top->tag;
		ptr = top;
		top = top->next;
		free(ptr);
     }

     return tag;
}

void imprimir()
{
	struct stack *temp;
	printf("\n Elementos de la pila: ");
	for( temp = top; temp != 0; temp = temp->next)
		printf("\n %s", temp->tag);
}
