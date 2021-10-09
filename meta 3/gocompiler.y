%{

    #include "gocompiler.h"
    int yylex(void);
    void yyerror (const char *s);
    int synErrors = 0;
    extern struct node * root;
    int yydebug = 1;
%}

%union {
	char * string;
	struct node * node;
}

%locations

%token SEMICOLON2 BLANKID PACKAGE RETURN AND ASSIGN STAR COMMA DIV EQ GE GT LBRACE LE LPAR LSQ LT CMDARGS
%token MINUS MOD NE NOT OR PLUS RBRACE RPAR RSQ ELSE FOR IF VAR INT FLOAT32 BOOL STRING PRINT PARSEINT FUNC 
%token <string> STRLIT2 INTLIT ID REALLIT RESERVED
 
%type<node> Program Declarations VarDeclaration VarSpec VarSpec2 Type Type2 FuncDeclaration Parameters Parameters2 Parameters3 FuncBody VarsAndStatements 
%type<node> Statement StatementAux StatementIfFor StatementCicle Statement3 Statement4 FuncInvocation FuncInvocation2 ParseArgs Expr Expr2 Expr3

%left COMMA
%right ASSIGN
%left OR
%left AND 
%left GE LE LT GT EQ NE
%left PLUS MINUS
%left STAR DIV MOD
%right UNARY
%left LPAR RPAR LSQ RSQ LBRACE RBRACE

%%
Program: PACKAGE ID SEMICOLON2 Declarations          {$$ = createNode("Program", "",0,0); if ($4 != NULL) addChild($$,$4); root=$$; /*printTree(0,$$);*/
}
;

Declarations: Declarations VarDeclaration SEMICOLON2             {if ($1 != NULL){$$ = $1; addSibling($$,$2);}else $$ = $2;}
            | Declarations FuncDeclaration SEMICOLON2            {if ($1 != NULL){$$ = $1; addSibling($$,$2);}else $$ = $2;}
            |                                                   {$$ = NULL;}
;

VarDeclaration: VAR VarSpec                         {$$ = $2;}
            |   VAR LPAR VarSpec SEMICOLON2 RPAR     {$$ = $3;}

;

VarSpec: ID VarSpec2 Type           {$$= createNode("VarDecl", "",0,0);addChild($$, $3);addChild($$, createNode("Id",$1, @1.first_line, @1.first_column));
                                    if($2!=NULL){addSibling($$,$2);addChildFirst($2, $3);}}
;
                                   


VarSpec2: COMMA ID VarSpec2                   {$$= createNode("VarDecl", "",0,0);addChild($$,createNode("Id", $2, @2.first_line, @2.first_column));if($3!=NULL) addSibling($$,$3);}
        |                                     {$$ = NULL;}
;

Type: INT           {$$ = createNode("Int", "", @1.first_line, @1.first_column);}
    | FLOAT32       {$$ = createNode("Float32", "", @1.first_line, @1.first_column);}
    | BOOL          {$$ = createNode("Bool", "", @1.first_line, @1.first_column);}
    | STRING        {$$ = createNode("String", "", @1.first_line, @1.first_column);}
;

FuncDeclaration: FUNC ID LPAR Parameters2 RPAR Type2 FuncBody   {$$ = createNode("FuncDecl", "",0,0); struct node * FuncHeader= createNode("FuncHeader", "",0,0);  addChild(FuncHeader, createNode("Id", $2, @2.first_line, @2.first_column)); 
                                                                 if ($6 != NULL) addChild(FuncHeader, $6);addChild(FuncHeader, $4); addChild($$,FuncHeader); addChild($$, $7);}
;

Parameters2: Parameters         {$$ = createNode("FuncParams", "",0,0); addChild($$, $1);}
;

Type2: Type         {$$ = $1;}
    |               {$$ = NULL;}
;

