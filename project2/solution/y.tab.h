/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

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

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     ID = 258,
     INTV = 259,
     FLOATV = 260,
     ASSIGN = 261,
     yEQ = 262,
     yNE = 263,
     yLT = 264,
     yLE = 265,
     yGT = 266,
     yGE = 267,
     PLUS = 268,
     MINUS = 269,
     TIMES = 270,
     OVER = 271,
     DOVER = 272,
     MOD = 273,
     SEMI = 274,
     COMMA = 275,
     LBRACE = 276,
     RBRACE = 277,
     LMIDB = 278,
     RMIDB = 279,
     LPAREN = 280,
     RPAREN = 281,
     ADD = 282
   };
#endif
/* Tokens.  */
#define ID 258
#define INTV 259
#define FLOATV 260
#define ASSIGN 261
#define yEQ 262
#define yNE 263
#define yLT 264
#define yLE 265
#define yGT 266
#define yGE 267
#define PLUS 268
#define MINUS 269
#define TIMES 270
#define OVER 271
#define DOVER 272
#define MOD 273
#define SEMI 274
#define COMMA 275
#define LBRACE 276
#define RBRACE 277
#define LMIDB 278
#define RMIDB 279
#define LPAREN 280
#define RPAREN 281
#define ADD 282




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;


int yyparse (void);
void yy_input_string(char* str);

