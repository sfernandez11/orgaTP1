#include <mips/regdef.h>
#include <sys/syscall.h>

#define ATAG_SS			40
#define ATAG_RA  		32
#define ATAG_FP			28
#define ATAG_GP			24
#define ATAG_ARG0		0
#define ATAG_ARG1  		4
#define ATAG_ARG2		8
#define ATAG_ARG3		12

#define TAG_A_LEVANTAR 	16
#define VAR_AUX 		20

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
	#.frame 	$fp, ATAG_SS, ra
	.set	noreorder
	.cpload	t9
	.set	reorder
	#Creo el stack frame
	subu	sp,	sp,	40
	sw		ra,	32(sp)	
	sw		$fp,28(sp)
	sw		gp, 24(sp)
	move 	$fp, sp
	sw		a0,0($fp)
	sw		a1,4($fp)
	sw 		a2,8($fp)
	sw 		a3,12($fp)

	#Texto = t0; 		Pos= t1; 				tagLevantado= t2
	#contadorLinea= t3; j/k(tagEncontrado/tagA)= t4; 	k(tagALevantar)= t5
	#auxiliar= t6;		contadorTag= t7

whileDistintoDeEnd:
	lw		t0, 0($fp)				#Cargo la direc el texto
	lw		t1, 8($fp)				#Cargo la pos
	addu	t0, t0,t1				#Muevo la direc del texto a la pos
	lb		t0, 0(t0)				#Cargo el texto en la pos(cargo un char)

	li 		t6, 0
	bne		t0, t6,verSiEsSaltoDeLinea 	#Distino de fin de texto
	b		errorNoCerrado				#LLegue al fin del texto y no cerre el tag

verSiEsSaltoDeLinea:
	lw		t0, 0($fp)				#Cargo la direc el texto
	lw		t1, 8($fp)				#Cargo la pos
	addu	t0, t0,t1				#Muevo la direc del texto a la pos
	lb		t0, 0(t0)				#Cargo el texto en la pos(cargo un char)
	li 		t6, 10
	bne		t0, t6,verSiComienzaTag		#Si no es salto de linea, salta  a analizar si empieza un tag
	#Si es igual a salto de linea, tengo que sumar uno al contador de lineas#
	lw		t3, 12($fp)					#Cargo la direccion de contadorLineas
	lw 		t6, 12($fp)					#Cargo un auxiliar para no perder la referencia
	lw		t6, 0(t6)					#Cargo contadorLineas(int)
	addu	t6, t6,1 					#Le sumo uno a contadorLineas
	sw		t6,	0(t3)					#Guardo en la direc de contadorLineas, contadorLineas + 1
	 		
verSiComienzaTag:
	lw		t0, 0($fp)				#Cargo la direc el texto
	lw		t1, 8($fp)				#Cargo la pos
	addu	t0, t0,t1				#Muevo la direc del texto a la pos
	lb		t0, 0(t0)				#Cargo el texto en la pos(cargo un char)
	li 		t6, 60	
	beq		t0, t6,comienzaTag			#Si es igual a '<'salto a comienzaTag 
	lw 		t1, 8($fp)					#Cargo pos
	addu	t1, t1,1 					#Si es distinto, le sumo uno a la pos
	sw 		t1, 8($fp)					#Guardo pos++
	b 		whileDistintoDeEnd			#Vuelvo al principio

comienzaTag:
	#Antes encontre un '<', tengo que saltearlo sumandole uno a pos
	lw 		t1, 8($fp)			#Cargo pos
	addu	t1, t1,1 			#Le sumo uno a pos
	sw 		t1, 8($fp)			#Guardo pos++
	lw		t0, 0($fp)			#Cargo la direc del texto
	lw		t1, 8($fp)			#Cargo la pos acutal
	addu	t0, t1,t0					#Muevo la direc del texto a la pos
	lbu		t0, 0(t0)					#Cargo el texto en la pos(cargo un char)
	li 		t6, 47
	bne		t0, t6, hayNuevoTag			#Si text[pos] es igual a la barra empieza un cerrar tag
	
	#Tengo que saltear la barra, muevo el texto una pos
	lw 		t1, 8($fp)			#Cargo pos
	addu	t1, t1,1 			#Le sumo uno a pos
	sw 		t1, 8($fp)			#Guardo pos++
	sw		zero,20($fp)		# j = 0

