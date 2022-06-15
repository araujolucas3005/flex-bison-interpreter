%{ 
/* analisador léxico para uma calculadora */
/* com suporte a definição de variáveis */
#include "parser.h"
#include <string.h>

char * substr(char * str, int start, int end);
%}

%option yylineno
%option noyywrap

%x      STRING

digit	[0-9]
letter_	[a-zA-Z_]
pontdig {digit}*"."?{digit}+
digpont {digit}+"."

number  {pontdig}|{digpont}
id		{letter_}({letter_}|{digit})*
str     \"[^\"\n]*\"

%%

[\t ]+		{ ; }
if          { return IF; }
sqrt        { return SQRT; }
pow         { return POW; }
print       { return PRINT; }
{number}    { yylval.num = atof(yytext); return NUM; }
{id}		{ strcpy(yylval.id, yytext); return ID; }
">="        { return GTE; }
"<="        { return LTE; }
"=="        { return EQ; }
"!="        { return NEQ; }
{str}       { 
                int len = strlen(yytext);

                if (len == 2) {
                    // se a string for apenas ""
                    strcpy(yylval.str, ""); 
                } else if (len > 100) {
                    // limite de 100 caracteres
                    // tira as aspas
                    strcpy(yylval.str, substr(yytext, 1, 101)); 
                } else {
                    // tira as aspas
                    strcpy(yylval.str, substr(yytext, 1, strlen(yytext) - 1)); 
                }

                return STR; 
            }
.|\n		{ return yytext[0]; }

%%

// função para criar uma substring de uma string
char * substr(char * str, int start, int end) {
    int i, j;
    char *sub; 
     
    if(start >= end || end > strlen(str)) {
        return NULL;
    }
     
    sub = (char *) malloc(sizeof(char) * (end - start + 1));
     
    for(i = start, j = 0; i < end; i++, j++) {
        sub[j] = str[i];
    }
     
    sub[j] = '\0';
     
    return sub;
}
