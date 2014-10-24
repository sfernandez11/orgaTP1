#include <mips/regdef.h>
#include <sys/syscall.h>

#Argumentos de la funcion
#define ATAG_ARG3		52
#define ATAG_ARG2		48
#define ATAG_ARG1  		44
#define ATAG_ARG0		40

#Stack Size
#define ATAG_SS			40

#SRA
#define ATAG_RA  		32
#define ATAG_FP			28
#define ATAG_GP			24

#LTA
#define TAG_A_LEVANTAR 	16
#define VAR_AUX 		20

#ABA
#define ABA_3			12
#define ABA_2			8
#define ABA_1			4
#define ABA_0			0

#Constantes
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
	.set	noreorder
	.cpload	t9
	.set	reorder
	#Creo el stack frame
	subu	sp,	sp,	ATAG_SS
	sw		ra,	ATAG_RA(sp)	
	sw		$fp,ATAG_FP(sp)
	sw		gp, ATAG_GP(sp)
	move 	$fp, sp
	sw		a0,ATAG_ARG0($fp)
	sw		a1,ATAG_ARG1($fp)
	sw 		a2,ATAG_ARG2($fp)
	sw 		a3,ATAG_ARG3($fp)

	# CONVENCION DE LOS TEMPORALES
	#Texto = t0; 			Pos = t1; 					tagLevantado = t2
	#contadorLinea = t3 	j/k(tagEncontrado)= t4; 	k(tagALevantar)= t5
	#auxiliar= t6;			contadorTag= t7

whileDistintoDeEnd:
	lw		t0, ATAG_ARG0($fp)				#Cargo la direc el texto
	lw		t1, ATAG_ARG2($fp)				#Cargo la pos
	addu	t0, t0,t1						#Muevo la direc del texto a la pos
	lb		t0, 0(t0)						#Cargo el texto en la pos(cargo un char)
	li 		t6, FIN_TEXTO					#Cargo el fin de texto
	bne		t0, t6,verSiEsSaltoDeLinea 		#Distino de fin de texto
	b		errorNoCerrado					#LLegue al fin del texto y no cerre el tag

verSiEsSaltoDeLinea:
	lw		t0, ATAG_ARG0($fp)				#Cargo la direc el texto
	lw		t1, ATAG_ARG2($fp)				#Cargo la pos
	addu	t0, t0,t1						#Muevo la direc del texto a la pos
	lb		t0, 0(t0)						#Cargo el texto en la pos(cargo un char)
	li 		t6, SALTO_DE_LINEA				#Cargo el salto de linea
	bne		t0, t6,verSiComienzaTag			#Si no es salto de linea, salta a analizar si empieza un tag

	#Si es igual a salto de linea, tengo que sumar uno al contador de lineas
	lw		t3, ATAG_ARG3($fp)				#Cargo la direccion de contadorLineas
	lw 		t6, ATAG_ARG3($fp)				#Cargo un auxiliar para no perder la referencia
	lw		t6, 0(t6)						#Cargo contadorLineas(int)
	addu	t6, t6,1 						#Le sumo uno a contadorLineas
	sw		t6,	0(t3)						#Guardo en la direc de contadorLineas, contadorLineas + 1
	 		
verSiComienzaTag:
	lw		t0, ATAG_ARG0($fp)				#Cargo la direc el texto
	lw		t1, ATAG_ARG2($fp)				#Cargo la pos
	addu	t0, t0,t1						#Muevo la direc del texto a la pos
	lb		t0, 0(t0)						#Cargo el texto en la pos(cargo un char)
	li 		t6, MENOR						#Cargo el MENOR '<'
	beq		t0, t6,comienzaTag				#Si es igual a '<'salto a comienzaTag 

	# Si es distinto de '<' tengo que sumar uno a pos y volver al principio
	lw 		t1, ATAG_ARG2($fp)				#Cargo pos
	addu	t1, t1,1 						#Si es distinto, le sumo uno a la pos
	sw 		t1, ATAG_ARG2($fp)				#Guardo pos++
	b 		whileDistintoDeEnd				#Vuelvo al principio

comienzaTag:

	#Antes encontre un '<', tengo que saltearlo sumandole uno a pos
	lw 		t1, ATAG_ARG2($fp)				#Cargo pos
	addu	t1, t1,1 						#Le sumo uno a pos
	sw 		t1, ATAG_ARG2($fp)				#Guardo pos++
	lw		t0, ATAG_ARG0($fp)				#Cargo la direc del texto
	lw		t1, ATAG_ARG2($fp)				#Cargo la pos acutal
	addu	t0, t1,t0						#Muevo la direc del texto a la pos
	lbu		t0, 0(t0)						#Cargo el texto en la pos(cargo un char)
	li 		t6, BARRA 						#Cargo la BARRA '/'
	bne		t0, t6, hayNuevoTag				#Si text[pos] no es igual a la barra empieza un nuevo tag anidado
	
	#Si habia una barra, tengo que saltearla sumandole uno a pos
	lw 		t1, ATAG_ARG2($fp)				#Cargo pos
	addu	t1, t1,1 						#Le sumo uno a pos
	sw 		t1, ATAG_ARG2($fp)				#Guardo pos++
	sw		zero,20($fp)					#j = 0 (Con j itero por el tagLevantado)

	#Despues de saltear la barra analizo si el tag que me pasaron es igual al que estoy encontrando