whileDistintoDeCerrarTag:
	lw		t0, 0($fp)					#Cargo la direc del texto
	lw 		t1, 8($fp)					#Cargo pos
	addu	t0, t1,t0					#Muevo la direc del texto a la pos
	lb		t0, 0(t0)					#Cargo el texto en la pos(cargo un char)
	li 		t6, 62
	beq 	t0, t6, finCerrarTag		#Si text[pos] == '>' salto a finCerrarTag

	#Cargo tagEncontrado[j]
	lw		t2, 4($fp) 					#Cargo el tagEncontrado
	lw		t3, 20($fp) 				#Cargo el valor de J
	addu	t2, t2, t3 					#Me paro en tagEncontrado[j]
	lb 		t2, 0(t2)					#Cargo el valor	

	#Cargo text[pos]
	lw		t0, 0($fp)					#Cargo la direc del texto
	lw 		t1, 8($fp)					#Cargo pos
	addu	t0, t1,t0					#Muevo la direc del texto a la pos
	lb		t0, 0(t0)					#Cargo el texto en la pos(cargo un char)	

	bne 	t0, t2,finCerrarTag			#Si el tagEncontrado[j] es distinto al text[pos] es un error

	lw		t3, 20($fp) 				#Cargo el valor de J
	addu 	t3, t3,1 					#j++
	sw		t3, 20($fp)	

	lw 		t1, 8($fp)					#Cargo pos
	addu 	t1, t1,1 					#Sumo uno a pos
	sw 		t1, 8($fp)					#Guardo pos++
	b 		whileDistintoDeCerrarTag	#Salto al comienzo del while

finCerrarTag:
	#Es un if doble
	lw		t2, 4($fp) 					#Cargo el tagEncontrado
	lw		t3, 20($fp) 				#Cargo el valor de J
	addu	t2, t2, t3 					#Me paro en tagEncontrado[j]
	lb 		t2, 0(t2)					#Cargo el valor	
	li 		t6, 0
	#Revisa si el tag se cerro bien tagEncontrado[j]=='\0'
	bne 	t2, t6, errorAnidado 		#Si el tagEncontrado no llego al fin, es un error

	lw		t0, 0($fp)					#Cargo la direc del texto
	lw 		t1, 8($fp)					#Cargo pos
	addu	t0, t1,t0					#Muevo la direc del texto a la pos
	lb		t0, 0(t0)					#Cargo el texto en la pos(cargo un char)	
	li 		t6, 62
	#Revisa si text[pos] == '>'
	bne 	t0, t6, errorAnidado 		#Si el text[pos] no llego a '>' es un error
	b 		devolverPosActual			#Si se cumplio lo anterior tengo que devolver la pos

hayNuevoTag:
	lw		t1, 8($fp)					#Cargo la direc de la pos
	sw		t1, 20($fp) 				#contadorTag = pos

contadorTag:
	lw		t0, 0($fp)					#Cargo la direc del texto
	lw 		t1, 20($fp)					#Cargo pos
	addu	t0, t1,t0					#Muevo la direc del texto a la pos
	lb		t0, 0(t0)					#Cargo el texto en la pos(cargo un char)
	li 		t6, 62
	bne		t8, t6, aumentarConTag		#Distino de fin de texto

	lw 		t3, 20($fp)					#Cargo contadortag
	lw 		t1, 8($fp)					#Cargo pos		
	subu 	t7, t3, t1					#ContadorTag = contadorTag - pos
	addu 	t7, t7, 1 					#contadorTag = contadorTag + 1 por el '\0'
	sw 		t7, 20($fp) 				#Guardo el nuevo valor de contadorTag
	lw		a0,	20($fp)					#cargo el argunmento de la funcion
	la 		t9, mymalloc				#Cargo en t9 la direccion de la funcion
	jal		t9							#llamo a la funcion malloc
	sw		v0, 16($fp)					#guardo en atag1 la posicion de memoria que reserve

	sw 		zero, 20($fp)				# int k = 0;
