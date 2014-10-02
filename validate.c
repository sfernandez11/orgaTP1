#include "validate.h"


int validate(char *text, char **errmsg){

	int i,j, entroEnAbrirTag, entroEnCerrarTag;
	i = 0;
	entroEnAbrirTag = 0;
	entroEnCerrarTag = 0;
	char* tagAbriendo;
	char* tagCerrando;
	while(text[i] != '\0')
	{
		printf("%c", text[i]);
		// Si entro en un tag
		if(text[i] == '<')
		{
			// Ya habia abireto un tag. Caso ej: "<<texto" es un error de sintaxis
			if(entroEnAbrirTag)
			{
				printf("Se abrio un nuevo tag, cuando todavia no se habia cerrado el anterior.\n");
				return 1;
			}
			// Es un tag vacio
			if(text[i + 1] == '>')
			{
				printf("Es un tag vacio.\n");
				return 1;
			}
			// Si entra en cerrar un tag
			if(text[i + 1] == '/')
			{
				entroEnCerrarTag = 1;
				i++;
				printf("%c", text[i]);
			} else { // Entro en abrir un tag
				entroEnAbrirTag = 1;
			}
			j = 0; 		// Con j recorro el tag

		} else if( (text[i] == '>') && ( (entroEnAbrirTag) | (entroEnCerrarTag)) )
		{
			if(entroEnAbrirTag) printf("||Se abrio bien el tag||");
			if(entroEnCerrarTag) printf("||Se cerro bien el tag||");
			// Cierra el tag
			entroEnCerrarTag = 0;
			entroEnAbrirTag = 0;
		}
		i++;
		if(entroEnAbrirTag)
		{
			tagAbriendo[j] = text[i];
			j++;
		}
		if(entroEnCerrarTag)
		{
			if(tagAbriendo[j] != text[i])
			{
				printf("El tag cerrado no es igual al abierto. Tag: %i. Texto: %i.\n", j, i);
				return 1;
			}
			j++;
		}
	}
	printf("\nRecorrio bien todo el texto\n");
	return 0;
}
