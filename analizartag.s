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

#define FIN_TEXTO 		0
#define BARRA 			47
#define SALTO_DE_LINEA	10
#define MENOR			60
#define MAYOR 			62

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
	sw		a0,ATAG_ARG0(sp)
	sw		a1,ATAG_ARG1(sp)
	sw 		a2,ATAG_ARG2(sp)
	sw 		a3,ATAG_ARG3(sp)

	#Texto = t0; Pos= t1; tagLevantado= t2;
	#contadorLinea= t3; j(tagEncontrado)= t4; k(tagALevantar)= t5;
	#auxiliar = t6;  contadorTag = t7

whileDistintoDeEnd:
	lw	t0,ATAG_ARG0(sp)	#Cargo la direc el texto
	lw	t1,ATAG_ARG2(sp)	#Cargo la direc de la pos
	addu	t0,t1,t0		#Muevo la direc del texto a la pos
	lb	t0,0(t0)			#Cargo el texto en la pos
	bne	t0,zero,saltoDeLinea 	#Distino de fin de texto
	b	errorNoCerrado		#LLegue al fin del texto y no cerre el tag

saltoDeLinea:
	li	t6,10				# Carga 
	bne	$v1,$v0,$L21


empezar:
	move 	t7, t1
	lw		t0,ATAG_ARG0(sp)			#Cargo la direc el texto
contadorTag:
	addu	t8,t0,t7					#Muevo la direc del texto a la pos
	lb		t9,0(t8)					#Cargo el texto en la pos
	bne		t9,MAYOR, aumentarConTag	#Distino de fin de texto
	subu	t8, t8, t7					#contadorTag = contadorTag - pos;
	lw		a0,	t8						#cargo el argunmento de la funcion
	jal		mymalloc					#llamo a la funcion malloc
	sw		v0, t8						#guardo en t8 la posicino de memoria que reserve

cargarTagALevantar:
	



aumentarConTag:
	addiu	t7, t7, 1 					#contadorTag++
	b 		contadorTag	


		
devolverPosActual;
	move 	v0, TEMPORALPOS
	b salirATAG

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
