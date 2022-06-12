%{
/* analisador sintático para uma calculadora */
/* com suporte a definição de variáveis */
#include <iostream>
#include <string>
#include <unordered_map>
#include <math.h>

using std::string;
using std::unordered_map;
using std::cout;

/* protótipos das funções especiais */
int yylex(void);
int yyparse(void);
void yyerror(const char *);

/* tabela de símbolos */
unordered_map<string,double> variables;
bool iflag = true;
%}

%union {
	double num;
	char id[16];
	char str[100];
}

%token <id> ID
%token <num> NUM
%token <str> STR
%token SQRT
%token POW
%token IF
%token PRINT
%token GTE
%token LTE
%token EQ
%token NEQ

%type <num> expr
%type <num> argnum
%type <str> argstr
%type <num> rel

%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%%

prog: prog code '\n'
	| code '\n'
	;

code: inst
	| if
	|
	; 

inst: ID '=' expr 					{ if (iflag) variables[$1] = $3; } 	
	| PRINT '(' args ')'			{ cout << '\n';}

if: IF '(' relif ')' inst			{ iflag = true; }

args: argnum
	| argstr					
	| argstr ',' args
	| argnum ',' args
	;			

argnum: expr						{ if (iflag) cout << $1 << " "; }
	  | rel							{ 
		  								if (iflag) {
											if ($1) {
												cout << "true ";
											} else {
												cout << "false ";
											}
										}
	   								}
argstr: STR							{ if (iflag) cout << $1 << " "; }

rel: expr '>' expr					{ $$ = $1 > $3; }
   | expr '<' expr					{ $$ = $1 < $3; }
   | expr GTE expr					{ $$ = $1 >= $3; }
   | expr LTE expr					{ $$ = $1 <= $3; }
   | expr EQ expr					{ $$ = $1 == $3; }
   | expr NEQ expr					{ $$ = $1 != $3; }
   ;

relif: rel							{ iflag = $1; }

expr: expr '+' expr					{ $$ = $1 + $3; }
	| expr '-' expr   				{ $$ = $1 - $3; }
	| expr '*' expr					{ $$ = $1 * $3; }
	| expr '/' expr					{ 
										if ($3 == 0)
											yyerror("divisão por zero");
										else
											$$ = $1 / $3; 
									}
	| SQRT '(' expr ')'				{ $$ = sqrt($3); }
	| POW '(' expr ',' expr ')'		{ $$ = pow($3, $5); }
	| '(' expr ')'					{ $$ = $2; }
	| '-' expr %prec UMINUS 		{ $$ = - $2; }
	| ID							{ $$ = variables[$1]; }
	| NUM
	;			
  							
%%

extern FILE * yyin;  

int main(int argc, char ** argv)
{
	if (argc > 1)
	{
		FILE * file;
		file = fopen(argv[1], "r");
		if (!file)
		{
			cout << "Arquivo " << argv[1] << " não encontrado!\n";
			exit(1);
		}
		
		yyin = file;
	}

	yyparse();
}

void yyerror(const char * s)
{
	extern int yylineno;    
	extern char * yytext;   

    cout << "Erro (" << s << "): símbolo \"" << yytext << "\" (linha " << yylineno << ")\n";
}
