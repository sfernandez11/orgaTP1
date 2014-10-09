# int validate(char *text, char **errmsg){

# 	char* buffer;
# 	int i = 0;
# 	int contadorLineas = 0;

# 	while(text[i] != '\0')
# 	{
# 		if(text[i] == '\n')
# 		{
# 			contadorLineas++;
# 		}

# 		if(text[i] == '<')
# 		{
# 			i++;
# 			int j = 0;
# 			char* tagALevantar;
# 			while(text[i] != '>')
# 			{
# 				tagALevantar[j] = text[i];
# 				j++; i++;
# 			}
# 			i = analizarTag(text, tagALevantar, i, &contadorLineas);
# 			switch(i)
# 			{
# 			case -1:
# 				sprintf(buffer, "El tag abierto, no fue cerrado, en la linea: %d.\n", contadorLineas);
# 				*errmsg = buffer;
# 				return 1;
# 				break;
# 			case -2:
# 				sprintf(buffer, "Tag mal anidado, el ultimo tag cerrado, no corresponde con el ultimo tag abierto, en la linea: %d.\n", contadorLineas);
# 				*errmsg = buffer;
# 				return 1;
# 				break;

# 			default:
# 				break;

# 			}
# 		}
# 		i++;
# 	}
# 	return 0;
# }

#include <mips/regdef.h>
#include <sys/syscall.h>

#define VALIDATE_SS			48
#define VALIDATE_RA  		40
#define VALIDATE_FP			36
#define VALIDATE_GP			32
#define VALIDATE_ARG0		0
#define VALIDATE_ARG1  		4
#define VALIDATE_I         	16
#define VALIDATE_CL			20
#define VALIDATE_J			24
#define VALIDATE_TAGL		28

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

	.data

ER_TAG_MAL_CERRADO:		.ascii	"El tag abierto, no fue cerrado, en la linea: %d.\n\000"
ER_TAG_MAL_ANIDADO1:	.ascii	"Tag mal anidado, el ultimo tag cerrado, no corresponde c"
ER_TAG_MAL_ANIDADO2: 	.ascii	"on el ultimo tag abierto, en la linea: %d.\n\000"
	.align	2


	.text
	.align	2
	.globl	validate
	.ent	validate

validate:
	#Creo el stack frame
	subu	sp,	sp,	VALIDATE_SS
	sw		ra,	VALIDATE_RA(sp)	
	sw		$fp,VALIDATE_FP(sp)
	sw		gp, VALIDATE_GP(sp)
	sw		a0,VALIDATE_ARG0(sp)
	sw		a1,VALIDATE_ARG1(sp)
	sw      $zero,VALIDATE_I(sp)  # i = 0
	sw		$zero,VALIDATE_CL(sp)  # contadorLineas = 0	

whileFinLinea:
	sw t1, VALIDATE_ARG0(sp) # t1 = *text
	sw t0, VALIDATE_I(sp) # t0 = i
	addu t0, t0, t1 
	lb t0, 0(t0)
	bne	t0, FIN_TEXTO, ifFinLinea
	b return_0

ifFinLinea:
	li	t2, SALTO_DE_LINEA # t2 = /0	
	bne	t1,t2, ifMenor # (if text[i] != /0)
	lw	t3,VALIDATE_CL(sp) # t3 -> contador
	addu  t3, t3, 1 #contadorLinea++
	sw	t3,VALIDATE_CL(sp) 

ifMenor:
	li	t2, MENOR	# t2 = <		
	bne	t1,t0, incrementarPos #Si no son iguales incremento la posicion
	lw	t0,VALIDATE_ARG0(sp) #Cargo el valor de i almacenado en el stack
	addu	t0,t0,1 # i++
	sw	t0,VALIDATE_ARG0(sp)
	sw	zero,VALIDATE_J(sp) # j = 0

whileNotFinTag:
	li	t2, MAYOR	# t2 = >		
	bne	t1,t2, tagALevantar # text[i] != '>'
	b	switchValidate

tagALevantar:
	lw	t4,VALIDATE_TAGL(sp) #Almaceno memoria para tag a levantar en el stack
	lw	t5,VALIDATE_J(sp) #Cargo en t5 j, j = 0
	addu	a0,t4,t5
	addu	t0,t1,t0
	lbu	t0,0(t0)
	sb	t0,0(a0)
	lw	t5,VALIDATE_J(sp)
	addu	t5,t5,1 #j++
	sw	t5,VALIDATE_J(sp)
	lw	t0,VALIDATE_I(sp)
	addu	t0,t0,1 #i++
	sw	t0,VALIDATE_I(sp)
	b	whileNotFinTag


swtichValidate:
		#SEGUIR ACA!!!!!!!!!!!!!!!!!!!!!!!!

incrementarPos:
	lw	t0,VALIDATE_ARG0(sp) # t0 = i
	addu	t0,t0,1 #Incremento i, i++
	sw	t0, VALIDATE_ARG0(sp) #Lo almaceno en el stack
	b	whileFinLinea #Vuelvo a iterar


	#Destruye stack frame
	move 	sp, $fp
	lw		ra, VALIDATE_RA(sp)
	lw		$fp,VALIDATE_FP(sp)
	lw		gp, VALIDATE_GP(sp)
	addu	sp,sp,VALIDATE_SS
	j		ra

.end	validate
