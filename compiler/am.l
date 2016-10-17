/*
     _
    /_\    /\/\
   //_\\  /    \
  /  _  \/ /\/\ \
  \_/ \_/\/    \/
      Compiler

  Bianca Albuquerque, Fellipe Pimentel
  UFRRJ 2016.2
*/
%{
  #include "y.tab.h"

  #include <iostream>
  #include <string>
  using namespace std;
%}

/* Regexp */
Int                 [0-9]+
Const               @{Var}
Char                '[A-z]'
Arithmetic          [\^*+/-=]
Logic               !|\|\||&&
FloatZero           (\.[0-9]+)
Bool                true|false
Var                 ([A-z])+([0-9])*
Float               {Int}{FloatZero}*
Relational          ==|===|!=|!==|>|=>|<=|<

%%
{Logic}             { return *yytext; }
{Relational}        { return *yytext; }
{Arithmetic}        { return *yytext; }
[()]                { return *yytext; }
"\n"                { return END_LINE; }
[ \t]               /* Ignore Spaces and TABs */

{Int} {
  /* Integer */
  cout << colorText("Integer ",hexToRGB(GREEN)) << "Found: " << yytext << endl;
  yylval.translate = yytext;
  yylval.token = INTEGER;
  return INTEGER;
}
{Float} {
  /* Float */
  cout << colorText("Float ",hexToRGB(GREEN)) << "Found: " << yytext << endl;
  yylval.translate = yytext;
  yylval.token = FLOAT;
  return FLOAT;
}
{Bool} {
  /* Boolean */
  cout << colorText("Boolean ",hexToRGB(GREEN)) << "Found: " << yytext << endl;
  yylval.translate = yytext;
  yylval.token = BOOLEAN;
  return BOOLEAN;
}
{Char} {
  /* Character */
  cout << colorText("Character ",hexToRGB(GREEN)) << "Found: " << yytext << endl;
  yylval.translate = yytext;
  yylval.token = CHARACTER;
  return CHARACTER;
}
{Var} {
  /* Variables */
  cout << colorText("Var ",hexToRGB(GREEN)) << "Found: " << yytext << endl;
  yylval.id = yytext;
  yylval.token = VAR;
  return VAR;
}
{Const} {
  /* Variables */
  cout << colorText("Const ",hexToRGB(GREEN)) << "Found: " << yytext << endl;
  yylval.id = yytext;
  yylval.token = CONST;
  return CONST;
}
%%