whileDistintoDeCerrarTag:
	lw		t0, ATAG_ARG0($fp)				#Cargo la direc del texto
	lw 		t1, ATAG_ARG2($fp)				#Cargo pos
	addu	t0, t1,t0						#Muevo la direc del texto a la pos
	lb		t0, 0(t0)						#Cargo el texto en la pos(cargo un char)
	li 		t6, MAYOR						#Cargo el MAYOR '>'
	beq 	t0, t6, finCerrarTag			#Si text[pos] == '>' salto a finCerrarTag
											#llegue al final del tag y voy a analizar si eran iguales

	#Cargo tagEncontrado[j]
	lw		t2, ATAG_ARG1($fp) 				#Cargo el tagEncontrado
	lw		t3, VAR_AUX($fp) 				#Cargo el valor de j
	addu	t2, t2, t3 						#Me paro en tagEncontrado[j]
	lb 		t2, 0(t2)						#Cargo el caracter de tagEncontrado[j]

	#Cargo text[pos]
	lw		t0, ATAG_ARG0($fp)				#Cargo la direc del texto
	lw 		t1, ATAG_ARG2($fp)				#Cargo pos
	addu	t0, t1,t0						#Muevo la direc del texto a la pos
	lb		t0, 0(t0)						#Cargo el texto en la pos(cargo un char)
	bne 	t0, t2,finCerrarTag				#Si el tagEncontrado[j] es distinto al text[pos] es un error, en finCerrarTag lo analizo

	#Si los caracteres eran iguales hago j++ y pos++
	lw		t3, VAR_AUX($fp) 				#Cargo el valor de J
	addu 	t3, t3,1 						#j++
	sw		t3, VAR_AUX($fp)				#Guardo j++ en la variable auxiliar
	lw 		t1, ATAG_ARG2($fp)				#Cargo pos
	addu 	t1, t1,1 						#Sumo uno a pos
	sw 		t1, ATAG_ARG2($fp)				#Guardo pos++
	b 		whileDistintoDeCerrarTag		#Salto al comienzo del while

finCerrarTag:
	#Es un if doble
	lw		t2, ATAG_ARG1($fp) 				#Cargo la direccion de tagEncontrado
	lw		t3, VAR_AUX($fp) 				#Cargo el valor de j
	addu	t2, t2, t3 						#Me paro en tagEncontrado[j]
	lb 		t2, ATAG_ARG0(t2)				#Cargo el caracter tagEncontrado[j]
	li 		t6, FIN_TEXTO					#Cargo el fin de texto '\0'

	#Revisa si el tag se cerro bien: if(tagEncontrado[j]=='\0')
	bne 	t2, t6, errorAnidado 			#Si el tagEncontrado no llego al fin, es un error

	#Ahora reviso si text[pos] == '>'
	lw		t0, ATAG_ARG0($fp)				#Cargo la direc del texto
	lw 		t1, ATAG_ARG2($fp)				#Cargo pos
	addu	t0, t1,t0						#Muevo la direc del texto a la pos
	lb		t0, 0(t0)						#Cargo el texto en la pos(cargo un char)	
	li 		t6, MAYOR						#Cargo el MAYOR '>'

	#Revisa si text[pos] == '>'
	bne 	t0, t6, errorAnidado 			#Si el text[pos] no llego a '>' es un error
	b 		devolverPosActual				#Si se cumplio lo anterior tengo que devolver la pos

hayNuevoTag:
	lw		t1, ATAG_ARG2($fp)				#Cargo la direc de la pos
	sw		t1, VAR_AUX($fp) 				#contadorTag = pos

contadorTag:
	lw		t0, ATAG_ARG0($fp)				#Cargo la direc del texto
	lw 		t1, VAR_AUX($fp)				#Cargo pos
	addu	t0, t1,t0						#Muevo la direc del texto a la pos
	lb		t0, 0(t0)						#Cargo el texto en la pos(cargo un char)
	li 		t6, MAYOR						#Cargo el MAYOR '>'
	bne		t0, t6, aumentarConTag			#Mientras sea distinto de MAYOR '>', aumentor el contador
	lw 		t3, VAR_AUX($fp)				#Cargo contadortag
	lw 		t1, ATAG_ARG2($fp)				#Cargo pos		
	subu 	t7, t3, t1						#ContadorTag = contadorTag - pos
	addiu 	t7, t7, 1 						#contadorTag = contadorTag + 1 por el '\0'
	sw 		t7, VAR_AUX($fp) 				#Guardo el nuevo valor de contadorTag
	lw		a0,	VAR_AUX($fp)				#cargo el argunmento de la funcion
	la 		t9, mymalloc					#Cargo en t9 la direccion de la funcion
	jal		t9								#Llamo a la funcion malloc
	sw		v0, TAG_A_LEVANTAR($fp)			#Guardo en atag1 la posicion de memoria que reserve
	sw 		zero, VAR_AUX($fp)				# int k = 0;

