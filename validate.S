#include <mips/regdef.h>
#include <sys/syscall.h>

#Argumentos de la funcion
#define VALIDATE_ARG1  		60
#define VALIDATE_ARG0		56

#Stack Size
#define VALIDATE_SS			56

#SRA
#define VALIDATE_RA  		48
#define VALIDATE_FP			44
#define VALIDATE_GP			40

#LTA
#define	VALIDATE_RT			36
#define VALIDATE_BF			32
#define VALIDATE_TAGL		28
#define VALIDATE_J			24
#define VALIDATE_CL 		20
#define VALIDATE_I 			16

#ABA
#define ABA_3				12
#define ABA_2				8
#define ABA_1				4
#define ABA_0				0

#Constantes
#define FIN_TEXTO 			0
#define SALTO_DE_LINEA		10
#define MENOR				60
#define MAYOR 				62


#Referencia de registros
# t0 = pos
# t1 = *text
# t2 = </0\n>
# t3 = contadorLineas
# t4 = tagALevantar
# t5 = j
# t6 = text[pos]

	.data
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
	.frame $fp, VALIDATE_SS, ra
	.set	noreorder
	.cpload	t9
	.set	reorder
	#Creo el stack frame
	subu	sp,	sp,	VALIDATE_SS
	.cprestore VALIDATE_GP
	sw		ra,	VALIDATE_RA(sp)	
	sw		$fp,VALIDATE_FP(sp)
	sw		gp, VALIDATE_GP(sp)
	move 	$fp,sp
	sw		a0, VALIDATE_ARG0($fp)
	sw		a1, VALIDATE_ARG1($fp)

	
	sw      zero, VALIDATE_I($fp)  		# i = 0
	sw		zero, VALIDATE_CL($fp) 	 	# contadorLineas = 0

whileFinLinea:
	lw 		t1, VALIDATE_ARG0($fp) 		# t1 = *text
	lw 		t0, VALIDATE_I($fp)			# t0 = i
	addu 	t6, t0, t1  				# Cargo direc te text[i] en t6
	lbu 	t6, 0(t6) 					# t6 = text[i]
	li 		t2, FIN_TEXTO
	bne		t6, t2, ifFinLinea 			# Si text[i] != \0 voy a ifFinLinea
	b 		return_0

ifFinLinea:
	lw 		t1, VALIDATE_ARG0($fp) 		# t1 = *text
	lw 		t0, VALIDATE_I($fp)			# t0 = i
	addu 	t6, t0, t1  				# Cargo direc te text[i] en t6
	lbu 	t6, 0(t6) 					# t6 = text[i]
	li		t2, SALTO_DE_LINEA 			# t2 = \n
	bne		t6,t2, ifMenor 				# (if text[i] != \n)
	lw		t3,VALIDATE_CL($fp) 		# t3 -> contador
	addu  	t3, t3, 1 					#contadorLinea++
	sw		t3,VALIDATE_CL($fp) 		#Almaceno el contadorLinea modificado en el stack

ifMenor:
	lw 		t1, VALIDATE_ARG0($fp) 		# t1 = *text
	lw 		t0, VALIDATE_I($fp)			# t0 = i
	addu 	t6, t0, t1  				# Cargo direc te text[i] en t6
	lbu		t6, 0(t6) 					# t6 = text[i]
	li		t2, MENOR					# t2 = <		
	bne		t6, t2, incrementarPos 		#Si no son iguales incremento la posicion
	lw		t0, VALIDATE_I($fp) 		#Cargo el valor de i almacenado en el stack
	addu	t0, t0,1 					# i++
	sw		t0, VALIDATE_I($fp)


	lw		t0, VALIDATE_I($fp)			#Cargo la i
	sw		t0, VALIDATE_TAGL($fp)		#contadorTag = i
contadorTag:
	lw 		t1, VALIDATE_ARG0($fp)		# t1 = *text
	lw 		t0, VALIDATE_TAGL($fp)		# t0 = contadorTag
	addu 	t6, t0, t1  				# Cargo direc te text[i] en t6
	lb 		t6, 0(t6) 					# t6 = text[i]
	li 		t2, MAYOR
	bne		t6, t2, aumentarConTag		#Distino de fin de texto
	lw		t2, VALIDATE_TAGL($fp) 		#t2 = contadorTag
	lw		t0, VALIDATE_I($fp)			#t0 = i
	subu	t7, t2, t0					#contadorTag = contadorTag - i
	addu 	t7, t7, 1 					#contadorTag = contadorTag + 1 para el '\0'
	sw		t7, VALIDATE_TAGL($fp)
	lw 		a0, VALIDATE_TAGL($fp)		#Cargo el argunmento de la funcion
	la 		t9, mymalloc				#Cargo en t9 la direccion de la funcion
	jal		t9							#llamo a la funcion malloc
	sw		v0, VALIDATE_TAGL($fp)		#guardo la posicion de memoria que reserve


	sw		zero,VALIDATE_J($fp) 		# j = 0
