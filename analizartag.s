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
	.set	noreorder
	.cpload	$t9
	.set	reorder
		#Creo el stack frame
	subu	sp,	sp,	ATAG_SS
	.cprestore 16
	sw		ra,	ATAG_RA(sp)	
	sw		$fp,ATAG_FP(sp)
	sw		gp, ATAG_GP(sp)
	move 	$fp, sp
	sw		a0,ATAG_ARG0($fp)
	sw		a1,ATAG_ARG1($fp)
	sw 		a2,ATAG_ARG2($fp)
	sw 		a3,ATAG_ARG3($fp)

	#Texto = t0; 		Pos= t1; 				tagLevantado= t2
	#contadorLinea= t3; j/k(tagEncontrado/tagA)= t4; 	k(tagALevantar)= t5
	#auxiliar= t6;		contadorTag= t7

whileDistintoDeEnd:
	lw		t0, ATAG_ARG0($fp)			#Cargo la direc el texto
	lw		t1, ATAG_ARG2($fp)			#Cargo la direc de la pos
	addu	t0, t1,t0					#Muevo la direc del texto a la pos
	lb		t0, 0(t0)					#Cargo el texto en la pos(cargo un char)
	bne		t0, FIN_TEXTO,verSiEsSaltoDeLinea 	#Distino de fin de texto
	b		errorNoCerrado				#LLegue al fin del texto y no cerre el tag

verSiEsSaltoDeLinea:
	bne		t0, SALTO_DE_LINEA,verSiComienzaTag	#Si no es salto de linea, salta  a analizar si empieza un tag
	#Si es igual a salto de linea, tengo que sumar uno al contador de lineas#
	lw		t3, ATAG_ARG3($fp)			#Guardo la direccion de contadorLineas
	lb		t6, 0(t3)					#Cargo contadorLineas(int)
	addiu	t3, t6,1 					#Le sumo uno a contadorLineas
	sw		t3,	ATAG_ARG3($fp)			#Guardo en la direc de contadorLineas, contadorLineas + 1
	 		

verSiComienzaTag:
	beq		t0, MENOR,comienzaTag		#Si es igual a '<'salto a comienzaTag 
	addiu	t1, t1,1 					#Si es distinto, le sumo uno a la pos
	sw 		t1, ATAG_ARG2($fp)			#Guardo pos++
	b 		whileDistintoDeEnd			#Vuelvo al principio

comienzaTag:
	#Antes encontre un '<', tengo que saltearlo sumandole uno a pos
	addiu	t1, t1,1 					#Le sumo uno a pos
	sw 		t1, ATAG_ARG2($fp)			#Guardo pos++
	lw		t0, ATAG_ARG0($fp)			#Cargo la direc del texto
	addu	t0, t1,t0					#Muevo la direc del texto a la pos
	lb		t0, 0(t0)					#Cargo el texto en la pos(cargo un char)
	beq		t0, BARRA, comienzaCerrarTag	#Si text[pos] es igual a la barra empieza un cerrar tag
	# ACA VA EMPEZAR DE SANTI
	b 		hayNuevoTag					#Si el caracter siguiente al '<' no es una barra '/' hay un tag anidado

comienzaCerrarTag:	
	#Tengo que saltear la barra, muevo el texto una pos
	addiu	t1, t1,1 					#Le sumo uno a pos
	sw 		t1, ATAG_ARG2($fp)			#Guardo pos++
	lw		t0, ATAG_ARG0($fp)			#Cargo la direc del texto
	addu	t0, t1,t0					#Muevo la direc del texto a la pos
	lb		t0, 0(t0)					#Cargo el texto en la pos(cargo un char)
	move 	t4, zero						# j = 0

whileDistintoDeCerrarTag:
	lw		t2, ATAG_ARG1($fp)			#En t2 cargo la direcc de tagEncontrado
	addu 	t2, t2,t4					#En t2 guardo la direc de tagEncontrado[j]
	lw		t2, 0(t2)					#Cargo tagEncontrado[j]
	beq 	t0, MAYOR, finCerrarTag		#Si text[pos] == '>' salto a finCerrarTag
	bne 	t0, t2,finCerrarTag			#Si el tagEncontrado[j] es distinto al text[pos] es un error
	addiu 	t4, t4,1 					#Sumo uno a j
	addiu 	t1, t1,1 					#Sumo uno a pos
	sw 		t1, ATAG_ARG2($fp)			#Guardo pos++
	lw		t0, ATAG_ARG0($fp)			#Cargo la direc el texto
	addu 	t0, t1,t0 					#Cargo la direc de text[pos] en t0
	lb		t0, 0(t0) 					#Cargo el text[pos] en t0
	b 		whileDistintoDeCerrarTag	#Salto al comienzo del while

finCerrarTag:
	#Es un if doble
	#Revisa si el tag se cerro bien(tagEncontrado[j]=='\0' Y text[pos] == '>')
	bne 	t2, FIN_TEXTO, errorAnidado #Si el tagEncontrado no llego al fin, es un error
	bne 	t0, MAYOR, errorAnidado 	#Si el text[pos] no llego a '>' es un error
	b 		devolverPosActual			#Si se cumplio lo anterior tengo que devolver la pos

hayNuevoTag:
	lw		t1, ATAG_ARG2($fp)			#Cargo la direc de la pos
	move 	t7, t1
	lw		t0, ATAG_ARG0($fp)			#Cargo la direc el texto
