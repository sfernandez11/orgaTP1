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

	.text
	.globl validate

validate:
	subu  $sp,$sp,SS
	sw	$ra,SS($sp)	
	sw	$fp,SS($sp)
	sw	$gp,SS($sp)
	move	$fp,$sp

	move	$sp,$fp		# destruye stack frame
	lw	$ra,40($sp)
	lw	$fp,36($sp)
	addu	$sp,$sp,48
	j	$ra