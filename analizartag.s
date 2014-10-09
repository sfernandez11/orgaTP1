#int analizarTag(char* text, char* tagEncontrado, int pos, int *contadorLineas)
#{
#	while(text[pos] != '\0')
#	{
#		if(text[pos] == '\n')
#		{
#			(*contadorLineas)++;
#		}
#		if(text[pos] == '<')
#		{
#			pos++;
#			// Si entra en cerrar un tag
#			if(text[pos] == '/')
#			{
#				pos++;
#				int j = 0;
#				while(text[pos] != '>')
#				{
#					if(tagEncontrado[j] != text[pos])
#					{
#						return -2;
#					}
#					j++;	pos++;
#				}
#				return pos;
#			}  else {
#				int contadorTag = pos;
#				while(text[contadorTag] != '>')
#				{
#					contadorTag++;
#				}
#				contadorTag = contadorTag - pos;
#				int k = 0;
#				char* tagALevantar = malloc(sizeof(char)*contadorTag);
#				while(text[pos] != '>')
#				{
#					tagALevantar[k] = text[pos];
#					k++; pos++;
#				}
#				pos++;
#				int posSiguiente;
#				posSiguiente = analizarTag(text, tagALevantar, pos, contadorLineas);
#				free(tagALevantar);
#				switch(posSiguiente)
#				{
#					return -1;
#					break;
#				case -2:
#					return -2;
#					break;
#
#				default:
#					pos = posSiguiente;
#					break;
#
#				}
#			}
#		}
#		pos++;
#	}
#	return -1;
#}
##################################################################

#include <mips/regdef.h>
#include <sys/syscall.h>

#define ATAG_SS			32
#define ATAG_RA  		24
#define ATAG_FP			20
#define ATAG_GP			16
#define ATAG_ARG0		0
#define ATAG_ARG1  		4
#define ATAG_ARG2		8
#define ATAG_ARG3		12

	.text
	.align	2
	.globl	analizarTag
	.ent	analizarTag

analizarTag:
		#Creo el stack frame
	subu	sp,	sp,	ATAG_SS
	sw		ra,	ATAG_RA(sp)	
	sw		$fp,ATAG_FP(sp)
	sw		gp, ATAG_GP(sp)
	sw		a0,ATAG_ARG0($fp)
	sw		a1,ATAG_ARG1($fp)
	sw 		a2,ATAG_ARG2($fp)
	sw 		a3,ATAG_ARG3($fp)

whileDistintoDeEnd:
		


errorNoCerrado;
	li	v0,-1	# return -1;
	b salirATAG

errorAnidado:
	li 	v0,-2	# return -2;
	b salirATAG

salirATAG:
	#Destruye stack frame
	lw		ra, ATAG_RA(sp)
	lw		$fp,ATAG_FP(sp)
	lw		gp, ATAG_GP(sp)
	addu	sp,sp,ATAG_SS
	j		ra

.end analizarTag
