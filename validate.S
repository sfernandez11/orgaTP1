#include <mips/regdef.h>
#include <sys/syscall.h>

	.data

		# Errores:

ER_TAG_SIN_CERRAR: 		.asciiz 	"\nERROR: Tag sin cerrar\n"
ER_TAG_SIN_ABRIR: 		.asciiz 	"\nERROR: Tag sin abrir\n"
ER_TAG_MAL_ANIDADO: 	.asciiz		"\nERROR: Tag mal anidado\n"

	.globl errmsg
	.align 2
	.size errmsg, 16	# 3 punteros de 4 bytes c/u + 1 para el 0.
errmsg: .word 	0,ER_TAG_SIN_CERRAR, ER_TAG_SIN_ABRIR, ER_TAG_MAL_ANIDADO