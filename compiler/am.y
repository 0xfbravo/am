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
  #include <vector>
  using namespace std;

  long long tempCount = 0;
  long long scopesCount = 0;
  long long switchCount = 0;
  bool onSwitch = true;

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
    string scopesLabels;        // Scopes Labels
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
  void addVar(temp,string,bool,string,int);
  attr getVar(string);
  string checkType(int);
  string checkType(string);
  temp createTemp(int,string);

  /* VarMap */
  map<string,attr> globalScope;
  map<string,attr>::iterator scopeIterator;

  /* Heap */
  vector<temp> tempsOnMemory = {};
  vector<map<string,attr>> scopes = {};

  /* Useful Functions */
  bool onMemory(temp);
  void removeFromMemory(temp);
  string clearMemory();
  string toUpper(const string&);
  string actualLine();
%}

%token BLOCK_INIT BLOCK_END SEMI_COLON
%token R_IF R_ELSE R_WHILE R_DO R_FOR R_SWITCH R_CASE R_DEFAULT R_BREAK R_CONTINUE
%token R_IN R_OUT R_IS R_DOT
%token INTEGER FLOAT BOOLEAN CHARACTER STRING
%token ARITHMETIC_1 ARITHMETIC_2 BOOLEAN_LOGIC EQUALITY_TEST ORDER_RELATION
%token ASSIGNMENT NOT COLON QUESTION COMMA
%token VAR CONST EXPLICIT_TYPE
%token END_LINE

%left ASSIGNMENT                        // "="
%left BOOLEAN_LOGIC                     // "||" "&&"
%left EQUALITY_TEST ORDER_RELATION      // "==" "===" "!==" "!=" "<" "<=" ">" ">="
%left QUESTION COLON                    // "?" ":"
%left NOT                               // "!"
%left R_DOT                             // 'a'.'b' == 'ab'
%left ARITHMETIC_1                      // "+" "-"
%left ARITHMETIC_2                      // "*" "/"
%left '(' ')'
%left BLOCK_INIT BLOCK_END              // "{" "}"

%start BEFORE_THE_BEGINNING

