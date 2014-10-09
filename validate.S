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
# 				return -1;
# 				break;
# 			case -2:
# 				sprintf(buffer, "Tag mal anidado, el ultimo tag cerrado, no corresponde con el ultimo tag abierto, en la linea: %d.\n", contadorLineas);
# 				*errmsg = buffer;
# 				return -2;
# 				break;

# 			default:
# 				break;

# 			}
# 		}
# 		i++;
# 	}
# 	return 0;
# }
###############################################################################################################################




#include <mips/regdef.h>
#include <sys/syscall.h>

#define VALIDATE_SS			32
#define VALIDATE_RA  		24
#define VALIDATE_FP			20
#define VALIDATE_GP			16
#define VALIDATE_ARG0		0
#define VALIDATE_ARG1  		4


	.data

	.globl vectorComp
	.align 2
	.size vectorComp, 4
vectorComp: .ascii 	"</>\0"


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
	sw		a0,ATAG_ARG0($fp)
	sw		a1,ATAG_ARG1($fp)





	#Destruye stack frame
	lw		ra, VALIDATE_RA(sp)
	lw		$fp,VALIDATE_FP(sp)
	lw		gp, VALIDATE_GP(sp)
	addu	sp,sp,VALIDATE_SS
	j		ra

.end	validate
