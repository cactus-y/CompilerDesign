/****************************************************/
/* File: tiny.y                                     */
/* The TINY Yacc/Bison specification file           */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/
%{
#define YYPARSER /* distinguishes Yacc output from other code files */

#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h"

#define YYSTYPE TreeNode *
static char * savedName; /* for use in assignments */
static int savedLineNo;  /* ditto */
static TreeNode * savedTree; /* stores syntax tree for later return */
static int yylex(void); // added 11/2/11 to ensure no conflict with lex

%}

/* precedence & associativity */
%nonassoc ELSE
%left PLUS MINUS
%left TIMES OVER
%right ASSIGN

%token IF THEN ELSE WHILE RETURN INT VOID
%token ID NUM 
%token ASSIGN EQ NE LT LE GT GE PLUS MINUS TIMES OVER LPAREN RPAREN LBRACE RBRACE LCURLY RCURLY SEMI COMMA
%token ERROR 

%% /* Grammar for C-Minus */

program
            : declaration_list
                  { savedTree = $1;} 
            ;
declaration_list
            : declaration_list declaration
                { YYSTYPE t = $1;
                  if (t != NULL) {
                    while (t -> sibling != NULL) t = t -> sibling;
                    t -> sibling = $2;
                    $$ = $1;
                  } else $$ = $2;
                }
            | declaration { $$ = $1 ;}
            ;
declaration
            : var_declaration { $$ = $1; }
            | fun_declaration { $$ = $1; }
            ;
var_declaration
            : type_specifier ID SEMI
                { $$ = newDeclNode(VarK);
                  $$ -> attr.name = copyString(tokenString);
                  $$ -> lineno = savedLineNo;
                  $$ -> type = $1 -> type;
                }
            | type_specifier ID LBRACE NUM RBRACE SEMI
                { $$ = newDeclNode(VarK);
                  $$ -> attr.name = copyString(tokenString);
                  $$ -> lineno = savedLineNo;
                  $$ -> type = $1 -> type;
                  $$ -> isArray = TRUE;
                  $$ -> child[0] = newExpNode(ConstK);
                  $$ -> child[0] -> attr.val = atoi(tokenString);
                }
            ;
type_specifier
            : INT { $$ = Integer; }
            | VOID { $$ = Void; }
            ;
fun_declaration
            : type_specifier ID LPAREN params RPAREN compound_stmt
                { $$ = newDeclNode(FuncK);
                  $$ -> attr.name = copyString(tokenString);
                  $$ -> lineno = savedLineNo;
                  $$ -> type = $1 -> type;
                  $$ -> child[0] = $4;
                  $$ -> child[1] = $6;
                }
            ;
params
            : param_list { $$ = $1; }
            | VOID { $$ = NULL; }
            ;
param_list
            : param_list COMMA param
                { YYSTYPE t = $1;
                  if (t != NULL) {
                    while (t -> sibling != NULL) t = t -> sibling;
                    t -> sibling = $3;
                    $$ = $1;
                  } else $$ = $3;
                }
            | param { $$ = $1; }
            ;
param
            : type_specifier ID 
                { $$ = newDeclNode(ParamK);
                  $$ -> attr.name = copyString(tokenString);
                  $$ -> lineno = savedLineNo;
                  $$ -> type = $1 -> type;
                }
            | type_specifier ID LBRACE RBRACE
                { $$ = newDeclNode(ParamK);
                  $$ -> attr.name = copyString(tokenString);
                  $$ -> lineno = savedLineNo;
                  $$ -> type = $1 -> type;
                  $$ -> isArray = TRUE;
                }
            ;
compound_stmt
            : LCURLY local_declrations statement_list RCURLY
                { $$ = newStmtNode(CompoundK);
                  $$ -> child[0] = $2;
                  $$ -> child[1] = $3;
                }
            ;
local_declrations
            : local_declrations var_declaration
                { YYSTYPE t = $1;
                  if (t != NULL) {
                    while (t -> sibling != NULL) t = t -> sibling;
                    t -> sibling = $2;
                    $$ = $1;
                  } else $$ = $2;
                }
            | { $$ = NULL; }
            ;
statement_list
            : statement_list statement
                { YYSTYPE t = $1;
                  if (t != NULL) {
                    while(t -> sibling != NULL) t = t -> sibling;
                    t -> sibling = $2;
                    $$ = $1;
                  } else $$ = $2;
                }
            | { $$ = NULL; }
            ;