cargarTagALevantar:
	lw		t0, ATAG_ARG0($fp)				#Cargo la direc el texto
	lw		t1, ATAG_ARG2($fp)				#Cargo la direc de la pos
	addu	t0, t1,t0						#Muevo la direc del texto a la pos
	lb		t0, 0(t0)						#Cargo el texto en la pos(cargo un char)
	li 		t6, MAYOR						#Cargo el MAYOR '>'
	bne		t0, t6, cargarCaracter			#Si no llegue al MAYOR, cargo el caracter en tagALevantar y aumento los contadores

	#Pongo el tagALevantar[k] = '\0' para indicar que llegue al final
	lw 		t8, TAG_A_LEVANTAR($fp)			#Cargo el tag
	lw 		t3, VAR_AUX($fp) 				#Cargo k
	addu 	t6, t8, t3						#Me paro en tagALevantar[k]
	li 		t7, FIN_TEXTO 					#Cargo en t7 '\0'
	sb 		t7, 0(t6) 						#tagALevantar[k] = '\0'

	#Sigo con la funcion	
	lw		t1, ATAG_ARG2($fp)				#Cargo la pos
	addu	t1, t1, 1 						#pos++
	sw 		t1, ATAG_ARG2($fp)				#Guardo la nueva posicion

	#Cargo los argumentos
	lw 		a0, ATAG_ARG0($fp)				#a0 = texto
	lw 		a1, TAG_A_LEVANTAR($fp)			#a1 = tagALevantar 
	lw 		a2, ATAG_ARG2($fp)				#a2 = pos
	lw 		a3, ATAG_ARG3($fp)				#a3 = contadorlineas
	la 		t9, analizarTag
	jal 	t9
	sw 		v0, ATAG_ARG2($fp)				#Reemplazo la nuevo posicion

	#Cargo argumento
	lw 		a0, TAG_A_LEVANTAR($fp)			#Cargo en la seccion a liberar el espacio allocado por malloc			
	la 		t9, myfree
	jal 	t9					
	b 		switchPos

cargarCaracter:
	lw		t0, ATAG_ARG0($fp)				#Cargo la direc el texto
	lw		t1, ATAG_ARG2($fp)				#Cargo la direc de la pos
	addu	t0, t1,t0						#Muevo la direc del texto a la pos
	lbu		t0, 0(t0)						#Cargo el texto en la pos(cargo un char)
	lw 		t8, TAG_A_LEVANTAR($fp)			#t8 espacio de memoria para tagALevantar
	lw 		t3, VAR_AUX($fp)				#Cargo el valor de k
	addu 	t6, t8, t3						#tagALevantar[k]
	sb 		t0, 0(t6)						#tagALevantar[k] = texto[pos]

	#Actualizo variables
	#k++
	lw		t3, VAR_AUX($fp)
	addiu 	t3, t3, 1
	sw		t3, VAR_AUX($fp)
	
	#pos++
	lw		t1, ATAG_ARG2($fp)				#Cargo la pos
	addiu	t1, t1, 1 						
	sw 		t1, ATAG_ARG2($fp)				#Guardo la nueva posicion
	b		cargarTagALevantar


aumentarConTag:
	lw 		t7, VAR_AUX($fp)
	addiu	t7, t7, 1 						#contadorTag++
	sw 		t7, VAR_AUX($fp)
	b 		contadorTag	

switchPos:
	lw 		v0, ATAG_ARG2($fp)				#Restauro el valor de v0 luego de analizar tag
	#Comprara lo que devolvio analizarTag, v0 = analizarTag()
	li 		t6, -1 							#Cargo -1 en t6
	beq 	v0, t6, errorNoCerrado			#Si v0 es igual a -1, es un errorNoCerrad
	li 		t6, -2 							#Cargo -2 en t6
	beq 	v0, t6, errorAnidado 			#si v0 es igual a -2, es un errorAnidado
	#Si no devolvio ningun error
 	addu 	v0, v0, 1 						#Le sumo uno a pos
 	sw 		v0, ATAG_ARG2($fp) 				#Guardo la pos
 	b 		whileDistintoDeEnd
 	
devolverPosActual:
	lw 		v0, ATAG_ARG2($fp)				#Muevo el t1 que tiene la pos a v0
	b 		salirATAG						#Recupero los registros

errorNoCerrado:
	li		v0,-1							# return -1;
	b 		salirATAG

errorAnidado:
	li 		v0,-2							# return -2;
	b 		salirATAG

salirATAG:
	#Destruye stack frame
	move 	sp, $fp
	lw		ra, ATAG_RA(sp)
	lw		$fp,ATAG_FP(sp)
	lw		gp, ATAG_GP(sp)
	addu	sp, sp,ATAG_SS
	j		ra

.end analizarTag
