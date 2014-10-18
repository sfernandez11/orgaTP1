#include <mips/regdef.h>
#include <sys/syscall.h>

#define VALIDATE_SS			56
#define VALIDATE_RA  		48
#define VALIDATE_FP			44
#define VALIDATE_GP			40
#define VALIDATE_ARG0		0
#define VALIDATE_ARG1  		4
#define VALIDATE_ARG2       8
#define VALIDATE_ARG3		12
#define VALIDATE_I         	16
#define VALIDATE_CL			20
#define VALIDATE_J			24
#define VALIDATE_TAGL		28
#define VALIDATE_BF			32
#define VALIDATE_RT			36


#define FIN_TEXTO 		0
#define BARRA 			47
#define SALTO_DE_LINEA	10
#define MENOR			60
#define MAYOR 			62


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
	addu 	t6, t0, t1  				# Cargo direc te text[i] en t6
	lb 		t6, 0(t6) 					# t6 = text[i]
	li 		t7, FIN_TEXTO
	bne		t6, t7, ifFinLinea 			# Si text[i] != \0 voy a ifFinLinea
	b 		return_0

ifFinLinea:
	li		t2, SALTO_DE_LINEA 			# t2 = \n
	bne		t6,t2, ifMenor 				# (if text[i] != \n)
	lw		t3,VALIDATE_CL($fp) 		# t3 -> contador
	addiu  	t3, t3, 1 					#contadorLinea++
	sw		t3,VALIDATE_CL($fp) 

ifMenor:
	li		t2, MENOR					# t2 = <		
	bne		t6, t2, incrementarPos 		#Si no son iguales incremento la posicion
	lw		t0, VALIDATE_I($fp) 		#Cargo el valor de i almacenado en el stack
	addiu	t0, t0,1 					# i++
	sw		t0, VALIDATE_I($fp)
	sw		zero,VALIDATE_J($fp) 		# j = 0

whileNotFinTag:
	lw 		t1, VALIDATE_ARG0($fp) 		# t1 = *text
	lw		t0, VALIDATE_I($fp) 		#Cargo el valor de i almacenado en el stack
	addu 	t6, t1, t0					#Muevo el texto a la nueva pos
	lb 		t6, 0(t6)					# text[pos]
	li		t2, MAYOR					#Cargo en t2 >	
	bne		t6, t2, tagALevantar 		# text[i] != '>'
	lw 		t4, VALIDATE_TAGL($fp) 		#Almaceno memoria para tagALevantar
	lw 		t5, VALIDATE_J($fp) 		#Almacento en t5 j
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
	addu	t8, t4,t5 					#Almacento en t8 la direc de de memoria de tagALevantar[j]
	addu	t6, t1,t0 					# Almaceno la dir de memoria de text[i]
	lbu		t6, 0(t6) 					# t6 = text[i]
	sb		t6, 0(t8) 					# tagALevantar[k] = text[pos];
	#sw 		t4, VALIDATE_TAGL($fp)
	lw		t5, VALIDATE_J($fp) 		#Cargo en t5 j, j = 0		
	addiu	t5, t5,1 					#j++
	sw		t5, VALIDATE_J($fp) 		#Almaceno el valor de j en el stack
	lw		t0, VALIDATE_I($fp)			#Cargo en t0 i
	addiu	t0, t0,1 					#i++
	sw		t0, VALIDATE_I($fp) 		#Almaceno el valor de i en el stack
	b		whileNotFinTag


switchValidate:
	lw 		a0, VALIDATE_ARG0($fp) 		#Cargo en a0 *text
	lw 		a1, VALIDATE_TAGL($fp) 		#Cargo en a1 tagALevantar
	lw 		a2, VALIDATE_CL($fp) 		#Cargo en a2 contadorLinea
	lw	 	a3, VALIDATE_I($fp)			#Copio el contenido de t0 en en a3
	la 		t9, analizarTag 			#Cargo la direccion de analizarTag en t9
	jal 	t9
	sw 		v0, VALIDATE_I($fp) 		#Almaceno en el stack lo que me devuelve analizarTag 
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
	#sw 		a0,	VALIDATE_BF($fp) 
	lw 		t0, VALIDATE_ARG1($fp) 		#Cargo en t0 *errmsg
	lw 		t1, VALIDATE_BF($fp) 		#Cargo en t1 el *buffer
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
	sw		t1, 0(t0)					#*errmsg = buffer
	#sw 		t0, VALIDATE_ARG1($fp)
	li 		v0, 1						#v0 = 1
	sw		v0, VALIDATE_RT($fp) 		#return 1
	b 		liberarStack

incrementarPos:
	lw 		t0, VALIDATE_I($fp)			#Cargo en t0 el valor de i
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
