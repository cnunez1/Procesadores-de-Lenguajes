%{
#include <stdio.h>
#include <stdlib.h>
// Declaración de funciones. 
int yyerror (char *);
int yylex ();
extern FILE* yyin;
int yydebug = 1;
// Variable que almacena el conteo de etiquetas (LBL).
static int nextTag=0;
// Variable usada para imprimir el incremento de los bucles for. Solo se actualiza si se determina en incremento en la entrada.
static int increment=1;

// Método usado como contador de etiquetas.
int getNextTag(){
	return nextTag++;
}

%}

// Unión que almacena los diferentes tipos de tokenes.
%union {
	char* id;
	int num;
	int etiq;
}

// Definición de tokenes.
%token DO READ IF ELSE WHILE FROM FOR TO BY PRINT ASIG IADD ISUB IMUL IDIV <num>NUM <id>ID
%left '+' '-'
%left '*' '/'
%%

// Definición del axioma.
stmts: stmt ';' stmts
      |stmt
      ;
      
// Símbolo no terminal que gestiona el acceso a bucles, condicionales, asignaciones y print y read.      
stmt: loop 
     | cond 
     | assig 
     | io
     ;

// Símbolo no terminal que gestiona el funcionamiento de los bucles do-while y for.
loop: DO etq {printf("LBL%d:\n", $<etiq>2);} stmts WHILE '(' expr ')' etq sifalsovea {printf("\tvea LBL%d\n", $<etiq>2);} {printf("LBL%d:\n", $<etiq>9);}
     |FOR '(' ID valorid FROM expr asigna TO NUM ')' etq '{' {printf("LBL%d:\n", $<etiq>11);} stmts impr_sinInc '}' 
     |FOR '(' ID valorid FROM expr asigna TO NUM BY NUM ')' etq '{' {printf("LBL%d:\n", $<etiq>11);} stmts impr_conInc '}'
     ;
     
// Símbolo no terminal auxiliar para el loop que imprime la variable ID al principio de los bucles for.
valorid: {printf("\tvalori %s\n", $<id>0);}

// Símbolo no terminal auxiliar que muestra las impresiones de los incrementos de los bucles for cuando no se especifica el incremento de la variable que itera.
impr_sinInc: {printf("\tvalori %s\n", $<id>-11);
	      printf("\tvalord %s\n", $<id>-11); 
	      printf("\tmete %d\n", increment); 
	      printf("\tadd\n\tasigna\n"); 
	      printf("\tmete %d\n", $<num>-5); 
	      printf("\tvalord %s\n", $<id>-11); 
	      printf("\tsub\n");} 
	      etq2 sifalsovea 
	     {printf("\tvea LBL%d\n", $<etiq>-3); 
	      printf("LBL%d:\n", $<etiq>2);}

// Símbolo no terminal auxiliar que muestra las impresiones de los incrementos de los bucles for cuando se especifica el incremento de la variable que itera.
impr_conInc: {increment = $<num>-7; 
              printf("\tvalori %s\n", $<id>-13); 
              printf("\tvalord %s\n", $<id>-13); 
              printf("\tmete %d\n", $<etiq>-5);
	      printf("\tadd\n\tasigna\n"); 
	      printf("\tmete %d\n", increment); 
	      printf("\tvalord %s\n", $<id>-13); 
	      printf("\tsub\n");} 
	      etq2 sifalsovea 
	     {printf("\tvea LBL%d\n", $<etiq>-3); 
	      printf("LBL%d:\n", $<etiq>2);}

// Símbolo no terminal que gestiona el funcionamiento de los condicionales if-else.
cond: IF '(' expr ')' etq sifalsovea '{' stmts '}' {printf("LBL%d:\n", $<etiq>5);}
     |IF '(' expr ')' etq sifalsovea '{' stmts '}' ELSE etq2 {printf("\tvea LBL%d\n", $<etiq>11); printf("LBL%d:\n", $<etiq>5);} '{' stmts '}' 
      {printf("LBL%d:\n", $<etiq>11);}
     ;

// Símbolo no terminal auxiliar que incrementa la etiqueta inicial.
etq: {$<etiq>$ = getNextTag();}

// Símbolo no terminal auxiliar que incrementa la etiqueta final.
etq2: {$<etiq>$ = getNextTag();}

// Símbolo no terminal auxiliar para el cond que imprime la condición de salida cuando el condicional es falso.
sifalsovea: {printf("\tsifalsovea LBL%d\n", $<etiq>0);}

// Símbolo no terminal que gestiona el print y read     
io:   PRINT expr {printf("\tprint\n");}
     |READ ID {printf("\tread %s\n", $2);}
     ;

// Símbolo no terminal que gestiona el funcionamiento de las asignaciones y los operadores de incremento.     
assig:ID valori ASIG expr asigna
     |ID valori IADD valord expr {printf("\tadd\n");} asigna
     |ID valori ISUB valord expr {printf("\tsub\n");} asigna
     |ID valori IMUL valord expr {printf("\tmul\n");} asigna 
     |ID valori IDIV valord expr {printf("\tdiv\n");} asigna 
     |val
     ;
     
// Símbolo no terminal auxiliar para el assig que imprime el valori de una variable.    
valori: {printf("\tvalori %s\n", $<id>0);}

// Símbolo no terminal auxiliar para el assig que imprime el valord de una variable.
valord: {printf("\tvalord %s\n", $<id>-2);}

// Símbolo no terminal auxiliar para el assig que muestra la asignación de una variable.
asigna: {printf("\tasigna\n");}

// Símbolo no terminal que gestiona el funcionamiento de las sumas y restas.     
expr: expr '+' mult {printf("\tadd\n");}
     |expr '-' mult {printf("\tsub\n");}
     |mult     
     ;

// Símbolo no terminal que gestiona el funcionamiento de los productos y divisiones.     
mult: mult '*' val {printf("\tmul\n");}
     |mult '/' val {printf("\tdiv\n");}
     |val
     ;

// Símbolo no terminal que gestiona la recogida de números y nombres de variables.     
val: NUM {printf("\tmete %d\n", $1);} | ID {printf("\tvalord %s\n", $1);} | '(' expr ')' ;

%%

// Método que muestra mensajes de errores sintácticos.
int yyerror (char* msg){
	fprintf(stderr, "Syntax error");
}

// Método main
int main(int argc, char** argv){
	if(argc > 1){
		FILE* file;
		file=fopen(argv[1], "r");
		if(!file){
			fprintf(stderr, "No se puede abrir %s\n", argv[1]);
			exit(1);
		}
		yyin = file;
	}
	yyparse();
}
	

