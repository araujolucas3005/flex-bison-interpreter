%{ 
/* analisador léxico para uma calculadora */
/* com suporte a definição de variáveis */
#include "parser.h"
#include <string.h>

char str[100];

char * substr(char * str, int start, int end);
%}

%option yylineno
%option noyywrap

%x      STRING

digito	[0-9]
letra_	[a-zA-Z_]
pontdig {digito}*"."?{digito}+
digpont {digito}+"."

numero  {pontdig}|{digpont}
id		{letra_}({letra_}|{digito})*
sqrt    sqrt
pow     pow
if      if
print   print
str     \"[^\"\n]*\"

%%

[\t ]+		{ ; }
{sqrt}      { return SQRT; }
{pow}       { return POW; }
{if}        { return IF; }
{print}     { return PRINT; }
{numero}    { yylval.num = atof(yytext); return NUM; }
{id}		{ strcpy(yylval.id, yytext); return ID; }
">="        { return GTE; }
"<="        { return LTE; }
"=="        { return EQ; }
"!="        { return NEQ; }
{str}       { 
                // quando yytext = ""
                if (strlen(yytext) == 2) {
                    strcpy(yylval.str, ""); 
                } else {
                    // remove as aspas duplas do yytext
                    // ex.: "test" vira test
                    strcpy(yylval.str, substr(yytext, 1, strlen(yytext) - 1)); 
                }
                return STR; 
            }
.|\n		{ return yytext[0]; }

%%

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
