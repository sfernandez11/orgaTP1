#include "b16.h"

//Funcion para escribir errores MIPS en stderr
void checkError(int errCode){
	if (errCode){
		fprintf(stderr, "%s", b16_errmsg[errCode]);
		exit(errCode);
	}
}

//Funcion para saber si se quiere codificar o decodificar.
Action getAction(char* string){
	if (strcmp(string, "encode") == 0){
		return ENCODE;
	}else if (strcmp(string, "decode") == 0){
		return DECODE;
	}else{
		checkError(8);	// 8 = accion invalida
		return INVALIDA;
	}
}

//Funcion que imprime el manual del TP1
void printManual(){
	printf("Usage:\n tp1 -h\n tp1 -V\n tp1 [options]\nOptions:\n");
	printf(" -V, --version	Print version and quit.\n");
	printf(" -h, --help	Print this information.\n");
	printf(" -i, --input	Location of the input file.\n");
	printf(" -o, --output	Location of the output file.\n");
	printf(" -a, --action	Program action: encode(default) or decode.\n");
	printf("Examples:\n");
	printf(" tp1\n");
	printf(" tp1 -a encode\n");
	printf(" tp1 -a decode\n");	
	printf(" tp1 -a encode -i -/input -o -/output\n");
	printf(" tp1 -a decode -i -/input -o -/output\n");
}

//Funcion para comprobar que los archivos se abrieron bien.
void checkFile(FILE* file){
	if (file == NULL){
		checkError(1); // 1 = error de apertura de archivo
	}
}

//Funcion principal del TP1
int main(int argc, char* argv[]){

  int next_option;

  const char* const short_options = "a:i:o:hV";

const struct option long_options[] = {
    { "action",		1, NULL, 'a' },
    { "output",   	1, NULL, 'o' },
    { "input",  	1, NULL, 'i' },
	{ "help",  		0, NULL, 'h' },
	{ "version",  	0, NULL, 'V' },    
    { NULL,       	0, NULL, 0   }   /* Necesario al final del array.  */
  };

FILE* input = stdin;
FILE* output = stdout;
const char* output_filename;
const char* input_filename;
Action action = ENCODE;
int infd;
int outfd;

do {
    next_option = getopt_long (argc, argv, short_options,
                               long_options, NULL);
    switch (next_option)
    {
    case 'o':   /* -o o --output */
      /* Toma un argumento, el nombre del archivo de salida.  */
      output_filename = optarg;
      if (strcmp(output_filename, "-") != 0){  
		output = fopen(output_filename, "w");
		checkFile(output);
	  }
      break;

	case 'i':   /* -i o --input */
	  /* Toma un argumento, el nombre del archivo de entrada.  */	
      input_filename = optarg;
      if (strcmp(input_filename, "-") != 0){
		input = fopen(input_filename, "r");
		checkFile(input);
	  }
      break;
      
	case 'a':   /* -a o --action */
      /* Toma un argumento, la accion.  */
      action = getAction(optarg);
      break;

    case 'h':   /* -h o --help */
      /* Imprime la ayuda  */
      printManual();
      break;

    case 'V':   /* -V o --version */
      /* imprime la version actual del programa */
      printf("Version 2.0\n");
      break;

    case -1:    /* Se terminaron las opciones */
      break;

    default:    /* Opcion incorrecta */
	  checkError(9);	// 9 = error de opcion incorrecta
    }
  }
  while (next_option != -1);

	infd = fileno(input);
	outfd = fileno(output);
	
	if (infd == -1 || outfd == -1){
		checkError(3); // 3 = error en el file descriptor
	}
		
	if (action == ENCODE){
		int errCode;
		errCode = encode(infd,outfd);
		checkError(errCode);
	}
	
	if (action == DECODE){
		int errCode;
		errCode = decode(infd,outfd);
		checkError(errCode);
	}
	
	if (input != stdin){
		 int valorCierre;
		 valorCierre = fclose(input);
		 if (valorCierre) checkError(2);	//2 = error de cierre
	}
	if (output != stdout){
		int valorCierre;
		valorCierre = fclose(output);
		if (valorCierre) checkError(2);	//2 = error de cierre
	}
	
    return 0;
}
