/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

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

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    RPAREN = 258,                  /* RPAREN  */
    ELSE = 259,                    /* ELSE  */
    PLUS = 260,                    /* PLUS  */
    MINUS = 261,                   /* MINUS  */
    TIMES = 262,                   /* TIMES  */
    OVER = 263,                    /* OVER  */
    ASSIGN = 264,                  /* ASSIGN  */
    IF = 265,                      /* IF  */
    WHILE = 266,                   /* WHILE  */
    RETURN = 267,                  /* RETURN  */
    INT = 268,                     /* INT  */
    VOID = 269,                    /* VOID  */
    ID = 270,                      /* ID  */
    NUM = 271,                     /* NUM  */
    EQ = 272,                      /* EQ  */
    NE = 273,                      /* NE  */
    LT = 274,                      /* LT  */
    LE = 275,                      /* LE  */
    GT = 276,                      /* GT  */
    GE = 277,                      /* GE  */
    LPAREN = 278,                  /* LPAREN  */
    LBRACE = 279,                  /* LBRACE  */
    RBRACE = 280,                  /* RBRACE  */
    LCURLY = 281,                  /* LCURLY  */
    RCURLY = 282,                  /* RCURLY  */
    SEMI = 283,                    /* SEMI  */
    COMMA = 284,                   /* COMMA  */
    ERROR = 285                    /* ERROR  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif
/* Token kinds.  */
#define YYEMPTY -2
#define YYEOF 0
#define YYerror 256
#define YYUNDEF 257
#define RPAREN 258
#define ELSE 259
#define PLUS 260
#define MINUS 261
#define TIMES 262
#define OVER 263
#define ASSIGN 264
#define IF 265
#define WHILE 266
#define RETURN 267
#define INT 268
#define VOID 269
#define ID 270
#define NUM 271
#define EQ 272
#define NE 273
#define LT 274
#define LE 275
#define GT 276
#define GE 277
#define LPAREN 278
#define LBRACE 279
#define RBRACE 280
#define LCURLY 281
#define RCURLY 282
#define SEMI 283
#define COMMA 284
#define ERROR 285

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
