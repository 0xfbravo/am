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
    R_RETURN = 265,
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
    R_DOLLAR = 281,
    MTX_INT = 282,
    MTX_FLOAT = 283,
    MTX_BOOLEAN = 284,
    MTX_CHAR = 285,
    MTX_STRING = 286,
    INTEGER = 287,
    FLOAT = 288,
    BOOLEAN = 289,
    CHARACTER = 290,
    STRING = 291,
    R_VOID = 292,
    ARITHMETIC_1 = 293,
    ARITHMETIC_2 = 294,
    BOOLEAN_LOGIC = 295,
    EQUALITY_TEST = 296,
    ORDER_RELATION = 297,
    ASSIGNMENT = 298,
    NOT = 299,
    COLON = 300,
    QUESTION = 301,
    COMMA = 302,
    VAR = 303,
    CONST = 304,
    EXPLICIT_TYPE = 305,
    END_LINE = 306
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
#define R_RETURN 265
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
#define R_DOLLAR 281
#define MTX_INT 282
#define MTX_FLOAT 283
#define MTX_BOOLEAN 284
#define MTX_CHAR 285
#define MTX_STRING 286
#define INTEGER 287
#define FLOAT 288
#define BOOLEAN 289
#define CHARACTER 290
#define STRING 291
#define R_VOID 292
#define ARITHMETIC_1 293
#define ARITHMETIC_2 294
#define BOOLEAN_LOGIC 295
#define EQUALITY_TEST 296
#define ORDER_RELATION 297
#define ASSIGNMENT 298
#define NOT 299
#define COLON 300
#define QUESTION 301
#define COMMA 302
#define VAR 303
#define CONST 304
#define EXPLICIT_TYPE 305
#define END_LINE 306

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
