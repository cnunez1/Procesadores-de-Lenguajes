%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
char* titulo;
char* formula = "";
int tit=0;
int xmin=0;
int xmax=0;
int funciones=0;

%}

%x AXIS TITLE PLOT COORD1 COORD2 COORD3 COORD4 FORM

ESPACIO (" "|"\t")*
DIGITO [0-9]

%%

"\\begin{axis}"  			BEGIN(AXIS);

<AXIS>title{ESPACIO}*={ESPACIO}*\{  	BEGIN(TITLE);

<TITLE>.+   				{
					free(titulo);
					titulo = strdup(yytext);
					tit=1;
				        BEGIN(AXIS);
				    	}
            
<AXIS>xmin{ESPACIO}*={ESPACIO}*	BEGIN(COORD1);

<AXIS>\\addplot			funciones++; BEGIN(PLOT);
			
<PLOT>domain{ESPACIO}*={ESPACIO}*  	BEGIN(COORD3);

<COORD1>{DIGITO}*	 		xmin = atoi(yytext);

<COORD1>xmax{ESPACIO}*={ESPACIO}*  	BEGIN(COORD2);

<COORD2>{DIGITO}*	 		xmax = atoi(yytext); BEGIN(AXIS);

<COORD3>[-]?{DIGITO}*			if(atoi(yytext)<xmin){
						xmin = atoi(yytext); 	
					}
			
<COORD3>:				BEGIN(COORD4);

<COORD4>[-]?{DIGITO}*			if(atoi(yytext)>xmax){
						xmax = atoi(yytext); 	
					}BEGIN(PLOT);
			
<PLOT>"{"				BEGIN(FORM);

<FORM>.+				{
					if(strlen(formula)<yyleng){
						formula = strdup(yytext);
					}
					BEGIN(AXIS);
					}

<*>.|\n	;

%%

int main(int argc, char** argv) {
    if (argc > 1) {
        FILE* file;
        file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "No se puede abrir %s\n", argv[1]);
            exit(1);
        }
        yyin = file;
    } else {
        yyin = stdin;
    }
    yylex();
    if(tit){
	printf("El título es: %.*s\n", (int)strlen(titulo) - 2, titulo);
    }else{
    	printf("El título es: \"\"\n");
    }
    
    printf("Coordenada mínima: %d y máxima: %d.\n", xmin, xmax);
    printf("El gráfico contiene %d gráficas/series\n", funciones);
    printf("La fórmula más larga es \"%.*s\".\n", (int)strlen(formula) - 2, formula);
    return 0;
}

