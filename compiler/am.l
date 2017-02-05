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
/* Block */
BlockInit           \{
BlockEnd            \}
SemiColon           ;
Comma               ,
/* Types */
ExplicitType        int|float
Int                 [0-9]+|-[0-9]+
String              \"(\\.|[^\\"])*\"
Char                '.'
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
Arithmetic1         [+\-]
Arithmetic2         [*\/]
Not                 !
Question            \?
Colon               :
Assignment          =

%%
"if"                { return R_IF; }
"else"              { return R_ELSE; }
"while"             { return R_WHILE; }
"do"                { return R_DO; }
"for"               { return R_FOR; }
"switch"            { return R_SWITCH; }
"case"              { return R_CASE; }
"break"             { return R_BREAK; }
"continue"          { return R_CONTINUE; }
"String"            { yylval.token = STRING; return STRING; }
"Float"             { yylval.token = FLOAT; return FLOAT; }
"Int"               { yylval.token = INTEGER; return INTEGER; }
"Bool"              { yylval.token = BOOLEAN; return BOOLEAN; }
"Char"              { yylval.token = CHARACTER; return CHARACTER; }
"is"                { return R_IS; }
"in"                { return R_IN; }
"out"               { return R_OUT; }
"\."                { return R_DOT; }
{BlockInit}         { return BLOCK_INIT; }
{BlockEnd}          { return BLOCK_END; }
{SemiColon}         { return SEMI_COLON; }
{Comma}             { return COMMA; }
{Arithmetic1}       { yylval.operation = yytext; return ARITHMETIC_1; }
{Arithmetic2}       { yylval.operation = yytext; return ARITHMETIC_2; }
{BooleanLogic}      { yylval.operation = yytext; return BOOLEAN_LOGIC; }
{EqualityTest}      { yylval.operation = yytext; return EQUALITY_TEST; }
{OrderRelation}     { yylval.operation = yytext; return ORDER_RELATION; }
{Assignment}        { yylval.operation = yytext; return ASSIGNMENT; }
{Question}          { yylval.operation = yytext; return QUESTION; }
{Colon}             { yylval.operation = yytext; return COLON; }
{Not}               { yylval.operation = yytext; return NOT; }
[\(\)]              { return *yytext; }
[\n]                { return END_LINE; }
[ \t]               /* Ignore Spaces and TABs */

{ExplicitType} {
  if((string)yytext == "int"){ yylval.token = INTEGER; }
  if((string)yytext == "float"){ yylval.token = FLOAT; }
  return EXPLICIT_TYPE;
}
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
{String} {
  /* String */
  //cout << colorText("String ",hexToRGB(GREEN)) << "Found: " << yytext << endl;
  yylval.value = yytext;
  yylval.token = STRING;
  return STRING;
}
{Char} {
  /* Character */
  //cout << colorText("Character ",hexToRGB(GREEN)) << "Found: " << yytext << endl;
  yylval.value = yytext;
  yylval.token = CHARACTER;
  return CHARACTER;
}
{Const} {
  /* Constants */
  //cout << colorText("Const ",hexToRGB(GREEN)) << "Found: " << yytext << endl;
  yylval.id = yytext;
  yylval.token = CONST;
  yylval.isVar = false;
  return CONST;
}
{Var} {
  /* Variables */
  //cout << colorText("Var ",hexToRGB(GREEN)) << "Found: " << yytext << endl;
  yylval.id = yytext;
  yylval.token = VAR;
  yylval.isVar = true;
  return VAR;
}
%%
