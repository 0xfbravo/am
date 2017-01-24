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
  #include "am-colors.h"
  #include <fstream>
  #include <iostream>
  #include <locale>
  #include <map>
  #include <string>
  using namespace std;

  long long tempCount = 0;
  long long scopeCount = 0;

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
    string tempTranslation;     // Var declaration - C Translation
    string operation;           // Operation
  };

  /* Flex/Yacc Functions */
  int yylex(void);
  void yyerror(string);

  /* Messages */
  void notDeclared(string);
  void constWontChangeValue(string);
  void alreadyDeclared(string,string);
  void wrongOperation(string,string);
  void warningExplicitType(string,string);

  /* VarMap Functions */
  bool exists(string);
  bool exists(temp);
  void addVar(temp,string,bool,string,int);
  attr getVar(string);
  string checkType(int);
  string checkType(string);
  temp createTemp(int,string);

  /* VarMap */
  map<string,attr> varInfo;
  map<string,attr>::iterator varInfoIt;

  /* Useful Functions */
  string toUpper(const string&);
  string actualLine();
%}

%token BLOCK_INIT BLOCK_END SEMI_COLON
%token INTEGER FLOAT BOOLEAN CHARACTER STRING
%token ARITHMETIC_1 ARITHMETIC_2 BOOLEAN_LOGIC EQUALITY_TEST ORDER_RELATION
%token ASSIGNMENT NOT COLON QUESTION
%token VAR CONST EXPLICIT_TYPE
%token END_LINE

%left ASSIGNMENT                        // "="
%left BOOLEAN_LOGIC                     // "||" "&&"
%left EQUALITY_TEST ORDER_RELATION      // "==" "===" "!==" "!=" "<" "<=" ">" ">="
%left QUESTION COLON                    // "?" ":"
%left NOT                               // "!"
%left ARITHMETIC_1                      // "+" "-"
%left ARITHMETIC_2                      // "*" "/"
%left '(' ')'
%left BLOCK_INIT BLOCK_END              // "{" "}"

%start BEFORE_THE_BEGINNING

