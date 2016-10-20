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
  #include <fstream>
  #include <iostream>
  #include <locale>
  #include <map>
  #include <string>
  using namespace std;

  /* Structs */
  #define YYSTYPE attr
  struct attr {
    int token;                  // LexToken (Type)
    string id;                  // (Var||Const).name
    string value;               // (Var||Const).value || Value
    bool isVar;                 // Var||Const
    string translation;         // C Translation
    string constTranslation;    // Const C Translation
    string operation;           // Operation
  };

  /* Flex/Yacc Functions */
  int yylex(void);
  void yyerror(string);
  void wrongOperation(string,string);

  /* VarMap Functions */
  void addVar(string,bool,string,int);
  attr getVar(string);
  string checkType(int);
  string checkType(string);
  void checkVar(string);

  /* VarMap */
  map<string,attr> varInfo;
  map<string,attr>::iterator varInfoIt;

  /* Useful Functions */
  string toUpper(const string&);
%}

%token INTEGER FLOAT BOOLEAN CHARACTER
%token ASSIGNMENT BOOLEAN_LOGIC CONDITIONAL_LOGIC EQUALITY_TEST ORDER_RELATION
%token VAR CONST
%token END_LINE

%left '='
%left "||" "&&" '!' '?' ':' "==" "!=" "===" "!==" '<' '>' "<=" ">="
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
    EXP BOOLEAN_LOGIC EXP {
      if($1.token != BOOLEAN){ wrongOperation($2.operation,checkType($1.token)); }
      else if($3.token != BOOLEAN){ wrongOperation($2.operation,checkType($3.token)); }
      if($2.operation == "||"){ $$.translation = $1.id + " || " + $3.id; }
      else if($2.operation == "&&"){ $$.translation = $1.id + " && " + $3.id; }
      $$.token = BOOLEAN;
    };
    | '!' EXP {
      if($2.token != BOOLEAN){ wrongOperation("!",checkType($2.token)); }
      $$.translation = "!" + $2.translation;
      $$.token = BOOLEAN;
    }
    | EXP '?' EXP ':' EXP {
      cout << $2.operation << " " << $1.translation << " " << $3.translation << endl;
    };
    | EXP EQUALITY_TEST EXP {
      cout << $1.value << " " << $2.value << endl;
      if($2.operation == "==="){
        // Equal Types
        $$.translation = $1.token == $3.token ? "TRUE" : "FALSE";
        $$.value = $1.token == $3.token ? "true" : "false";
        $$.token = BOOLEAN;
      }
      else if($2.operation == "!=="){
        // Different Types
        $$.translation = $1.token != $3.token ? "TRUE" : "FALSE";
        $$.value = $1.token != $3.token ? "true" : "false";
        $$.token = BOOLEAN;
      }
      else if($2.operation == "=="){
        // Equal Values
        $$.translation = $1.value == $3.value ? "TRUE" : "FALSE";
        $$.value = $1.value == $3.value ? "true" : "false";
        $$.token = BOOLEAN;
      }
      else if($2.operation == "!="){
        // Different Values
        $$.translation = $1.value != $3.value ? "TRUE" : "FALSE";
        $$.value = $1.value != $3.value ? "true" : "false";
        $$.token = BOOLEAN;
      }
    };
    | EXP ORDER_RELATION EXP {
      if($1.token != FLOAT && $1.token != INTEGER){ wrongOperation($2.operation,checkType($1.token)); }
      else if($3.token != FLOAT && $3.token != INTEGER){ wrongOperation($2.operation,checkType($3.token)); }
      cout << $2.operation << " " << $1.translation << " " << $3.translation << endl;
    };
    | varConst ASSIGNMENT EXP {
      addVar($1.id, $1.isVar, $3.value, $3.token);
      if(!$1.isVar){ $$.constTranslation = "#define " + $1.id.erase(0,1) + " " + $3.translation; }
      else {
        string type = checkType($1.id) == "bool" ? "int" : checkType($1.id);
        $$.translation = type + " " + $1.id + " = " + $3.translation;
      }
    };
    | EXP '+' EXP {
      if($1.token == BOOLEAN || $3.token == BOOLEAN){ wrongOperation("+","bool"); }
      if($1.token == INTEGER && $3.token == FLOAT){ $1.translation = "(float) "+$1.translation; $$.token = FLOAT; }
      else if($1.token == FLOAT && $3.token == INTEGER){ $3.translation = "(float) "+$3.translation; $$.token = FLOAT; }
      $$.translation = $1.translation + " + " + $3.translation;
    };
    | EXP '-' EXP {
      if($1.token == BOOLEAN || $3.token == BOOLEAN){ wrongOperation("-","bool"); }
      if($1.token == INTEGER && $3.token == FLOAT){ $1.translation = "(float) "+$1.translation; $$.token = FLOAT; }
      else if($1.token == FLOAT && $3.token == INTEGER){ $3.translation = "(float) "+$3.translation; $$.token = FLOAT; }
      $$.translation = $1.translation + " - " + $3.translation;
    };
    | EXP '*' EXP {
      if($1.token == BOOLEAN || $3.token == BOOLEAN){ wrongOperation("*","bool"); }
      if($1.token == INTEGER && $3.token == FLOAT){ $1.translation = "(float) "+$1.translation; $$.token = FLOAT; }
      else if($1.token == FLOAT && $3.token == INTEGER){ $3.translation = "(float) "+$3.translation; $$.token = FLOAT; }
      $$.translation = $1.translation + " * " + $3.translation;
    };
    | EXP '/' EXP {
      if($1.token == BOOLEAN || $3.token == BOOLEAN){ wrongOperation("/","bool"); }
      if($1.token == INTEGER && $3.token == FLOAT){ $1.translation = "(float) "+$1.translation; $$.token = FLOAT; }
      else if($1.token == FLOAT && $3.token == INTEGER){ $3.translation = "(float) "+$3.translation; $$.token = FLOAT; }
      $$.translation = $1.translation + " / " + $3.translation;
    };
    | EXP '^' EXP {
      if($1.token == BOOLEAN || $3.token == BOOLEAN){ wrongOperation("^","bool"); }
      if($1.token == INTEGER && $3.token == FLOAT){ $1.translation = "(float) "+$1.translation; $$.token = FLOAT; }
      else if($1.token == FLOAT && $3.token == INTEGER){ $3.translation = "(float) "+$3.translation; $$.token = FLOAT; }
      $$.translation = "pow("+ $1.translation + "," + $3.translation + ")";
    };
    | '(' EXP ')' {
      $$.token = $2.token;
      $$.translation = "("+ $2.translation + ")";
      $$.value = $2.value;
    };
    | VAR {
      checkVar($1.id);
      $$.token = getVar($1.id).token;
      $$.value = getVar($1.id).value;
      $$.translation = $1.id;
    };
    | CONST {
      checkVar($1.id);
      $$.token = getVar($1.id).token;
      $$.value = getVar($1.id).value;
      $$.translation = $1.id;
    };
    | INTEGER { $$.translation = $1.value; $$.value = $1.value; $$.token = INTEGER; };
    | FLOAT { $$.translation = $1.value; $$.value = $1.value; $$.token = FLOAT; };
    | BOOLEAN { $$.translation = toUpper($1.value); $$.value = $1.value; $$.token = BOOLEAN; };
    | CHARACTER { $$.translation = $1.value; $$.value = $1.value; $$.token = CHARACTER; };
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
  colorText("yylval.token: ",hexToRGB(TEXT)) << yylval.token << endl <<
  colorText("yylval.id: ",hexToRGB(TEXT)) << yylval.id << endl <<
  colorText("yylval.value: ",hexToRGB(TEXT)) << yylval.value << endl <<
  colorText("yylval.isVar: ",hexToRGB(TEXT)) << yylval.isVar << endl <<
  colorText("yylval.translation: ",hexToRGB(TEXT)) << yylval.translation << endl <<
  colorText("yylval.constTranslation: ",hexToRGB(TEXT)) << yylval.constTranslation << endl;
}