whileNotFinTag:
	lw 		t1, VALIDATE_ARG0($fp) 		# t1 = *text
	lw		t0, VALIDATE_I($fp)			#Cargo el valor de i almacenado en el stack
	addu 	t6, t1, t0					#Muevo el texto a la nueva i
	lbu 	t6, 0(t6)					# text[i]
	li		t2, MAYOR					#Cargo en t2 >	
	bne		t6, t2, tagALevantar 		# text[i] != '>'
	lw 		t4, VALIDATE_TAGL($fp) 		#Almaceno memoria para tagALevantar
	lw 		t5, VALIDATE_J($fp)			#Almacento en t5 j
	addu 	t8, t4, t5 					#Cargo en a0 la direccion de tagALevantar[j]
	li 		t2, FIN_TEXTO 				#Cargo en t2 \0
	sb		t2, 0(t8) 					#tagALevantar[j] = '\0'
	b		switchValidate

	aumentarConTag:
	lw		t0,VALIDATE_TAGL($fp)
	addu	t0,t0,1 					#contadorTag++
	sw		t0,VALIDATE_TAGL($fp)				
	b 		contadorTag		

tagALevantar:
	#Para cargar tagALevantar[j]
	lw		t4, VALIDATE_TAGL($fp) 		#Cargo tag a levantar del stack
	lw		t5, VALIDATE_J($fp) 		#Cargo en t5 j, j = 0
	addu	t8, t4,t5 					#Almacento en t8 la direc de de memoria de tagALevantar[j]
	#Para cargar text[i]
	lw 		t1, VALIDATE_ARG0($fp) 		# t1 = *text
	lw		t0, VALIDATE_I($fp) 		#Cargo el valor de i almacenado en el stack
	addu	t6, t1,t0 					# Almaceno la dir de memoria de text[i]
	# tagALevantar[j] = text[i];
	lb		t6, 0(t6) 					# t6 = text[i]
	sb 		t6, 0(t8) 					# tagALevantar[j] = text[i];

	#j++
	lw		t5, VALIDATE_J($fp) 		#Cargo en t5 j, j = 0	
	addiu	t5, t5,1 					#j++
	sw		t5, VALIDATE_J($fp) 		#Almaceno el valor de j en el stack
	#i++
	lw		t0, VALIDATE_I($fp)			#Cargo en t0 i
	addiu	t0, t0,1 					#i++
	sw		t0, VALIDATE_I($fp) 		#Almaceno el valor de i en el stack
	b		whileNotFinTag


switchValidate:
	lw 		a0, VALIDATE_ARG0($fp) 		#Cargo en a0 *text
	lw 		a1, VALIDATE_TAGL($fp) 		#Cargo en a1 tagALevantar
	lw 		a2, VALIDATE_I($fp) 		#Cargo en a2 la posicion
	la	 	a3, VALIDATE_CL($fp)		#Cargo en a3 el contadorLinea
	la 		t9, analizarTag 			#Cargo la direccion de analizarTag en t9
	jal 	t9
	sw 		v0, VALIDATE_I($fp) 		#Almaceno en el stack lo que me devuelve analizarTag 
	#Cargo argumento - FREE
	lw		a0, VALIDATE_TAGL($fp)		#Cargo en a1 la seccion a liberar
	la 		t9, myfree
	jal 	t9	

	#Sigo con el fin del programa
	lw 		t0, VALIDATE_I($fp) 		#Cargo en t0 i
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
	
	lw 		t0, VALIDATE_ARG1($fp) 		#Cargo en t0 *errmsg
	lw 		t1, VALIDATE_BF($fp) 		#Cargo en t1 el *buffer
	sw		t1, 0(t0)					#*errmsg = buffer
	li 		v0, 1						#v0 = 1
	sw		v0, VALIDATE_RT($fp) 		#return 1
	b 		liberarStack


errorAnidado:
	lw 		a0, VALIDATE_BF($fp) 		#Cargo en a0 el buffer
	la 		a1, ER_TAG_MAL_ANIDADO 		#Cargo en a1 la direc de tag mal anidado
	lw 		a2, VALIDATE_CL($fp) 		#Cargo en a2 contador lineas
	la 		t9, sprintf 				#Cargo la direccion de sprintf en t9
	jal 	t9

	lw 		t0, VALIDATE_ARG1($fp) 		#Cargo en t0 *errmsg
	lw 		t1, VALIDATE_BF($fp)		#Cargo en t1 el *buffer
	sw		t1, 0(t0)					#*errmsg = buffer
	li 		v0, 1						#v0 = 1
	sw		v0, VALIDATE_RT($fp) 		#return 1
	b 		liberarStack

incrementarPos:
	lw 		t0, VALIDATE_I($fp)			#Cargo en t0 el valor de i
	addu 	t0, t0, 1 					# i++
	sw 		t0, VALIDATE_I($fp)			#Lo almaceno en el stack
	b 		whileFinLinea

return_0:
	sw		zero,VALIDATE_RT($fp)

liberarStack:
	#Destruye stack frame
	lw 		v0, VALIDATE_RT($fp) 
	move 	sp, $fp
	lw		ra, VALIDATE_RA(sp)
	lw		$fp,VALIDATE_FP(sp)
	lw		gp, VALIDATE_GP(sp)
	addu	sp, sp,VALIDATE_SS
	j		ra

.end	validate
