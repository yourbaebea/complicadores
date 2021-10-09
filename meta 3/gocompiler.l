%option yylineno
%{
  /* GRUPO: Ana Beatriz Marques(2018274233) Barbara Gonçalves(2018295452)*/


  #include <stdio.h>
  #include <string.h>
  #include "y.tab.h"
  #define DEBUG true


  #include "gocompiler.h"
  extern struct table_element * global_symtab;
  int flag = 0; //flag = 1 lex, 2 yacc
  int errorsLex = 0; // print dos erros do Lex
  int errorsSyn = 0; // print dos erros do Syn


  void printlex(const char*);
  void printlexlit(const char* token,const char* text);
  void savePosition();
  int line = 1; //eliminar
  int yycolumn= 1;

  int firstLine;
  int firstLine_c;
  int firstLine_s;
  int firstColumn;
  int firstColumn_c;
  int firstColumn_s;
  char buffer[100] = "";
  int errorline=-1;
  int errorcolumn=-1;
  int flagnewline=0;
  int semiccolumn=-1;
  int errorsemic;
  int errorstrlit;
  int semic_state=0;

%}


SEMIC       ";"
COMMA       ","
BLANKID     "_"
ASSIGN      "="
STAR        "*"
DIV         "/"
MINUS       "-"
PLUS        "+"
EQ          "=="
GE          ">="
GT          ">"
LBRACE      "{"
LE          "<="
LPAR        "("
LSQ         "["
LT          "<"
MOD         "%"
NE          "!="
NOT         "!"
AND         "&&"
OR          "||"
RBRACE      "}"
RPAR        ")"
RSQ         "]"
PACKAGE     "package"
RETURN      "return"
ELSE        "else"
FOR         "for"
IF          "if"
VAR         "var"
INT         "int"
FLOAT32     "float32"
BOOL        "bool"
STRING      "string"
PRINT       "fmt.Println"
PARSEINT    "strconv.Atoi"
FUNC        "func"
CMDARGS     "os.Args"

RESERVED        (break|default|interface|select|case|defer|go|map|struct|chan|goto|switch|const|fallthrough|range|type|continue|import|"++"|"--")
letter          (_|[A-Z]|[a-z])
number          [0-9]
decimal_lit 		[0-9]+
octal_lit		   	0[0-7]+
hex_lit			  	0[xX][0-9A-Fa-f]+

