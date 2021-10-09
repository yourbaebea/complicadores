#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct node * createNode (char* typeToken, char* valueToken);
void addChild (struct node * parent, struct node * child);
void addSibling (struct node * child, struct node * sibling);
int addChildFirst(struct node * parent, struct node * type);
void printTree(int height, struct node* root);
void cleanTree(struct node* current);
int check(struct node * first, struct node * second);
struct node * root;

typedef struct node {
	struct node * sibling;
	struct node * child;
	char * tokenType;
	char * tokenValue;
} node;
