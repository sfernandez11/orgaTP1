#include <mips/regdef.h>
#include <sys/syscall.h>



.data
	VALIDATE_SS: .word 56
 	VALIDATE_RA: .word 48
 	VALIDATE_FP: .word 44
 	VALIDATE_GP: .word 40
 	VALIDATE_ARG0: .word 0
 	VALIDATE_ARG1: .word 4
 	VALIDATE_ARG2: .word 8
 	VALIDATE_ARG3: .word 12
 	VALIDATE_I: .word  16
 	VALIDATE_CL: .word 20
 	VALIDATE_J: .word  24
 	VALIDATE_TAGL: .word 28
 	VALIDATE_BF: .word 32
 	VALIDATE_RT: .word	36


 	FIN_TEXTO: .word 		0
 	BARRA: .word 			47
 	SALTO_DE_LINEA: .word	10
 	MENOR: .word			60
	MAYOR: .word 			62


#Referencia de registros
# t0 = pos
# t1 = *text
# t2 = </0\n>
# t3 = contadorLineas
# t4 = tagALevantar
# t5 = j
# t6 = text[pos]

	
	.align	2	
ER_TAG_MAL_CERRADO:	
		.ascii	"Linea: %d. El tag abierto, no fue cerrado.\n\0"
		.align	2
ER_TAG_MAL_ANIDADO:	
		.ascii	"Linea: %d. Tag mal anidado, el ultimo tag cerrado, no corresponde"
		.ascii	"con el ultimo tag abierto.\n\0"

	.text
	.align	2
	.globl	validate
	.ent	validate

validate:
	#.frame 	$fp, VALIDATE_SS, ra
	.set	noreorder
	.cpload	t9
	.set	reorder
	#Creo el stack frame
	subu	sp,	sp,	VALIDATE_SS
	sw		ra,	VALIDATE_RA(sp)	
	sw		$fp,VALIDATE_FP(sp)
	sw		gp, VALIDATE_GP(sp)
	move 	$fp,sp
	sw		a0, VALIDATE_ARG0($fp)
	sw		a1, VALIDATE_ARG1($fp)
	sw      zero, VALIDATE_I($fp)  		# i = 0
	sw		zero, VALIDATE_CL($fp)  	# contadorLineas = 0	

whileFinLinea:
	lw 		t1, VALIDATE_ARG0($fp) 		# t1 = *text
	lw 		t0, VALIDATE_I($fp)			# t0 = i
	nop
	addu 	t6, t0, t1  				# Cargo direc te text[i] en t6
	lbu 	t6, 0(t6) 					# t6 = text[i]
	li 		t7, FIN_TEXTO
	nop
	bne		t6, t7, ifFinLinea 			# Si text[i] != \0 voy a ifFinLinea
	b 		return_0

ifFinLinea:
	li		t2, SALTO_DE_LINEA 			# t2 = \n
	bne		t6,t2, ifMenor 				# (if text[i] != \n)
	lw		t3,VALIDATE_CL($fp) 		# t3 -> contador
	nop
	addiu  	t3, t3, 1 					#contadorLinea++
	sw		t3,VALIDATE_CL($fp) 		#Almaceno el contadorLinea modificado en el stack
	nop

ifMenor:
	li		t2, MENOR					# t2 = <		
	bne		t6, t2, incrementarPos 		#Si no son iguales incremento la posicion
	lw		t0, VALIDATE_I($fp) 		#Cargo el valor de i almacenado en el stack
	nop
	addiu	t0, t0,1 					# i++
	sw		t0, VALIDATE_I($fp)
	sw		zero,VALIDATE_J($fp) 		# j = 0
	nop

whileNotFinTag:
	lw 		t1, VALIDATE_ARG0($fp) 		# t1 = *text
	lw		t0, VALIDATE_I($fp) 		#Cargo el valor de i almacenado en el stack
	nop
	addu 	t6, t1, t0					#Muevo el texto a la nueva pos
	lbu 	t6, 0(t6)					# text[pos]
	nop
	li		t2, MAYOR					#Cargo en t2 >	
	bne		t6, t2, tagALevantar 		# text[i] != '>'
	lw 		t4, VALIDATE_TAGL($fp) 		#Almaceno memoria para tagALevantar
	lw 		t5, VALIDATE_J($fp) 		#Almacento en t5 j
	nop
	addu 	t8, t4, t5 					#Cargo en a0 la direccion de tagALevantar[j]
	li 		t2, FIN_TEXTO 				#Cargo en t2 \0
	sb 		t2, 0(t8) 					#tagALevantar[j] = '\0'
	#sw 		t4, VALIDATE_TAGL($fp)
	b		switchValidate


