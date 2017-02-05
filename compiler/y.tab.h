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
    R_IF = 261,
    R_ELSE = 262,
    R_WHILE = 263,
    R_DO = 264,
    R_FOR = 265,
    R_SWITCH = 266,
    R_CASE = 267,
    R_BREAK = 268,
    R_CONTINUE = 269,
    R_IN = 270,
    R_OUT = 271,
    R_IS = 272,
    R_DOT = 273,
    INTEGER = 274,
    FLOAT = 275,
    BOOLEAN = 276,
    CHARACTER = 277,
    STRING = 278,
    ARITHMETIC_1 = 279,
    ARITHMETIC_2 = 280,
    BOOLEAN_LOGIC = 281,
    EQUALITY_TEST = 282,
    ORDER_RELATION = 283,
    ASSIGNMENT = 284,
    NOT = 285,
    COLON = 286,
    QUESTION = 287,
    COMMA = 288,
    VAR = 289,
    CONST = 290,
    EXPLICIT_TYPE = 291,
    END_LINE = 292
  };
#endif
/* Tokens.  */
#define BLOCK_INIT 258
#define BLOCK_END 259
#define SEMI_COLON 260
#define R_IF 261
#define R_ELSE 262
#define R_WHILE 263
#define R_DO 264
#define R_FOR 265
#define R_SWITCH 266
#define R_CASE 267
#define R_BREAK 268
#define R_CONTINUE 269
#define R_IN 270
#define R_OUT 271
#define R_IS 272
#define R_DOT 273
#define INTEGER 274
#define FLOAT 275
#define BOOLEAN 276
#define CHARACTER 277
#define STRING 278
#define ARITHMETIC_1 279
#define ARITHMETIC_2 280
#define BOOLEAN_LOGIC 281
#define EQUALITY_TEST 282
#define ORDER_RELATION 283
#define ASSIGNMENT 284
#define NOT 285
#define COLON 286
#define QUESTION 287
#define COMMA 288
#define VAR 289
#define CONST 290
#define EXPLICIT_TYPE 291
#define END_LINE 292

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
