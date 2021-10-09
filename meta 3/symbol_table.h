#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H
#include "gocompiler.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
struct table_element * global_symtab;
struct table_element * save;
struct table_element * to_print;


typedef enum {globalDecl, varDecl, funcDecl, funcParam} typeDeclaration;

typedef struct table_element {
	typeDeclaration typeDecl;
	char * id;
	char * type;
	int line;
	int column;
	int used;
	struct table_element * funcVars; //=NULL; //if vardecl, funcVars=NULL;
	struct table_element * next;

} table_element;

void global();
struct table_element * createVarDecl(char * id, char * type, int line, int column);
struct table_element * createFuncParam(char * id, char * type, int line, int column);
struct table_element * addFuncDecl(char * id, char * type, int line, int column);
struct table_element * addTable(struct table_element * new_symbol, struct table_element * symtab);
void printTable(struct table_element * table);

void printSymbolTable();
void cleanTable(struct table_element * symtab);
int unusedElements();

#endif