Parameters: ID Type Parameters3         {$$ = createNode("ParamDecl", "",0,0); addChild($$, $2); if ($3 != NULL) addSibling($$, $3); addChild($$, createNode("Id", $1, @1.first_line, @1.first_column)); }
            |                           {$$ = NULL;}
;

Parameters3: Parameters3 COMMA ID Type  {struct node * ParamDecl = createNode("ParamDecl", "",0,0); addChild(ParamDecl, $4);addChild(ParamDecl, createNode("Id", $3,@3.first_line, @3.first_column));
                                        if ($1 != NULL){ addSibling($1, ParamDecl); $$=$1; } else{$$=ParamDecl;} }
            |                           {$$ = NULL;}
;

FuncBody: LBRACE VarsAndStatements RBRACE   {$$ = createNode("FuncBody","",0,0); if ($2 != NULL) addChild($$, $2);}
;

VarsAndStatements: VarsAndStatements VarDeclaration SEMICOLON2 {if ($1 != NULL){$$ = $1; addSibling($$, $2);}else $$ = $2;}
                | VarsAndStatements Statement SEMICOLON2       {if ($1 != NULL){$$ = $1; addSibling($$, $2);}else $$ = $2;}                                        
                | VarsAndStatements SEMICOLON2                 {if ($1 != NULL) $1 = $$; else $$ = NULL;}  
                |                                              {$$ = NULL;}
;


Statement: ID ASSIGN Expr                                   {$$ = createNode("Assign", "=",@2.first_line, @2.first_column); addChild($$, createNode("Id", $1, @1.first_line, @1.first_column)); addChild($$, $3);}
        | LBRACE StatementAux RBRACE                          {$$ = $2;}
        | IF Expr LBRACE StatementIfFor RBRACE Statement3       {$$ = createNode("If", "",@2.first_line, @2.first_column); addChild($$, $2);addChild($$, $4); addChild($$, $6);}
        | FOR Expr2 LBRACE StatementIfFor RBRACE                {$$ = createNode("For", "",@2.first_line, @2.first_column); addChild($$, $2); addChild($$, $4);}
                                                            
        | RETURN Expr2                                      {$$ = createNode("Return", "",@2.first_line, @2.first_column); if($2 != NULL) addChild($$, $2);
        }
        | FuncInvocation                                    {$$ = $1;}
        | ParseArgs                                         {$$ = $1;}
        | PRINT LPAR Statement4 RPAR                        {$$ = createNode("Print", "",@3.first_line, @3.first_column); addChild($$, $3);}
        | error                                             {$$ = NULL; synErrors = 1;}
;


StatementIfFor: StatementCicle Statement SEMICOLON2       {$$ = createNode("Block", "",0,0); if($1!=NULL){addChild($$, $1); addSibling($1, $2);}else{addChild($$, $2);}}
            |                                       {$$ = createNode("Block", "",0,0);}
;

StatementAux: StatementCicle Statement SEMICOLON2       {

	if(check($1,$2)>=2){
		$$= createNode("Block", "",0,0);
		addChild($$, $1);
		addSibling($1, $2);
	}
	else{
		if($1!=NULL) $$=$1;
		if($2!=NULL) $$=$2;
	}
}
		|					{$$=NULL;}
		//ns se este é preciso supostamente nao é
;

StatementCicle: StatementCicle Statement SEMICOLON2   {if($1 !=NULL){$$=$1; addSibling($$, $2);}else $$=$2;}
            |                                       {$$ = NULL;}
;


Statement3: ELSE LBRACE StatementIfFor RBRACE           {$$ = $3;}
            |                                       {$$ = createNode("Block", "",0,0);}
;

Statement4: Expr            {$$ = $1;}
            |STRLIT2         {$$ = createNode("StrLit", $1, @1.first_line, @1.first_column);}
;

Expr2: Expr         {$$ = $1;}
        |           {$$ = NULL;}
;

