#include <mips/regdef.h>
#include <sys/syscall.h>

	.data

		# Errores:

ER_APERTURA_ARCHIVO: 		.asciiz 	"\nERROR: Apertura del archivo\n"
ER_CIERRE_ARCHIVO: 		.asciiz 	"\nERROR: Cierre del archivo\n"
ER_DESCRIPTOR_ARCHIVO: 		.asciiz		"\nERROR: Obtencion del File Descriptor\n"
ER_LECTURA: 			.asciiz		"\nERROR: Lectura del archivo\n"
ER_HEXA_INVALIDO: 		.asciiz		"\nERROR: Valor Hexadecimal invalido\n"
ER_HEXA_INCOMPLETO: 		.asciiz		"\nERROR: Valor Hexadecimal incompleto\n"
ER_ESCRITURA: 			.asciiz		"\nERROR: Escritura en el archivo\n"
ER_ACCION_INV:			.asciiz		"\nERROR: Accion Invalida\n"
ER_OPCION_INV:			.asciiz		"\nERROR: Opcion Invalida\n"

	.globl b16_errmsg
	.align 2
	.size b16_errmsg, 40	# 9 punteros de 4 bytes c/u
b16_errmsg: .word 	0,ER_APERTURA_ARCHIVO, ER_CIERRE_ARCHIVO, ER_DESCRIPTOR_ARCHIVO, ER_LECTURA, ER_HEXA_INVALIDO, ER_HEXA_INCOMPLETO, ER_ESCRITURA, ER_ACCION_INV, ER_OPCION_INV
	

		# Tabla de traduccion:	
	.globl	hexa
	.align	2
	.size	hexa, 17
hexa: .ascii	"0123456789ABCDEF\0"	


		# Buffer para lectura/escritura:
	.globl buffer
	.align 2
buffer: .space 2

	
	
		# Busqueda secuencial en la tabla de traduccion:
		#	Recibe un hexa de un digito (como char) y devuelve su valor 
		#	decimal o -1 en caso de que no sea un hexadecimal valido
	.text
	.align	2
	.globl	posicion
	.ent	posicion

posicion:

		# Crear el frame:
	.frame $fp, 32, ra
	subu sp,sp,32
	sw ra,20(sp)
	sw $fp,16(sp)
	addiu $fp,sp,28
	sw a0, 0($fp)

		# pasar las minusculas a mayusculas:
			# si 97<= char <= 122
			# 	char = char-22
			# si no, directo a busquedaSecuencial
	li t4, 97
	blt a0, t4, busqSec
	li t4, 122
	bgt a0, t4, busqSec
	
	li t4, 32
	subu a0, a0, t4		# char = char-22 (se lo pasa a mayuscula)
	
		# Busqueda secuencial:
	busqSec:		
	li v0, -1	# v0 es el valor a devolver
	li t0, -1 	# t0 es el indice para iterar sobre el vector hexa
	li t1, 16	# t1 lleva el valor de corte
	la t2, hexa # t2 tiene la direccion de la posicion actual 
				#	en el vector hexa
				# t3 tiene el valor actual en el vector
	
	loopPosicion:
		addiu t0, t0, 1
		beq t0, t1, salirPosicion	# si llego al fin del vector, 
						# sale con v0 = -1
		lb t3, (t2)
		addi t2, t2, 1
		bne a0, t3, loopPosicion	# si son distintos, es que sigue
						# sin haberse encontrado el char en
						# el vector de traduccion hexa[]
						# --> se lo sigue recorriendo
			
		move v0, t0 	# v0 = t0, solo si se lo encontro, por lo que no
				# se tomo el branch-not-equals anterior
		
		# Destruir el frame y volver:
	salirPosicion:
		lw ra,20(sp)
		lw $fp,16(sp)
		addiu sp,sp,32
		jr ra
		
.end	posicion
				
		
			# CODIFICACION:		
	.align	2
	.globl	encode
	.ent	encode

