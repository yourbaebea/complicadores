#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "gocompiler.h"
//#include "semantic.h"
//#include "symbol_table.h"
table_element * insideFunction;
extern int flag;

void printfuncHeader(int height, struct node* current);

struct node * createNode (char* tokenType, char* tokenValue, int line, int column) {
	
	struct node * newNode = (struct node *)malloc(sizeof(struct node));
	newNode->child = NULL;
	newNode->sibling = NULL;
    newNode->tokenType = tokenType;
	newNode->tokenValue = tokenValue;
	newNode->line=line;
	newNode->column=column;
	newNode->annotation="";
	return newNode;

}

void addChild (struct node * parent, struct node * child) {
	if (parent == NULL || child == NULL) return;

    if (parent->child == NULL){
        parent->child = child;
    }
    else addSibling(parent->child, child);
}

void addSibling(struct node * child, struct node * sibling) {
    if (sibling == NULL)return;
    if(child == NULL){
    	child= sibling;
    	return;
    }
	struct node * current = child;


	if (current->sibling == NULL){
        current->sibling = sibling;
    }
    else{
		while (current != NULL && current->sibling != NULL) {
			current = current->sibling;
		}
		current->sibling = sibling;
	}

}

int addChildFirst(struct node * parent, struct node * type) {
	////printf("antes\n");
	//printTree(0,parent);
	
	struct node * p= parent;
	int i=0;
    while (p != NULL) {
    		struct node * aux = p->child;
    		p->child=NULL;
    		addChild(p, createNode(type->tokenType, "",type->line, type->column));
    		addChild(p, aux);
    		p= p->sibling;
    		i=i+1;
	}
	
	////printf("\n\ndepois\n");
	//printTree(0,parent);
	return i;

}

int check(struct node * first, struct node * second){
	int count = 0;
	if(first==NULL) return count;
	count=count +1;
	if(second!=NULL) count= count +1;
	if(first->sibling!=NULL) count= count+1;
	
	return count;

}


void printTree(int height, struct node* root){
    if (root == NULL) return;
    struct node * current = (struct node *) malloc(sizeof(struct node));
    current = root;
    for (int i = 0; i < height; i++){
    	printf("..");
    }
	if( strcmp(current->tokenType, "Id") != 0 && strcmp(current->tokenType, "IntLit") != 0 && strcmp(current->tokenType, "RealLit") != 0 && strcmp(current->tokenType, "StrLit") != 0){
		printf("%s\n", current->tokenType);	
	}
	else{
		printf("%s(%s)\n", current->tokenType, current->tokenValue);
	}

/*
    if (strcmp(current->tokenValue, "") == 0){
    	//printf("%s\n", current->tokenType);
    }
    else {
    	//printf("%s(%s)\n", current->tokenType, current->tokenValue);
    }

	*/
    printTree(height + 1, current->child);
    printTree(height, current->sibling);
}

void cleanTree(struct node* current){
    if (current == NULL) return;

    if (current->child != NULL) cleanTree(current->child);
    if (current->sibling != NULL) cleanTree(current->sibling);
    if (current->tokenType != NULL) free(current->tokenType);
    if (current->tokenValue != NULL) free(current->tokenValue);
    free(current);
   
}



/*****************************META 3******************************/

bool checkParams(char * args, struct table_element * symbol){
		if (symbol == NULL) return false;

		char * auxargs = (char*)malloc(500*sizeof(char));
		table_element * params = symbol->funcVars;
		strcat(auxargs, "(");

		while(params!=NULL && params->typeDecl==funcParam){
			strcat(auxargs, params->type);
			strcat(auxargs,",");
			params=params->next;
		}


		//remove the last comma
		int size = strlen(auxargs);
		if(auxargs[size-1]==',') auxargs[size-1] = '\0';
		strcat(auxargs, ")");
		
		//printf("dentro do checkparams %s from outside%s\n", auxargs, args);

		if (strcmp(auxargs, args) != 0) return false;


		return true;
	
}