ParseArgs: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR      {$$ = createNode("ParseArgs", "strconv.Atoi" ,@5.first_line, @5.first_column); addChild($$, createNode("Id", $1, @1.first_line, @1.first_column)); addChild($$,$9);}
        | ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR                      {$$ = NULL;  synErrors = 1;}
;

FuncInvocation: ID LPAR FuncInvocation2 RPAR        {$$ = createNode("Call","", @1.first_line, @1.first_column); addChild($$, createNode("Id",$1, @1.first_line, @1.first_column)); if ($3 != NULL) addChild($$, $3);}
                |ID LPAR error RPAR                 {$$ = NULL;  synErrors = 1;}
;

FuncInvocation2: Expr Expr3             {$$ = $1; if ($2 != NULL) addSibling($$, $2);}
                |                       {$$ = NULL;}
;

Expr3: Expr3 COMMA Expr                 {if ($1 != NULL){$$ = $1; addSibling($$, $3);}else $$ = $3;}
        |                               {$$ = NULL;}
;

Expr: LPAR Expr RPAR              {$$ = $2;}
    	| LPAR error RPAR               {$$ = NULL; synErrors = 1;}
	| Expr OR Expr                  {$$ = createNode("Or", "||",@2.first_line, @2.first_column); addChild($$, $1); addChild($$, $3);}
	| Expr AND Expr                 {$$ = createNode("And", "&&",@2.first_line, @2.first_column); addChild($$, $1); addChild($$, $3);}
	| Expr LT Expr                  {$$ = createNode("Lt", "<",@2.first_line, @2.first_column); addChild($$, $1); addChild($$, $3);}
	| Expr GT Expr                  {$$ = createNode("Gt", ">",@2.first_line, @2.first_column); addChild($$, $1); addChild($$, $3);}
	| Expr EQ Expr                  {$$ = createNode("Eq", "==",@2.first_line, @2.first_column); addChild($$, $1); addChild($$, $3);}
	| Expr NE Expr                  {$$ = createNode("Ne", "!=",@2.first_line, @2.first_column); addChild($$, $1); addChild($$, $3);}
	| Expr LE Expr                  {$$ = createNode("Le", "<=",@2.first_line, @2.first_column); addChild($$, $1); addChild($$, $3);}
	| Expr GE Expr                  {$$ = createNode("Ge", ">=",@2.first_line, @2.first_column); addChild($$, $1); addChild($$, $3);}
	| Expr PLUS Expr                {$$ = createNode("Add", "+", @2.first_line, @2.first_column); addChild($$, $1); addChild($$, $3);}
	| Expr MINUS Expr               {$$ = createNode("Sub", "-", @2.first_line, @2.first_column); addChild($$, $1); addChild($$, $3);}
	| Expr STAR Expr                {$$ = createNode("Mul", "*",@2.first_line, @2.first_column); addChild($$, $1); addChild($$, $3);}
	| Expr DIV Expr                 {$$ = createNode("Div", "/",@2.first_line, @2.first_column); addChild($$, $1); addChild($$, $3);}
	| Expr MOD Expr                 {$$ = createNode("Mod", "%",@2.first_line, @2.first_column); addChild($$, $1); addChild($$, $3);}
	| NOT Expr %prec UNARY          {$$ = createNode("Not", "!", @1.first_line, @1.first_column); addChild($$, $2);}
        | MINUS Expr %prec UNARY        {$$ = createNode("Minus", "-", @1.first_line, @1.first_column); addChild($$, $2);}
        | PLUS Expr %prec UNARY         {$$ = createNode("Plus", "+", @1.first_line, @1.first_column); addChild($$, $2);}
	| INTLIT                        {$$ = createNode("IntLit", $1,@1.first_line, @1.first_column);}
	| REALLIT                       {$$ = createNode("RealLit", $1,@1.first_line, @1.first_column);}
    	| ID                            {$$ = createNode("Id", $1,@1.first_line, @1.first_column);}
	| FuncInvocation                {$$ = $1;}
	;
