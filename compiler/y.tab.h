/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    BLOCK_INIT = 258,
    BLOCK_END = 259,
    SEMI_COLON = 260,
    MATRIX_INIT = 261,
    MATRIX_END = 262,
    R_UP = 263,
    R_UM = 264,
    RETURN = 265,
    R_IF = 266,
    R_ELSE = 267,
    R_WHILE = 268,
    R_DO = 269,
    R_FOR = 270,
    R_SWITCH = 271,
    R_CASE = 272,
    R_DEFAULT = 273,
    R_BREAK = 274,
    R_CONTINUE = 275,
    R_IN = 276,
    R_OUT = 277,
    R_IS = 278,
    R_DOT = 279,
    R_OF = 280,
    MTX_INT = 281,
    MTX_FLOAT = 282,
    MTX_BOOLEAN = 283,
    MTX_CHAR = 284,
    MTX_STRING = 285,
    INTEGER = 286,
    FLOAT = 287,
    BOOLEAN = 288,
    CHARACTER = 289,
    STRING = 290,
    VOID = 291,
    ARITHMETIC_1 = 292,
    ARITHMETIC_2 = 293,
    BOOLEAN_LOGIC = 294,
    EQUALITY_TEST = 295,
    ORDER_RELATION = 296,
    ASSIGNMENT = 297,
    NOT = 298,
    COLON = 299,
    QUESTION = 300,
    COMMA = 301,
    VAR = 302,
    CONST = 303,
    EXPLICIT_TYPE = 304,
    END_LINE = 305
  };
#endif
/* Tokens.  */
#define BLOCK_INIT 258
#define BLOCK_END 259
#define SEMI_COLON 260
#define MATRIX_INIT 261
#define MATRIX_END 262
#define R_UP 263
#define R_UM 264
#define RETURN 265
#define R_IF 266
#define R_ELSE 267
#define R_WHILE 268
#define R_DO 269
#define R_FOR 270
#define R_SWITCH 271
#define R_CASE 272
#define R_DEFAULT 273
#define R_BREAK 274
#define R_CONTINUE 275
#define R_IN 276
#define R_OUT 277
#define R_IS 278
#define R_DOT 279
#define R_OF 280
#define MTX_INT 281
#define MTX_FLOAT 282
#define MTX_BOOLEAN 283
#define MTX_CHAR 284
#define MTX_STRING 285
#define INTEGER 286
#define FLOAT 287
#define BOOLEAN 288
#define CHARACTER 289
#define STRING 290
#define VOID 291
#define ARITHMETIC_1 292
#define ARITHMETIC_2 293
#define BOOLEAN_LOGIC 294
#define EQUALITY_TEST 295
#define ORDER_RELATION 296
#define ASSIGNMENT 297
#define NOT 298
#define COLON 299
#define QUESTION 300
#define COMMA 301
#define VAR 302
#define CONST 303
#define EXPLICIT_TYPE 304
#define END_LINE 305

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