struct table_element * handleId(struct node * node, struct table_element * symtab, bool call){
	struct table_element * symbol;

	if(symtab==NULL){
		//printf("%s HANDLE ID: symtab null\n", node->tokenValue);
		return NULL;
	}
	
	if(call){
		symbol= searchElementCall(node);

		struct node * aux= node->sibling;

		char * args = (char*)malloc(500*sizeof(char));
		strcat(args, "(");
		while(aux!=NULL){
			
			annotateTree(aux, symtab);
			if(strcmp(aux->annotation,"")==0) strcat(args, "none");
			strcat(args, aux->annotation);
			strcat(args, ",");
			aux=aux->sibling;
		}

		//remove the last comma
		int size = strlen(args);
		if(args[size-1]==',') args[size-1] = '\0';
		strcat(args, ")");

		if(!checkParams(args, symbol)){
			flag = -1;
			printf("Line %d, column %d: Cannot find symbol %s%s\n", node->line, node->column, node->tokenValue, args);
			annotateNode(node, "undef");
			return NULL;
		}


		if(symbol->line >= node->line && symbol->column >= node->column ){
			//printf("CHAMADA DA FUNCAO ANTES DA FUNCAO DEU MERDA\n");
			flag = -1;
			printf("Line %d, column %d: Cannot find symbol %s%s\n", node->line, node->column, node->tokenValue, args);
			annotateNode(node, "undef");
			return NULL;
		}

		annotateNode(node, args);
		return symbol;

	}

	else{
		
		symbol= searchElement(node, symtab);
		//printf("searched %s\n", symtab->id);
		//if(symtab != global_symtab) printf("handle id working\n");
		if(symbol==NULL){
		symbol = searchElement(node, global_symtab);
		//printf("searched %s\n", symtab->id);
		}
	
	}

	if(symbol==NULL){
		flag = -1;
		printf("Line %d, column %d: Cannot find symbol %s\n", node->line, node->column, node->tokenValue);
		annotateNode(node, "undef");
		return NULL;
	}

	annotateNode(node, symbol->type);
	return symbol;

}



void handleFuncHeader(struct node * node, struct table_element * symtab){
		
	struct node * firstChild= node->child;	
	struct table_element * symbol = searchElementCall(firstChild);
	struct node * aux= firstChild->sibling;
	if(strcmp(aux->tokenType,"FuncParams")!=0) aux= aux->sibling;
	aux=aux->child;
	
	//printf("chegou aqui %s\n", firstChild->tokenValue);
	if(aux==NULL){
		//printf("1chegou aqui %s\n", firstChild->tokenValue);
		if(!checkParams("()", symbol)){
			//printf("2echegou aqui %s\n", firstChild->tokenValue);
			flag = -1;

			//printf("Line %d, column %d: Cannot find symbol %s()\n", firstChild->line, firstChild->column, firstChild->tokenValue);
			annotateNode(node, "undef");
			insideFunction=global_symtab;
			return;
		}
		else{
			//printf("2chegou aqui %s\n", firstChild->tokenValue);
			//annotateNode(firstChild, symbol->type);
			insideFunction=symbol;
			return;
		}

	}
	//printf("3chegou aqui %s\n", firstChild->tokenValue);
	
	struct node * param=aux->child;
	char * args = (char*)malloc(500*sizeof(char));
	strcat(args, "(");
	//printf("4chegou aqui %s\n", firstChild->tokenValue);
	
	char * type = (char*) malloc(strlen(param->tokenType)*sizeof(char*));
	
	while(aux!=NULL){
		param=aux->child;
	
		strcpy(type, param->tokenType);
		*type = tolower(*type);
		//printf("here: %s->%s\n",param->tokenType, param->annotation);	
		
		if(strcmp(type,"")==0) strcat(args, "none");
		strcat(args, type);

		strcat(args, ",");
		aux=aux->sibling;
	}
	//printf("5chegou aqui %s\n", firstChild->tokenValue);

	//remove the last comma
	int size = strlen(args);
	if(args[size-1]==',') args[size-1] = '\0';
	strcat(args, ")");

	if(!checkParams(args, symbol)){
		//printf("6echegou aqui %s\n", firstChild->tokenValue);
		flag = -1;
		//printf("Line %d, column %d: Cannot find symbol %s%s\n", firstChild->line, firstChild->column, firstChild->tokenValue, args);
		annotateNode(node, "undef");
		insideFunction=global_symtab;
		return;
	}
	
	//printf("6chegou aqui %s\n", firstChild->tokenValue);
	
	
	annotateNode(firstChild, symbol->type);
	insideFunction=symbol;
	//printf("chegou aqui %s\n", firstChild->tokenValue);
		
}

