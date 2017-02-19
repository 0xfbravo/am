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
    R_UP = 261,
    R_UM = 262,
    R_IF = 263,
    R_ELSE = 264,
    R_WHILE = 265,
    R_DO = 266,
    R_FOR = 267,
    R_SWITCH = 268,
    R_CASE = 269,
    R_DEFAULT = 270,
    R_BREAK = 271,
    R_CONTINUE = 272,
    R_IN = 273,
    R_OUT = 274,
    R_IS = 275,
    R_DOT = 276,
    INTEGER = 277,
    FLOAT = 278,
    BOOLEAN = 279,
    CHARACTER = 280,
    STRING = 281,
    ARITHMETIC_1 = 282,
    ARITHMETIC_2 = 283,
    BOOLEAN_LOGIC = 284,
    EQUALITY_TEST = 285,
    ORDER_RELATION = 286,
    ASSIGNMENT = 287,
    NOT = 288,
    COLON = 289,
    QUESTION = 290,
    COMMA = 291,
    VAR = 292,
    CONST = 293,
    EXPLICIT_TYPE = 294,
    END_LINE = 295
  };
#endif
/* Tokens.  */
#define BLOCK_INIT 258
#define BLOCK_END 259
#define SEMI_COLON 260
#define R_UP 261
#define R_UM 262
#define R_IF 263
#define R_ELSE 264
#define R_WHILE 265
#define R_DO 266
#define R_FOR 267
#define R_SWITCH 268
#define R_CASE 269
#define R_DEFAULT 270
#define R_BREAK 271
#define R_CONTINUE 272
#define R_IN 273
#define R_OUT 274
#define R_IS 275
#define R_DOT 276
#define INTEGER 277
#define FLOAT 278
#define BOOLEAN 279
#define CHARACTER 280
#define STRING 281
#define ARITHMETIC_1 282
#define ARITHMETIC_2 283
#define BOOLEAN_LOGIC 284
#define EQUALITY_TEST 285
#define ORDER_RELATION 286
#define ASSIGNMENT 287
#define NOT 288
#define COLON 289
#define QUESTION 290
#define COMMA 291
#define VAR 292
#define CONST 293
#define EXPLICIT_TYPE 294
#define END_LINE 295

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