/* WrongOperation */
void wrongOperation(string operation, string type){
  cout << colorText("error:"+to_string(yylineno-1)+": ",hexToRGB(RED)) << "This operation " << colorText("'"+operation+"'",hexToRGB(CYAN)) << " wasn't defined for type " << colorText(type,hexToRGB(GREEN))  << endl;
  exit(1);
}

/* GetVar */
attr getVar(string name){
  varInfoIt = varInfo.find(name);
  return varInfoIt->second;
}

/* AddVar */
void addVar(string name, bool isVar, string value, int token){
  varInfoIt = varInfo.find(name);
  //cout << name << " " << isVar << " " << value << " " << token << endl;

  if(varInfoIt != varInfo.end()){ // Var||Const was declared previously
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
  v.id = name;
  v.isVar = isVar;
  v.value = value;
  v.token = token;
  varInfo[name] = v;
}

/* CheckType */
string checkType(int token){
  switch (token) {
    case INTEGER: return "int";
    case FLOAT: return "float";
    case BOOLEAN: return "bool";
    case CHARACTER: return "char";
    default: return "UNDEFINED";
  }
}
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

/* ToUpper */
string toUpper(const string& s){
  string result; locale l;
  for(int i = 0; i < s.length(); i++){ result += toupper(s.at(i),l); }
  return result;
}
