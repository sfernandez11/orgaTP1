#include "validate.h"

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
				while((text[pos] != '>') && (tagEncontrado[j] == text[pos]))
				{
					j++;	pos++;
				}
				if((tagEncontrado[j] == '\0') && (text[pos] == '>'))
				{
					return pos;
				} else {
					return -2;
				}
			}  else {
				int contadorTag = pos;
				while(text[contadorTag] != '>')
				{
					contadorTag++;
				}
				contadorTag = contadorTag - pos;
				contadorTag = contadorTag + 1; //Para el '\0' final
				char* tagALevantar = (char*)malloc(sizeof(char)*contadorTag);
				int k = 0;
				while(text[pos] != '>')
				{
					tagALevantar[k] = text[pos];
					k++; pos++;
				}
				tagALevantar[k] = '\0';
				pos++;
				pos = analizarTag(text, tagALevantar, pos, contadorLineas);
				free(tagALevantar);
				switch(pos)
				{
				case -1:
					return -1;
					break;
				case -2:
					return -2;
					break;

				default:
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
			int contadorTag = i;
			while(text[contadorTag] != '>')
			{
				contadorTag++;
			}
			contadorTag = contadorTag - i;
			contadorTag = contadorTag + 1; //Para el '\0' final
			char* tagALevantar = (char*)malloc(sizeof(char)*contadorTag);
			int j = 0;
			while(text[i] != '>')
			{
				tagALevantar[j] = text[i];
				j++; i++;
			}
			tagALevantar[j] = '\0';
			i = analizarTag(text, tagALevantar, i, &contadorLineas);
			free(tagALevantar);
			switch(i)
			{
			case -1:
				contadorLineas = contadorLineas + 1;
				sprintf(buffer, "Linea: %d. El tag abierto, no fue cerrado.\n", contadorLineas);
				*errmsg = buffer;
				return 1;
				break;
			case -2:
				contadorLineas = contadorLineas + 1;
				sprintf(buffer, "Linea: %d. Tag mal anidado, el ultimo tag cerrado, no corresponde con el ultimo tag abierto.\n", contadorLineas);
				*errmsg = buffer;
				return 1;
				break;

			default:
				break;

			}
		}
		i++;
	}
	return 0;
}
