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
/* Types */
Int                 [0-9]+
Char                '[A-z]'
Bool                true|false
FloatZero           (\.[0-9]+)
Float               {Int}{FloatZero}*
/* Var||Const */
Var                 [a-zA-Z]+[0-9]*
Const               @{Var}
/* Operators */
BooleanLogic        (\|\||&&)
EqualityTest        ==|!=|===|!==
OrderRelation       <|<=|>|>=
Arithmetic          [*+\-/\^]
Not                 !
Question            \?
Colon               :
Assignment          =

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
{Arithmetic}        { yylval.operation = yytext; return ARITHMETIC; }
{BooleanLogic}      { yylval.operation = yytext; return BOOLEAN_LOGIC; }
{EqualityTest}      { yylval.operation = yytext; return EQUALITY_TEST; }
{OrderRelation}     { yylval.operation = yytext; return ORDER_RELATION; }
{Assignment}        { yylval.operation = yytext; return ASSIGNMENT; }
{Question}          { yylval.operation = yytext; return QUESTION; }
{Colon}             { yylval.operation = yytext; return COLON; }
{Not}               { yylval.operation = yytext; return NOT; }
[();]               { return *yytext; }
[\n]                { return END_LINE; }
[ \t]               /* Ignore Spaces and TABs */
%%
