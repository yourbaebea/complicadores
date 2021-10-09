#ifndef  GOCOMPILER_H
#define GOCOMPILER_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "semantic.h"
#include "symbol_table.h"

extern struct table_element * global_symtab;

struct node * createNode (char* tokenType, char* tokenValue, int line, int column);
void addChild (struct node * parent, struct node * child);
void addSibling (struct node * child, struct node * sibling);
int addChildFirst(struct node * parent, struct node * type);
void printTree(int height, struct node* root);
void cleanTree(struct node* current);
int check(struct node * first, struct node * second);

void annotateTree(struct node * node, struct table_element * symtab);
void annotateNode(struct node * node, char * annotation);
void printAnnotedTree(int height, struct node * root);
void printFuncHeader(int height, struct node* current);
void printVarDecl(int height, struct node* current);


struct node * root;

typedef struct node {
	struct node * sibling;
	struct node * child;
	char * tokenType;
	char * tokenValue;
	int line;
	int column;
	char * annotation;
} node;

#endif
