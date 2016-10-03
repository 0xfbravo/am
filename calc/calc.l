%{
  #include "calc.tab.h"
%}

/* Definições (Regexp) */
Int [0-9]+

%%
{Int} { yylval = atoi(yytext); return INT; }

"+"   { return '+'; }
"-"   { return '-'; }
"*"   { return '*'; }
"/"   { return '/'; }

[ \t] /* Ignorar Espaços e TABs */

"\n" { return ENDLINE; }