%%
  BEFORE_THE_BEGINNING:
    CMDS {
      ofstream ccode;
      ccode.open("am-ccode.cpp");
      ccode <<
      "/*" << endl <<
      "     _" << endl <<
      "    /_\\    /\\/\\" << endl <<
      "   //_\\\\  /    \\" << endl <<
      "  /  _  \\/ /\\/\\ \\" << endl <<
      "  \\_/ \\_/\\/    \\/" << endl <<
      "*/" << endl <<
      "#include <iostream>" << endl <<
      "#include <string.h>" << endl <<
      "using namespace std;\n" << endl <<
      "#define TRUE 1" << endl <<
      "#define FALSE 0" << endl <<
      "#define MAX_BUFFER_SIZE 300\n" << endl <<
      "int main() {" << endl <<
      "\t/* Declarations */" << endl <<
      "\t" << $$.tempTranslation << endl <<
      "\t/* Operations */" << endl <<
      "\t" << $$.translation << endl <<
      "\t/* Free memory */" << endl <<
      "\t" << clearMemory() << endl <<
      "\tBLOCK_LABEL_0_END:" << endl <<
      "\treturn 0;\n" << endl <<
      "\t/* Scopes Labels */" << endl <<
      "\t" << $$.scopesLabels << endl <<
      "}" << endl;
      ccode.close();
    };

  BLOCK:
    START_SCOPE BLOCK_INIT CMDS BLOCK_END END_SCOPE {
      $$.translation =  $3.translation;
      $$.tempTranslation = $3.tempTranslation;
      $$.scopesLabels = $3.scopesLabels;
    };

  START_SCOPE:
    {
      map<string,attr> newScope;
      scopes.push_back(newScope);
      $$.tempTranslation = "";
      $$.translation = "";
    };

  END_SCOPE:
    {
      scopes.pop_back();
      $$.tempTranslation = "";
      $$.translation = "";
    };

  CMDS:
    CMD CMDS {
      $$.translation = $1.translation + $2.translation;
      $$.tempTranslation = $1.tempTranslation + $2.tempTranslation;
      $$.scopesLabels = $1.scopesLabels + $2.scopesLabels;
    };
    | {
      $$.translation = "";
      $$.tempTranslation = "";
    };

  WHILE:
    R_WHILE EXP BLOCK {
      if($2.token != BOOLEAN){  wrongOperation("while",checkType($2.token)); }
      scopesCount++;
      $$.translation =
        "BLOCK_LABEL_" + to_string(scopesCount) + "_BEGIN:\n\t" +
        $2.translation +
        "if(" + $2.tempVar.name + ") { goto BLOCK_LABEL_" + to_string(scopesCount) +"; } \n\t" +
        "BLOCK_LABEL_" + to_string(scopesCount) + "_END:\n\t";
      $$.tempTranslation = $2.tempTranslation + $3.tempTranslation;
      $$.scopesLabels =
        "BLOCK_LABEL_" + to_string(scopesCount) + ":\n\t" +
        $3.translation +
        "goto BLOCK_LABEL_" + to_string(scopesCount) + "_BEGIN;\n\t";
    };

  DO_WHILE:
    R_DO BLOCK R_WHILE EXP{
      if($4.token != BOOLEAN){  wrongOperation("do-while",checkType($4.token)); }
      scopesCount++;
      $$.translation =
        "BLOCK_LABEL_" + to_string(scopesCount) + "_BEGIN:\n\t" +
        $2.translation +
        "goto BLOCK_LABEL_" + to_string(scopesCount) +";\n\t" +
        "BLOCK_LABEL_" + to_string(scopesCount) + "_END:\n\t";
      $$.tempTranslation = $2.tempTranslation + $4.tempTranslation;
      $$.scopesLabels =
        $2.scopesLabels +
        "BLOCK_LABEL_" + to_string(scopesCount) + ":\n\t" +
        $4.translation +
        "if(" + $4.tempVar.name + ") { goto BLOCK_LABEL_" + to_string(scopesCount) +"_BEGIN; } \n\t" +
        "goto BLOCK_LABEL_" + to_string(scopesCount) + "_END;\n\t";
    };

  IF:
    R_IF EXP BLOCK ELSE {
      if($2.token != BOOLEAN){ wrongOperation("if",checkType($2.token)); }
      scopesCount++;
      $$.translation =
        $2.translation +
        "if (" + $2.tempVar.name + ") { goto BLOCK_LABEL_" + to_string(scopesCount) + "; }\n\t" +
        $4.translation +
        "BLOCK_LABEL_" + to_string(scopesCount) + "_END:\n\t";
      $$.tempTranslation = $2.tempTranslation + $3.tempTranslation + $4.tempTranslation;
      $$.scopesLabels =
        "BLOCK_LABEL_" + to_string(scopesCount) + ":\n\t" +
        $3.translation +
        "goto BLOCK_LABEL_" + to_string(scopesCount) + "_END;\n\t" +
        $4.scopesLabels;
    };

  ELSE:
    R_ELSE ELSEIF {
      $$.translation = $2.translation;
      $$.tempTranslation = $2.tempTranslation;
      $$.scopesLabels = $2.scopesLabels;
    };
    |;

  ELSEIF:
    IF;
    | BLOCK {
      scopesCount++;
      $$.tempTranslation = $1.tempTranslation;
      $$.translation =
        "else { goto BLOCK_LABEL_"+ to_string(scopesCount) +"; }\n\t" +
        "BLOCK_LABEL_" + to_string(scopesCount) + "_END:\n\t";
      $$.scopesLabels =
        $1.scopesLabels +
        "BLOCK_LABEL_" + to_string(scopesCount) + ":\n\t" +
        $1.translation +
        "goto BLOCK_LABEL_" + to_string(scopesCount) + "_END;\n\t";
    };

  FOR:
    R_FOR '(' ASSIGNMENT_STATE SEMI_COLON EXP SEMI_COLON ASSIGNMENT_STATE ')' BLOCK {
      if($5.token != BOOLEAN){ wrongOperation("for",checkType($5.token)); }
      scopesCount++;
      $$.tempTranslation = $3.tempTranslation + $5.tempTranslation +
        $7.tempTranslation + $9.tempTranslation;
      $$.translation = $3.translation +
        "BLOCK_LABEL_" + to_string(scopesCount) + "_BEGIN:\n\t" +
        $5.translation +
        "if(" + $5.tempVar.name +") { goto BLOCK_LABEL_" + to_string(scopesCount) + ";}\n\t" +
        "BLOCK_LABEL_" + to_string(scopesCount) + "_END:\n\t";
      $$.scopesLabels =
        $9.scopesLabels +
        "BLOCK_LABEL_" + to_string(scopesCount) + ":\n\t" +
        $9.translation + $7.translation +
        "goto BLOCK_LABEL_" + to_string(scopesCount) + "_BEGIN;\n\t";
    };

  SWITCH:
    R_SWITCH EXP BLOCK_INIT END_LINE CASES BLOCK_END {
      onSwitch = true;
      scopesCount++;
      switchCount++;
      $$.translation =
        $2.token == STRING ?
        $2.translation +
        checkType(CHARACTER) + "* tempSwitch" + to_string(switchCount-1) + " = " + $2.tempVar.name + "; // tempSwitch = " + to_string(switchCount) + "\n\t" +
        $5.translation +
        "BLOCK_LABEL_"+to_string(scopesCount)+"_END:\n\t"
        :
        $2.translation +
        checkType($2.token) + " tempSwitch" + to_string(switchCount-1) + " = " + $2.tempVar.name + "; // tempSwitch = " + to_string(switchCount) + "\n\t" +
        $5.translation +
        "BLOCK_LABEL_"+to_string(scopesCount)+"_END:\n\t";
      $$.tempTranslation = $2.tempTranslation + $5.tempTranslation;
      $$.scopesLabels = $5.scopesLabels;
    };

  CASES:
    CASE DEFAULT {
      $$.translation = $1.translation + $2.translation;
      $$.tempTranslation = $1.tempTranslation + $2.tempTranslation;
      $$.scopesLabels = $1.scopesLabels + $2.scopesLabels;
    };
    | CASE CASES {
      $$.translation = $1.translation + $2.translation;
      $$.tempTranslation = $1.tempTranslation + $2.tempTranslation;
      $$.scopesLabels = $1.scopesLabels + $2.scopesLabels;
    };

  CASE:
    R_CASE EXP COLON CMDS {
      scopesCount++;
      map<string,attr> newScope;
      scopes.push_back(newScope);

      $$.tempTranslation = $2.tempTranslation + $4.tempTranslation;
      $$.translation =
        $2.token == STRING ?
        $2.translation +
        "if(strcmp(" + $2.tempVar.name + ",tempSwitch" + to_string(switchCount) + ") == 0) { goto BLOCK_LABEL_" + to_string(scopesCount) + "; }\n\t" +
        "BLOCK_LABEL_" + to_string(scopesCount) + "_END:\n\t"
        :
        $2.translation +
        "if(" + $2.tempVar.name + " == tempSwitch" + to_string(switchCount) + ") { goto BLOCK_LABEL_" + to_string(scopesCount) + "; }\n\t" +
        "BLOCK_LABEL_" + to_string(scopesCount) + "_END:\n\t";

      $$.scopesLabels =
        $4.scopesLabels +
        "BLOCK_LABEL_" + to_string(scopesCount) + ":\n\t" +
        $4.translation;

      scopes.pop_back();
    };

  DEFAULT:
    R_DEFAULT COLON CMDS {
      scopesCount++;
      map<string,attr> newScope;
      scopes.push_back(newScope);

      $$.translation =
        "goto BLOCK_LABEL_" + to_string(scopesCount) + ";\n\t" +
        "BLOCK_LABEL_" + to_string(scopesCount) + "_END:\n\t";
      $$.tempTranslation = $3.tempTranslation;
      $$.scopesLabels =
        $3.scopesLabels +
        "BLOCK_LABEL_" + to_string(scopesCount) + ":\n\t" +
        $3.translation;

      scopes.pop_back();
    };

  BREAK:
    R_BREAK {
      $$.translation =
        onSwitch ?
        "goto BLOCK_LABEL_" + to_string(scopes.size()+1) + "_END;\n\t" :
        "goto BLOCK_LABEL_" + to_string(scopes.size()) + "_END;\n\t";
    };

  CONTINUE:
    R_CONTINUE {
      $$.translation = "goto BLOCK_LABEL_" + to_string(scopes.size()) +"_BEGIN;\n\t";
    }
  ;

  ASSIGNMENT_STATE:
    varConst ASSIGNMENT EXP { // varConst = EXP
      string name = $1.isVar ? $1.id : $1.id.erase(0,1);

      if(!(exists(name))) { // Var/Const Not Declared
        $1.tempVar = createTemp($3.token,$3.translation);
        addVar($1.tempVar,name, $1.isVar, $3.value, $3.token);
        $$.tempTranslation = $3.tempTranslation + $1.tempVar.translation + " // " + name + "\n\t";
        if($3.token == STRING){
          temp strLenTemp = createTemp(INTEGER,"strlen(" + $3.tempVar.name + ");");
          temp sizeOfTemp = createTemp(INTEGER,"sizeof(char);");
          temp calcMallocTemp = createTemp(INTEGER,strLenTemp.name + " * " + sizeOfTemp.name + ";");
          $$.tempTranslation =
            $$.tempTranslation +
            strLenTemp.translation + "// " + strLenTemp.value + "\n\t" +
            sizeOfTemp.translation + "// " + sizeOfTemp.value + "\n\t" +
            calcMallocTemp.translation + "// " + calcMallocTemp.value + "\n\t";
          $$.translation =
            $3.translation +
            strLenTemp.name + " = " + strLenTemp.value + "\n\t" +
            sizeOfTemp.name + " = " + sizeOfTemp.value + "\n\t" +
            calcMallocTemp.name + " = " + calcMallocTemp.value + "\n\t" +
            $1.tempVar.name + " = (char*) malloc("+ calcMallocTemp.name +");\n\t" +
            "strcpy(" + $1.tempVar.name + "," + $3.tempVar.name + ");\n\t";
            tempsOnMemory.push_back($1.tempVar);
        }
        else {
            $$.translation = $3.translation + $1.tempVar.name + " = " + $3.tempVar.name + ";\n\t";
        }
        $$.tempVar = $1.tempVar;
        $$.token = $1.tempVar.token;
      }
      else { // Var/Const Already Declared
        attr varConst = getVar(name);
        if(!varConst.isVar){ constWontChangeValue(name); }
        if(varConst.token != $3.token) { alreadyDeclared(name,checkType(name)); }
        $$.tempTranslation = $3.tempTranslation;
        switch(varConst.token){
          case STRING:
            $$.translation =
              $3.translation +
              "free(" + varConst.tempVar.name + ");\n\t" +
              varConst.tempVar.name + " = (char*) malloc(strlen(" + $3.tempVar.name + ") * sizeof(char));\n\t" +
              "strcpy(" + varConst.tempVar.name + "," + $3.tempVar.name + ");\n\t";
          break;
          default:
            $$.translation = $3.translation + varConst.tempVar.name + " = " + $3.tempVar.name + ";\n\t";
          break;
        }
        varConst.value = $3.value;
      }
    };

  CMD:
    IF;
    | WHILE;
    | DO_WHILE;
    | END_LINE;
    | FOR;
    | SWITCH;
    | BREAK;
    | CONTINUE;
    | IS;
    | IN;
    | OUT;
    | IS SEMI_COLON;
    | IN SEMI_COLON;
    | OUT SEMI_COLON;
    | ASSIGNMENT_STATE;
    | ASSIGNMENT_STATE SEMI_COLON;

  IS:
    varConst R_IS TYPE {
      if(exists($1.id)){ alreadyDeclared($1.id, checkType($1.id)); }
      temp t = createTemp($3.token,"");
      addVar(t,$1.id, $1.isVar, "", $3.token);
      $$.tempTranslation = t.translation + " // Pre-declaration\n\t";
    };

  TYPE:
    INTEGER;
    | FLOAT;
    | BOOLEAN;
    | CHARACTER;
    | STRING;

  IN:
    R_IN COLON varConst {
      if(!(exists($3.id))){ notDeclared($3.id); }
      if(!getVar($3.id).isVar){ constWontChangeValue($3.id); }
      attr t = getVar($3.id);
      attr inBuffer;
      switch(t.token){
        case STRING:
          if(!(exists("inBuffer"))){
            temp inBuffer = createTemp(t.token,"");
            addVar(inBuffer,"inBuffer", "true", "", $3.token);
            inBuffer.translation.pop_back();
            $$.tempTranslation = inBuffer.translation + " = (char*) malloc(MAX_BUFFER_SIZE * sizeof(char)); // String Input Buffer\n\t";
            tempsOnMemory.push_back(inBuffer);
          }
          inBuffer = getVar("inBuffer");
          if(onMemory(t.tempVar)){
            $$.translation =
              $$.translation + "\n\t" +
              "free(" + t.tempVar.name + ");\n\t" +
              "fgets(" + inBuffer.tempVar.name + ",MAX_BUFFER_SIZE,stdin);\n\t" +
              inBuffer.tempVar.name + "[strlen(" + inBuffer.tempVar.name + ")-1] = 0;\n\t" +
              t.tempVar.name + " = (char*) malloc(strlen(" + inBuffer.tempVar.name + ") * sizeof(char));\n\t" +
              "strcpy(" + t.tempVar.name + "," + inBuffer.tempVar.name + ");\n\t";
          }
          else {
            $$.translation =
              $$.translation + "\n\t" +
              "fgets(" + inBuffer.tempVar.name + ",MAX_BUFFER_SIZE,stdin);\n\t" +
              inBuffer.tempVar.name + "[strlen(" + inBuffer.tempVar.name + ")-1] = 0;\n\t" +
              t.tempVar.name + " = (char*) malloc(strlen(" + inBuffer.tempVar.name + ") * sizeof(char));\n\t" +
              "strcpy(" + t.tempVar.name + "," + inBuffer.tempVar.name + ");\n\t";
              tempsOnMemory.push_back(t.tempVar);
          }
        break;
        default:
          $$.translation = "cin >> " + t.tempVar.name + ";\n\t";
        break;
      }
    };

  OUT:
    R_OUT COLON EXP COMMA_OUT {
      temp t = $3.tempVar;
      $$.tempTranslation = $3.tempTranslation + $4.tempTranslation;
      $$.translation =
        $3.translation + "cout << " + t.name + " << \" \";\n\t" + $4.translation + "cout << endl;\n\t";
    };

  COMMA_OUT:
    COMMA EXP COMMA_OUT {
      temp t = $2.tempVar;
      $$.tempTranslation = $2.tempTranslation + $3.tempTranslation;
      $$.translation = $2.translation + "cout << " + t.name + " << \" \";\n\t" + $3.translation;
    };
    |;

  EXP:
    EXP R_DOT EXP { // EXP.EXP (String Concatenation)
      if($1.token != STRING){ wrongOperation("'.' (String concatenation)",checkType($1.token)); }
      else if($3.token != STRING){ wrongOperation("'.' (String concatenation)",checkType($3.token)); }
      temp t = createTemp(STRING,$1.tempVar.name+ " . "+ $3.tempVar.name);
      $$.tempTranslation = $1.tempTranslation + $3.tempTranslation + t.translation + " // "+ t.value + "\n\t";
      $$.translation =
        $1.translation +
        $3.translation +
        t.name + " = (char*) malloc((strlen(" + $1.tempVar.name + ") + strlen(" + $3.tempVar.name + ")) * sizeof(char));\n\t" +
        "strcat(" + t.name + "," + $1.tempVar.name + ");\n\t" +
        "strcat(" + t.name + "," + $3.tempVar.name + ");\n\t";
      if(onMemory($1.tempVar)){ // Free $1.tempVar
        //$$.translation = $$.translation + "free(" + $1.tempVar.name + ");\n\t";
        //removeFromMemory($1.tempVar);
      }
      if(onMemory($3.tempVar)){ // Free $3.tempVar
        //$$.translation = $$.translation + "free(" + $3.tempVar.name + ");\n\t";
        //removeFromMemory($3.tempVar);
      }
      $$.token = STRING;
      $$.tempVar = t;
      tempsOnMemory.push_back(t);
    };
    | EXP COLON COLON EXPLICIT_TYPE { // EXP::EXPLICIT_TYPE
      temp t;
      if($1.token == $4.token){ warningExplicitType($1.tempVar.value,checkType($4.token)); }
      else if(($1.token != FLOAT) && ($1.token != INTEGER)){ wrongOperation("::"+checkType($4.token),checkType($1.token)); }
      else if($4.token == FLOAT){
        t = createTemp(FLOAT,"(float) "+$1.tempVar.name + ";");
        $$.tempTranslation = $1.tempTranslation + t.translation + " // " + t.value + "\n\t";
        $$.translation = $1.translation + t.name + " = " + t.value + "\n\t";
        $$.token = FLOAT;
        $$.tempVar = t;
      }
      else if($4.token == INTEGER){
        t = createTemp(INTEGER,"(int) "+$1.tempVar.name + ";");
        $$.tempTranslation = $1.tempTranslation + t.translation + " // " + t.value + "\n\t";
        $$.translation = $1.translation + t.name + " = " + t.value + "\n\t";
        $$.token = INTEGER;
        $$.tempVar = t;
      }
    };
    | EXP BOOLEAN_LOGIC EXP {
      if($1.token != BOOLEAN){ wrongOperation($2.operation,checkType($1.token)); }
      else if($3.token != BOOLEAN){ wrongOperation($2.operation,checkType($3.token)); }
      temp t = createTemp(BOOLEAN,$1.tempVar.name + " " + $2.operation + " " + $3.tempVar.name);
      $$.tempTranslation =
        $1.tempTranslation +
        $3.tempTranslation +
        t.translation + " // " + t.value + "\n\t";
      $$.translation =
        $1.translation +
        $3.translation +
        t.name + " = " + t.value + ";\n\t";
      $$.token = BOOLEAN;
      $$.tempVar = t;
    };
    | NOT EXP { // !EXP
      if($2.token != BOOLEAN){ wrongOperation("!",checkType($2.token)); }
      temp t = createTemp($2.token,$2.translation);
      $$.tempTranslation = $2.tempTranslation + t.translation + " // " + $1.operation + $2.tempVar.name + "\n\t";
      $$.translation = $2.translation + t.name + " = " + $1.operation + $2.tempVar.name + ";\n\t";
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

      $$.tempTranslation = $1.tempTranslation + $3.tempTranslation;
      $$.translation = $1.translation + $3.translation;

      if($2.operation == "===" || $2.operation == "!=="){ // Equal Types || Different Types
        t = $2.operation == "===" ?
          createTemp(BOOLEAN, ($1.tempVar.token == $3.tempVar.token) ? "TRUE" : "FALSE") :
          createTemp(BOOLEAN, ($1.tempVar.token != $3.tempVar.token) ? "TRUE" : "FALSE");
        $$.tempTranslation = $$.tempTranslation + t.translation + " // " + t.value + "\n\t";
        $$.translation = $$.translation + t.name + " = " + t.value + ";\n\t";
        $$.tempVar = t;
      }
      else {
        if($1.token == INTEGER && $3.token == FLOAT){ // int EQUALITY_TEST float -> float
          t = createTemp(FLOAT, "(float) " + $1.tempVar.name + ";");
          op = createTemp(BOOLEAN,t.name + " "+ $2.operation +" " + $3.tempVar.name);
          $$.tempTranslation = $$.tempTranslation + t.translation + " // " + t.value + "\n\t";
          $$.translation = $$.translation + t.name + " = " + t.value + "\n\t";
        }
        else if($1.token == FLOAT && $3.token == INTEGER){ // float EQUALITY_TEST int -> float
          t = createTemp(FLOAT, "(float) " + $3.tempVar.name + ";");
          op = createTemp(BOOLEAN,t.name + " "+ $2.operation +" " + $1.tempVar.name);
          $$.tempTranslation = $$.tempTranslation + t.translation + " // " + t.value + "\n\t";
          $$.translation = $$.translation + t.name + " = " + t.value + ";\n\t";
        }
        else { op = createTemp(BOOLEAN, $1.tempVar.name + " "+ $2.operation +" " + $3.tempVar.name); }

        $$.tempTranslation = $$.tempTranslation + op.translation + " // " + op.value + "\n\t";
        $$.translation = $$.translation + op.name + " = " + op.value + ";\n\t";
        $$.tempVar = op;
      }

      $$.token = BOOLEAN;
    };
    | EXP ORDER_RELATION EXP {
      temp t;
      temp op;

      $$.tempTranslation = $1.tempTranslation + $3.tempTranslation;
      $$.translation = $1.translation + $3.translation;

      if($1.token != FLOAT && $1.token != INTEGER){ wrongOperation($2.operation,checkType($1.token)); }
      else if($3.token != FLOAT && $3.token != INTEGER){ wrongOperation($2.operation,checkType($3.token)); }

      if($1.token == INTEGER && $3.token == FLOAT){ // int ORDER_RELATION float -> float
        t = createTemp(FLOAT, "(float) " + $1.tempVar.name + ";");
        op = createTemp(BOOLEAN,t.name + " "+ $2.operation +" " + $3.tempVar.name);
        $$.tempTranslation = $$.tempTranslation + t.translation + " // " + t.value + "\n\t";
        $$.translation = $$.translation + t.name + " = " + t.value + ";\n\t";
      }
      else if($1.token == FLOAT && $3.token == INTEGER){ // float ORDER_RELATION int -> float
        t = createTemp(FLOAT, "(float) " + $3.tempVar.name + ";");
        op = createTemp(BOOLEAN,t.name + " "+ $2.operation +" " + $1.tempVar.name);
        $$.tempTranslation = $$.tempTranslation + t.translation + " // " + t.value + "\n\t";
        $$.translation = $$.translation + t.name + " = " + t.value + ";\n\t";
      }
      else { op = createTemp(BOOLEAN, $1.tempVar.name + " "+ $2.operation +" " + $3.tempVar.name); }
      $$.tempTranslation = $$.tempTranslation + op.translation + " // " + op.value + "\n\t";
      $$.translation = $$.translation + op.name + " = " + op.value + ";\n\t";
      $$.tempVar = op;
      $$.token = BOOLEAN;
    };
    | EXP ARITHMETIC_1 EXP {
      temp t;
      temp op;

      $$.tempTranslation = $1.tempTranslation + $3.tempTranslation;
      $$.translation = $1.translation + $3.translation;

      if($1.token == BOOLEAN || $3.token == BOOLEAN){ wrongOperation($2.operation,"bool"); }
      if($1.token == STRING || $3.token == STRING){ wrongOperation($2.operation,"string"); }
      if($1.token == CHARACTER || $3.token == CHARACTER){ wrongOperation($2.operation,"char"); }
      if($1.token == INTEGER && $3.token == FLOAT){ // int ARITHMETIC float -> float
        $$.token = FLOAT;
        t = createTemp(FLOAT, "(float) " + $1.tempVar.name + ";");
        op = createTemp(FLOAT,t.name + " "+ $2.operation +" " + $3.tempVar.name);
        $$.tempTranslation = $$.tempTranslation + "\n\t" + t.translation + " // " + t.value + "\n\t";
        $$.translation = $$.translation + "\n\t" + t.name + " = " + t.value + "\n\t";
      }
      else if($1.token == FLOAT && $3.token == INTEGER){ // float ARITHMETIC int -> float
        $$.token = FLOAT;
        t = createTemp(FLOAT, "(float) " + $3.tempVar.name + ";");
        op = createTemp(FLOAT,t.name + " "+ $2.operation +" " + $1.tempVar.name);
        $$.tempTranslation = $$.tempTranslation + "\n\t" + t.translation + " // " + t.value + "\n\t";
        $$.translation = $$.translation + "\n\t" + t.name + " = " + t.value + "\n\t";
      }
      else if($1.token == INTEGER && $3.token == INTEGER){ // int ARITHMETIC int -> int
        $$.token = INTEGER;
        op = createTemp(INTEGER, $1.tempVar.name + " "+ $2.operation +" " + $3.tempVar.name);
      }
      else if($1.token == FLOAT && $3.token == FLOAT){ // float ARITHMETIC float -> float
        $$.token = FLOAT;
        op = createTemp(FLOAT, $1.tempVar.name + " "+ $2.operation +" " + $3.tempVar.name);
      }
      $$.tempTranslation = $$.tempTranslation + op.translation + " // " + op.value + "\n\t";
      $$.translation = $$.translation + op.name + " = " + op.value + ";\n\t";
      $$.tempVar = op;
    };
    | EXP ARITHMETIC_2 EXP {
      temp t;
      temp op;

      $$.tempTranslation = $1.tempTranslation + $3.tempTranslation;
      $$.translation = $1.translation + $3.translation;

      if($1.token == BOOLEAN || $3.token == BOOLEAN){ wrongOperation($2.operation,"bool"); }
      if($1.token == INTEGER && $3.token == FLOAT){ // int ARITHMETIC float -> float
        $$.token = FLOAT;
        t = createTemp(FLOAT, "(float) " + $1.tempVar.name + ";");
        op = createTemp(FLOAT,t.name + " "+ $2.operation +" " + $3.tempVar.name);
        $$.tempTranslation = $$.tempTranslation + "\n\t" + t.translation + " // " + t.value + "\n\t";
        $$.translation = $$.translation + "\n\t" + t.name + " = " + t.value + "\n\t";
      }
      else if($1.token == FLOAT && $3.token == INTEGER){ // float ARITHMETIC int -> float
        $$.token = FLOAT;
        t = createTemp(FLOAT, "(float) " + $3.tempVar.name + ";");
        op = createTemp(FLOAT,t.name + " "+ $2.operation +" " + $1.tempVar.name);
        $$.tempTranslation = $$.tempTranslation + "\n\t" + t.translation + " // " + t.value + "\n\t";
        $$.translation = $$.translation + "\n\t" + t.name + " = " + t.value + "\n\t";
      }
      else if($1.token == INTEGER && $3.token == INTEGER){ // int ARITHMETIC int -> int
        $$.token = INTEGER;
        op = createTemp(INTEGER, $1.tempVar.name + " "+ $2.operation +" " + $3.tempVar.name);
      }
      else if($1.token == FLOAT && $3.token == FLOAT){ // float ARITHMETIC float -> float
        $$.token = FLOAT;
        op = createTemp(FLOAT, $1.tempVar.name + " "+ $2.operation +" " + $3.tempVar.name);
      }
      $$.tempTranslation = $$.tempTranslation + "\n\t" + op.translation + " // " + op.value + "\n\t";
      $$.translation = $$.translation + "\n\t" + op.name + " = " + op.value + ";\n\t";
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
      $$.translation = $$.tempVar.name + " = " + $1.value + ";\n\t";
      $$.value = $1.value;
      $$.token = INTEGER;
      $$.tempTranslation = $$.tempVar.translation + " // " + $$.translation;
    };
    | FLOAT {
      $$.tempVar = createTemp($1.token,$1.value);
      $$.translation = $$.tempVar.name + " = " + $1.value + ";\n\t";
      $$.value = $1.value;
      $$.token = FLOAT;
      $$.tempTranslation = $$.tempVar.translation + " // " + $$.translation;
    };
    | BOOLEAN {
      $$.tempVar = createTemp($1.token,toUpper($1.value));
      $$.translation = $$.tempVar.name + " = " + toUpper($1.value) + ";\n\t";
      $$.value = $1.value;
      $$.token = BOOLEAN;
      $$.tempTranslation = $$.tempVar.translation + " // " + $$.translation;
    };
    | CHARACTER {
      $$.tempVar = createTemp($1.token,$1.value);
      $$.translation = $$.tempVar.name + " = " + $1.value + ";\n\t";
      $$.value = $1.value;
      $$.token = CHARACTER;
      $$.tempTranslation = $$.tempVar.translation + " // " + $$.translation;
    };
    | STRING {
      $$.tempVar = createTemp($1.token,$1.value);
      $$.translation = $$.tempVar.name + " = (char*) " + $1.value + ";\n\t";
      $$.value = $1.value;
      $$.token = STRING;
      $$.tempTranslation = $$.tempVar.translation + " // " + $$.translation;
    };

  varConst:
    VAR {
      $$.id = $1.id;
      $$.isVar = true;
      if(exists($1.id)){ $$.token = getVar($1.id).token; }
    };
    | CONST {
      $$.id = $1.id;
      $$.isVar = false;
      if(exists($1.id)){ $$.token = getVar($1.id).token; }
    };