void handleIf(struct node * node, struct table_element * symtab){
	struct node * firstChild= node->child;
	
	struct node * aux= firstChild->sibling;

	annotateTree(firstChild, symtab);

	if (strcmp(firstChild->annotation, "bool") != 0) {
		flag = -1;
		printf("Line %d, column %d: Incompatible type %s in if statement\n", node->line, node->column, firstChild->annotation);
		annotateNode(node, "undef");
	}

	while(aux){
		annotateTree(aux, symtab);
		aux=aux->sibling;

	}
	
}

void handleFor(struct node * node, struct table_element * symtab){
	struct node * firstChild= node->child;
	struct node * aux= firstChild;
	
	if(strcmp(firstChild->tokenType,"Block")!=0){
		annotateTree(firstChild, symtab);

		if (strcmp(firstChild->annotation, "bool") != 0) {
			flag = -1;
			printf("Line %d, column %d: Incompatible type %s in for statement\n", node->line, node->column, firstChild->annotation);
			annotateNode(node, "undef");
		}
		
		aux=aux->sibling;
	
	}
	

	while(aux!=NULL){
		annotateTree(aux, symtab);
		aux=aux->sibling;

	}
	
}








void handleReturn(struct node * node, struct table_element * symtab){
	struct node * firstChild= node->child;
	char * type= (char*)malloc(100*sizeof(char));
	
	if(firstChild!=NULL){
		annotateTree(firstChild, symtab);
		type=firstChild->annotation;

	}
	else{
		type="none";
	}
		

	if (strcmp(type, symtab->type) != 0) {
		flag = -1;
		printf("Line %d, column %d: Incompatible type %s in return statement\n", node->line, node->column, type);
	}

}

void handleAssign(struct node * node, struct table_element * symtab){
	struct node * firstChild= node->child;
	struct node * secondChild;
	if(firstChild!=NULL) secondChild= node->child->sibling;
	else secondChild = NULL;

	annotateTree(firstChild, symtab);
	if (secondChild) annotateTree(secondChild, symtab);
	
	
	if(strcmp(firstChild->annotation,"undef")==0){
		flag = -1;
		printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", node->line, node->column, node->tokenValue, firstChild->annotation, secondChild->annotation);
		annotateNode(node, "undef");
		return;
				
	}
	
	
	
	
	if (strcmp(firstChild->annotation, secondChild->annotation) != 0) {
		flag = -1;
		printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", node->line, node->column, node->tokenValue, firstChild->annotation, secondChild->annotation);
		annotateNode(node, "undef");
		//printf("operator assign: %s\n", node->tokenType);
	}
	else {
		annotateNode(node, firstChild->annotation);
	}
}


void handleOperation(struct node * node, struct table_element * symtab){
	struct node * firstChild= node->child;
	struct node * secondChild;
	if(firstChild!=NULL) secondChild= node->child->sibling;
	else secondChild = NULL;

	annotateTree(firstChild, symtab);
	if (secondChild) annotateTree(secondChild, symtab);
	

	if (strcmp(firstChild->annotation, secondChild->annotation) == 0 ) 		{
		if(strcmp(firstChild->annotation, "int")==0 || strcmp(firstChild->annotation, "float32")==0){
			annotateNode(node, firstChild->annotation);
			return;
		}
		if(strcmp(firstChild->annotation, "string")==0 &&
		!strcmp(node->tokenType, "Add")){
			annotateNode(node, firstChild->annotation);
			return;
		}
		
		
		
	}
	
	annotateNode(node, "undef");
	flag = -1;
	printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", node->line, node->column, node->tokenValue, node->child->annotation, node->child->sibling->annotation);
	
		
}



