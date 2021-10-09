#include "symbol_table.h"

void global(){
	global_symtab= (struct table_element*)malloc(sizeof(struct table_element));

	global_symtab->typeDecl = globalDecl;
	global_symtab->id= "";
	global_symtab->type="none";
	global_symtab->next = NULL;
	global_symtab->funcVars=NULL;

}

struct table_element * createVarDecl(char * id, char * type, int line, int column) {
	
	table_element * current = (struct table_element*)malloc(sizeof(struct table_element));

	current->typeDecl = varDecl;

	current->id = (char*)malloc(strlen(id)*sizeof(char));
	strcpy(current->id, id);

	current->next = NULL;
	current->funcVars=NULL;

	current->type = (char*)malloc(strlen(type)*sizeof(char));
	strcpy(current->type, type);

	current->line=line;
	current->column=column;
	current->used=0;
	

	return current;
}

struct table_element * createFuncParam(char * id, char * type, int line, int column) {
	
	struct table_element * current = (table_element*)malloc(sizeof(table_element));

	current->typeDecl = funcParam;

	current->id = (char*)malloc(strlen(id)*sizeof(char));
	strcpy(current->id, id);

	current->next = NULL;
	current->funcVars=NULL;


	current->type = (char*)malloc(strlen(type)*sizeof(char));
	strcpy(current->type, type);

	current->line=line;
	current->column=column;
	current->used=0;
	
	return current;

}




struct table_element * addFuncDecl(char * id, char * type, int line, int column) {

	struct table_element * current = (struct table_element*)malloc(sizeof(struct table_element));

	current->typeDecl = funcDecl;

	current->id = (char*)malloc(strlen(id)*sizeof(char));
	strcpy(current->id, id);

	current->next = NULL;
	current->funcVars=NULL;


	current->type = (char*)malloc(strlen(type)*sizeof(char));
	strcpy(current->type, type);

	current->line=line;
	current->column=column;
	
	struct table_element * aux= global_symtab->funcVars;
	
	while(aux!=NULL){
		if(strcmp(aux->id, current->id) == 0) return NULL;
		aux=aux->next;
	}
	

	return addTable(current, global_symtab);
}


//all fixed here!!!
struct table_element * addTable(struct table_element * element, struct table_element * symtab) {

	if(symtab==NULL){
		symtab=element;
		return element;
	}
	
	table_element * current = symtab;

	while(current!=NULL){
	
		if(current->typeDecl!=globalDecl)
			if(strcmp(current->id, element->id) == 0) return NULL;
		
		if(current->next==NULL){
			current->next= element;
			return element;
		}

		current= current->next;
	}

	return NULL;

}



int unusedElements() {
	int error=0;
	//printf("checking if any var is unused!!!\n");

	struct table_element * current = global_symtab->next;
	struct table_element * vars;

	while (current != NULL) {

		vars= current->funcVars;
		while(vars!=NULL){
			if(vars->used<=1&&vars->typeDecl==varDecl){
				error=-1;
				printf("Line %d, column %d: Symbol %s declared but never used\n", vars->line, vars->column, vars->id);	
			}

			vars=vars->next;
		}

		current=current->next;
	}

	//printf("done checking used vars\n");
	return error;

}




void printTable(struct table_element * table){

	if(table==NULL){
	printf("is empty wtf");
	return;
	}

	printf("===== table =====\n");
	printf("\t id %s\t type %s \t typedecl %d\n", table->id,table->type, table->typeDecl);
	struct table_element * current=table->funcVars;
	printf("===== func vars =====\n");
	while(current!=NULL){
		printf("\t id %s\t type %s \t typedecl %d\n", current->id,current->type, current->typeDecl);
		current=current->next;
	}

	printf("\n\n");

	if(table->next!=NULL){
		printf("existe next!");
		printTable(table->next);
	}

}


/*


O formato das linhas é “Nament[ParamTypes]ntType[ntparam]”, onde [] significa opcional.
===== Global Symbol Table =====
factorial ( int) int
main () none
===== Function factorial ( int ) Symbol Table =====
return int
n int param
===== Function main () Symbol Table =====
return none
argument int
*/


void printDecl(struct table_element * current){
	while(current!=NULL){
		if(current->typeDecl==varDecl) printf("%s\t\t%s\n", current->id, current->type);
		if(current->typeDecl==funcParam) printf("%s\t\t%s\tparam\n", current->id, current->type);

		current= current->next;
		
	}
	//printf("saiu do ciclo");
	
	
	
/*
	if(current!=NULL){
		switch(current->typeDecl){
			case varDecl: printf("%s\t\t%s\n", current->id, current->type); break;
			case funcParam: printf("%s\t\t%s\tparam\n", current->id, current->type); break;			
			default: return;
		}

		current=current->next;

	}
	*/

}

void printFunction(struct table_element * current){

	table_element * params= current->funcVars;
	printf("===== Function %s(", current->id);

	if(params!=NULL && params->typeDecl==funcParam){
		printf("%s", params->type);
		params=params->next;
	}

	while(params!=NULL && params->typeDecl==funcParam){
		printf(",%s", params->type);
		params=params->next;
	}
	printf(") Symbol Table =====\n");


	printf("return\t\t%s\n", current->type);

	printDecl(current->funcVars);


}

void printSymbolTable() {


	printf("===== Global Symbol Table =====\n");


	printDecl(global_symtab->funcVars);

	struct table_element * current = global_symtab->next;

	while(current!=NULL){

		table_element * params= current->funcVars;
		printf("%s\t(", current->id);

		if(params!=NULL && params->typeDecl==funcParam){
			printf("%s", params->type);
			params=params->next;
		}

		while(params!=NULL && params->typeDecl==funcParam){
			printf(",%s", params->type);
			params=params->next;
		}
		printf(")\t%s\n", current->type);

		current=current->next;

	}
	printf("\n");

	current = global_symtab->next;
	while(current!=NULL){
		printFunction(current);
	        current=current->next;
	        printf("\n");
	}

}
	
	

void cleanTable(struct table_element * symtab){
    if (symtab == NULL) return;
    if (symtab->next != NULL) cleanTable(symtab->next);
	if (symtab->id != NULL) free(symtab->id);
    if (symtab->type != NULL) free(symtab->type);
	if (symtab->funcVars != NULL) cleanTable(symtab->funcVars);
    free(symtab);
}