ID                  {letter}({letter}|{number})*
INTLIT              {decimal_lit}|{hex_lit}|{octal_lit}
exp                 (E|e)("+"|"-")?{INTLIT}
REALLIT             ({INTLIT}"."{INTLIT}?{exp}?|"."{INTLIT}{exp}?|{INTLIT}{exp})
strlit              ([^\n\r\\\"]|{escape})*
escape              \\n|\\f|\\r|\\\\|\\\"|\\t
carriagereturn      "\r"
whitespace          " "|"\t"
lineterminator       "\n"|"\r\n"

%x COMMENT STRLIT SEMICOLON
%%
{RESERVED}				         	{printlexlit("RESERVED",yytext); savePosition(); yylval.string=(char*)strdup(yytext); if(flag>=2) return RESERVED;}
0[0-7]*([8|9]+[0-7]*)+   		{firstLine = yylineno; firstColumn = yycolumn; if (errorsLex)  printf("Line %d, column %d: invalid octal constant (%s)\n",firstLine, yycolumn, yytext);savePosition();}
{INTLIT} 		            		{printlexlit("INTLIT",yytext);savePosition(); BEGIN SEMICOLON; yylval.string=(char*)strdup(yytext); if(flag>=2) return INTLIT;}
{REALLIT}		                {printlexlit("REALLIT",yytext);savePosition(); BEGIN SEMICOLON; yylval.string=(char*)strdup(yytext); if(flag>=2) return REALLIT;}
{SEMIC}				              {printlex("SEMICOLON"); savePosition(); if(flag>=2) return SEMICOLON2;}
{COMMA} 					          {printlex("COMMA"); savePosition(); if(flag>=2) return COMMA;}
{BLANKID} 					        {printlex("BLANKID"); savePosition(); if(flag>=2) return BLANKID;}
{ASSIGN}  				        	{printlex("ASSIGN"); savePosition(); if(flag>=2) return ASSIGN;}
{STAR}				           		{printlex("STAR"); savePosition(); if(flag>=2) return STAR;}
{DIV}					            	{printlex("DIV"); savePosition(); if(flag>=2) return DIV;}
{MINUS}				            	{printlex("MINUS"); savePosition(); if(flag>=2) return MINUS;}
{PLUS} 					          	{printlex("PLUS"); savePosition(); if(flag>=2) return PLUS;}
{EQ} 					          		{printlex("EQ"); savePosition(); if(flag>=2) return EQ;}
{GE}					          		{printlex("GE"); savePosition(); if(flag>=2) return GE;}
{GT}					          		{printlex("GT"); savePosition(); if(flag>=2) return GT;}
{LBRACE}				          	{printlex("LBRACE"); savePosition(); if(flag>=2) return LBRACE;}
{LE} 						          	{printlex("LE"); savePosition(); if(flag>=2) return LE;}
{LPAR} 					          	{printlex("LPAR"); savePosition(); if(flag>=2) return LPAR;}
{LSQ} 					          	{printlex("LSQ"); savePosition(); if(flag>=2) return LSQ;}
{LT}						          	{printlex("LT"); savePosition(); if(flag>=2) return LT;}
{MOD} 					          	{printlex("MOD"); savePosition(); if(flag>=2) return MOD;}
{NE} 						          	{printlex("NE"); savePosition(); if(flag>=2) return NE;}
{NOT} 				          		{printlex("NOT"); savePosition(); if(flag>=2) return NOT;}
{AND} 				          		{printlex("AND"); savePosition(); if(flag>=2) return AND;}
{OR}						          	{printlex("OR"); savePosition(); if(flag>=2) return OR;}
{RBRACE}				          	{printlex("RBRACE"); savePosition();BEGIN SEMICOLON; if(flag>=2) return RBRACE;}
{RPAR} 					          	{printlex("RPAR"); savePosition();BEGIN SEMICOLON; if(flag>=2) return RPAR;}
{RSQ}					            	{printlex("RSQ"); savePosition();BEGIN SEMICOLON; if(flag>=2) return RSQ;}
{PACKAGE} 				        	{printlex("PACKAGE"); savePosition(); if(flag>=2) return PACKAGE;}
{RETURN} 				          	{printlex("RETURN"); savePosition(); BEGIN SEMICOLON; if(flag>=2) return RETURN;}
{ELSE} 					          	{printlex("ELSE"); savePosition(); if(flag>=2) return ELSE;}
{FOR} 					          	{printlex("FOR"); savePosition(); if(flag>=2) return FOR;}
{IF}					          		{printlex("IF"); savePosition(); if(flag>=2) return IF;}
{VAR} 					          	{printlex("VAR"); savePosition(); if(flag>=2) return VAR;}
{INT} 					          	{printlex("INT"); savePosition(); if(flag>=2) return INT;}
{FLOAT32} 		         			{printlex("FLOAT32"); savePosition(); if(flag>=2) return FLOAT32;}
{BOOL} 					          	{printlex("BOOL"); savePosition(); if(flag>=2) return BOOL;}
{STRING}				          	{printlex("STRING"); savePosition(); if(flag>=2) return STRING;}
{PRINT}					          	{printlex("PRINT"); savePosition(); if(flag>=2) return PRINT;}
{PARSEINT} 				        	{printlex("PARSEINT"); savePosition(); if(flag>=2) return PARSEINT;}
{FUNC} 						          {printlex("FUNC"); savePosition(); if(flag>=2) return FUNC;}
{CMDARGS}					          {printlex("CMDARGS"); savePosition(); if(flag>=2) return CMDARGS;}
{ID}	 						          {printlexlit("ID",yytext);savePosition(); BEGIN SEMICOLON; yylval.string=(char*)strdup(yytext); if(flag>=2) return ID;}

"/*"						          	{firstLine_c = yylineno; firstColumn_c = yycolumn; savePosition(); BEGIN COMMENT;}
"//"[^\n\r]*				        {yycolumn= 1;}
<COMMENT>\n|\r\n|\r			    {yycolumn= 1;}
<COMMENT><<EOF>>			      {if (errorsLex) printf("Line %d, column %d: unterminated comment\n", firstLine_c, firstColumn_c);BEGIN 0;}
<COMMENT>"*/"			          {savePosition();if(semic_state==1){BEGIN SEMICOLON;} else {BEGIN 0;}}
<COMMENT>.					        {savePosition();}

\"													{BEGIN STRLIT;strcpy(buffer,yytext); firstLine_s = yylineno; firstColumn_s = yycolumn; yylloc.first_line = yylineno; yylloc.first_column = yycolumn; yycolumn += yyleng; errorstrlit=0; }
<STRLIT>\"									{strcat(buffer,"\"");yylloc.last_column = yycolumn - 1; yylloc.last_line = yylineno; if(errorstrlit==0) { printlexlit("STRLIT",buffer); yylval.string=(char*)strdup(buffer); yytext = buffer; BEGIN SEMICOLON; if(flag>=2) return STRLIT2;} else BEGIN 0;}
<STRLIT>\n|\r\n|\r     			{if (errorsLex) printf("Line %d, column %d: unterminated string literal\n",firstLine_s, firstColumn_s);  yycolumn= 1; BEGIN 0;}
<STRLIT><<EOF>>							{if (errorsLex) printf("Line %d, column %d: unterminated string literal\n",firstLine_s, firstColumn_s); BEGIN 0;}
<STRLIT>{strlit}						{strcat(buffer,yytext); yycolumn += yyleng;}
<STRLIT>\\(.?)							{if (errorsLex) printf("Line %d, column %d: invalid escape sequence (%s)\n", firstLine_s,yycolumn, yytext); errorstrlit=1; savePosition();}


