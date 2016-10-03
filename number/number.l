%{
  #include "number.tab.h"
%}

/* Definições (Regexp) */
Int [0-9]+
Hex [a-fA-F0-9]

%%
"0"{Int} {
  /* Octal */
  printf("Octal: %o\n",yytext);
}
{Int} {
  /* Integer */
  printf("Integer: %d\n",atoi(yytext));
  yylval = atoi(yytext);
  return INT;
}
{Int}"."{Int}* {
  /* Float */
  printf("Float: %f\n", atof(yytext));
}
"."{Int}* {
  /* Float, sem indicador inicial */
  printf("Float: %f\n", atof(yytext));
}
"0x"{Hex}+ {
  /* Hexadecimal */
  printf("Hexadecimal: %s\n", yytext);
}
"#"{Hex}{3}|"#"{Hex}{6} {
  /* Color */
  printf("Color: %s\n", yytext);
}

"+"   { return '+'; }
"-"   { return '-'; }
"*"   { return '*'; }
"/"   { return '/'; }

[ \t] /* Ignorar Espaços e TABs */

"\n" { return ENDLINE; }
%%
