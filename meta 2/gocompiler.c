#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "gocompiler.h"

struct node * createNode (char* tokenType, char* tokenValue) {
	
	struct node * newNode = (struct node *)malloc(sizeof(struct node));
	newNode->child = NULL;
	newNode->sibling = NULL;
    newNode->tokenType = tokenType;
	newNode->tokenValue = tokenValue;
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
	//printf("antes\n");
	//printTree(0,parent);
	
	struct node * p= parent;
	int i=0;
    while (p != NULL) {
    		struct node * aux = p->child;
    		p->child=NULL;
    		addChild(p, createNode(type->tokenType, ""));
    		addChild(p, aux);
    		p= p->sibling;
    		i=i+1;
	}
	
	//printf("\n\ndepois\n");
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
    if (strcmp(current->tokenValue, "") == 0){
    	printf("%s\n", current->tokenType);
    }
    else {
    	printf("%s(%s)\n", current->tokenType, current->tokenValue);
    }
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
