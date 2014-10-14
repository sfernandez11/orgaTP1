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
#define SALTO_DE_LINEA	10
#define BARRA 			47
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

	#Texto = t0; 		Pos= t1; 				tagLevantado= t2
	#contadorLinea= t3; j(tagEncontrado)= t4; 	k(tagALevantar)= t5
	#auxiliar= t6;		contadorTag= t7

whileDistintoDeEnd:
	lw		t0,ATAG_ARG0(sp)	#Cargo la direc el texto
	lw		t1,ATAG_ARG2(sp)	#Cargo la direc de la pos
	addu	t0,t1,t0			#Muevo la direc del texto a la pos
	lb		t0,0(t0)			#Cargo el texto en la pos(cargo un char)
	bne		t0,FIN_TEXTO,verSiEsSaltoDeLinea 	#Distino de fin de texto
	b		errorNoCerrado		#LLegue al fin del texto y no cerre el tag

verSiEsSaltoDeLinea:
	#li		t6,SALTO_DE_LINEA	#Carga el caracter de salto de linea '\n'
	bne		t0,SALTO_DE_LINEA,verSiComienzaTag	#Si no es salto de linea, salta  a analizar si empieza un tag

	#Si es igual a salto de linea, tengo que sumar uno al contador de lineas#

	lw		t3,ATAG_ARG3(sp)	#Guardo la direccion de contadorLineas
	lw		t6,ATAG_ARG3(sp)	#Guardo la direccion de contadorLineas
	lw		t3,0(t3)			#Cargo contadorLineas(int)
	addiu	t3,t3,1 			#Le sumo uno a contadorLineas
	sw		t3,ATAG_ARG3(sp)	#Guardo en la direc de contadorLineas, contadorLineas + 1

verSiComienzaTag:
	#li		t6,MENOR			#Cargo el '<'
	beq		t0,MENOR,comienzaTag	#Si es igual a '<'salto a comienzaTag 
	addu	t1,t1,1 			#Si es distinto, le sumo uno a la pos
	sw 		t1, ATAG_ARG2(sp)	#Guardo pos++
	b 		whileDistintoDeEnd	#Vuelvo al principio

comienzaTag:
	#Antes encontre un '<', tengo que saltearlo sumandole uno a pos
	addu	t1,t1,1 			#Le sumo uno a pos
	sw 		t1, ATAG_ARG2(sp)	#Guardo pos++
	lw		t0,ATAG_ARG0(sp)	#Cargo la direc del texto
	addu	t0,t1,t0			#Muevo la direc del texto a la pos
	lb		t0,0(t0)			#Cargo el texto en la pos(cargo un char)
	#li 		t6, BARRA			#Cargo la barra en t6
	beq		t0, BARRA, comienzaCerrarTag	#Si text[pos] es igual a la barra empieza un cerrar tag
	# ACA VA EMPEZAR DE SANTI

comienzaCerrarTag:	
	#Tengo que saltear la barra, muevo el texto una pos
	addu	t1,t1,1 			#Le sumo uno a pos
	sw 		t1, ATAG_ARG2(sp)	#Guardo pos++
	lw		t0,ATAG_ARG0(sp)	#Cargo la direc del texto
	addu	t0,t1,t0			#Muevo la direc del texto a la pos
	lb		t0,0(t0)			#Cargo el texto en la pos(cargo un char)
	move 	t4,zero				# j = 0

whileDistintoDeCerrarTag:
	#li 		t6, MAYOR		#En t6 cargo el '>'
	lw		t2,ATAG_ARG1		#En t2 cargo la direcc de tagEncontrado
	addu 	t2,t2,t4			#En t2 guardo la direc de tagEncontrado[j]
	lw		t2,0(t2)			#Cargo tagEncontrado[j]
	beq 	t0, MAYOR, finCerrarTag		#Si text[pos] == '>' salto a finCerrarTag
	bne 	t0,t2,finCerrarTag	#Si el tagEncontrado[j] es distinto al text[pos] es un error
	addu 	t4,t4,1 			#Sumo uno a j
	addu 	t1,t1,1 			#Sumo uno a pos
	sw 		t1,ATAG_ARG2($fp)	#Guardo pos++
	lw		t0,ATAG_ARG0(sp)	#Cargo la direc el texto
	addu 	t0,t1,t0 			#Cargo la direc de text[pos] en t0
	lb		t0, 0(t0) 			#Cargo el text[pos] en t0
	b 		whileDistintoDeCerrarTag	#Salto al comienzo del while
	#ACA TENGO QUE SEGUIR(PACHO)

finCerrarTag:
	#Es un if doble
	#Revisa si el tag se cerro bien(tagEncontrado[j]=='\0' Y text[pos] == '>')
	bne 	t2, FIN_TEXTO, errorAnidado #Si el tagEncontrado no llego al fin, es un error
	bne 	t0, MAYOR, errorAnidado 	#Si el text[pos] no llego a '>' es un error
	b 		devolverPosActual			#Si se cumplio lo anterior tengo que devolver la pos

empezar:
	lw		t1,ATAG_ARG2(sp)			#Cargo la direc de la pos
	move 	t7, t1
	lw		t0,ATAG_ARG0(sp)			#Cargo la direc el texto
contadorTag:
	addu	t8,t0,t7					#Muevo la direc del texto a la pos
	lb		t9,0(t8)					#Cargo el texto en la pos
	bne		t9,MAYOR, aumentarConTag	#Distino de fin de texto
	subu	t8, t8, t7					#contadorTag = contadorTag - pos
	addiu	t8, t8, 1
	lw		a0,	t8						#cargo el argunmento de la funcion
	la 		t9, mymalloc				#Cargo en t9 la direccion de la funcion
	jal		t9							#llamo a la funcion malloc
	sw		v0, t8						#guardo en t8 la posicino de memoria que reserve

cargarTagALevantar:
	move 	t4, zero					# int k = 0;
	lw		t0,ATAG_ARG0(sp)			#Cargo la direc el texto
	lw		t1,ATAG_ARG2(sp)			#Cargo la direc de la pos
	addu	t0,t1,t0					#Muevo la direc del texto a la pos
	lb		t0,0(t0)					#Cargo el texto en la pos(cargo un char)
	bne		t0,MAYOR, aumentarVar		#Distino de fin de texto


actualizarVar:
	

aumentarConTag:
	lb		t7, 0(t7)					#Cargo el valor de contadorTag
	addiu	t7, t7, 1 					#contadorTag++
	b 		contadorTag	

switchPosSiguiente:
	#Comprara lo que devolvio analizarTag, v0 = analizarTag()
	li 		t6,-1 					#Cargo -1 en t6
	beq 	v0,t6, errorNoCerrado	#Si v0 es igual a -1, es un errorNoCerrad
	li 		t6,-2 					#Cargo -2 en t6
	beq 	v0, t6, errorAnidado 	#si v0 es igual a -2, es un errorAnidado
	#Si no devolvio ningun error, a pos le asigno posSiguiente: t2 = v0
 	move 	t2,v0 					#En t2 guardo v0 (pos = posSiguiente)
 	addiu 	t2,t2,1 				#Le sumo uno a pos
 	sw 		t2,ATAG_ARG2 			#Guardo la pos
 	b 		whileDistintoDeEnd
 	
devolverPosActual;
	move 	v0, t1				#Muevo el t1 que tiene la pos a v0
	b salirATAG					#Recupero los registros

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