contadorTag:
	addu	t8, t0,t7					#Muevo la direc del texto a la pos
	lb		t8, 0(t8)					#Cargo el texto en la pos
	bne		t8, MAYOR, aumentarConTag	#Distino de fin de texto
	subu	t7, t7, t1					#contadorTag = contadorTag - pos
	addiu	t7, t7, 1 					#Subo una posicion mas de espacio para el '\0'
	move	a0,	t7						#cargo el argunmento de la funcion
	la 		t9, mymalloc				#Cargo en t9 la direccion de la funcion
	jal		t9							#llamo a la funcion malloc
	sw		v0, ATAG_ARG1($fp)			#guardo en atag1 la posicion de memoria que reserve

	move 	t4, zero					# int k = 0;

cargarTagALevantar:
	lw		t0, ATAG_ARG0($fp)			#Cargo la direc el texto
	lw		t1, ATAG_ARG2($fp)			#Cargo la direc de la pos
	addu	t0, t1,t0					#Muevo la direc del texto a la pos
	lb		t0, 0(t0)					#Cargo el texto en la pos(cargo un char)
	bne		t0, MAYOR, actualizarVar	#Distino de fin de texto
	#tagALevantar[k] = '\0'
	lw 		t8, ATAG_ARG1($fp)			#Cargo el tag
	addu 	t6, t8, t4					#Me paro en tagALevantar[k]
	li 		t7, FIN_TEXTO 				#Cargo en t7 '\0'
	sb 		t7, 0(t6) 					#tagALevantar[k] = '\0'
	sw 		t8, ATAG_ARG1($fp)			
	#Sigo con la funcion	
	lw		t1, ATAG_ARG2($fp)			#Cargo la direc de la pos
	addiu	t1, t1, 1 					#pos++
	sw 		t1, ATAG_ARG2($fp)			#Guardo la nueva posicion
	#Cargo los argumentos
	lw 		a0, ATAG_ARG0($fp)			#a0 = texto
	lw 		a1, ATAG_ARG1($fp)			#a1 = tagALevantar 
	lw 		a2, ATAG_ARG2($fp)			#a2 = pos
	lw 		a3, ATAG_ARG3($fp)			#a3 = contadorlineas
	la 		t9, analizarTag
	jal 	t9
	sw 		v0, ATAG_ARG2($fp)			#Reemplazo la nuevo posicion
	#Cargo argumento
	lw		a0, ATAG_ARG1($fp)			#Cargo en a1 la seccion a liberar
	la 		t9, free
	jal 	t9					
	b 		switchPos

actualizarVar:
	lw 		t8, ATAG_ARG1($fp)			#t8 espacio de memoria para tagALevantar
	#t4 k de tarALevantar, al pricipio k=0, despues no
	addu 	t6, t8, t4					#tagALevantar[k]
	lw		t0, ATAG_ARG0($fp)			#Cargo la direc el texto
	lw		t1, ATAG_ARG2($fp)			#Cargo la direc de la pos
	addu	t0, t1,t0					#Muevo la direc del texto a la pos
	lbu		t0, 0(t0)					#Cargo el texto en la pos(cargo un char)
	sb 		t0, 0(t6)					#tagALevantar[k] = texto[pos]
	sw 		t8, ATAG_ARG1($fp)			#Guardo el nuevo tagEncontrado
	#Actualizo variables
	#k++
	addiu 	t4, t4, 1
	#pos++
	addiu	t1, t1, 1 					
	sw 		t1, ATAG_ARG2($fp)			#Guardo la nueva posicion
	b		cargarTagALevantar


aumentarConTag:
	addiu	t7, t7, 1 					#contadorTag++
	b 		contadorTag	

switchPos:
	lw 		v0, ATAG_ARG2($fp)			#Restauro el valor de v0 luego de analizar tag
	#Comprara lo que devolvio analizarTag, v0 = analizarTag()
	li 		t6, -1 						#Cargo -1 en t6
	beq 	v0, t6, errorNoCerrado		#Si v0 es igual a -1, es un errorNoCerrad
	li 		t6, -2 						#Cargo -2 en t6
	beq 	v0, t6, errorAnidado 		#si v0 es igual a -2, es un errorAnidado
	#Si no devolvio ningun error
 	addiu 	v0, v0, 1 					#Le sumo uno a pos
 	sw 		v0, ATAG_ARG2($fp) 			#Guardo la pos
 	b 		whileDistintoDeEnd
 	
devolverPosActual;
	lw 		v0, ATAG_ARG2($fp)			#Muevo el t1 que tiene la pos a v0
	b 		salirATAG					#Recupero los registros

errorNoCerrado;
	li		v0,-1						# return -1;
	b 		salirATAG

errorAnidado:
	li 		v0,-2						# return -2;
	b 		salirATAG

salirATAG:
	#Destruye stack frame
	lw		a0,ATAG_ARG0($fp)
	lw		a1,ATAG_ARG1($fp)
	lw 		a2,ATAG_ARG2($fp)
	lw 		a3,ATAG_ARG3($fp)
	move 	sp, $fp
	lw		ra, ATAG_RA(sp)
	lw		$fp,ATAG_FP(sp)
	lw		gp, ATAG_GP(sp)
	addu	sp, sp,ATAG_SS
	j		ra

.end analizarTag
