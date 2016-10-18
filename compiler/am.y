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
  #include <fstream>
  #include <map>
  #include <string>
  using namespace std;

  /* Structs */
  #define YYSTYPE attr
  struct attr {
    int token;                // LexToken (Type)
    string id;                // (Var||Const).name
    string value;             // (Var||Const).value || Value
    bool isVar;               // Var||Const
    string translation;         // C Translation
    string constTranslation;    // Const C Translation
  };

  /* Flex/Yacc Functions */
  int yylex(void);
  void yyerror(string);

  /* VarMap Functions */
  void addVar(string,string,int);
  attr getVar(string);
  string checkType(string);
  void checkVar(string);

  /* VarMap */
  map<string,attr> varInfo;
  map<string,attr>::iterator varInfoIt;
%}

%token INTEGER FLOAT BOOLEAN CHARACTER VAR CONST
%token END_LINE

%left '+' '-'
%left '*' '/'
%left '^'
%left '(' ')'

%start BEFORE_THE_BEGINNING

%%
  BEFORE_THE_BEGINNING:
    BLOCK {
      ofstream ccode;
      ccode.open("am-ccode.c");
      ccode <<
      "/*" << endl <<
      "     _" << endl <<
      "    /_\\    /\\/\\" << endl <<
      "   //_\\\\  /    \\" << endl <<
      "  /  _  \\/ /\\/\\ \\" << endl <<
      "  \\_/ \\_/\\/    \\/" << endl <<
      "*/" << endl <<
      "#include <stdlib.h>" << endl <<
      "#include <stdio.h>" << endl <<
      "#include <math.h>\n" << endl <<
      "#define TRUE 1" << endl <<
      "#define FALSE 0\n" << endl <<
      "// User Consts" << endl <<
      $$.constTranslation << endl <<
      "int main() {" << endl <<
      $$.translation << endl <<
      "\treturn 0;" << endl <<
      "}" << endl;
      ccode.close();
    };
  BLOCK:
    CMDS {
      $$.translation = $1.translation;
      $$.constTranslation = $1.constTranslation;
    };
  CMDS:
    CMD CMDS {
      $$.translation = $1.translation + $2.translation;
      $$.constTranslation = $1.constTranslation + $2.constTranslation;
    };
    |;
  CMD:
    EXP END_LINE {
      if(!$1.translation.empty()){ $$.translation = "\t" + $1.translation + ";\n"; }
      if(!$1.constTranslation.empty()){ $$.constTranslation = $1.constTranslation + "\n"; }
    };
    | EXP ';' END_LINE {
      if(!$1.translation.empty()){ $$.translation = "\t" + $1.translation + ";\n"; }
      if(!$1.constTranslation.empty()){ $$.constTranslation = $1.constTranslation + "\n"; }
    };
  EXP:
    varConst '=' EXP {
      addVar($1.id, $3.translation, $3.token);
      string type = checkType($1.id) == "bool" ? "int" : checkType($1.id);
      string translation = checkType($1.id) == "bool" ? (getVar($1.id).translation == "false" ? "FALSE" : "TRUE") : $3.translation;

      if(!$1.isVar){ $$.constTranslation = "#define " + $1.id.erase(0,1) + " " + $3.translation; }
      else { $$.translation = type + " " + $1.id + " = " + translation; }
    };
    | EXP '+' EXP { $$.translation = $1.translation + " + " + $3.translation; };
    | EXP '-' EXP { $$.translation = $1.translation + " - " + $3.translation; };
    | EXP '*' EXP { $$.translation = $1.translation + " * " + $3.translation; };
    | EXP '/' EXP { $$.translation = $1.translation + " / " + $3.translation; };
    | EXP '^' EXP { $$.translation = "pow("+ $1.translation + "," + $3.translation + ")"; };
    | '(' EXP ')' { $$.translation = "("+ $2.translation + ")"; };
    | VAR {
      checkVar($1.id);
      $$.translation = $1.id;
    };
    | CONST {
      checkVar($1.id);
      $$.translation = $1.id;
    };
    | INTEGER { $$.translation = $1.value; };
    | FLOAT { $$.translation = $1.value; };
    | BOOLEAN { $$.translation = $1.value; };
    | CHARACTER { $$.translation = $1.value; };
  varConst:
    VAR { $$.id = $1.id; };
    | CONST { $$.id = $1.id; };
%%

#include "lex.yy.c"
int yyparse();
int main(int argc, char** argv){ yyparse(); }

/* Bison Error Msg */
void yyerror(string msg){
  cout <<
  colorText("error:"+to_string(yylineno)+": ",hexToRGB(RED)) <<  msg  << " with " << colorText("'"+(string)yytext+"'",hexToRGB(YELLOW)) << endl <<
  colorText("yylval.id: ",hexToRGB(TEXT)) << yylval.id << endl <<
  colorText("yylval.token: ",hexToRGB(TEXT)) << yylval.token << endl <<
  colorText("yylval.translation: ",hexToRGB(TEXT)) << yylval.translation << endl;
}

/* GetVar */
attr getVar(string name){
  varInfoIt = varInfo.find(name);
  return varInfoIt->second;
}

/* AddVar */
void addVar(string name, string translation, int token){
  varInfoIt = varInfo.find(name);
  if(varInfoIt != varInfo.end()){
    attr var = varInfoIt->second;
    if(!var.isVar) {
      /* Error when try to add a new value to a Const */
      cout << colorText("error:"+to_string(yylineno-1)+": ",hexToRGB(RED)) << colorText(name,hexToRGB(CYAN)) << " is a " << colorText("Constant",hexToRGB(GREEN)) << " and was declared previously." << endl;
      exit(1);
    }
    if(var.token != token) {
      /* Error when try to add a new value with a Different Type */
      cout << colorText("error:"+to_string(yylineno-1)+": ",hexToRGB(RED)) << colorText(name,hexToRGB(CYAN))  << " was declared previously with type " << colorText(checkType(name),hexToRGB(GREEN))  << endl;
      exit(1);
    }
  }
  attr v;
  v.token = token;
  v.translation = translation;
  varInfo[name] = v;
}

/* CheckType */
string checkType(string name){
  varInfoIt = varInfo.find(name);
  attr v = varInfoIt->second;
  switch (v.token) {
    case INTEGER: return "int";
    case FLOAT: return "float";
    case BOOLEAN: return "bool";
    case CHARACTER: return "char";
    default: return "UNDEFINED";
  }
}

/* CheckVar */
void checkVar(string name){
  varInfoIt = varInfo.find(name);
  if(varInfoIt == varInfo.end()){
    /* Error when a Var/Const wasn't declared previously */
    cout << colorText("error:"+to_string(yylineno-1)+": ",hexToRGB(RED)) << colorText(name,hexToRGB(CYAN)) << " wasn't " << colorText("declared",hexToRGB(GREEN)) << " previously." << endl;
    exit(1);
  }
}