statement
            : expression_stmt
            | compound_stmt
            | selection_stmt
            | iteration_stmt
            | return_stmt
            ;
expression_stmt
            : expression SEMI { $$ = $1; }
            | SEMI { $$ = NULL; }
            ;
selection_stmt
            : IF LPAREN expression RPAREN statement %prec ELSE
                { $$ = newStmtNode(IfK); 
                  $$ -> child[0] = $3;
                  $$ -> child[1] = $5;
                }
            | IF LPAREN expression RPAREN statement ELSE statement
                { $$ = newStmtNode(IfK);
                  $$ -> child[0] = $3;
                  $$ -> child[1] = $5;
                  $$ -> child[2] = $7;
                }
            ;
iteration_stmt
            : WHILE LPAREN expression RPAREN statement
                { $$ = newStmtNode(WhileK);
                  $$ -> child[0] = $3;
                  $$ -> child[1] = $5;
                }
            ;
return_stmt
            : RETURN SEMI
                { $$ = newStmtNode(ReturnK); }
            | RETURN expression SEMI
                { $$ = newStmtNode(ReturnK); 
                  $$ -> child[0] = $2;
                }
            ;
expression
            : var ASSIGN expression
                { $$ = newExpNode(AssignK);
                  $$ -> child[0] = $1;
                  $$ -> child[1] = $3;
                }
            | simple_expression { $$ = $1; }
            ;
var
            : ID
                { $$ = newExpNode(IdK);
                  $$ -> attr.name = copyString(tokenString);
                }
            | ID LBRACE expression RBRACE
                { $$ = newExpNode(IdK);
                  $$ -> attr.name = copyString(tokenString);
                  $$ -> child[0] = $3;
                }
            ;
simple_expression
            : additive_expression relop additive_expression
                { $$ = newExpNode(OpK);
                  $$ -> child[0] = $1;
                  $$ -> child[1] = $3;
                  $$ -> attr.op = $2;
                }
            | additive_expression { $$ = $1; }
            ;
relop
            : LE { $$ = LE; }
            | LT { $$ = LT; }
            | GT { $$ = GT; }
            | GE { $$ = GE; }
            | EQ { $$ = EQ; }
            | NE { $$ = NE; }
            ;
additive_expression
            : additive_expression addop term
                { $$ = newExpNode(OpK);
                  $$ -> child[0] = $1;
                  $$ -> child[1] = $3;
                  $$ -> attr.op = $2;
                }
            | term { $$ = $1; }
            ;
addop
            : PLUS { $$ = PLUS; }
            | MINUS { $$ = MINUS; }
            ;
term
            : term mulop factor
                { $$ = newExpNode(OpK);
                  $$ -> child[0] = $1;
                  $$ -> child[1] = $3;
                  $$ -> attr.op = $2;
                }
            | factor { $$ = $1; }
            ;
mulop
            : TIMES { $$ = TIMES; }
            | OVER { $$ = OVER; }
            ;
factor
            : LPAREN expression RPAREN { $$ = $2; }
            | var { $$ = $1; }
            | NUM
                { $$ = newExpNode(ConstK);
                  $$ -> attr.val = atoi(tokenString);
                }
            ;
call
            : ID LPAREN args RPAREN
                { $$ = newExpNode(CallK);
                  $$ -> attr.name = copyString(tokenString);
                  $$ -> child[0] = $3;
                }
            ;
args
            : arg_list { $$ = $1; }
            | { $$ = NULL; }
            ;
arg_list
            : arg_list COMMA expression
                { YYSTYPE t = $1;
                  if (t != NULL) {
                    while (t -> sibling != NULL) t = t -> sibling;
                    t -> sibling = $3;
                    $$ = $1;
                  } else $$ = $3;
                }
            | expression { $$ = $1; }
            ;

%%

int yyerror(char * message)
{ fprintf(listing,"Syntax error at line %d: %s\n",lineno,message);
  fprintf(listing,"Current token: ");
  printToken(yychar,tokenString);
  Error = TRUE;
  return 0;
}

/* yylex calls getToken to make Yacc/Bison output
 * compatible with ealier versions of the TINY scanner
 */
static int yylex(void)
{ return getToken(); }

TreeNode * parse(void)
{ yyparse();
  return savedTree;
}

