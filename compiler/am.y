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
  #include "am-custom.h"
  #include <iostream>
  #include <map>
  #include <string>
  using namespace std;

  /* Structs */
  #define YYSTYPE attr
  struct attr {
    int token;
    string id;
    string type;
    string translate;
  };

  /* Flex/Yacc Functions */
  int yylex(void);
  void yyerror(string);

  /* VarMap Functions */
  void addVar(string,string,int);
  attr getVar(string);
  string checkType(string);
  bool isVar(string);

  /* VarMap */
  map<string,attr> varInfo;
  map<string,attr>::iterator varInfoIt;
%}

%token INTEGER FLOAT BOOLEAN CHARACTER VAR CONST
%token END_LINE

%start BEFORE_THE_BEGINNING

%%
  BEFORE_THE_BEGINNING:
    BLOCK {
      cout <<
      "#include <stdlib.h>" << endl <<
      "#include <stdio.h>\n" << endl <<
      "#define TRUE 1" << endl <<
      "#define FALSE 0\n" << endl <<
      "int main() {" << endl <<
      $$.translate << endl <<
      "\treturn 0;" << endl <<
      "}" << endl;
    };
  BLOCK:
    CMDS { $$.translate = "\t"+$1.translate; };
  CMDS:
    CMD CMDS
    |;
  CMD:
    EXP END_LINE;
  EXP:
    varConst '=' temp {
      addVar($1.id, $3.translate, $3.token);
      $$.id = $1.id;  $$.translate = $3.translate; $$.token = $3.token;
      string type = checkType($1.id) == "bool" ? "int" : checkType($1.id);
      string translate = checkType($1.id) == "bool" ? (getVar($1.id).translate == "false" ? "FALSE" : "TRUE") : $3.translate;
      $$.translate = type + " " + $1.id + " = " + translate+";\n";
    };
  varConst:
    VAR { $$.id = $1.id; };
    | CONST { $$.id = $1.id; };
  temp:
    VAR { $$.id = $1.id; };
    | CONST { $$.id = $1.id; };
    | INTEGER { $$.translate = $1.translate; };
    | FLOAT { $$.translate = $1.translate; };
    | BOOLEAN { $$.translate = $1.translate; };
    | CHARACTER { $$.translate = $1.translate; };
%%

#include "lex.yy.c"
int yyparse();
int main(int argc, char** argv){ yyparse(); }

/* Bison Error Msg */
void yyerror(string msg){
  cout << colorText("ERROR: ",hexToRGB(RED)) << msg  << " at " << colorText("'"+(string)yytext+"'",hexToRGB(YELLOW)) << endl <<
  colorText("\tyylval.id: ",hexToRGB(TEXT)) << yylval.id << endl <<
  colorText("\tyylval.type: ",hexToRGB(TEXT)) << yylval.type << endl <<
  colorText("\tyylval.translate: ",hexToRGB(TEXT)) << yylval.translate << endl;
}

/* GetVar */
attr getVar(string name){
  varInfoIt = varInfo.find(name);
  return varInfoIt->second;
}

/* AddVar */
void addVar(string name, string translate, int type){
  varInfoIt = varInfo.find(name);
  if(varInfoIt != varInfo.end()){
    cout << colorText("ERROR: ",hexToRGB(RED)) << "Dude... " << colorText(name,hexToRGB(YELLOW)) << " was already declared previously..." << endl;
    exit(1);
  }
  attr v;
  v.token = type;
  v.translate = translate;
  varInfo[name] = v;
}

/* CheckType */
string checkType(string name){
  varInfoIt = varInfo.find(name);
  attr v = varInfoIt->second;
  switch (v.token) {
    case INTEGER: v.type = "int"; return "int";
    case FLOAT: v.type = "float"; return "float";
    case BOOLEAN: v.type = "bool"; return "bool";
    case CHARACTER: v.type = "char"; return "char";
    case VAR: v.type = "var"; return "var";
    case CONST: v.type = "const"; return "const";
    default: return "UNDEFINED";
  }
}
