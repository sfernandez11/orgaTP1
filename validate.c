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
			printf("%c", text[pos]);
			pos++;
			// Si entra en cerrar un tag
			if(text[pos] == '/')
			{
				printf("%c", text[pos]);
				pos++;
				int j = 0;
				while(text[pos] != '>')
				{
					if(tagEncontrado[j] != text[pos])
					{
						printf("El tag cerrado no es igual al abierto. Tag: %i. Texto: %i.\n", j, pos);
						return -2;
					}
					printf("%c", text[pos]);
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
					printf("%c", text[pos]);
					k++; pos++;
				}
				printf("%c", text[pos]);
				pos++;
				int posSiguiente;
				posSiguiente = analizarTag(text, tagALevantar, pos, contadorLineas);
				free(tagALevantar);
				char digitoEnChar = (char)(((int)'0')+(*contadorLineas));
				switch(posSiguiente)
				{
				case -1:
					printf("El tag abierto, no fue cerrado, en la linea: %c.\n", digitoEnChar);
					return -1;
					break;
				case -2:

					printf("Tag mal anidado, el ultimo tag abierto, no corresponde al tag cerrado, en la linea: %c.\n", digitoEnChar);
					return -2;
					break;

				default:
					pos = posSiguiente;
					break;

				}
			}
		}
		printf("%c", text[pos]);
		pos++;
	}
	return -1;
}

int validate(char *text, char **errmsg){

	char* buffer;
	int i = 0;
	int contadorLineas = 1;

	while(text[i] != '\0')
	{
		if(text[i] == '\n')
		{
			contadorLineas++;
		}

		if(text[i] == '<')
		{
			//char buffer[256];
			printf("%c", text[i]);
			i++;
			int j = 0;
			char* tagALevantar;
			while(text[i] != '>')
			{
				tagALevantar[j] = text[i];
				printf("%c", text[i]);
				j++; i++;
			}
			i = analizarTag(text, tagALevantar, i, &contadorLineas);
			char digitoEnChar = (char)(((int)'0')+contadorLineas);
			switch(i)
			{
			case -1:
				//errmsg = "El tag abierto, no fue cerrado, en la linea: %c.\n", digitoEnChar;
				sprintf(buffer, " Antes del -1El tag abierto, no fue cerrado, en la linea: %c.\n", digitoEnChar);
				//printf(buffer);
				//strcpy(*errmsg,buffer);
				//errmsg[0][0] = buffer;
				return -1;
				break;
			case -2:

				printf("Tag mal anidado, el ultimo tag abierto, no corresponde al tag cerrado, en la linea: %c.\n", digitoEnChar);
				return -2;
				break;

			default:
				printf("||Analizo todo bien joyisimo. Linea: %i|| \n", contadorLineas);
				break;

			}
		}
		//printf("%c", text[i]);
		i++;
	}
	return 0;
}
