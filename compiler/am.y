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

  int tempCount = 0;

  /* Structs */
  struct temp {
    int token;
    string name;
    string value;
    string translation;
  };

  #define YYSTYPE attr
  struct attr {
    int token;                  // LexToken (Type)
    temp tempVar;               // TempVar
    string id;                  // (Var||Const).name
    string value;               // (Var||Const).value || Value
    bool isVar;                 // Var||Const
    string translation;         // C Translation
    string tempTranslation;     // Var declared C Translation
    string constTranslation;    // Const C Translation
    string operation;           // Operation
  };

  /* Flex/Yacc Functions */
  int yylex(void);
  void yyerror(string);
  void wrongOperation(string,string);

  /* VarMap Functions */
  bool exists(string);
  bool exists(temp);
  void addVar(temp,string,bool,string,int);
  attr getVar(string);
  string checkType(int);
  string checkType(string);
  void checkVar(string);

  /* VarMap */
  map<string,attr> varInfo;
  map<string,attr>::iterator varInfoIt;

  /* Useful Functions */
  temp createTemp(int,string);
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
      $$.tempTranslation << endl <<
      $$.translation << endl <<
      "\treturn 0;" << endl <<
      "}" << endl;
      ccode.close();
    };
  BLOCK:
    CMDS {
      $$.translation = $1.translation;
      $$.constTranslation = $1.constTranslation;
      $$.tempTranslation = $1.tempTranslation;
    };
  CMDS:
    CMD CMDS {
      $$.translation = $1.translation + $2.translation;
      $$.constTranslation = $1.constTranslation + $2.constTranslation;
      $$.tempTranslation = $1.tempTranslation + $2.tempTranslation;
    };
    |;
  CMD:
    EXP END_LINE {
      if(!$1.translation.empty()){ $$.translation = "\t" + $1.translation + "\n"; }
      if(!$1.constTranslation.empty()){ $$.constTranslation = $1.constTranslation + "\n"; }
      if(!$1.tempTranslation.empty()){ $$.tempTranslation = "\t" + $1.tempTranslation + "\n"; }
    };
    | EXP ';' END_LINE {
      if(!$1.translation.empty()){ $$.translation = "\t" + $1.translation + "\n"; }
      if(!$1.constTranslation.empty()){ $$.constTranslation = $1.constTranslation + "\n"; }
      if(!$1.tempTranslation.empty()){ $$.tempTranslation = "\t" + $1.tempTranslation + "\n"; }
    };
  EXP:
    EXP BOOLEAN_LOGIC EXP {
      if($1.token != BOOLEAN){ wrongOperation($2.operation,checkType($1.token)); }
      else if($3.token != BOOLEAN){ wrongOperation($2.operation,checkType($3.token)); }
      if($2.operation == "||"){
        if(!exists($1.id) && !exists($3.id)){
          $$.tempTranslation = $3.tempVar.translation + " " + $1.tempVar.translation + " //" + $3.translation + "," +  $1.translation;
        }
        $$.translation = $1.tempVar.name + " || " + $3.tempVar.name;
      }
      else if($2.operation == "&&"){ $$.translation = $1.tempVar.name + " && " + $3.tempVar.name; }
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
        $$.translation = $1.translation + " == " + $3.translation;
        $$.value = $1.value == $3.value ? "true" : "false";
        $$.token = BOOLEAN;
      }
      else if($2.operation == "!="){
        // Different Values
        $$.translation = $1.translation + " != " + $3.translation;
        $$.value = $1.value != $3.value ? "true" : "false";
        $$.token = BOOLEAN;
      }
    };
    | EXP ORDER_RELATION EXP {
      if($1.token != FLOAT && $1.token != INTEGER){ wrongOperation($2.operation,checkType($1.token)); }
      else if($3.token != FLOAT && $3.token != INTEGER){ wrongOperation($2.operation,checkType($3.token)); }

      if($2.operation == "<"){ $$.translation = $1.translation + " < " + $3.translation; }
      else if($2.operation == "<="){ $$.translation = $1.translation + " <= " + $3.translation; }
      else if($2.operation == ">"){ $$.translation = $1.translation + " > " + $3.translation; }
      else if($2.operation == ">="){ $$.translation = $1.translation + " >= " + $3.translation; }

      $$.token = BOOLEAN;
    };
    | varConst ASSIGNMENT EXP {
      if(!(exists($1.id))) { $1.tempVar = createTemp($3.token,$3.translation); }
      if(!exists($1.id) && !exists($3.id)){ addVar($1.tempVar,$1.id, $1.isVar, $3.value, $3.token); }
      $$.tempTranslation = $3.tempTranslation + "\n\t" + $1.tempVar.translation + " // " + $1.id;

      if(!$1.isVar){ $$.constTranslation = "#define " + $1.id.erase(0,1) + " " + $3.translation; }
      else {
        string expTranslation = $3.token == BOOLEAN ? toUpper($3.tempVar.value) : $3.tempVar.value;
        if((exists($1.id))){
          $$.translation =
            exists($3.tempVar) ?
              getVar($1.id).tempVar.name + " = " + $3.tempVar.name + ";" :
              $3.tempVar.name + " = " + expTranslation + ";\n\t" + getVar($1.id).tempVar.name + " = " + $3.tempVar.name + ";"; }
        else {
          $$.translation =
            exists($3.tempVar) ?
              $1.tempVar.name + " = " + $3.tempVar.name + ";" :
              $3.tempVar.name + " = " + expTranslation + ";\n\t" + $1.tempVar.name + " = " + $3.tempVar.name + ";";
        }
      }
    };
    | EXP '+' EXP {
      if($1.token == BOOLEAN || $3.token == BOOLEAN){ wrongOperation("+","bool"); }
      if($1.token == INTEGER && $3.token == FLOAT){
        $1.tempVar.value = "(float) "+$1.translation;
        $$.token = FLOAT;
      }
      else if($1.token == FLOAT && $3.token == INTEGER){ $3.translation = "(float) "+$3.translation; $$.token = FLOAT; }
      $$.translation = $1.tempVar.name;
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
      $$.tempVar = getVar($1.id).tempVar;
      $$.token = getVar($1.id).token;
      $$.value = getVar($1.id).value;
      $$.translation = $1.id;
    };
    | CONST {
      checkVar($1.id);
      $$.tempVar = getVar($1.id).tempVar;
      $$.token = getVar($1.id).token;
      $$.value = getVar($1.id).value;
      $$.translation = $1.id;
    };
    | INTEGER {
      $$.tempVar = createTemp($1.token,$1.value);
      $$.translation = $1.value;
      $$.value = $1.value;
      $$.token = INTEGER;
      $$.tempTranslation = $$.tempVar.translation + " // " + $$.translation;
    };
    | FLOAT {
      $$.tempVar = createTemp($1.token,$1.value);
      $$.translation = $1.value;
      $$.value = $1.value;
      $$.token = FLOAT;
      $$.tempTranslation = $$.tempVar.translation + " // " + $$.translation;
    };
    | BOOLEAN {
      $$.tempVar = createTemp($1.token,$1.value);
      $$.translation = toUpper($1.value);
      $$.value = $1.value;
      $$.token = BOOLEAN;
      $$.tempTranslation = $$.tempVar.translation + " // " + $$.translation;
    };
    | CHARACTER {
      $$.tempVar = createTemp($1.token,$1.value);
      $$.translation = $1.value;
      $$.value = $1.value;
      $$.token = CHARACTER;
      $$.tempTranslation = $$.tempVar.translation + " // " + $$.translation;
    };
  varConst:
    VAR { $$.id = $1.id; $$.translation = $1.id; };
    | CONST { $$.id = $1.id; $$.translation = $1.id; };
