/****************************************************/
/* File: symtab.c                                   */
/* Symbol table implementation for the TINY compiler*/
/* (allows only one symbol table)                   */
/* Symbol table is implemented as a chained         */
/* hash table                                       */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

/* SIZE is the size of the hash table */
#define SIZE 211

/* SHIFT is the power of two used as multiplier
   in hash function  */
#define SHIFT 4

/* the hash function */
static int hash ( char * key )
{ int temp = 0;
  int i = 0;
  while (key[i] != '\0')
  { temp = ((temp << SHIFT) + key[i]) % SIZE;
    ++i;
  }
  return temp;
}

/* the list of line numbers of the source 
 * code in which a variable is referenced
 */
typedef struct LineListRec
   { int lineno;
     struct LineListRec * next;
   } * LineList;

/* The record in the bucket lists for
 * each variable, including name, 
 * assigned memory location, and
 * the list of line numbers in which
 * it appears in the source code
 */
typedef struct BucketListRec
   { char * symbolName;
     char * symbolKind;
     char * symbolType;
     LineList lines;
     int memloc ; /* memory location for variable */
     struct BucketListRec * next;
   } * BucketList;
   
/* Scope Tree's node */
typedef struct ScopeNode {
  char * scopeName;
  struct ScopeNode * parent;
  BucketList hashTable[SIZE];
} * ScopeNode;

/* create scope node */
ScopeNode createScope(char *scopeName, ScopeNode parent) {
  ScopeNode scope = (ScopeNode)malloc(sizeof(struct ScopeNode));
  scope -> scopeName = scopeName;
  scope -> parent = parent;
  for(int i = 0; i < SIZE; ++i) {
    scope -> hashTable[i] = NULL;
  }
  return scope;
}

/* start a new nested scope */
void insertScope(char *scopeName) {
  ScopeNode newScope = createScope(scopeName, currentScope);
  currentScope = newScope;
}

/* exit the current scope */
void exitScope() {
  if(currentScope != NULL) {
    currentScope = currentScope -> parent;
  }
}

ScopeNode globalScope = NULL;
ScopeNode currentScope = NULL;

/* the hash table */
// static BucketList hashTable[SIZE];

/* Procedure st_insert inserts line numbers and
 * memory locations into the symbol table
 * loc = memory location is inserted only the
 * first time, otherwise ignored
 */
void st_insert( char * symbolName, char * symbolKind, char * symbolType, int lineno, int loc )
{ int h = hash(symbolName);
  BucketList l =  currentScope -> hashTable[h];
  while ((l != NULL) && (strcmp(symbolName,l->symbolName) != 0))
    l = l->next;
  if (l == NULL) /* variable not yet in table */
  { l = (BucketList) malloc(sizeof(struct BucketListRec));
    l->symbolName = symbolName;
    l->symbolKind = symbolKind;
    l->symbolType = symbolType;
    l->lines = (LineList) malloc(sizeof(struct LineListRec));
    l->lines->lineno = lineno;
    l->lines->next = NULL;
    l->memloc = loc;
    l->next = currentScope -> hashTable[h];
    currentScope -> hashTable[h] = l; }
  else /* found in table, so just add line number */
  { LineList t = l->lines;
    while (t->next != NULL) t = t->next;
    t->next = (LineList) malloc(sizeof(struct LineListRec));
    t->next->lineno = lineno;
    t->next->next = NULL;
  }
} /* st_insert */

/* Function st_lookup returns the memory 
 * location of a variable or -1 if not found
 */
int st_lookup ( char * symbolName )
{ ScopeNode scope = currentScope;
  while(scope != NULL) {
    int h = hash(symbolName);
    BucketList l = scope -> hashTable[h];
    while(l != NULL) {
      if(strcmp(symbolName, l -> symbolName) == 0) {
        return l;
      }
      l = l -> next;
    }
    scope = scope -> parent;
  }
  return NULL;
}

/* Procedure printSymTab prints a formatted 
 * listing of the symbol table contents 
 * to the listing file
 */
void printSymTab(FILE * listing)
{ /* symbol kind, symbol type, scope name added to symbol table column */
  fprintf(listing," Symbol Name   Symbol Kind   Symbol Type    Scope Name   Location  Line Numbers\n");
  fprintf(listing,"-------------  -----------  -------------  ------------  --------  ------------\n");

  ScopeNode scope = globalScope;

  while(scope != NULL) {
    for(int i = 0; i < SIZE; ++i) {
      if(scope -> hashTable[i] != NULL) {
        BucketList l = scope -> hashTable[i];
        while(l != NULL) {
          LineList t = l -> lines;
          fprintf(listing, "%-14s %-12s %-13s %-12s %-8d  ", l -> symbolName, l -> symbolKind, l -> symbolType, scope -> scopeName, l -> memloc);
          while(t != NULL) {
            fprintf(listing, "%4d ", t -> lineno);
            t = t -> next;
          }
          fprintf(listing, "\n");
          l = l -> next;
        }
      }
    }
    scope = scope -> parent;
  }
} /* printSymTab */
