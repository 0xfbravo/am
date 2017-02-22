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

  /* Structs */
  struct temp {
    int token;
    string name;
    string value;
    string translation;
    int col;
    int ln;
    int tokenAccessMatrix;
  };

  struct func {
    int returnType;
    string name;
    string translation;
    vector<temp> params = {};
  };

  #define YYSTYPE attr
  struct attr {
    int token;                    // LexToken (Type)
    temp tempVar;                 // TempVar
    string id;                    // (Var||Const).name
    string value;                 // (Var||Const).value || Value
    bool isVar;                   // Var||Const
    string translation;           // C Translation
    string tempTranslation;       // Var declaration - C Translation
    string scopesLabels;          // Scopes Labels
    string operation;             // Operation
    string paramTranslation;      // Function Params Translation
  };

  /* Flex/Yacc Functions */
  int yylex(void);
  void yyerror(string);

  /* Messages */
  void outOfRange(string,int,int);
  void notDeclared(string);
  void constWontChangeValue(string);
  void alreadyDeclared(string,string);
  void wrongOperation(string,string);
  void warningExplicitType(string,string);

  /* VarMap Functions */
  bool exists(string);
  bool existsOnScope(string);
  void addVar(temp,string,bool,string,int);
  attr getVar(string);
  string checkType(int);
  string checkType(string);
  temp createTemp(int,string);

  /* VarMap */
  map<string,attr> globalScope;
  map<string,attr>::iterator scopeIterator;

  /* Heap */
  vector<func> functions = {};
  vector<temp> functionsParams = {};
  vector<temp> tempsOnMemory = {};
  vector<map<string,attr>> scopes = {};

  /* Useful Functions */
  bool onMemory(temp);
  void removeFromMemory(temp);
  string createFunctions();
  string clearMemory();
  string toUpper(const string&);
  string actualLine();
%}

%token BLOCK_INIT BLOCK_END SEMI_COLON MATRIX_INIT MATRIX_END
%token R_UP R_UM RETURN
%token R_IF R_ELSE R_WHILE R_DO R_FOR R_SWITCH R_CASE R_DEFAULT R_BREAK R_CONTINUE
%token R_IN R_OUT R_IS R_DOT R_OF
%token MTX_INT MTX_FLOAT MTX_BOOLEAN MTX_CHAR MTX_STRING
%token INTEGER FLOAT BOOLEAN CHARACTER STRING VOID
%token ARITHMETIC_1 ARITHMETIC_2 BOOLEAN_LOGIC EQUALITY_TEST ORDER_RELATION
%token ASSIGNMENT NOT COLON QUESTION COMMA
%token VAR CONST EXPLICIT_TYPE
%token END_LINE