encode:
	
		# Crear el frame:
	.frame $fp, 40, ra
	subu sp,sp,40
	sw ra,28(sp)
	sw $fp,24(sp)
	sw s0, 20(sp)
	sw s1, 16(sp)
	addiu $fp,sp,36
	sw a0, 0($fp)
	sw a1, 4($fp)
	
	move s0, a0		# s0 tiene el infd
	move s1, a1		# s1 tiene el outfd
	
		# Loop que lee (1 char), lo codifica y escribe el hexa (2 char):
	loopEncode:		
	
			# Read del archivo de entrada:
		move a0, s0
		la a1, buffer
		li a2, 1		# vamos a leer de a 1 char
		li v0, SYS_read
		syscall			# v0 = 1 si leyo, 0 si es EOF, <0 si hubo error
					# buffer = char a codificar
		
		beq v0, zero, salirEncode	# Si se llego a EOF, sale
		
			# Checkeo error lectura:
		bltz v0, salirErLectura
		
			# Encode del char leido:
		lbu t0, (buffer)	# Se carga en t0 el char leido
		li t6, 16
		div t0, t6
		mflo t0			# t0 = char/16 (los 4 bits mas significativos) 
		mfhi t1			# t1 = char%16 (los 4 bits menos significativos)
		
			# Pasamos t0 y t1 de entero al char hexa que los representa:
		lb t0, hexa+0(t0)
		lb t1, hexa+0(t1)
		sb t0, buffer
		sb t1, buffer+1
		
			# write en el archivo de salida:
		move a0, s1
		la a1, buffer
		li a2, 2 		# vamos a escribir de a 2 caracteres
		li v0, SYS_write
		syscall			# v0 = 2 si escribio ambos caracteres, 
					# o <2 si hubo algun error en la escritura
		
			# Checkeo error escritura:
		li t7, 2	#si no se escribieron 2 char, hubo error
		blt v0, t7, salirErEscritura
		
		b loopEncode
	
		
	salirErLectura:
		li v0, 4		# ER_LECTURA es la posicion 4 de b16_errmsg
		b salirEncode
		
	salirErEscritura:
		li v0, 7		# ER_ESCRITURA es la posicion 7 de b16_errmsg
		b salirEncode
		
		# Destruir el frame y volver:
	salirEncode:
		lw ra,28(sp)
		lw $fp,24(sp)
		lw s0, 20(sp)
		lw s1, 16(sp)
		addiu sp,sp,40
			
		jr ra
	
.end 	encode


		# DECODIFICACION:		
	.align	2
	.globl	decode
	.ent	decode
	
decode: 
		
		# Crear el frame
	.frame $fp, 40, ra
	subu sp,sp,40
	sw ra,28(sp)
	sw $fp,24(sp)
	sw s0, 20(sp)
	sw s1, 16(sp)
	addiu $fp,sp,36
	sw a0, 0($fp)
	sw a1, 4($fp)
	
	move s0, a0		# s0 tiene el infd
	move s1, a1		# s1 tiene el outfd
	
		# Loop que lee cada hexa (2 char), lo decodifica 
		#	y lo escribe (1 char):
	loopDecode:
	
		# read de a dos char:
		move a0, s0
		la a1, buffer
		li a2, 2	# vamos a leer de a 2 char
		li v0, SYS_read
		syscall		# v0 = 2 si leyo todo, 1 si leyo poco,
				# 	0 si EOF, <0 si hubo error
				# 	buffer = chars hexa del char a decodificar
		
		beq v0, zero, salirDecode	# Si se llego a EOF, sale
		
			#checkeo error lectura:
		bltz v0, salirErrLectura
		
			#checkeo hexa_incompleto:
		li t7, 1
		beq v0, t7, salirErrHexaInc
		
		
			# traducir lo leido a un valor ascii 
			# usando "posicion":
		lbu a0, (buffer) 	# a0 tiene el primer char del hexa
		jal posicion		# v0 tiene el valor decimal del digito hexa a0
		bltz v0, salirErrHexaInv	#sale con error si el hexa es invalido
			
		move t5, v0 		# ahora, t5 tiene el valor decimal 
					# 	del primer hexa 
		lbu a0, (buffer+1)	# a0 tiene el segundo char del hexa
		jal posicion		# v0 tiene el valor decimal del digito hexa a0
		bltz v0, salirErrHexaInv	# sale con error si el hexa es invalido
		
		move t6, v0		# ahora, t6 tiene el valor decimal 
					# 	del segundo hexa
						
			# concatenamos las dos partes:
		sll t5, t5, 4
		addu t2, t5, t6	 	#t2 tiene el valor ascii del char a escribir
		
		sb t2, buffer		# se pone el char a escribir en el buffer
		
			# write en el archivo de salida:
		move a0, s1
		la a1, buffer
		li a2, 1 		# vamos a escribir de a 1 caracter
		li v0, SYS_write
		syscall			# v0 = 1 si se escribio, 
					# <1 si hubo algun error en la escritura
		
		ble v0, zero, salirErrEscritura
		
		b loopDecode
				
		
	salirErrEscritura:
		li v0, 7		# ER_ESCRITURA es la posicion 7 de b16_errmsg
		b salirDecode
		
	salirErrLectura:
		li v0, 4		# ER_LECTURA es la posicion 4 de b16_errmsg
		b salirDecode
		
	salirErrHexaInc:
		li v0, 6		# ER_HEXA_INC es la posicion 6 de b16_errmsg
		b salirDecode
		
	salirErrHexaInv:
		li v0, 5		# ER_HEXA_INV es la posicion 5 de b16_errmsg
		b salirDecode
		
		
		# Destruir el frame y volver:
	salirDecode:
		lw ra,28(sp)
		lw $fp,24(sp)
		lw s0, 20(sp)
		lw s1, 16(sp)

		addiu sp,sp,40
		jr ra

.end decode
