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
%token ARITHMETIC BOOLEAN_LOGIC EQUALITY_TEST ORDER_RELATION
%token ASSIGNMENT NOT COLON QUESTION
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
      "\t// Declare" << endl <<
      $$.tempTranslation << endl <<
      "\t// Operations" << endl <<
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
      temp t = createTemp(BOOLEAN,$1.tempVar.name + " " + $2.operation + " " + $3.tempVar.name);
      $$.tempTranslation =
        $1.tempTranslation + "\n\t" +
        $3.tempTranslation + "\n\t" +
        t.translation + " // " + t.value;
      $$.translation =
        $1.translation + "\n\t" +
        $3.translation + "\n\t" +
        t.name + " = " + t.value + ";";
      $$.token = BOOLEAN;
      $$.tempVar = t;
    };
    | NOT EXP {
      if($2.token != BOOLEAN){ wrongOperation($1.operation,checkType($2.token)); }
      temp t = createTemp($2.token,$2.translation);
      $$.tempTranslation = $2.tempTranslation + "\n\t" + t.translation + " // " + $1.operation + $2.tempVar.name;
      $$.translation = $2.translation + "\n\t" + t.name + " = " + $1.operation + $2.tempVar.name + ";";
      $$.token = $2.token;
      $$.tempVar = t;
    };
    | EXP QUESTION EXP COLON EXP {
      temp t;

      if($1.token != BOOLEAN){ wrongOperation("? :",checkType($1.token)); }
      if($1.tempVar.value == "TRUE"){
        t = createTemp($3.token, $3.tempVar.name);
        $$.tempTranslation = $1.tempTranslation + "\n\t" + $3.tempTranslation + "\n\t" + t.translation + " // " + t.value + "\n\t";
        $$.translation = $1.translation + "\n\t" + $3.translation + "\n\t" + t.name + " = " + t.value + ";";
      }
      else {
        t = createTemp($5.token, $5.tempVar.name);
        $$.tempTranslation = $1.tempTranslation + "\n\t" + $5.tempTranslation + "\n\t" + t.translation + " // " + t.value + "\n\t";
        $$.translation = $1.translation + "\n\t" + $5.translation + "\n\t" + t.name + " = " + t.value + ";";
      }
      $$.token = t.token;
      $$.tempVar = t;
    };
    | EXP EQUALITY_TEST EXP {
      temp t;
      temp op;

      $$.tempTranslation = $1.tempTranslation + "\n\t" + $3.tempTranslation + "\n\t";
      $$.translation = $1.translation + "\n\t" + $3.translation + "\n\t";

      if($2.operation == "===" || $2.operation == "!=="){ // Equal Types || Different Types
        t = $2.operation == "===" ?
          createTemp(BOOLEAN, ($1.tempVar.token == $3.tempVar.token) ? "TRUE" : "FALSE") :
          createTemp(BOOLEAN, ($1.tempVar.token != $3.tempVar.token) ? "TRUE" : "FALSE");
        $$.tempTranslation = $$.tempTranslation + t.translation + " // " + t.value;
        $$.translation = $$.translation + t.name + " = " + t.value + ";";
      }
      else {
        if($1.token == INTEGER && $3.token == FLOAT){ // int ORDER_RELATION float -> float
          t = createTemp(FLOAT, "(float) " + $1.tempVar.name);
          op = createTemp(BOOLEAN,t.name + " "+ $2.operation +" " + $3.tempVar.name);
          $$.tempTranslation = $$.tempTranslation + t.translation + " // " + t.value + "\n\t";
          $$.translation = $$.translation + t.name + " = " + t.value + ";\n\t";
        }
        else if($1.token == FLOAT && $3.token == INTEGER){ // float ORDER_RELATION int -> float
          t = createTemp(FLOAT, "(float) " + $3.tempVar.name);
          op = createTemp(BOOLEAN,t.name + " "+ $2.operation +" " + $1.tempVar.name);
          $$.tempTranslation = $$.tempTranslation + t.translation + " // " + t.value + "\n\t";
          $$.translation = $$.translation + t.name + " = " + t.value + ";\n\t";
        }
        else { op = createTemp(BOOLEAN, $1.tempVar.name + " "+ $2.operation +" " + $3.tempVar.name); }

        $$.tempTranslation = $$.tempTranslation + op.translation + " // " + op.value;
        $$.translation = $$.translation + op.name + " = " + op.value + ";";
      }

      $$.tempVar = t;
      $$.token = BOOLEAN;
    };
    | EXP ORDER_RELATION EXP {
      temp t;
      temp op;

      $$.tempTranslation = $1.tempTranslation + "\n\t" + $3.tempTranslation + "\n\t";
      $$.translation = $1.translation + "\n\t" + $3.translation + "\n\t";

      if($1.token != FLOAT && $1.token != INTEGER){ wrongOperation($2.operation,checkType($1.token)); }
      else if($3.token != FLOAT && $3.token != INTEGER){ wrongOperation($2.operation,checkType($3.token)); }

      if($1.token == INTEGER && $3.token == FLOAT){ // int ORDER_RELATION float -> float
        t = createTemp(FLOAT, "(float) " + $1.tempVar.name);
        op = createTemp(BOOLEAN,t.name + " "+ $2.operation +" " + $3.tempVar.name);
        $$.tempTranslation = $$.tempTranslation + t.translation + " // " + t.value + "\n\t";
        $$.translation = $$.translation + t.name + " = " + t.value + ";\n\t";
      }
      else if($1.token == FLOAT && $3.token == INTEGER){ // float ORDER_RELATION int -> float
        t = createTemp(FLOAT, "(float) " + $3.tempVar.name);
        op = createTemp(BOOLEAN,t.name + " "+ $2.operation +" " + $1.tempVar.name);
        $$.tempTranslation = $$.tempTranslation + t.translation + " // " + t.value + "\n\t";
        $$.translation = $$.translation + t.name + " = " + t.value + ";\n\t";
      }
      else { op = createTemp(BOOLEAN, $1.tempVar.name + " "+ $2.operation +" " + $3.tempVar.name); }
      $$.tempTranslation = $$.tempTranslation + op.translation + " // " + op.value;
      $$.translation = $$.translation + op.name + " = " + op.value + ";";
      $$.tempVar = op;
      $$.token = BOOLEAN;
    };
    | varConst ASSIGNMENT EXP {
      if(!(exists($1.id))) {
        $1.tempVar = createTemp($3.token,$3.translation);
        addVar($1.tempVar,$1.id, $1.isVar, $3.value, $3.token);
        $$.tempTranslation = $3.tempTranslation + "\n\t" + $1.tempVar.translation + " // " + $1.id;
        $$.translation = $3.translation + "\n\t" + $1.tempVar.name + " = " + $3.tempVar.name + ";";
      }
      else {
        $$.tempTranslation = $3.tempTranslation;
        $$.translation = $3.translation + "\n\t" + getVar($1.id).tempVar.name + " = " + $3.tempVar.name + ";";
      }
    };
    | EXP ARITHMETIC EXP {
      temp t;
      temp op;

      $$.tempTranslation = $1.tempTranslation + "\n\t" + $3.tempTranslation + "\n\t";
      $$.translation = $1.translation + "\n\t" + $3.translation + "\n\t";

      if($1.token == BOOLEAN || $3.token == BOOLEAN){ wrongOperation($2.operation,"bool"); }
      if($1.token == INTEGER && $3.token == FLOAT){ // int ARITHMETIC float -> float
        $$.token = FLOAT;
        t = createTemp(FLOAT, "(float) " + $1.tempVar.name);
        op = createTemp(FLOAT,t.name + " "+ $2.operation +" " + $3.tempVar.name);
        $$.tempTranslation = $$.tempTranslation + t.translation + " // " + t.value + "\n\t";
        $$.translation = $$.translation + t.name + " = " + t.value + ";\n\t";
      }
      else if($1.token == FLOAT && $3.token == INTEGER){ // float ARITHMETIC int -> float
        $$.token = FLOAT;
        t = createTemp(FLOAT, "(float) " + $3.tempVar.name);
        op = createTemp(FLOAT,t.name + " "+ $2.operation +" " + $1.tempVar.name);
        $$.tempTranslation = $$.tempTranslation + t.translation + " // " + t.value + "\n\t";
        $$.translation = $$.translation + t.name + " = " + t.value + ";\n\t";
      }
      else if($1.token == INTEGER && $3.token == INTEGER){ // int ARITHMETIC int -> int
        $$.token = INTEGER;
        op = createTemp(INTEGER, $1.tempVar.name + " "+ $2.operation +" " + $3.tempVar.name);
      }
      else if($1.token == FLOAT && $3.token == FLOAT){ // float ARITHMETIC float -> float
        $$.token = FLOAT;
        op = createTemp(FLOAT, $1.tempVar.name + " "+ $2.operation +" " + $3.tempVar.name);
      }
      $$.tempTranslation = $$.tempTranslation + op.translation + " // " + op.value;
      $$.translation = $$.translation + op.name + " = " + op.value + ";";
      $$.tempVar = op;
    };
    | '(' EXP ')' {
      $$.token = $2.token;
      $$.tempTranslation = $2.tempTranslation;
      $$.translation = $2.translation;
      $$.tempVar = $2.tempVar;
    };
    | VAR {
      checkVar($1.id);
      $$.tempVar = getVar($1.id).tempVar;
      $$.token = getVar($1.id).token;
      $$.value = getVar($1.id).value;
      $$.id = $1.id;
    };
    | CONST {
      checkVar($1.id);
      $$.tempVar = getVar($1.id).tempVar;
      $$.token = getVar($1.id).token;
      $$.value = getVar($1.id).value;
      $$.id = $1.id;
    };
    | INTEGER {
      $$.tempVar = createTemp($1.token,$1.value);
      $$.translation = $$.tempVar.name + " = " + $1.value + ";";
      $$.value = $1.value;
      $$.token = INTEGER;
      $$.tempTranslation = $$.tempVar.translation + " // " + $$.translation;
    };
    | FLOAT {
      $$.tempVar = createTemp($1.token,$1.value);
      $$.translation = $$.tempVar.name + " = " + $1.value + ";";
      $$.value = $1.value;
      $$.token = FLOAT;
      $$.tempTranslation = $$.tempVar.translation + " // " + $$.translation;
    };
    | BOOLEAN {
      $$.tempVar = createTemp($1.token,toUpper($1.value));
      $$.translation = $$.tempVar.name + " = " + toUpper($1.value) + ";";
      $$.value = $1.value;
      $$.token = BOOLEAN;
      $$.tempTranslation = $$.tempVar.translation + " // " + $$.translation;
    };
    | CHARACTER {
      $$.tempVar = createTemp($1.token,$1.value);
      $$.translation = $$.tempVar.name + " = " + $1.value + ";";
      $$.value = $1.value;
      $$.token = CHARACTER;
      $$.tempTranslation = $$.tempVar.translation + " // " + $$.translation;
    };
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