<SEMICOLON>{whitespace}			{savePosition();}
<SEMICOLON>";"							{printlex("SEMICOLON"); savePosition(); BEGIN 0; if(flag>=2) return SEMICOLON2;}
<SEMICOLON>\n|\r\n					{flagnewline=1;
  semiccolumn=yycolumn; printlex("SEMICOLON"); yycolumn= 1; errorline=yylineno; errorcolumn=yycolumn; BEGIN 0; if(flag>=2) return SEMICOLON2;}
<SEMICOLON>"//".*				  	{printlex("SEMICOLON"); BEGIN 0; if(flag>=2) return SEMICOLON2;}
<SEMICOLON>"/*"						  {savePosition();semic_state=1; BEGIN COMMENT;}
<SEMICOLON><<EOF>>					{printlex("SEMICOLON");BEGIN 0; if(flag>=2) return SEMICOLON2;}
<SEMICOLON>""/.							{savePosition();BEGIN 0;}



{whitespace}                {savePosition();}
{carriagereturn}            {savePosition();}
{lineterminator}*	     { yycolumn= 1;}
.                           {firstLine = yylineno; firstColumn = yycolumn;if (errorsLex) printf("Line %d, column %d: illegal character (%s)\n",firstLine, yycolumn, yytext);savePosition();}
<<EOF>>                     {return 0;}
%%

void savePosition(){
  yylloc.first_line = yylloc.last_line = yylineno;
	yylloc.first_column = yycolumn;
  yylloc.last_column = yycolumn + yyleng - 1; \
  yycolumn += yyleng;

}




void printlex(const char* token){
 	if(flag==1){
    printf("%s\n",token);
    }
}

void printlexlit(const char* token,const char* text){
	 if(flag==1){
    printf("%s(%s)\n",token,text);
   }
}

void yyerror (char *s) {
  flag=-1;
  if(errorsSyn) {
	  if(flagnewline){


	    if(  	(strcmp(yytext,"\n")==0 || strcmp(yytext,"\r\n") ==0) && 			(yycolumn==errorcolumn && line== errorline)        ){
		printf ("Line %d, column %d: %s: %s\n", yylineno -1 , semiccolumn, s, yytext);
	    }
	    else{
	    	int aux= yycolumn;
	    	if(yycolumn>1) aux= (int)(yycolumn-strlen(yytext));
	    	printf ("Line %d, column %d: %s: %s\n", yylineno , aux, s, yytext);

	    	}
	    }

    else{
	printf ("Line %d, column %d: %s: %s\n", yylineno, (int)(yycolumn-strlen(yytext)), s, yytext);
    }
  }
}


int yywrap(){
  return 1;
}

int main(int argc, char *argv[]){
  if(argc ==2) {

    if(strcmp(argv[1], "-l") == 0){
      errorsLex = 1;
      errorsSyn = 0;
      flag = 1;
      yyparse();
    }

    if(strcmp(argv[1], "-t") == 0){
      errorsLex = 1;
      errorsSyn = 1;
      flag = 2;
      yyparse();

      if(flag>=2) printTree(0,root);
      printf("depois mudar aqui again porque meti as linhas e colunas como debug");

    }

    if(strcmp(argv[1], "-s") == 0){
      errorsLex = 1;
      errorsSyn = 1;
      flag = 3;
      yyparse();
      

       if(flag==3){
       //printf("erros de root:\n\n");
       checkRoot(root);
       //printSymbolTable();
       //printf("\n\nerros de annotatetree:\n\n"); 
       annotateTree(root, global_symtab);
       //printAnnotedTree(0, root);
        if(unusedElements()==-1) flag=-1;
       }
      // b deixa estar isto aqui tem de ser assim!!!!!
      if(flag==3){
      	printSymbolTable();
      	//printf("tabelas done\n");
      	
        printAnnotedTree(0, root);
        //cleanTable(global_symtab);
      }
      /*else{
      	printf("(debug) some error in the tables, we cant annotate tree\n");
      }*/



	}

  }

  else{
  	errorsLex = 1;
  	errorsSyn = 1;
  	flag = 0;
  	yyparse();

    if(flag==0){
      //check_program(node);
	    //check_tree(node);
      //nao faz print das tabelas
    }

  }

  yylex();
  //cleanTree(root);
  return 0;

}
