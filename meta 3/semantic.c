#include "semantic.h"
bool debug = true;


void checkRoot(struct node * node) {

	global();


	struct node * current;

	if(root==NULL || root->child==NULL){
		flag=-1;
		return;
	}

	current=root->child;

	while(current!=NULL){
		if (strcmp(current->tokenType, "FuncDecl") == 0) {
			checkFuncDecl(current, global_symtab);
		}

		if (strcmp(current->tokenType, "VarDecl") == 0) {
			checkVarDecl(current, global_symtab);
		}

	
		current=current->sibling;

	}

	
	
	
	//if(debug) printTable(global_symtab);
	
}

void checkVarDecl(struct node * node,struct table_element * symtab) {
	//printf("entrou em checkvardecl\n");
	struct node * current=node->child;

	char * type= (char*) malloc(strlen(current->tokenType)*sizeof(char*));
	strcpy(type, current->tokenType);
	*type = tolower(*type);

	current=current->sibling;

	char * id = (char*) malloc(strlen(current->tokenValue)*sizeof(char*));
	strcpy(id, current->tokenValue);
	struct node * error=current;
	struct table_element * aux= createVarDecl(id, type, current->line, current->column);
	struct table_element * check=  insertDecl(aux, symtab);
			bool done= false;
			if(check!=NULL) done=true;
	if(!done){
		printf("Line %d, column %d: Symbol %s already defined\n", error->line, error->column, error->tokenValue);
		flag=-1;
	}
	
	//printTable(symtab);
}


void checkFuncDecl(struct node * node,struct table_element * symtab) {
	//if(debug) printf("entrou em checkfuncdecl\n");
	struct node * current=node->child->child; //id
	// Func Decl -> func Header -> id,type,funcparams

	char * id = (char*) malloc(strlen(current->tokenValue)*sizeof(char*));
	char * type = (char*) malloc(strlen(current->tokenType)*sizeof(char*));

	strcpy(id, current->tokenValue);
	struct node * error= current;

	current= current->sibling; //caso type exista, current = type. caso nao exista, current = funcParams
	struct node * aux= current->sibling; //se current = funcParams, aux = NULL. se current = type, aux = funcParams

	if(aux !=NULL){
		strcpy(type, current->tokenType);
		*type = tolower(*type);

		current= aux; //se type existir, current = funcParams 
	}
	else{
		type="none"; 
	}
	
	
	struct table_element * funcdecl_symbol = addFuncDecl(id, type, current->line, current->column);
	//printf("sou burra");
	//if(debug)printTable(global_symtab);
	
	if(funcdecl_symbol==NULL){
	printf("Line %d, column %d: Symbol %s already defined\n", error->line, error->column, error->tokenValue);
	flag=-1;
	return;
	}
	
		

	char * var_id = (char*) malloc(strlen(current->tokenValue)*sizeof(char*));
	char * var_type = (char*) malloc(strlen(current->tokenType)*sizeof(char*));
	
	struct node * paramdecl= current->child;
	struct node * decl;
	

	while(paramdecl!=NULL){
		decl= paramdecl->child;
		strcpy(var_type, decl->tokenType);
		*var_type = tolower(*var_type);

		decl= decl->sibling;

		strcpy(var_id, decl->tokenValue);
		struct node * error= decl;
		struct table_element * aux;
		
		
		aux= createFuncParam(var_id, var_type, decl->line, decl->column);
		//free(var_type);
		
		struct table_element * check=  insertDecl(aux, funcdecl_symbol);
		
		if(check==NULL){
			printf("Line %d, column %d: Symbol %s already defined\n", error->line, error->column, error->tokenValue);
			flag=-1;
		}
		

		paramdecl=paramdecl->sibling;

	}

	struct node * body= node->child->sibling;
	current=body->child;

	while(current!=NULL){
		
		if(strcmp(current->tokenType, "VarDecl") == 0){
		//if(debug) printf("vardecl inside func\n");
			decl= current->child;
			
			strcpy(var_type, decl->tokenType);
			*var_type = tolower(*var_type);

			decl= decl->sibling;

			strcpy(var_id, decl->tokenValue);
			
			struct table_element * aux;
			aux= createVarDecl(var_id, var_type, decl->line, decl->column);
			
			
			
			struct table_element * check=  insertDecl(aux, funcdecl_symbol);
			
			if(check==NULL){
				printf("Line %d, column %d: Symbol %s already defined\n", decl->line, decl->column, decl->tokenValue);
				flag=-1;
			}
			
			

		}

		current=current->sibling;

	}
	
	free(var_type);

}


struct table_element * insertDecl(struct table_element * t, struct table_element * symbol){

	struct table_element * aux= global_symtab->funcVars;
	struct table_element * save= aux;
	/*
	if(symbol!=global_symtab){

		while(aux!=NULL){
			if(strcmp(aux->id, t->id) == 0) return NULL;
			aux=aux->next;
		}
	
	}
	*/
	
	aux= symbol->funcVars;

	
	if(aux==NULL){
		symbol->funcVars=t;
	}
	else{
		save=aux;
		while(aux!=NULL){
			if(strcmp(aux->id, t->id) == 0) return NULL;
			save=aux;
			aux=aux->next;
		}
		save->next=t;
		
		
	}
		

	return t;
	
}


struct table_element * searchElement(struct node * node,struct table_element * symtab) {
	table_element * save=NULL;

	table_element * current = symtab->funcVars;

	while (current != NULL) {
			
		if (strcmp(current->id, node->tokenValue) == 0){
			
			if(current->line > node->line) return save;
			if(current->line == node->line && current->column > node->column) return save;
			current->used+=1;
			//printf("new: %s %d\n",current->id, current->used);
			//printf("found inside function\n");
			save= current;
		}
		current = current->next;
	}
	
	
	return save;
}

struct table_element * searchElementCall(struct node * node) {

	table_element * current = global_symtab;

	while (current != NULL) {
		if (strcmp(current->id, node->tokenValue) == 0){
			//printf("checking for order in element\n");
			if(current->line > node->line) return NULL;
			if(current->line == node->line && current->column > node->column) return NULL;
			//printf("found it and it was in the right order\n");



			return current;
		}
		current = current->next;
	}

	//printf("did not find it\n");

	return NULL;
}

	









