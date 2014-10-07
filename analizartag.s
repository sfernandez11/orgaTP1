#int analizarTag(char* text, char* tagEncontrado, int pos, int *contadorLineas)
#{
#	while(text[pos] != '\0')
#	{
#		if(text[pos] == '\n')
#		{
#			(*contadorLineas)++;
#		}
#		if(text[pos] == '<')
#		{
#			pos++;
#			// Si entra en cerrar un tag
#			if(text[pos] == '/')
#			{
#				pos++;
#				int j = 0;
#				while(text[pos] != '>')
#				{
#					if(tagEncontrado[j] != text[pos])
#					{
#						return -2;
#					}
#					j++;	pos++;
#				}
#				return pos;
#			}  else {
#				int contadorTag = pos;
#				while(text[contadorTag] != '>')
#				{
#					contadorTag++;
#				}
#				contadorTag = contadorTag - pos;
#				int k = 0;
#				char* tagALevantar = malloc(sizeof(char)*contadorTag);
#				while(text[pos] != '>')
#				{
#					tagALevantar[k] = text[pos];
#					k++; pos++;
#				}
#				pos++;
#				int posSiguiente;
#				posSiguiente = analizarTag(text, tagALevantar, pos, contadorLineas);
#				free(tagALevantar);
#				switch(posSiguiente)
#				{
#					return -1;
#					break;
#				case -2:
#					return -2;
#					break;
#
#				default:
#					pos = posSiguiente;
#					break;
#
#				}
#			}
#		}
#		pos++;
#	}
#	return -1;
#}
##################################################################

	.text
	.globl	analizarTag

analizarTag:
		subu	$sp,$sp,XX
		sw		$ra,XX($sp)
		sw		$fp,XX($sp)
		sw		$gp,XX($sp)
		move	$fp,$sp
		sw		$a0,XX($fp)
		sw		$a1,XX($fp)
		sw 		$a2,XX($fp)
		sw 		$a3,XX($fp)

whileDistintoDeEnd:
		

#switch:
#		li t0, -1
#		beq t0


returnMenosUno;
		move	$v0,-1	# return -1;
		b return

returnMenosDos:
		move 	$v0,-2
		b return

return:
		lw		$ao,XX(fp)
		lw		$a1,XX(fp)
		lw		$a2,XX(fp)
		lw		$a3,XX(fp)
		move	$sp,$fp		# destruccion del stack frame
		lw		$ra,XX($sp)
		lw		$fp,XX($sp)
		lw		$gp,XX($sp)
		addu	$sp,$sp,XX
		j		$ra