tagALevantar:
	lw 		t1, VALIDATE_ARG0($fp) 		# t1 = *text
	lw		t0, VALIDATE_I($fp) 		#Cargo el valor de i almacenado en el stack
	lw		t4, VALIDATE_TAGL($fp) 		#Almaceno memoria para tag a levantar en el stack
	lw		t5, VALIDATE_J($fp) 		#Cargo en t5 j, j = 0
	nop
	addu	t8, t4,t5 					#Almacento en t8 la direc de de memoria de tagALevantar[j]
	addu	t6, t1,t0 					# Almaceno la dir de memoria de text[i]
	lbu		t6, 0(t6) 					# t6 = text[i]
	sb		t6, 0(t8) 					# tagALevantar[k] = text[pos];
	#sw 		t4, VALIDATE_TAGL($fp)
	lw		t5, VALIDATE_J($fp) 		#Cargo en t5 j, j = 0	
	nop	
	addiu	t5, t5,1 					#j++
	sw		t5, VALIDATE_J($fp) 		#Almaceno el valor de j en el stack
	nop
	lw		t0, VALIDATE_I($fp)			#Cargo en t0 i
	nop
	addiu	t0, t0,1 					#i++
	sw		t0, VALIDATE_I($fp) 		#Almaceno el valor de i en el stack
	nop
	b		whileNotFinTag


switchValidate:
	lw 		a0, VALIDATE_ARG0($fp) 		#Cargo en a0 *text
	lw 		a1, VALIDATE_TAGL($fp) 		#Cargo en a1 tagALevantar
	lw 		a2, VALIDATE_CL($fp) 		#Cargo en a2 contadorLinea
	lw	 	a3, VALIDATE_I($fp)			#Copio el contenido de t0 en en a3
	la 		t9, analizarTag 			#Cargo la direccion de analizarTag en t9
	jal 	t9
	sw 		v0, VALIDATE_I($fp) 		#Almaceno en el stack lo que me devuelve analizarTag 
	nop
	lw 		t0, VALIDATE_I($fp) 		#Cargo en t0 i
	nop
	#Arranca el switch
	li 		t6, -2 						#Cargo en t6 -2
	beq 	t0, t6, errorAnidado 		# Si i = -2 voy a errorAnidado 
	li 		t6, -1 						#Cargo en t6 -1
	beq 	t0, t6, errorNoCerrado 		# si i = -1 voy a errorNoCerrado
	b 		incrementarPos 				#Va a default


errorNoCerrado:
	lw 		a0, VALIDATE_BF($fp) 		#Cargo en a0 el buffer
	la 		a1, ER_TAG_MAL_CERRADO 		#Cargo en a1 la direcc de tag mal cerrado
	lw 		a2, VALIDATE_CL($fp) 		#Cargo en a2 contador lineas
	la 		t9, sprintf 				#Cargo la direccion de sprintf en t9
	jal 	t9
	#sw 		a0,	VALIDATE_BF($fp) 
	lw 		t0, VALIDATE_ARG1($fp) 		#Cargo en t0 *errmsg
	lw 		t1, VALIDATE_BF($fp) 		#Cargo en t1 el *buffer
	nop
	sw		t1, 0(t0)					#*errmsg = buffer
	#sw 		t0, VALIDATE_ARG1($fp)
	li 		v0, 1						#v0 = 1
	sw		v0, VALIDATE_RT($fp) 		#return 1
	b 		liberarStack


errorAnidado:
	lw 		a0, VALIDATE_BF($fp) 		#Cargo en a0 el buffer
	la 		a1, ER_TAG_MAL_ANIDADO 		#Cargo en a1 la direc de tag mal anidado
	lw 		a2, VALIDATE_CL($fp) 		#Cargo en a2 contador lineas
	la 		t9, sprintf 				#Cargo la direccion de sprintf en t9
	jal 	t9

	#sw 		a0,	VALIDATE_BF($fp) 
	lw 		t0, VALIDATE_ARG1($fp) 		#Cargo en t0 *errmsg
	lw 		t1, VALIDATE_BF($fp) 		#Cargo en t1 el *buffer
	nop
	sw		t1, 0(t0)					#*errmsg = buffer
	#sw 		t0, VALIDATE_ARG1($fp)
	li 		v0, 1						#v0 = 1
	sw		v0, VALIDATE_RT($fp) 		#return 1
	b 		liberarStack

incrementarPos:
	lw 		t0, VALIDATE_I($fp)			#Cargo en t0 el valor de i
	nop
	addiu 	t0, t0, 1 					# i++
	sw 		t0, VALIDATE_I($fp)			#Lo almaceno en el stack
	b 		whileFinLinea

return_0:
	sw		zero,VALIDATE_RT($fp)

liberarStack:
	#Destruye stack frame
	lw 		v0, VALIDATE_RT($fp) 		
	lw 		a0, VALIDATE_ARG0($fp)
	lw 		a1, VALIDATE_ARG1($fp)
	move 	sp, $fp
	lw		ra, VALIDATE_RA(sp)
	lw		$fp,VALIDATE_FP(sp)
	lw		gp, VALIDATE_GP(sp)
	addu	sp,sp,VALIDATE_SS
	j		ra

.end	validate
