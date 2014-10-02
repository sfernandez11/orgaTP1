#include "validate.h"

void cargarArchivoAMemoria(FILE* archivoEntrada, char** text) 
{ 
	int size;
	fseek(archivoEntrada, 0, SEEK_END);
	size = ftell(archivoEntrada);
	rewind(archivoEntrada);
	*text = (char *)malloc(size+1);
	if (size != fread(*text, sizeof(char), size, archivoEntrada)) 
	{ 
		free(*text);
		fprintf(stderr, "Error, no se pudo cargar el archivo a memoria, el programa se cerrara.\n");
		exit(1);
	} 
	(*text)[size] = 0; //Para saber donde cortar la iteracion del vector.
}

//Funcion que imprime el manual del TP1
void printManual(){
	printf("Usage:\n validate -h\n");
	printf(" validate -V\n");
	printf(" validate [options] file\n");
	printf("Options:\n");
	printf(" -h, --help  	Prints usage information.\n");
	printf(" -V, --version 	Prints version information.\n");
	printf(" -i, --input 	Path to input file (-i - for stdin)\n");
	printf("Examples:\n");
	printf(" validate -i -\n");
	printf(" validate myfile.tagged\n");
	printf(" validate -i myfile.tagged\n");
}

//Funcion para comprobar que los archivos se abrieron bien.
void checkFile(FILE* file){
    if (file == NULL){
    	//Si hay error se escribe por stderr.
    	fprintf(stderr, "Error, nombre de archivo inexistente, el programa se cerrara.\n");
        exit(1); // Se cierra el programa y se devuelve 1 por error.
    }
}

//Funcion principal del TP1
int main(int argc, char* argv[]){

	int next_option;

	const char* const short_options = "i:hV";

	const struct option long_options[] = {

		{ "input",     	1, NULL, 'i' },
		{ "help",    	0, NULL, 'h' },
		{ "version",    0, NULL, 'V' },
		{ NULL,         0, NULL, 0   } /* Necesario al final del array.  */
	};

	//Aca por defecto se establecen algunos parametros.
	//Luego depende las opciones elegidas se van cambiando.
	FILE* archivoEntrada = stdin;
	const char* nombreArchivo;
	int ejecutar = 0;
	int flag;
	char* text;

	//Procesamiento de los parametros de entrada.
	do {
		next_option = getopt_long(argc, argv, short_options, long_options, NULL);

		switch (next_option){

		case 'i':   /* -i, --input */
		/* Indica el archivo de entrada a utilizar (-i - for stdin) */
		if (strcmp(optarg, "-") != 0){
			nombreArchivo = optarg;
	    	archivoEntrada = fopen(nombreArchivo, "r");
			printf("\nArchivo actual: %s\n",nombreArchivo);
			checkFile(archivoEntrada);
			cargarArchivoAMemoria(archivoEntrada, &text);
			fclose(archivoEntrada);
		}
		ejecutar = 1;
		break;

		case 'h':   /* -h, --help */
		/* Imprime el menu de ayuda  */
		printManual();
		exit(0);
		break;

		case 'V':   /* -V, --version */
		/*  Prints version information.  */
		printf(" Version 1.0 del TP1\n");
		exit(0);
		break;

		case -1:    /* Se terminaron las opciones */
		break;

		default:    /* Opcion incorrecta */
		fprintf(stderr, "Error, opcion incorrecta, el programa se cerrara.\n");
		printManual(); //Se imprime el manual para que se vean las opciones correctas.
		exit(1);	// Se cierra el programa y se devuelve 1 por error.
		}
	} while (next_option != -1);

	if (argc == (optind + 1)){
		nombreArchivo = argv[optind];
		archivoEntrada = fopen(nombreArchivo, "r");
		printf("\nArchivo actual: %s\n",nombreArchivo);
		checkFile(archivoEntrada);
		cargarArchivoAMemoria(archivoEntrada, &text);
		fclose(archivoEntrada);
		ejecutar = 1;
	}

	int prueba = 0;
	//Arranca la ejecucion del programa.
	if (ejecutar){
		printf("Arranca\n");

		//Se llama a la funcion validate.
		// *text es un puntero al texto contenido en el archivo.
		// **errmsg es un puntero a un array de caracteres, a llenar por la funcion validate en caso de error.
		//Se utiliza la variable flag para ver si hubo error o no en la validacion.
		//La funcion debe retornar 0 en caso de que la validacion sea correcta, o 1 en caso de que no.
		//flag = validate(char *text, char **errmsg);
		//if (flag != 0){
		//	fprintf(stderr, "%s en la linea %i\n", errmsg[flag], lineaError);
		//	exit(1);
		//}

		do { 
			putchar(text[prueba]);
			prueba++;
		} 
		while(text[prueba] != '\0');

	} else {
		fprintf(stderr, "Error, accion invalida, el programa se cerrara.\n");
		printManual(); //Se imprime el manual para que se vean las opciones correctas.
		exit(1);	// Se cierra el programa y se devuelve 1 por error.
	}

    return 0;
}
