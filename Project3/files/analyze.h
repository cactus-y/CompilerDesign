/****************************************************/
/* File: analyze.h                                  */
/* Semantic analyzer interface for TINY compiler    */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#ifndef _ANALYZE_H_
#define _ANALYZE_H_

/* Error types for symbol table
 * Will be used for switch-case in error printing function
 */
typedef enum 
{ UndeclaredFunc, UndeclaredVar, RedefinedSymbol, DeclaredVoidVar,
  IndexNotInteger, IndexingOnlyForArray, 
  InvalidFuncCall, InvalidOp, InvalidAssign, InvalidCond, InvalidReturn
} ErrorKind;

/* Function buildSymtab constructs the symbol 
 * table by preorder traversal of the syntax tree
 */
void buildSymtab(TreeNode *);

/* Procedure typeCheck performs type checking 
 * by a postorder syntax tree traversal
 */
void typeCheck(TreeNode *);

#endif
