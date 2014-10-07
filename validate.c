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
						return -1;
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
				char buffer[1];
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
				if(posSiguiente  == -1 )
				{
					return -1;
				} else {
					pos = posSiguiente;
				}
			}
		}
		printf("%c", text[pos]);
		pos++;
	}
	return -1;
}

int validate(char *text, char **errmsg){

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
			if(i == -1)
			{
				printf("El tag esta mal");
				return -1;
			} else {
				printf("||Analizo todo bien joyisimo. Linea: %i|| \n", contadorLineas);
			}
		}
		printf("%c", text[i]);
		i++;
	}
	return 0;
}
