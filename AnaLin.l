%{
#include <stdio.h>
#include "y.tab.h"
// Variables que almacenan números y strings.
int num;
char* id;

// Definición de reglas para los comentarios y los símbolos terminales.
%}

%%

[ \n\t]	;
"#".*		;

"do"		return DO;
"read"		return READ;
"if"		return IF;
"else"		return ELSE;
"while"	return WHILE;
"from"		return FROM;
"for"		return FOR;
"to"		return TO;
"by"		return BY;
"print"	return PRINT;
"<:"		return ASIG;
"+="		return IADD;
"-="		return ISUB;
"*="		return IMUL;
"/="		return IDIV;

[0-9]+					{yylval.num=atoi(yytext); return NUM;}
[a-zA-Z_][a-zA-Z0-9_]*			{yylval.id = strdup(yytext); return ID;}
.					return yytext[0];

%%

