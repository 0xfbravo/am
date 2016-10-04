%{
  #include <stdlib.h>
  #include <stdio.h>
  void yyerror(char *);

  int exponential(int base, int exp);
%}

%token INT
%token ENDLINE

%left '+' '-'
%left '*' '/'
%left '^'
%left '{' '}'
%left '[' ']'
%left '(' ')'

%start line

%%
line: exp ENDLINE { printf("Resultado: \%d\n", $1); }
exp:
    '('exp')' { $$ = $2; }
  | '['exp']' { $$ = $2; }
  | '{'exp'}' { $$ = $2; }
  | exp '^' exp { $$ = exponential($1,$3); };
  | exp '*' exp { $$ = $1 * $3; };
  | exp '/' exp { $$ = $1 / $3; };
  | exp '+' exp { $$ = $1 + $3; };
  | exp '-' exp { $$ = $1 - $3; };
  | termo { $$ = $1; };
termo: INT { $$ = $1; };
%%

/*
  Exponential
*/
int exponential(int base, int exp){
  if(exp == 0) { return 1; }
  return base * exponential(base,exp-1);
}

int main(int argc, char** argv){ return yyparse(); }

/* função usada pelo bison para dar mensagens de erro */
void yyerror(char *msg){ fprintf(stderr, "erro: %s\n", msg); }
