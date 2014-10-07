#include "validate.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int analizarTag(char* text, char* tagEncontrado, int pos, int *contadorLineas)
{
	while(text[pos] != '\0')
	{
		if(text[pos] == '\n')
		{
			(*contadorLineas)++;
		}
		if(text[pos] == '<')
		{
			pos++;
			// Si entra en cerrar un tag
			if(text[pos] == '/')
			{
				pos++;
				int j = 0;
				while(text[pos] != '>')
				{
					if(tagEncontrado[j] != text[pos])
					{
						return -2;
					}
					j++;	pos++;
				}
				return pos;
			}  else {
				int contadorTag = pos;
				while(text[contadorTag] != '>')
				{
					contadorTag++;
				}
				contadorTag = contadorTag - pos;
				int k = 0;
				char* tagALevantar = malloc(sizeof(char)*contadorTag);
				while(text[pos] != '>')
				{
					tagALevantar[k] = text[pos];
					k++; pos++;
				}
				pos++;
				int posSiguiente;
				posSiguiente = analizarTag(text, tagALevantar, pos, contadorLineas);
				free(tagALevantar);
				switch(posSiguiente)
				{
				case -1:
					return -1;
					break;
				case -2:
					return -2;
					break;

				default:
					pos = posSiguiente;
					break;

				}
			}
		}
		pos++;
	}
	return -1;
}

int validate(char *text, char **errmsg){

	char* buffer;
	int i = 0;
	int contadorLineas = 0;

	while(text[i] != '\0')
	{
		if(text[i] == '\n')
		{
			contadorLineas++;
		}

		if(text[i] == '<')
		{
			i++;
			int j = 0;
			char* tagALevantar;
			while(text[i] != '>')
			{
				tagALevantar[j] = text[i];
				j++; i++;
			}
			i = analizarTag(text, tagALevantar, i, &contadorLineas);
			switch(i)
			{
			case -1:
				sprintf(buffer, "El tag abierto, no fue cerrado, en la linea: %d.\n", contadorLineas);
				*errmsg = buffer;
				return -1;
				break;
			case -2:
				sprintf(buffer, "Tag mal anidado, el ultimo tag cerrado, no corresponde con el ultimo tag abierto, en la linea: %d.\n", contadorLineas);
				*errmsg = buffer;
				return -2;
				break;

			default:
				break;

			}
		}
		i++;
	}
	return 0;
}