%%
  BEFORE_THE_BEGINNING:
    CMDS {
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
      "int main() {" << endl <<
      "\t/* Declarations */" << endl <<
      "\t" << $$.tempTranslation << endl <<
      "\t/* Operations */" << endl <<
      "\t" << $$.translation << endl <<
      "\treturn 0;" << endl <<
      "}" << endl;
      ccode.close();
    };
  BLOCK:
    BLOCK_INIT CMDS BLOCK_END {
      $$.translation = "// Scope\n\t" + $2.translation;
      $$.tempTranslation = "// Scope\n\t" + $2.tempTranslation;
    };
  CMDS:
    CMD CMDS {
      $$.translation = $1.translation + $2.translation;
      $$.tempTranslation = $1.tempTranslation + $2.tempTranslation;
    };
    | {
      $$.translation = "";
      $$.tempTranslation = "";
    };
  CMD:
    BLOCK;
    | END_LINE;
    | EXP { // EXP
      if(!$1.translation.empty()){ $$.translation = $1.translation + "\n\t"; }
      if(!$1.tempTranslation.empty()){ $$.tempTranslation = $1.tempTranslation + "\n\t"; }
    };
    | EXP SEMI_COLON { // EXP;
      if(!$1.translation.empty()){ $$.translation = $1.translation + "\n\t"; }
      if(!$1.tempTranslation.empty()){ $$.tempTranslation = $1.tempTranslation + "\n\t"; }
    };
  EXP:
    EXP COLON COLON EXPLICIT_TYPE { // EXP::EXPLICIT_TYPE
      temp t;
      if($1.token == $4.token){ warningExplicitType($1.tempVar.value,checkType($4.token)); }
      else if(($1.token != FLOAT) && ($1.token != INTEGER)){ wrongOperation("::"+checkType($4.token),checkType($1.token)); }
      else if($4.token == FLOAT){
        t = createTemp(FLOAT,"(float) "+$1.tempVar.name);
        $$.tempTranslation = $1.tempTranslation + "\n\t" + t.translation + " // " + t.value;
        $$.translation = $1.translation + "\n\t" + t.name + " = " + t.value;
        $$.token = FLOAT;
        $$.tempVar = t;
      }
      else if($4.token == INTEGER){
        t = createTemp(INTEGER,"(int) "+$1.tempVar.name);
        $$.tempTranslation = $1.tempTranslation + "\n\t" + t.translation + " // " + t.value;
        $$.translation = $1.translation + "\n\t" + t.name + " = " + t.value;
        $$.token = INTEGER;
        $$.tempVar = t;
      }
    };
    | EXP BOOLEAN_LOGIC EXP {
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
    | NOT EXP { // !EXP
      if($2.token != BOOLEAN){ wrongOperation("!",checkType($2.token)); }
      temp t = createTemp($2.token,$2.translation);
      $$.tempTranslation = $2.tempTranslation + "\n\t" + t.translation + " // " + $1.operation + $2.tempVar.name;
      $$.translation = $2.translation + "\n\t" + t.name + " = " + $1.operation + $2.tempVar.name + ";";
      $$.token = $2.token;
      $$.tempVar = t;
    };
    | EXP QUESTION EXP COLON EXP { // EXP ? EXP : EXP
      if($1.token != BOOLEAN){ wrongOperation("? :",checkType($1.token)); }
      temp t = createTemp($1.token,$1.translation);
      $$.tempTranslation = t.translation;
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
    | varConst ASSIGNMENT EXP { // varConst = EXP
      string name = $1.isVar ? $1.id : $1.id.erase(0,1);

      if(!(exists(name))) { // Var/Const Not Declared
        $1.tempVar = createTemp($3.token,$3.translation);
        addVar($1.tempVar,name, $1.isVar, $3.value, $3.token);
        $$.tempTranslation = $3.tempTranslation + "\n\t" + $1.tempVar.translation + " // " + name;
        $$.translation = $3.translation + "\n\t" + $1.tempVar.name + " = " + $3.tempVar.name + ";";
        $$.tempVar = $1.tempVar;
        $$.token = $1.tempVar.token;
      }
      else { // Var/Const Already Declared
        if(!getVar(name).isVar){ constWontChangeValue(name); }
        if(getVar(name).token != $3.token) { alreadyDeclared(name,checkType(name)); }
        $$.tempTranslation = $3.tempTranslation;
        $$.translation = $3.translation + "\n\t" + getVar(name).tempVar.name + " = " + $3.tempVar.name + ";";
        getVar(name).value = $3.value;
      }
    };
    | EXP ARITHMETIC_1 EXP {
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
    | EXP ARITHMETIC_2 EXP {
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
      if(!exists($1.id)) { notDeclared($1.id); };
      $$.tempVar = getVar($1.id).tempVar;
      $$.token = getVar($1.id).token;
      $$.value = getVar($1.id).value;
      $$.id = $1.id;
    };
    | CONST {
      if(!exists($1.id)) { notDeclared($1.id); };
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
    | STRING {
      $$.tempVar = createTemp($1.token,$1.value);
      $$.translation = "strcpy("+$$.tempVar.name + "," + $1.value + ");";
      $$.value = $1.value;
      $$.token = STRING;
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
  colorText("yylval.translation: ",hexToRGB(OFF_WHITE)) << yylval.translation << endl;
}

/*
  ------------------------
          Useful
  ------------------------
*/
string toUpper(const string& s){
  string result; locale l;
  for(int i = 0; i < s.length(); i++){ result += toupper(s.at(i),l); }
  return result;
}

string actualLine(){
  return yylineno == 1 ? to_string(yylineno) : to_string(yylineno-1);
}

/*
  ------------------------
          Messages
  ------------------------
*/
void notDeclared(string name){
  cout << colorText("error:"+actualLine()+": ",hexToRGB(RED)) << colorText(name,hexToRGB(AQUA)) << " wasn't " << colorText("declared",hexToRGB(GREEN)) << " previously." << endl;
  exit(1);
}

void constWontChangeValue(string name){
  cout << colorText("error:"+actualLine()+": ",hexToRGB(RED)) << "You're a dumbass... The Const " << colorText("'"+name+"'",hexToRGB(AQUA)) << " won't chage value, because " << colorText("IS A FUCKIN' CONST!!!",hexToRGB(ORANGE_RED)) << "." << endl;
  exit(1);
}

void alreadyDeclared(string name,string type){
  cout << colorText("error:"+actualLine()+": ",hexToRGB(RED)) << "You're a dumbass... The var " << colorText("'"+name+"'",hexToRGB(AQUA)) << " was declared previouly with type " << colorText(type,hexToRGB(GREEN)) << "." << endl;
  exit(1);
}

void wrongOperation(string operation, string type){
  cout << colorText("error:"+actualLine()+": ",hexToRGB(RED)) << "You're a dumbass... This operation " << colorText("'"+operation+"'",hexToRGB(AQUA)) << " wasn't defined for type " << colorText(type,hexToRGB(GREEN)) << "." << endl;
  exit(1);
}

void warningExplicitType(string value, string type){
  cout << colorText("warning:"+actualLine()+": ",hexToRGB(YELLOW)) << "You're a dumbass... " << colorText(value,hexToRGB(AQUA)) << " already has the type " << colorText(type,hexToRGB(GREEN)) << ". I can't do anything about it!"  << endl;
}

/*
  ------------------------
          VarConst
  ------------------------
*/
attr getVar(string name){
  varInfoIt = varInfo.find(name);
  return varInfoIt->second;
}

temp createTemp(int token, string value){
  tempCount++;
  temp t;
  t.token = token;
  t.value = value;
  t.name = "temp" + to_string(tempCount);
  switch (token) {
    case STRING:
      t.translation = checkType(CHARACTER) + "* " + t.name + ";";
    break;
    default:
      t.translation = checkType(t.token) + " " + t.name + ";";
    break;
  }
  return t;
}

void addVar(temp tempVar, string name, bool isVar, string value, int token){
  varInfoIt = varInfo.find(name);
  attr v;
  v.id = name;
  v.isVar = isVar;
  v.value = value;
  v.token = token;
  v.tempVar = tempVar;
  varInfo[name] = v;
}

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

bool exists(string varName){
  varInfoIt = varInfo.find(varName);
  return !(varInfoIt == varInfo.end());
}

bool exists(temp tempVar){
  for(varInfoIt = varInfo.begin(); varInfoIt != varInfo.end(); ++varInfoIt){ if(varInfoIt->second.tempVar.name == tempVar.name){ return true; } }
  return false;
}