void handleFuncDecl(struct node * node, struct table_element * symtab){
	//printf("handling func decl\n");
	struct node * firstChild= node->child;
	struct node * secondChild;
	if(firstChild!=NULL) secondChild= node->child->sibling;
	else secondChild = NULL;

	annotateTree(firstChild, global_symtab);
	
	if(insideFunction!=global_symtab) annotateTree(secondChild, insideFunction);
	
}

void handleProgram(struct node * node, struct table_element * symtab){
	struct node * firstChild= node->child;
	struct node * secondChild;
	if(firstChild!=NULL) secondChild= node->child->sibling;
	else secondChild = NULL;
	struct node * aux;

	aux= firstChild;
	while(aux!=NULL){
		annotateTree(aux, symtab);

		aux=aux->sibling;
	}
	
}

void handleIntLit(struct node * node, struct table_element * symtab){
	annotateNode(node, "int");
}

void handleRealLit(struct node * node, struct table_element * symtab){
	annotateNode(node, "float32");
}

void handleStrLit(struct node * node, struct table_element * symtab){
	annotateNode(node, "string");
}

void handlePrint(struct node * node, struct table_element * symtab){

	struct node * firstChild= node->child;

	annotateTree(firstChild,symtab);

	if (strcmp(firstChild->annotation, "undef") == 0) {
		flag = -1;
		printf("Line %d, column %d: Incompatible type %s in fmt.Println statement\n", node->line, node->column, firstChild->annotation);
		annotateNode(node, "undef");
	}

}

/*
void handleLogic(struct node * node, struct table_element * symtab){
	struct node * firstChild= node->child;
	annotateTree(firstChild, symtab);
	
	if (strcmp(firstChild->annotation, "bool")==0){
		annotateNode(node, "bool");
	}
	else{
		flag = -1;
		printf("Line %d, column %d: Operator %s cannot be applied to type %s\n", node->line, node->column, node->tokenValue, firstChild->annotation);
		annotateNode(node, "undef");
	}
}
*/

void handleLogicBool(struct node * node, struct table_element * symtab){
	struct node * firstChild= node->child;
	struct node * secondChild=firstChild->sibling;
	annotateTree(firstChild, symtab);
	annotateTree(secondChild,symtab);
	
	if (strcmp(firstChild->annotation, secondChild->annotation)==0 && strcmp(firstChild->annotation, "bool")==0){
			annotateNode(node, firstChild->annotation);
			return;
	}
	flag = -1;
	printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", node->line, node->column, node->tokenValue, firstChild->annotation, secondChild->annotation);
	annotateNode(node, "bool");
	//printf("operator logic : %s\n", node->tokenType);
	
	
}







void handleLogic(struct node * node, struct table_element * symtab){
	struct node * firstChild= node->child;
	struct node * secondChild=firstChild->sibling;
	annotateTree(firstChild, symtab);
	annotateTree(secondChild,symtab);
	
	if(strcmp(firstChild->annotation,"undef")==0){
		flag = -1;
		printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", node->line, node->column, node->tokenValue, firstChild->annotation, secondChild->annotation);
		annotateNode(node, "bool");
		return;
				
	}
	
	if (strcmp(firstChild->annotation, secondChild->annotation)==0){
	
		if(strcmp(firstChild->annotation,"bool")==0){
			if(strcmp(node->tokenType, "Eq")!=0
			&& strcmp(node->tokenType, "Ne")!=0){
				flag = -1;
				printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", node->line, node->column, node->tokenValue, firstChild->annotation, secondChild->annotation);
				annotateNode(node, "bool");
				return;
				
			}
			else{
				annotateNode(node, "bool");
				return;
			}
		
		
		}
		else{
			annotateNode(node, "bool");
			return;
		}
		
	}
	
	flag = -1;
	printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", node->line, node->column, node->tokenValue, firstChild->annotation, secondChild->annotation);
	annotateNode(node, "bool");
	//printf("operator logic : %s\n", node->tokenType);
	
	
}