%%

#include "lex.yy.c"
int yyparse();
int main(int argc, char** argv){ yyparse(); }

/* Bison Error Msg */
void yyerror(string msg){
  cout <<
  colorText("error:"+to_string(yylineno)+": ",hexToRGB(RED)) <<  msg  << " with " << colorText("'"+(string)yytext+"'",hexToRGB(YELLOW)) << endl <<
  colorText("yylval.token: ",hexToRGB(OFF_WHITE)) << yylval.token << endl <<
  colorText("yylval.id: ",hexToRGB(OFF_WHITE)) << yylval.id << endl <<
  colorText("yylval.value: ",hexToRGB(OFF_WHITE)) << yylval.value << endl <<
  colorText("yylval.isVar: ",hexToRGB(OFF_WHITE)) << yylval.isVar << endl <<
  colorText("yylval.translation: ",hexToRGB(OFF_WHITE)) << yylval.translation << endl <<
  colorText("yylval.constTranslation: ",hexToRGB(OFF_WHITE)) << yylval.constTranslation << endl;
}

/* WrongOperation */
void wrongOperation(string operation, string type){
  cout << colorText("error:"+to_string(yylineno-1)+": ",hexToRGB(RED)) << "This operation " << colorText("'"+operation+"'",hexToRGB(AQUA)) << " wasn't defined for type " << colorText(type,hexToRGB(GREEN))  << endl;
  exit(1);
}

