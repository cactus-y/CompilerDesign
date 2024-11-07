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
static int savedLineNo;  /* ditto */
static TreeNode * savedTree; /* stores syntax tree for later return */
static int yylex(void); // added 11/2/11 to ensure no conflict with lex

%}

/* precedence & associativity */
%nonassoc RPAREN
%nonassoc ELSE
%left PLUS MINUS
%left TIMES OVER
%right ASSIGN

%token IF WHILE RETURN INT VOID
%token ID NUM 
%token EQ NE LT LE GT GE LPAREN LBRACE RBRACE LCURLY RCURLY SEMI COMMA
%token ERROR 

%% /* Grammar for C-Minus */

program
            : declaration_list { savedTree = $1;} 
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
            : type_specifier identifier SEMI
                { $$ = newDeclNode(VarK);
                  $$ -> attr.name = $2 -> name;
                  $$ -> lineno = $2 -> lineno;
                  $$ -> type = $1 -> type;
                }
            | type_specifier identifier LBRACE number RBRACE SEMI
                { $$ = newDeclNode(VarK);
                  $$ -> attr.name = $2 -> name;
                  $$ -> lineno = $2 -> lineno;
                  if ($1 -> type == Integer) $$ -> type = IntegerArray;
                  else if ($1 -> type == Void) $$ -> type = VoidArray;
                  else $$ -> type = None;
                  $$ -> child[0] = $4;
                }
            ;
type_specifier
            : INT 
                { $$ = newParserNode(TypeK);
                  $$ -> lineno = lineno;
                  $$ -> type = Integer;
                }
            | VOID 
                { $$ = newParserNode(TypeK);
                  $$ -> lineno = lineno;
                  $$ -> type = Void;
                }
            ;
fun_declaration
            : type_specifier identifier LPAREN params RPAREN compound_stmt
                { $$ = newDeclNode(FuncK);
                  $$ -> attr.name = $2 -> name;
                  $$ -> lineno = $2 -> lineno;
                  if ($1 -> type == Integer) $$ -> type = Integer;
                  else if ($1 -> type == Void) $$ -> type = Void;
                  else $$ -> type = None;
                  $$ -> child[0] = $4;
                  $$ -> child[1] = $6;
                }
            ;