void handlePlusMinus(struct node * node, struct table_element * symtab){

	struct node * firstChild= node->child;

	annotateTree(firstChild,symtab);
	
	if (strcmp(firstChild->annotation, "int")==0 || strcmp(firstChild->annotation, "float32")==0 ){
		annotateNode(node, firstChild->annotation);
		return;
	}
	
	flag = -1;
	printf("Line %d, column %d: Operator %s cannot be applied to type %s\n", node->line, node->column, node->tokenValue, firstChild->annotation);
	annotateNode(node, "undef");

}

void handleNot(struct node * node, struct table_element * symtab){

	struct node * firstChild= node->child;

	annotateTree(firstChild,symtab);
	
	if (strcmp(firstChild->annotation, "bool")==0){
		annotateNode(node, firstChild->annotation);
		return;
	}
	
	flag = -1;
	printf("Line %d, column %d: Operator %s cannot be applied to type %s\n", node->line, node->column, node->tokenValue, firstChild->annotation);
	annotateNode(node, "bool");

}

void handleArgs(struct node * node, struct table_element * symtab){

	struct node * firstChild= node->child;
	struct node * secondChild= firstChild->sibling;

	annotateTree(firstChild,symtab);
	annotateTree(secondChild,symtab);
	
	if (strcmp(firstChild->annotation, "int")==0 && strcmp(secondChild->annotation, "int")==0 ){
		annotateNode(node, firstChild->annotation);
		return;
	}
	
	flag = -1;
	printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", node->line, node->column, node->tokenValue, firstChild->annotation, secondChild->annotation);
	annotateNode(node, "int");
	//printf("operator args: %s\n", node->tokenType);

}

void handleCall(struct node * node, struct table_element * symtab){

	struct node * firstChild= node->child;
	struct table_element* function= handleId(firstChild, symtab, true);
	if(function==NULL){
		annotateNode(node,"undef");
		return;
	}
	if(strcmp(function->type, "none")!=0) annotateNode(node, function->type);
	
	
	


}


void printWithout(int height, struct node* current){
	if(current==NULL) return;
	int i;

	for (i = 0; i < height; i++){
    		printf("..");
    	}
    	
    	if(strcmp(current->tokenValue,"")!=0) printf("%s(%s)\n", current->tokenType, current->tokenValue);

	else{
		printf("%s\n", current->tokenType);
	}
	
	current=current->child;
	
	while(current!=NULL){
		printWithout(height+1, current);
		current=current->sibling;
	}

}


void printAnnotedTree(int height, struct node* root){
    if (root == NULL) return;
    struct node * current = (struct node *) malloc(sizeof(struct node));
    current = root;
	int i;

	if(strcmp(current->tokenType, "FuncHeader") == 0){ 
		printWithout(height, current);
		printAnnotedTree(height, current->sibling);
		return;
	}
	if(strcmp(current->tokenType, "VarDecl") == 0){ 
		printVarDecl(height, root);
		printAnnotedTree(height, current->sibling);
		return;
	}

    for (i = 0; i < height; i++){
    	printf("..");
    }

	if(strcmp(current->tokenType, "Id") != 0 && strcmp(current->tokenType, "IntLit") != 0 && strcmp(current->tokenType, "RealLit") != 0 && strcmp(current->tokenType, "StrLit") != 0){
		printf("%s", current->tokenType);	
	}
	else{
		printf("%s(%s)", current->tokenType, current->tokenValue);
	}

	if(strcmp(current->annotation,"") != 0) {
		printf(" - %s", current->annotation);
	}

	printf("\n");


	printAnnotedTree(height + 1, current->child);
	printAnnotedTree(height, current->sibling);

}