/* GetVar */
attr getVar(string name){
  varInfoIt = varInfo.find(name);
  return varInfoIt->second;
}

/* AddVar */
void addVar(temp tempVar, string name, bool isVar, string value, int token){
  varInfoIt = varInfo.find(name);
  //cout << name << " " << isVar << " " << value << " " << token << endl;

  if(varInfoIt != varInfo.end()){ // Var||Const was declared previously
    attr var = varInfoIt->second;

    if(!var.isVar) {
      /* Error when try to add a new value to a Const */
      cout << colorText("error:"+to_string(yylineno-1)+": ",hexToRGB(RED)) << colorText(name,hexToRGB(AQUA)) << " is a " << colorText("Constant",hexToRGB(GREEN)) << " and was declared previously." << endl;
      exit(1);
    }

    if(var.token != token) {
      /* Error when try to add a new value with a Different Type */
      cout << colorText("error:"+to_string(yylineno-1)+": ",hexToRGB(RED)) << colorText(name,hexToRGB(AQUA))  << " was declared previously with type " << colorText(checkType(name),hexToRGB(GREEN))  << endl;
      exit(1);
    }
  }

  attr v;
  v.id = name;
  v.isVar = isVar;
  v.value = value;
  v.token = token;
  v.tempVar = tempVar;
  varInfo[name] = v;
}

/* CheckType */
string checkType(int token){
  switch (token) {
    case INTEGER: return "int";
    case FLOAT: return "float";
    case BOOLEAN: return "int";
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
    case BOOLEAN: return "int";
    case CHARACTER: return "char";
    default: return "UNDEFINED";
  }
}

/* Exists */
bool exists(string varName){
  varInfoIt = varInfo.find(varName);
  return !(varInfoIt == varInfo.end());
}
bool exists(temp tempVar){
  for(varInfoIt = varInfo.begin(); varInfoIt != varInfo.end(); ++varInfoIt){
    if(varInfoIt->second.tempVar.name == tempVar.name){ return true; }
  }
  return false;
}

/* CheckVar */
void checkVar(string name){
  varInfoIt = varInfo.find(name);
  if(varInfoIt == varInfo.end()){
    /* Error when a Var/Const wasn't declared previously */
    cout << colorText("error:"+to_string(yylineno-1)+": ",hexToRGB(RED)) << colorText(name,hexToRGB(AQUA)) << " wasn't " << colorText("declared",hexToRGB(GREEN)) << " previously." << endl;
    exit(1);
  }
}

/* ToUpper */
string toUpper(const string& s){
  string result; locale l;
  for(int i = 0; i < s.length(); i++){ result += toupper(s.at(i),l); }
  return result;
}

/* TempName */
temp createTemp(int token, string value){
  tempCount++;
  temp t;
  t.token = token;
  t.value = value;
  t.name = "temp" + to_string(tempCount);
  t.translation = checkType(t.token) + " " + t.name + ";";
  return t;
}