cargarTagALevantar:
	lw		t0, 0($fp)				#Cargo la direc el texto
	lw		t1, 8($fp)				#Cargo la direc de la pos
	addu	t0, t1,t0				#Muevo la direc del texto a la pos
	lb		t0, 0(t0)				#Cargo el texto en la pos(cargo un char)
	li 		t6, 62
	bne		t0, t6, actualizarVar	#Distino de fin de texto
	#tagALevantar[k] = '\0'
	lw 		t8, 16($fp)				#Cargo el tag
	lw 		t3, 20($fp) 			#Cargo k
	addu 	t6, t8, t3				#Me paro en tagALevantar[k]
	li 		t7, 0 					#Cargo en t7 '\0'
	sb 		t7, 0(t6) 				#tagALevantar[k] = '\0'
	#Sigo con la funcion	
	lw		t1, 8($fp)				#Cargo la pos
	addu	t1, t1, 1 				#pos++
	sw 		t1, 8($fp)				#Guardo la nueva posicion
	#Cargo los argumentos
	lw 		a0, 0($fp)				#a0 = texto
	lw 		a1, 16($fp)				#a1 = tagALevantar 
	lw 		a2, 8($fp)				#a2 = pos
	lw 		a3, 12($fp)				#a3 = contadorlineas
	la 		t9, analizarTag
	jal 	t9
	sw 		v0, 8($fp)				#Reemplazo la nuevo posicion
	#Cargo argumento
	lw 		a0, 16($fp)				#Cargo en la seccion a liberar el espacio allocado por malloc			
	la 		t9, myfree
	jal 	t9					
	b 		switchPos

actualizarVar:
	lw		t0, 0($fp)				#Cargo la direc el texto
	lw		t1, 8($fp)				#Cargo la direc de la pos
	addu	t0, t1,t0				#Muevo la direc del texto a la pos
	lbu		t0, 0(t0)				#Cargo el texto en la pos(cargo un char)

	lw 		t8, 16($fp)				#t8 espacio de memoria para tagALevantar
	lw 		t3, 20($fp)
	addu 	t6, t8, t3				#tagALevantar[k]
	sb 		t0, 0(t6)				#tagALevantar[k] = texto[pos]

	#Actualizo variables
	#k++
	lw		t3, 20($fp)
	addu 	t3, t3, 1
	sw		t3, 20($fp)
	
	#pos++
	lw		t1, 8($fp)					#Cargo la pos
	addu	t1, t1, 1 						
	sw 		t1, 8($fp)					#Guardo la nueva posicion
	b		cargarTagALevantar


aumentarConTag:
	lw 		t7, 20($fp)
	addu	t7, t7, 1 					#contadorTag++
	sw 		t7, 20($fp)
	b 		contadorTag	

switchPos:
	lw 		v0, 8($fp)					#Restauro el valor de v0 luego de analizar tag
	#Comprara lo que devolvio analizarTag, v0 = analizarTag()
	li 		t6, -1 						#Cargo -1 en t6
	beq 	v0, t6, errorNoCerrado		#Si v0 es igual a -1, es un errorNoCerrad
	li 		t6, -2 						#Cargo -2 en t6
	beq 	v0, t6, errorAnidado 		#si v0 es igual a -2, es un errorAnidado
	#Si no devolvio ningun error
 	addu 	v0, v0, 1 					#Le sumo uno a pos
 	sw 		v0, 8($fp) 					#Guardo la pos
 	b 		whileDistintoDeEnd
 	
devolverPosActual:
	lw 		v0, 8($fp)					#Muevo el t1 que tiene la pos a v0
	b 		salirATAG					#Recupero los registros

errorNoCerrado:
	li		v0,-1						# return -1;
	b 		salirATAG

errorAnidado:
	li 		v0,-2						# return -2;
	b 		salirATAG

salirATAG:
	#Destruye stack frame
	move 	sp, $fp
	lw		ra, 32(sp)
	lw		$fp,28(sp)
	lw		gp, 24(sp)
	addu	sp, sp,40
	j		ra

.end analizarTag
