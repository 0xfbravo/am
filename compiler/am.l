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

%option yylineno

/* Regexp */
Int                 [0-9]+
Const               @{Var}
Char                '[A-z]'
FloatZero           (\.[0-9]+)
Arithmetic          [*+\-=/\^]
Logic               (!|\|\||&&)
Var                 [a-zA-Z]+[0-9]*
Float               {Int}{FloatZero}*
Relational          ((===|==)|(!==|!=)|>|=>|<=|<)
Bool                true|false|True|False|TRUE|FALSE

%%
{Int} {
  /* Integer */
  //cout << colorText("Integer ",hexToRGB(GREEN)) << "Found: " << yytext << endl;
  yylval.value = yytext;
  yylval.token = INTEGER;
  return INTEGER;
}
{Float} {
  /* Float */
  //cout << colorText("Float ",hexToRGB(GREEN)) << "Found: " << yytext << endl;
  yylval.value = yytext;
  yylval.token = FLOAT;
  return FLOAT;
}
{Bool} {
  /* Boolean */
  //cout << colorText("Boolean ",hexToRGB(GREEN)) << "Found: " << yytext << endl;
  yylval.value = yytext;
  yylval.token = BOOLEAN;
  return BOOLEAN;
}
{Char} {
  /* Character */
  //cout << colorText("Character ",hexToRGB(GREEN)) << "Found: " << yytext << endl;
  yylval.value = yytext;
  yylval.token = CHARACTER;
  return CHARACTER;
}

{Var} {
  /* Variables */
  //cout << colorText("Var ",hexToRGB(GREEN)) << "Found: " << yytext << endl;
  yylval.id = yytext;
  yylval.token = VAR;
  yylval.isVar = true;
  return VAR;
}
{Const} {
  /* Constants */
  //cout << colorText("Const ",hexToRGB(GREEN)) << "Found: " << yytext << endl;
  yylval.id = yytext;
  yylval.token = CONST;
  yylval.isVar = false;
  return CONST;
}

{Logic}             { return *yytext; }
{Relational}        { return *yytext; }
{Arithmetic}        { return *yytext; }
[();]               { return *yytext; }
[\n]                { return END_LINE; }
[ \t]               /* Ignore Spaces and TABs */
%%