%left ASSIGNMENT                        // "="
%left BOOLEAN_LOGIC                     // "||" "&&"
%left EQUALITY_TEST ORDER_RELATION      // "==" "===" "!==" "!=" "<" "<=" ">" ">="
%left QUESTION COLON                    // "?" ":"
%left NOT                               // "!"
%left R_DOT                             // "abc"."123" == "abc123"
%left ARITHMETIC_1                      // "+" "-"
%left ARITHMETIC_2                      // "*" "/"
%left '(' ')'
%left MATRIX_INIT MATRIX_END            // "[" "]"
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
      "/* Functions */" << endl <<
      createFunctions() << endl <<
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
    BLOCK_INIT CMDS BLOCK_END {
      $$.translation =  $2.translation;
      $$.tempTranslation = $2.tempTranslation;
      $$.scopesLabels = $2.scopesLabels;
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
    R_WHILE EXP START_SCOPE BLOCK END_SCOPE {
      if($2.token != BOOLEAN){  wrongOperation("while",checkType($2.token)); }
      scopesCount++;
      $$.translation =
        "BLOCK_LABEL_" + to_string(scopesCount) + "_BEGIN:\n\t" +
        $2.translation +
        "if(" + $2.tempVar.name + ") goto BLOCK_LABEL_" + to_string(scopesCount) +";\n\t" +
        "BLOCK_LABEL_" + to_string(scopesCount) + "_END:\n\t";
      $$.tempTranslation = $2.tempTranslation + $4.tempTranslation;
      $$.scopesLabels =
        "BLOCK_LABEL_" + to_string(scopesCount) + ":\n\t" +
        $4.translation +
        "goto BLOCK_LABEL_" + to_string(scopesCount) + "_BEGIN;\n\t";
    };

  DO_WHILE:
    R_DO START_SCOPE BLOCK END_SCOPE R_WHILE EXP {
      if($6.token != BOOLEAN){  wrongOperation("do-while",checkType($6.token)); }
      scopesCount++;
      $$.translation =
        "BLOCK_LABEL_" + to_string(scopesCount) + "_BEGIN:\n\t" +
        $3.translation +
        "goto BLOCK_LABEL_" + to_string(scopesCount) +";\n\t" +
        "BLOCK_LABEL_" + to_string(scopesCount) + "_END:\n\t";
      $$.tempTranslation = $3.tempTranslation + $6.tempTranslation;
      $$.scopesLabels =
        $3.scopesLabels +
        "BLOCK_LABEL_" + to_string(scopesCount) + ":\n\t" +
        $6.translation +
        "if(" + $6.tempVar.name + ") goto BLOCK_LABEL_" + to_string(scopesCount) +"_BEGIN;\n\t" +
        "goto BLOCK_LABEL_" + to_string(scopesCount) + "_END;\n\t";
    };

  IF:
    R_IF EXP START_SCOPE BLOCK END_SCOPE ELSES {
      if($2.token != BOOLEAN){ wrongOperation("if",checkType($2.token)); }
      scopesCount++;
      $$.translation =
        $2.translation +
        "if (" + $2.tempVar.name + ") goto BLOCK_LABEL_" + to_string(scopesCount) + ";\n\t" +
        $6.translation +
        "BLOCK_LABEL_" + to_string(scopesCount) + "_END:\n\t";
      $$.tempTranslation = $2.tempTranslation + $4.tempTranslation + $6.tempTranslation;
      $$.scopesLabels =
        "BLOCK_LABEL_" + to_string(scopesCount) + ":\n\t" +
        $4.translation +
        "goto BLOCK_LABEL_" + to_string(scopesCount) + "_END;\n\t" +
        $6.scopesLabels;
    };

  ELSES:
    ELSE ELSES {
      $$.translation = $1.translation + $2.translation;
      $$.tempTranslation = $1.tempTranslation + $2.tempTranslation;
      $$.scopesLabels = $1.scopesLabels + $2.scopesLabels;
    };
    | {
      $$.translation = "";
      $$.tempTranslation = "";
      $$.scopesLabels = "";
    };

  ELSE:
    R_ELSE ELSEIF {
      $$.translation = $2.translation;
      $$.tempTranslation = $2.tempTranslation;
      $$.scopesLabels = $2.scopesLabels;
    };
    | END_LINE;

  ELSEIF:
    IF;
    | START_SCOPE BLOCK END_SCOPE {
      scopesCount++;
      $$.tempTranslation = $2.tempTranslation;
      $$.translation =
        "else goto BLOCK_LABEL_"+ to_string(scopesCount) +";\n\t" +
        "BLOCK_LABEL_" + to_string(scopesCount) + "_END:\n\t";
      $$.scopesLabels =
        $2.scopesLabels +
        "BLOCK_LABEL_" + to_string(scopesCount) + ":\n\t" +
        $2.translation +
        "goto BLOCK_LABEL_" + to_string(scopesCount) + "_END;\n\t";
    };

  FOR:
    R_FOR START_SCOPE '(' ASSIGNMENT_STATE SEMI_COLON EXP SEMI_COLON FOR_EXP_STATE ')' BLOCK END_SCOPE {
      if($6.token != BOOLEAN){ wrongOperation("for(;;)",checkType($6.token)); }
      scopesCount++;
      $$.tempTranslation = $4.tempTranslation + $6.tempTranslation +
        $8.tempTranslation + $10.tempTranslation;
      $$.translation = $4.translation +
        "BLOCK_LABEL_" + to_string(scopesCount) + "_BEGIN:\n\t" +
        $6.translation +
        "if(" + $6.tempVar.name +") goto BLOCK_LABEL_" + to_string(scopesCount) + ";\n\t" +
        "BLOCK_LABEL_" + to_string(scopesCount) + "_END:\n\t";
      $$.scopesLabels =
        $10.scopesLabels +
        "BLOCK_LABEL_" + to_string(scopesCount) + ":\n\t" +
        $10.translation + $8.translation +
        "goto BLOCK_LABEL_" + to_string(scopesCount) + "_BEGIN;\n\t";
    };

  FOR_EXP_STATE:
    UNITARY_STATE {
      $$.translation = $1.translation;
      $$.tempTranslation = $1.tempTranslation;
    };
    | ASSIGNMENT_STATE {
      $$.translation = $1.translation;
      $$.tempTranslation = $1.tempTranslation;
    };

  SWITCH:
    R_SWITCH EXP START_SCOPE BLOCK_INIT END_LINE CASES BLOCK_END END_SCOPE {
      scopesCount++;
      switchCount++;
      $$.translation =
        $2.translation +
        "tempSwitch" + to_string(switchCount-1) + " = " + $2.tempVar.name + ";\n\t" +
        $6.translation +
        "BLOCK_LABEL_"+to_string(scopesCount)+"_END:\n\t";
      $$.tempTranslation =
        $2.token == STRING ?
          $2.tempTranslation +
          $6.tempTranslation +
          checkType(CHARACTER) + "* tempSwitch" + to_string(switchCount-1) + "; // tempSwitch = " + to_string(switchCount) + "\n\t"
          :
          $2.tempTranslation +
          $6.tempTranslation +
          checkType($2.token) + " tempSwitch" + to_string(switchCount-1) + "; // tempSwitch = " + to_string(switchCount) + "\n\t";
      $$.scopesLabels = $6.scopesLabels;
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
    R_CASE EXP COLON START_SCOPE CMDS END_SCOPE {
      scopesCount++;
      map<string,attr> newScope;
      scopes.push_back(newScope);
      temp t =
        $2.token == STRING ?
          createTemp(BOOLEAN,"strcmp(" + $2.tempVar.name + ",tempSwitch" + to_string(switchCount) + ") == 0;") :
          createTemp(BOOLEAN,$2.tempVar.name + " == tempSwitch" + to_string(switchCount) + ";");
      $$.tempTranslation =
        $2.tempTranslation +
        $5.tempTranslation +
        t.translation + " // " + t.value + "\n\t";
      $$.translation =
        $2.translation +
        t.name + " = " + t.value + "\n\t" +
        "if("+t.name+") goto BLOCK_LABEL_" + to_string(scopesCount) + ";\n\t" +
        "BLOCK_LABEL_" + to_string(scopesCount) + "_END:\n\t";

      $$.scopesLabels =
        $5.scopesLabels +
        "BLOCK_LABEL_" + to_string(scopesCount) + ":\n\t" +
        $5.translation;

      scopes.pop_back();
    };

  DEFAULT:
    R_DEFAULT COLON START_SCOPE CMDS END_SCOPE {
      scopesCount++;
      map<string,attr> newScope;
      scopes.push_back(newScope);

      $$.translation =
        "goto BLOCK_LABEL_" + to_string(scopesCount) + ";\n\t" +
        "BLOCK_LABEL_" + to_string(scopesCount) + "_END:\n\t";
      $$.tempTranslation = $4.tempTranslation;
      $$.scopesLabels =
        $4.scopesLabels +
        "BLOCK_LABEL_" + to_string(scopesCount) + ":\n\t" +
        $4.translation;

      scopes.pop_back();
    };

  BREAK:
    R_BREAK {
      $$.translation = "goto BLOCK_LABEL_" + to_string(scopes.size()+1) + "_END;\n\t";
    };

  CONTINUE:
    R_CONTINUE {
      $$.translation = "goto BLOCK_LABEL_" + to_string(scopes.size()) +"_BEGIN;\n\t";
    }
  ;

  ASSIGNMENT_STATE:
    varConst MATRIX_INIT PRIMITIVE COMMA PRIMITIVE MATRIX_END ASSIGNMENT EXP {
      string name = $1.isVar ? $1.id : $1.id.erase(0,1);
      if(!existsOnScope(name)){ notDeclared($1.id); }
      if($1.token != MTX_INT && $1.token != MTX_FLOAT && $1.token != MTX_STRING &&
         $1.token != MTX_CHAR && $1.token != MTX_BOOLEAN) { wrongOperation("'[Int,Int]' (Matrix Assignment)",checkType($1.token));  }
      if($3.token != INTEGER){ wrongOperation("'[Int,Int]' (Matrix Assignment)",checkType($3.token)); }
      if($5.token != INTEGER){ wrongOperation("'[Int,int]' (Matrix Assignment)",checkType($5.token)); }
      if($8.token != $1.tempVar.tokenAccessMatrix){ wrongOperation("'[Int,int]' (Matrix Assignment)",checkType($8.token)); }
      if((stoi($5.value) < 0) || (stoi($3.value) < 0) || (stoi($5.value) >= $1.tempVar.col) || (stoi($3.value) >= $1.tempVar.ln)){
        outOfRange($1.id,stoi($3.value),stoi($5.value));
      }

      temp calcLineColumnTemp1 = createTemp(INTEGER,to_string($1.tempVar.col) + " * " + $3.value + ";");
      temp calcLineColumnTemp2 = createTemp(INTEGER,$5.value + " + " + calcLineColumnTemp1.name + ";");
      temp matrixAccess = createTemp($1.tempVar.tokenAccessMatrix,$1.tempVar.name + "[" + calcLineColumnTemp2.name + "]");

      $$.tempTranslation =
        $1.tempTranslation +
        $3.tempTranslation +
        $5.tempTranslation +
        $8.tempTranslation +
        calcLineColumnTemp1.translation + " // " + calcLineColumnTemp1.value + "\n\t" +
        calcLineColumnTemp2.translation + " // " + calcLineColumnTemp2.value + "\n\t" +
        matrixAccess.translation + " // " + matrixAccess.value + "\n\t";

      $$.translation =
        $1.translation +
        $3.translation +
        $5.translation +
        $8.translation +
        calcLineColumnTemp1.name + " = " + calcLineColumnTemp1.value + "\n\t" +
        calcLineColumnTemp2.name + " = " + calcLineColumnTemp2.value + "\n\t" +
        matrixAccess.value + " = " + $8.tempVar.name + ";\n\t";

        $$.token = $1.tempVar.tokenAccessMatrix;
        $$.tempVar = matrixAccess;
    };
    | varConst ASSIGNMENT EXP { // varConst = EXP
      string name = $1.isVar ? $1.id : $1.id.erase(0,1);

      if(!(existsOnScope(name))) { // Var/Const Not Declared
        $1.tempVar = createTemp($3.token,$3.translation);
        $1.tempVar.ln = $3.tempVar.ln;
        $1.tempVar.col = $3.tempVar.col;
        $1.tempVar.tokenAccessMatrix = $3.tempVar.tokenAccessMatrix;
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
            $1.tempVar.name + " = (char*) malloc(" + calcMallocTemp.name + ");\n\t" +
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
        temp strLenTemp = createTemp(INTEGER,"strlen(" + $3.tempVar.name + ");");
        temp sizeOfTemp = createTemp(INTEGER,"sizeof(char);");
        temp calcMallocTemp = createTemp(INTEGER,strLenTemp.name + " * " + sizeOfTemp.name + ";");
        switch(varConst.token){
          case STRING:
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
              "free(" + varConst.tempVar.name + ");\n\t" +
              varConst.tempVar.name + " = (char*) malloc(" + calcMallocTemp.name + ");\n\t" +
              "strcpy(" + varConst.tempVar.name + "," + $3.tempVar.name + ");\n\t";
          break;
          default:
            $$.translation = $3.translation + varConst.tempVar.name + " = " + $3.tempVar.name + ";\n\t";
          break;
        }
        varConst.value = $3.value;
      }
    };

  FUNCTION_STATE:
    varConst START_SCOPE '(' PARAMS ')' BLOCK END_SCOPE {
      $6.translation.pop_back();
      func f;
      f.name = $1.id;
      f.returnType = VOID;
      f.translation =
        checkType(VOID) + " " + f.name + " (" + $4.paramTranslation + ") {\n\t" +
          $6.tempTranslation +
          $6.translation +
        "}";
      f.params = functionsParams;
      functionsParams.clear();
      functions.push_back(f);
    };

  PARAMS:
    PARAM COMMA_PARAMS {
      $$.translation = $1.translation + $2.translation;
      $$.tempTranslation = $1.tempTranslation + $2.tempTranslation;
      $$.paramTranslation =
        $2.paramTranslation.empty() ?
          $1.paramTranslation :
          $1.paramTranslation + ", " + $2.paramTranslation;
    };
    |;

  COMMA_PARAMS:
    COMMA PARAM COMMA_PARAMS {
      $$.translation = $2.translation + $3.translation;
      $$.tempTranslation = $2.tempTranslation + $3.tempTranslation;
      $$.paramTranslation =
        $3.paramTranslation.empty() ?
          $2.paramTranslation :
          $2.paramTranslation + ", " + $3.paramTranslation;
    };
    |;

  PARAM:
    IS {
      $$.translation = $1.translation;
      $$.tempTranslation = $1.tempTranslation;
      $$.paramTranslation =
        $1.tempVar.token == STRING ?
        "char* " + $1.tempVar.name :
        checkType($1.tempVar.token) + " " + $1.tempVar.name;
      functionsParams.push_back($1.tempVar);
    };

  CMD:
    FUNCTION_STATE;
    | IF;
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
    | UNITARY_STATE;
    | UNITARY_STATE SEMI_COLON;
    | START_SCOPE BLOCK END_SCOPE {
      $$.tempTranslation = $2.tempTranslation;
      $$.translation = $2.translation;
      $$.scopesLabels = $2.scopesLabels;
    };

  UNITARY_STATE:
    varConst R_UP {
      string name = $1.isVar ? $1.id : $1.id.erase(0,1);
      if(!exists(name)){ notDeclared($1.id); }
      if($1.token != INTEGER){ wrongOperation("'++' (Unitary Increment)",checkType($1.token)); }
      attr varConst = getVar(name);
      if(!varConst.isVar){ constWontChangeValue(name); }
      temp t = createTemp($1.token,varConst.tempVar.name + " + 1;");
      $$.tempTranslation =
        t.translation + " // " + t.value + "\n\t";
      $$.translation =
        t.name + " = " + t.value + "\n\t" +
        varConst.tempVar.name + " = " + t.name + ";\n\t";
      $$.tempVar = varConst.tempVar;
    };
    | varConst R_UM {
      string name = $1.isVar ? $1.id : $1.id.erase(0,1);
      if(!exists(name)){ notDeclared($1.id); }
      if($1.token != INTEGER){ wrongOperation("'--' (Unitary Decrement)",checkType($1.token)); }
      attr varConst = getVar(name);
      if(!varConst.isVar){ constWontChangeValue(name); }
      temp t = createTemp($1.token,varConst.tempVar.name + " - 1;");
      $$.tempTranslation =
        t.translation + " // " + t.value + "\n\t";
      $$.translation =
        t.name + " = " + t.value + "\n\t" +
        varConst.tempVar.name + " = " + t.name + ";\n\t";
      $$.tempVar = varConst.tempVar;
    };

  IS:
    varConst R_IS TYPE {
      if(exists($1.id)){ alreadyDeclared($1.id, checkType($1.id)); }
      temp t = createTemp($3.token,"");
      addVar(t,$1.id, $1.isVar, "", $3.token);
      $$.tempTranslation = t.translation + " // Pre-declaration\n\t";
      $$.tempVar = t;
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
            temp sizeOfTemp = createTemp(INTEGER,"sizeof(char);");
            temp calcMallocTemp = createTemp(INTEGER,"MAX_BUFFER_SIZE * " + sizeOfTemp.name + ";");
            temp inBuffer = createTemp(t.token,calcMallocTemp.name+";");
            addVar(inBuffer,"inBuffer", "true", calcMallocTemp.name, $3.token);
            inBuffer.translation.pop_back();
            $$.tempTranslation =
              sizeOfTemp.translation + " // " + sizeOfTemp.value + "\n\t" +
              calcMallocTemp.translation + " // " + calcMallocTemp.value + "\n\t" +
              inBuffer.translation + "; // String Input Buffer\n\t";
            $$.translation =
              sizeOfTemp.name + " = " + sizeOfTemp.value + "\n\t" +
              calcMallocTemp.name + " = " + calcMallocTemp.value + "\n\t" +
              inBuffer.name + " = (char*) malloc(" + calcMallocTemp.name + ");\n\t";
            tempsOnMemory.push_back(inBuffer);
          }
          inBuffer = getVar("inBuffer");
          if(onMemory(t.tempVar)){
            temp strLenTemp = createTemp(INTEGER,"strlen(" + inBuffer.tempVar.name + ");");
            temp sizeOfTemp = createTemp(INTEGER,"sizeof(char);");
            temp calcMallocTemp = createTemp(INTEGER,strLenTemp.name + " * " + sizeOfTemp.name + ";");
            $$.tempTranslation =
              $$.tempTranslation +
              strLenTemp.translation + " // " + strLenTemp.value + "\n\t" +
              sizeOfTemp.translation + " // " + sizeOfTemp.value + "\n\t" +
              calcMallocTemp.translation + " // " + calcMallocTemp.value + "\n\t";
            $$.translation =
              $$.translation +
              strLenTemp.name + " = " + strLenTemp.value + "\n\t" +
              sizeOfTemp.name + " = " + sizeOfTemp.value + "\n\t" +
              calcMallocTemp.name + " = " + calcMallocTemp.value + "\n\t" +
              "free(" + t.tempVar.name + ");\n\t" +
              "fgets(" + inBuffer.tempVar.name + ",MAX_BUFFER_SIZE,stdin);\n\t" +
              inBuffer.tempVar.name + "[strlen(" + inBuffer.tempVar.name + ")-1] = 0;\n\t" +
              t.tempVar.name + " = (char*) malloc("+ calcMallocTemp.name +");\n\t" +
              "strcpy(" + t.tempVar.name + "," + inBuffer.tempVar.name + ");\n\t";
          }
          else {
            temp strLenTemp = createTemp(INTEGER,"strlen(" + inBuffer.tempVar.name + ");");
            temp sizeOfTemp = createTemp(INTEGER,"sizeof(char);");
            temp calcMallocTemp = createTemp(INTEGER,strLenTemp.name + " * " + sizeOfTemp.name + ";");
            $$.tempTranslation =
              $$.tempTranslation +
              strLenTemp.translation + " // " + strLenTemp.value + "\n\t" +
              sizeOfTemp.translation + " // " + sizeOfTemp.value + "\n\t" +
              calcMallocTemp.translation + " // " + calcMallocTemp.value + "\n\t";
            $$.translation =
              $$.translation +
              strLenTemp.name + " = " + strLenTemp.value + "\n\t" +
              sizeOfTemp.name + " = " + sizeOfTemp.value + "\n\t" +
              calcMallocTemp.name + " = " + calcMallocTemp.value + "\n\t" +
              "fgets(" + inBuffer.tempVar.name + ",MAX_BUFFER_SIZE,stdin);\n\t" +
              inBuffer.tempVar.name + "[strlen(" + inBuffer.tempVar.name + ")-1] = 0;\n\t" +
              t.tempVar.name + " = (char*) malloc("+ calcMallocTemp.name +");\n\t" +
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
      $$.translation = $3.translation + "cout << " + t.name + " << \" \";\n\t" + $4.translation + "cout << endl;\n\t";

      if($3.token == MTX_INT || $3.token == MTX_FLOAT || $1.token == MTX_STRING ||
         $3.token == MTX_CHAR || $3.token == MTX_BOOLEAN){
           $$.tempTranslation = $3.tempTranslation + $4.tempTranslation;
           string result = "";
           for(int i = 0; i < t.ln; i++){
             for(int j = 0; j < t.col; j++){
               result += "cout << " + t.name + "[ "+ to_string(j) +" + "+ to_string(t.col) +" * "+to_string(i)+" ] << \" \";\n\t";
             }
             result += "cout << endl;\n\t";
           }
           $$.translation = result + $4.translation + "cout << endl;\n\t";
      }
    };

  COMMA_OUT:
    COMMA EXP COMMA_OUT {
      temp t = $2.tempVar;
      $$.tempTranslation =
        $3.tempTranslation.empty() ?
          $2.tempTranslation :
          $2.tempTranslation + $3.tempTranslation;
      $$.translation =
        $3.translation.empty() ?
          $2.translation + "cout << " + t.name + " << \" \";\n\t" :
          $2.translation + "cout << " + t.name + " << \" \";\n\t" + $3.translation;
    };
    |;

  MATRIX_INIT_STATE:
    MATRIX_INIT PRIMITIVE COLON PRIMITIVE MATRIX_END R_OF TYPE {
      if($2.token != INTEGER){ wrongOperation("'[Int:Int]' (Matrix Init)",checkType($2.token)); }
      if($4.token != INTEGER){ wrongOperation("'[Int:Int]' (Matrix Init)",checkType($4.token)); }

      int matrixToken;
      if($7.token == STRING) { matrixToken = MTX_STRING; }
      else if($7.token == CHARACTER) { matrixToken = MTX_CHAR; }
      else if($7.token == INTEGER) { matrixToken = MTX_INT; }
      else if($7.token == FLOAT) { matrixToken = MTX_FLOAT; }
      else if($7.token == BOOLEAN) { matrixToken = MTX_BOOLEAN; }

      temp sizeOfTemp = createTemp(INTEGER,"sizeof(" + checkType($7.token) + ");");
      temp calcLineColumn = createTemp(INTEGER,$2.tempVar.name + " * " + $4.tempVar.name + ";");
      temp calcMallocTemp = createTemp(INTEGER,calcLineColumn.name + " * " + sizeOfTemp.name + ";");
      temp matrixTemp = createTemp(matrixToken,"[" + $2.tempVar.name + "][" + $4.tempVar.name + "];");
      matrixTemp.ln = stoi($2.value);
      matrixTemp.col = stod($4.value);
      matrixTemp.tokenAccessMatrix = $7.token;

      $$.tempTranslation =
        $2.tempTranslation +
        $4.tempTranslation +
        sizeOfTemp.translation + " // " + sizeOfTemp.value + "\n\t" +
        calcLineColumn.translation + " // " + calcLineColumn.value + "\n\t" +
        calcMallocTemp.translation + " // " + calcMallocTemp.value + "\n\t" +
        matrixTemp.translation + " // " + matrixTemp.value + "\n\t";
      $$.translation =
        $2.translation +
        $4.translation +
        sizeOfTemp.name + " = " + sizeOfTemp.value + "\n\t" +
        calcLineColumn.name + " = " + calcLineColumn.value + "\n\t" +
        calcMallocTemp.name + " = " + calcMallocTemp.value + "\n\t" +
        matrixTemp.name + " = " + "("+ checkType(matrixToken) +") malloc(" + calcMallocTemp.name + ");\n\t" +
        "memset("+ matrixTemp.name +",0,"+ calcMallocTemp.name +");\n\t";
      $$.tempVar = matrixTemp;
      $$.token = matrixToken;
      tempsOnMemory.push_back(matrixTemp);
    };

  MATRIX_ACCESS_STATE:
    varConst MATRIX_INIT PRIMITIVE COMMA PRIMITIVE MATRIX_END {
      string name = $1.isVar ? $1.id : $1.id.erase(0,1);
      if(!exists(name)){ notDeclared($1.id); }
      if($1.token != MTX_INT && $1.token != MTX_FLOAT && $1.token != MTX_STRING &&
          $1.token != MTX_CHAR && $1.token != MTX_BOOLEAN) { wrongOperation("'[Int,Int]' (Matrix Access)",checkType($1.token));  }
      if($3.token != INTEGER){ wrongOperation("'[Int,Int]' (Matrix Access)",checkType($3.token)); }
      if($5.token != INTEGER){ wrongOperation("'[Int,int]' (Matrix Access)",checkType($5.token)); }
      if((stoi($5.value) < 0) || (stoi($3.value) < 0) || (stoi($5.value) >= $1.tempVar.col) || (stoi($3.value) >= $1.tempVar.ln)){
        outOfRange($1.id,stoi($3.value),stoi($5.value));
      }

      temp calcLineColumnTemp1 = createTemp(INTEGER,to_string($1.tempVar.col) + " * " + $3.value + ";");
      temp calcLineColumnTemp2 = createTemp(INTEGER,$5.value + " + " + calcLineColumnTemp1.name + ";");
      temp matrixAccess = createTemp($1.tempVar.tokenAccessMatrix,$1.tempVar.name + "[" + calcLineColumnTemp2.name + "];");

      $$.tempTranslation =
        $1.tempTranslation +
        $3.tempTranslation +
        $5.tempTranslation +
        calcLineColumnTemp1.translation + " // " + calcLineColumnTemp1.value + "\n\t" +
        calcLineColumnTemp2.translation + " // " + calcLineColumnTemp2.value + "\n\t" +
        matrixAccess.translation + " // " + matrixAccess.value + "\n\t";

      $$.translation =
        $1.translation +
        $3.translation +
        $5.translation +
        calcLineColumnTemp1.name + " = " + calcLineColumnTemp1.value + "\n\t" +
        calcLineColumnTemp2.name + " = " + calcLineColumnTemp2.value + "\n\t" +
        matrixAccess.name + " = " + matrixAccess.value + "\n\t";

        $$.token = $1.tempVar.tokenAccessMatrix;
        $$.tempVar = matrixAccess;
    };

  EXP:
    MATRIX_INIT_STATE;
    | MATRIX_ACCESS_STATE;
    | UNITARY_STATE;
    | EXP R_DOT EXP { // EXP.EXP (String Concatenation)
      if($1.token != STRING){ wrongOperation("'.' (String concatenation)",checkType($1.token)); }
      else if($3.token != STRING){ wrongOperation("'.' (String concatenation)",checkType($3.token)); }
      temp t = createTemp(STRING,$1.tempVar.name+ " . "+ $3.tempVar.name);
      temp strLenTemp1 = createTemp(INTEGER,"strlen(" + $1.tempVar.name + ");");
      temp strLenTemp2 = createTemp(INTEGER,"strlen(" + $3.tempVar.name + ");");
      temp strLenTemp3 = createTemp(INTEGER,strLenTemp1.name + " + " + strLenTemp2.name + ";");
      temp sizeOfTemp = createTemp(INTEGER,"sizeof(char);");
      temp calcMallocTemp = createTemp(INTEGER,strLenTemp3.name + " * " + sizeOfTemp.name + ";");
      $$.tempTranslation =
        $1.tempTranslation +
        $3.tempTranslation +
        strLenTemp1.translation + " // " + strLenTemp1.value + "\n\t" +
        strLenTemp2.translation + " // " + strLenTemp2.value + "\n\t" +
        strLenTemp3.translation + " // " + strLenTemp3.value + "\n\t" +
        sizeOfTemp.translation + " // " + sizeOfTemp.value + "\n\t" +
        calcMallocTemp.translation + " // " + calcMallocTemp.value + "\n\t" +
        t.translation + " // "+ t.value + "\n\t";
      $$.translation =
        $1.translation +
        $3.translation +
        strLenTemp1.name + " = " + strLenTemp1.value + "\n\t" +
        strLenTemp2.name + " = " + strLenTemp2.value + "\n\t" +
        strLenTemp3.name + " = " + strLenTemp3.value + "\n\t" +
        sizeOfTemp.name + " = " + sizeOfTemp.value + "\n\t" +
        calcMallocTemp.name + " = " + calcMallocTemp.value + "\n\t" +
        t.name + " = (char*) malloc(" + calcMallocTemp.name + ");\n\t" +
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
          op = createTemp(BOOLEAN,$1.tempVar.name + " "+ $2.operation +" " + t.name);
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
        op = createTemp(BOOLEAN,$1.tempVar.name + " "+ $2.operation +" " + t.name);
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
    | PRIMITIVE;

  PRIMITIVE:
      VAR {
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
      if(exists($1.id)){
        $$.tempVar = getVar($1.id).tempVar;
        $$.token = getVar($1.id).token;
      }
    };
    | CONST {
      $$.id = $1.id;
      $$.isVar = false;
      if(exists($1.id)){
        $$.tempVar = getVar($1.id).tempVar;
        $$.token = getVar($1.id).token;
      }
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

string createFunctions(){
  string result = "";
  for(func f : functions){
    cout << f.name << endl;
    for(temp t : f.params){
      cout << "\t" << t.name << " " << checkType(t.token) << endl;
    }
    result += f.translation + "\n\t";
  }
  return result;
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
void outOfRange(string name, int ln, int col){
  cout << colorText("error:"+actualLine()+": ",hexToRGB(RED)) << colorText(name,hexToRGB(AQUA)) << "[" << ln << "," << col << "] is " << colorText("OUT",hexToRGB(RED)) << " of range." << endl;
  exit(1);
}

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
    case VOID: return "void";
    case MTX_INT: return "int*";
    case MTX_FLOAT: return "float*";
    case MTX_CHAR: return "char*";
    case MTX_STRING: return "char**";
    case MTX_BOOLEAN: return "int*";
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

bool existsOnScope(string varName){
  if(scopes.size() >= 1){
    scopeIterator = scopes.back().find(varName);
    return !(scopeIterator == scopes.back().end());
  }
  scopeIterator = globalScope.find(varName);
  return !(scopeIterator == globalScope.end());
}