void printfuncHeader(int height, struct node* current){
	int i;

	for (i = 0; i < height; i++){
    		printf("..");
    	}

	printf("%s\n", current->tokenType);

	current=current->child;
	height+=1;

	for (i = 0; i < height; i++){
    		printf("..");
    	}


	printf("%s(%s)\n", current->tokenType, current->tokenValue);

	current=current->sibling;
	
	if(current!=NULL){
		for (i = 0; i < height; i++){
			printf("..");
		}
		printf("%s\n", current->tokenType);
		

		current=current->sibling;
	}


	printAnnotedTree(height, current);

}




void printVarDecl(int height, struct node* current){
	int i;

	for (i = 0; i < height; i++){
    		printf("..");
    	}

	printf("%s\n", current->tokenType);

	current=current->child;
	height+=1;

	for (i = 0; i < height; i++){
    		printf("..");
    	}


	printf("%s\n", current->tokenType);

	current=current->sibling;

	for (i = 0; i < height; i++){
    		printf("..");
    	}


	printf("%s(%s)\n", current->tokenType, current->tokenValue);
	
	//printAnnotedTree(height, current);

}


void annotateNode(struct node * node, char * annotation) {
	node->annotation = strdup(annotation);
	// remover o \0 da string should work like this
}


void annotateTree(struct node * node, struct table_element * symtab) {
	if(symtab==NULL){
	symtab=global_symtab;
	//printf("node: %s symtab is null:replaced with global\n",node->tokenType);
	}
	/*
	if(strcmp(node->tokenValue,"")!=0) printf("node: %s(%s) symtab: %s\n",node->tokenType,node->tokenValue, symtab->id);
	else printf("node: %s symtab: %s\n",node->tokenType,symtab->id);
	*/

	char * type= node->tokenType;
	if (!strcmp(type, "IntLit")) return handleIntLit(node,symtab);
	if (!strcmp(type, "RealLit")) return handleRealLit(node,symtab);
	if (!strcmp(type, "StrLit")) return handleStrLit(node,symtab);
	if (!strcmp(type, "Id")){
	handleId(node, symtab, false);
	return;
	}
	if (!strcmp(type, "Return")) return handleReturn(node,symtab);
	if (!strcmp(type, "Call")) return handleCall(node,symtab);
	if (!strcmp(type, "Assign")) return handleAssign(node,symtab);
	if (!strcmp(type, "Plus")||!strcmp(type, "Minus")) return handlePlusMinus(node,symtab);
	if (!strcmp(type, "Not")) return handleNot(node,symtab);
	if (!strcmp(type, "ParseArgs")) return handleArgs(node,symtab);
	if (!strcmp(type, "Or") || !strcmp(type, "And")) return handleLogicBool(node,symtab);
	if (!strcmp(type, "Eq") || !strcmp(type, "Ne") || !strcmp(type, "Lt") || !strcmp(type, "Gt") || !strcmp(type, "Le") || !strcmp(type, "Ge") ) return handleLogic(node,symtab);
	if (!strcmp(type, "Add") || !strcmp(type, "Sub") || !strcmp(type, "Mul") || !strcmp(type, "Div") || !strcmp(type, "Mod")) return handleOperation(node,symtab);
	if (!strcmp(type, "FuncDecl")) return handleFuncDecl(node,symtab);
	if (!strcmp(type, "FuncHeader")) return handleFuncHeader(node,symtab);
	if (!strcmp(type, "Program")) return handleProgram(node,symtab);
	//if (!strcmp(type, "For")|| !strcmp(type, "If")) return handleIfFor(node,symtab);
	if (!strcmp(type, "For")) return handleFor(node,symtab);
	if (!strcmp(type, "If")) return handleIf(node,symtab);
	if (!strcmp(type, "Print")) return handlePrint(node,symtab);	
	struct node * aux = node->child;
	while(aux){
		annotateTree(aux, symtab);
		aux = aux->sibling;
	} 
	////printf("This should never reach here, something is not being handled: %s\n", type);


}