params
            : param_list { $$ = $1; }
            | VOID 
                { $$ = newDeclNode(ParamK);
                  $$ -> attr.flag = TRUE;
                }
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
            : type_specifier identifier 
                { $$ = newDeclNode(ParamK);
                  $$ -> attr.name = $2 -> name;
                  $$ -> lineno = $2 -> lineno;
                  $$ -> type = $1 -> type;
                }
            | type_specifier identifier LBRACE RBRACE
                { $$ = newDeclNode(ParamK);
                  $$ -> attr.name = $2 -> name;
                  $$ -> lineno = $2 -> lineno;
                  $$ -> type = $1 -> type;
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
            | empty { $$ = $1; }
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
            | empty { $$ = $1; }
            ;
statement
            : expression_stmt { $$ = $1; }
            | compound_stmt { $$ = $1; }
            | selection_stmt { $$ = $1; }
            | iteration_stmt { $$ = $1; }
            | return_stmt { $$ = $1; }
            ;
expression_stmt
            : expression SEMI { $$ = $1; }
            | SEMI { }
            ;
selection_stmt
            : IF LPAREN expression RPAREN statement ELSE statement
                { $$ = newStmtNode(IfK); 
                  $$ -> lineno = $3 -> lineno;
                  $$ -> attr.flag = TRUE;
                  $$ -> child[0] = $3;
                  $$ -> child[1] = $5;
                  $$ -> child[2] = $7;
                }
            | IF LPAREN expression RPAREN statement
                { $$ = newStmtNode(IfK);
                  $$ -> lineno = $3 -> lineno;
                  $$ -> child[0] = $3;
                  $$ -> child[1] = $5;
                }
            ;
iteration_stmt
            : WHILE LPAREN expression RPAREN statement
                { $$ = newStmtNode(WhileK);
                  $$ -> lineno = $3 -> lineno;
                  $$ -> child[0] = $3;
                  $$ -> child[1] = $5;
                }
            ;
return_stmt
            : RETURN SEMI
                { $$ = newStmtNode(ReturnK); 
                  $$ -> attr.flag = TRUE;
                }
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
            : identifier
                { $$ = newExpNode(VarAccessK);
                  $$ -> attr.name = $1 -> name;
                }
            | identifier LBRACE expression RBRACE
                { $$ = newExpNode(VarAccessK);
                  $$ -> attr.name = $1 -> name;
                  $$ -> child[0] = $3;
                }
            ;
simple_expression
            : additive_expression relop additive_expression
                { $$ = newExpNode(OpK);
                  $$ -> lineno = $2 -> lineno;
                  $$ -> child[0] = $1;
                  $$ -> child[1] = $3;
                  $$ -> attr.op = $2;
                }
            | additive_expression { $$ = $1; }
            ;
relop
            : LE 
                { $$ = newParserNode(OpcodeK);
                  $$ -> lineno = lineno;
                  $$ -> attr.op = LE;
                }
            | LT
                { $$ = newParserNode(OpcodeK);
                  $$ -> lineno = lineno;
                  $$ -> attr.op = LT;
                }
            | GT
                { $$ = newParserNode(OpcodeK);
                  $$ -> lineno = lineno;
                  $$ -> attr.op = GT;
                }
            | GE
                { $$ = newParserNode(OpcodeK);
                  $$ -> lineno = lineno;
                  $$ -> attr.op = GE;
                }
            | EQ
                { $$ = newParserNode(OpcodeK);
                  $$ -> lineno = lineno;
                  $$ -> attr.op = EQ;
                }
            | NE
                { $$ = newParserNode(OpcodeK);
                  $$ -> lineno = lineno;
                  $$ -> attr.op = NE;
                }
            ;
additive_expression
            : additive_expression addop term
                { YYSTYPE t = newExpNode(OpK);
                  $$ -> attr.op = $2;
                  if (t != NULL) {
                    $$ -> child[0] = $1;
                    $$ -> child[1] = $3;
                    $$ = t;
                  } else { $$ = $2; }
                }
            | term { $$ = $1; }
            ;
addop
            : PLUS 
                { $$ = newParserNode(OpcodeK);
                  $$ -> lineno = lineno;
                  $$ -> attr.op = PLUS;
                }
            | MINUS
                { $$ = newParserNode(OpcodeK);
                  $$ -> lineno = lineno;
                  $$ -> attr.op = MINUS;
                }
            ;
term
            : term mulop factor
                { YYSTYPE t = newExpNode(OpK);
                  $$ -> attr.op = $2;
                  if (t != NULL) {
                    $$ -> child[0] = $1;
                    $$ -> child[1] = $3;
                    $$ = t;
                  } else { $$ = $2; }
                }
            | factor { $$ = $1; }
            ;
mulop
            : TIMES
                { $$ = newParserNode(OpcodeK);
                  $$ -> lineno = lineno;
                  $$ -> attr.op = TIMES;
                }
            | OVER
                { $$ = newParserNode(OpcodeK);
                  $$ -> lineno = lineno;
                  $$ -> attr.op = OVER;
                }
            ;
factor
            : LPAREN expression RPAREN { $$ -> name = $2 -> name; }
            | var { $$ = $1; }
            | call { $$ = $1; }
            | number { $$ = $1; }
            ;
call
            : identifier LPAREN args RPAREN
                { $$ = newExpNode(CallK);
                  $$ -> attr.name = $1 -> name;
                  $$ -> child[0] = $3;
                }
            ;
args
            : arg_list { $$ = $1; }
            | empty { $$ = $1; }
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
identifier
            : ID
                { $$ = newParserNode(IdK);
                  $$ -> lineno = lineno;
                  $$ -> attr.name = copyString(tokenString);
                }
            ;
number
            : NUM
                { $$ = newExpNode(ConstK);
                  $$ -> lineno = lineno;
                  $$ -> attr.val = atoi(tokenString);
                }
            ;
empty
            : { $$ = NULL; }
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

