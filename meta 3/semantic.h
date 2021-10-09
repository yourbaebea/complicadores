#ifndef  SEMANTIC_H
#define SEMANTIC_H

#include "symbol_table.h"
#include "gocompiler.h"
#include <stdio.h>
#include <ctype.h>

extern struct node * root;
extern struct table_element * global_symtab;
extern int flag;

void checkRoot(struct node * node);
void checkFuncDecl(struct node * node, struct table_element * symtab);
void checkVarDecl(struct node * node, struct table_element * symtab);
struct table_element * insertDecl(struct table_element * aux, struct table_element * symbol);
struct table_element * searchElement(struct node * node, struct table_element * symtab);
struct table_element * searchElementCall(struct node * node);


#endif
