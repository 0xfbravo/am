%{
  #include <stdlib.h>
  #include <stdio.h>
  void yyerror(char *);
%}

%token INT
%token ENDLINE

%left '+' '-'
%left '*' '/'

%start line

%%
line: exp ENDLINE { printf("Resultado: \%d\n", $1); }

exp:
  exp '*' exp { $$ = $1 * $3; };
  | exp '/' exp { $$ = $1 / $3; };
  | exp '+' exp { $$ = $1 + $3; };
  | exp '-' exp { $$ = $1 - $3; };
  | termo { $$ = $1; };

termo: INT { $$ = $1; };
%%

int main(int argc, char** argv){
  return yyparse();
}

/* função usada pelo bison para dar mensagens de erro */
void yyerror(char *msg)
{
  fprintf(stderr, "erro: %s\n", msg);
}