%%

#include "lex.yy.c"
int yyparse();
int main(int argc, char** argv){ yyparse(); }

/* Bison Error Msg */
void yyerror(string msg){
  cout <<
  colorText("error:"+to_string(yylineno)+": ",hexToRGB(RED)) <<  msg  << " with " << colorText("'"+(string)yytext+"'",hexToRGB(YELLOW)) << endl;
}

/*
  ------------------------
          Useful
  ------------------------
*/
bool onMemory(temp tempVar){
  bool onMemory;
  for(temp t : tempsOnMemory){
    if(t.name == tempVar.name){ onMemory = true; break; }
  }
  return onMemory;
}

void removeFromMemory(temp tempVar){
  for(vector<temp>::iterator it = tempsOnMemory.begin(); it != tempsOnMemory.end();){
    if(it->name == tempVar.name){ tempsOnMemory.erase(it); }
    else { ++it; }
  }
}

string clearMemory(){
  string result = "";
  for(temp t : tempsOnMemory){ result += "free("+t.name+");\n\t"; }
  return result;
}

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
  cout << colorText("error:"+actualLine()+": ",hexToRGB(RED)) << "You're a dumbass... The Const " << colorText("'"+name+"'",hexToRGB(AQUA)) << " won't change value, because " << colorText("IS A FUCKIN' CONST!!!",hexToRGB(ORANGE_RED)) << "." << endl;
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
  for(int i = 0; i < scopes.size(); i++){
      scopeIterator = scopes[i].find(name);
      if(scopeIterator != scopes[i].end()){ return scopeIterator->second; }
  }
  scopeIterator = globalScope.find(name);
  return scopeIterator->second;
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
  /* new Var */
  attr v;
  v.id = name;
  v.isVar = isVar;
  v.value = value;
  v.token = token;
  v.tempVar = tempVar;

  if(scopes.size() >= 1){ scopes.back()[name] = v; }
  else { globalScope[name] = v; }
}

string checkType(int token){
  switch (token) {
    case INTEGER: return "int";
    case FLOAT: return "float";
    case BOOLEAN: return "int";
    case CHARACTER: return "char";
    case STRING: return "string";
    default: return "UNDEFINED";
  }
}

string checkType(string name){
  map<string,attr> scope = scopes.size() >= 1 ? scopes.back() : globalScope;
  scopeIterator = scope.find(name);
  attr v = scopeIterator->second;
  switch (v.token) {
    case INTEGER: return "int";
    case FLOAT: return "float";
    case BOOLEAN: return "int";
    case CHARACTER: return "char";
    case STRING: return "string";
    default: return "UNDEFINED";
  }
}

bool exists(string varName){
  for(int i = 0; i < scopes.size(); i++){
      scopeIterator = scopes[i].find(varName);
      if(scopeIterator != scopes[i].end()){ return true; }
  }
  scopeIterator = globalScope.find(varName);
  return !(scopeIterator == globalScope.end());
}
