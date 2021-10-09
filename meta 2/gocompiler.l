%option yylineno
%{
  /* GRUPO: Ana Beatriz Marques(2018274233) Barbara Gonçalves(2018295452)*/
  #include <stdio.h>
  #include <string.h>
  #include "y.tab.h"
  #define DEBUG true


  #include "gocompiler.h"
  int flag = 0; //flag = 1 lex, 2 yacc
  int yyerrorflag=2;
  int errorsLex = 0; // print dos erros do Lex
  int errorsSyn = 0; // print dos erros do Syn


  void printlex(const char*);
  void printlexlit(const char* token,const char* text);
  int line = 1;
  int column = 1;

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
{RESERVED}				         	{printlexlit("RESERVED",yytext); column += yyleng; yylval.string=(char*)strdup(yytext); if(flag==2) return RESERVED;}
0[0-7]*([8|9]+[0-7]*)+   		{firstLine = yylineno; firstColumn = column; if (errorsLex)  printf("Line %d, column %d: invalid octal constant (%s)\n",firstLine, column, yytext);column += yyleng;}
{INTLIT} 		            		{printlexlit("INTLIT",yytext);column += yyleng; BEGIN SEMICOLON; yylval.string=(char*)strdup(yytext); if(flag==2) return INTLIT;}
{REALLIT}		                {printlexlit("REALLIT",yytext);column += yyleng; BEGIN SEMICOLON; yylval.string=(char*)strdup(yytext); if(flag==2) return REALLIT;}
{SEMIC}				              {printlex("SEMICOLON"); column += yyleng; if(flag==2) return SEMICOLON2;}
{COMMA} 					          {printlex("COMMA"); column += yyleng; if(flag==2) return COMMA;}
{BLANKID} 					        {printlex("BLANKID"); column += yyleng; if(flag==2) return BLANKID;}
{ASSIGN}  				        	{printlex("ASSIGN"); column += yyleng; if(flag==2) return ASSIGN;}
{STAR}				           		{printlex("STAR"); column += yyleng; if(flag==2) return STAR;}
{DIV}					            	{printlex("DIV"); column += yyleng; if(flag==2) return DIV;}
{MINUS}				            	{printlex("MINUS"); column += yyleng; if(flag==2) return MINUS;}
{PLUS} 					          	{printlex("PLUS"); column += yyleng; if(flag==2) return PLUS;}
{EQ} 					          		{printlex("EQ"); column += yyleng; if(flag==2) return EQ;}
{GE}					          		{printlex("GE"); column += yyleng; if(flag==2) return GE;}
{GT}					          		{printlex("GT"); column += yyleng; if(flag==2) return GT;}
{LBRACE}				          	{printlex("LBRACE"); column += yyleng; if(flag==2) return LBRACE;}
{LE} 						          	{printlex("LE"); column += yyleng; if(flag==2) return LE;}
{LPAR} 					          	{printlex("LPAR"); column += yyleng; if(flag==2) return LPAR;}
{LSQ} 					          	{printlex("LSQ"); column += yyleng; if(flag==2) return LSQ;}
{LT}						          	{printlex("LT"); column += yyleng; if(flag==2) return LT;}
{MOD} 					          	{printlex("MOD"); column += yyleng; if(flag==2) return MOD;}
{NE} 						          	{printlex("NE"); column += yyleng; if(flag==2) return NE;}
{NOT} 				          		{printlex("NOT"); column += yyleng; if(flag==2) return NOT;}
{AND} 				          		{printlex("AND"); column += yyleng; if(flag==2) return AND;}
{OR}						          	{printlex("OR"); column += yyleng; if(flag==2) return OR;}
{RBRACE}				          	{printlex("RBRACE"); column += yyleng;BEGIN SEMICOLON; if(flag==2) return RBRACE;}
{RPAR} 					          	{printlex("RPAR"); column += yyleng;BEGIN SEMICOLON; if(flag==2) return RPAR;}
{RSQ}					            	{printlex("RSQ"); column += yyleng;BEGIN SEMICOLON; if(flag==2) return RSQ;}
{PACKAGE} 				        	{printlex("PACKAGE"); column += yyleng; if(flag==2) return PACKAGE;}
{RETURN} 				          	{printlex("RETURN"); column += yyleng; BEGIN SEMICOLON; if(flag==2) return RETURN;}
{ELSE} 					          	{printlex("ELSE"); column += yyleng; if(flag==2) return ELSE;}
{FOR} 					          	{printlex("FOR"); column += yyleng; if(flag==2) return FOR;}
{IF}					          		{printlex("IF"); column += yyleng; if(flag==2) return IF;}
{VAR} 					          	{printlex("VAR"); column += yyleng; if(flag==2) return VAR;}
{INT} 					          	{printlex("INT"); column += yyleng; if(flag==2) return INT;}
{FLOAT32} 		         			{printlex("FLOAT32"); column += yyleng; if(flag==2) return FLOAT32;}
{BOOL} 					          	{printlex("BOOL"); column += yyleng; if(flag==2) return BOOL;}
{STRING}				          	{printlex("STRING"); column += yyleng; if(flag==2) return STRING;}
{PRINT}					          	{printlex("PRINT"); column += yyleng; if(flag==2) return PRINT;}
{PARSEINT} 				        	{printlex("PARSEINT"); column += yyleng; if(flag==2) return PARSEINT;}
{FUNC} 						          {printlex("FUNC"); column += yyleng; if(flag==2) return FUNC;}
{CMDARGS}					          {printlex("CMDARGS"); column += yyleng; if(flag==2) return CMDARGS;}
{ID}	 						          {printlexlit("ID",yytext);column += yyleng; BEGIN SEMICOLON; yylval.string=(char*)strdup(yytext); if(flag==2) return ID;}

"/*"						          	{firstLine_c = yylineno; firstColumn_c = column; column += yyleng; BEGIN COMMENT;}
"//"[^\n\r]*				        {column = 1;}
<COMMENT>\n|\r\n|\r			    {column = 1;}
<COMMENT><<EOF>>			      {if (errorsLex) printf("Line %d, column %d: unterminated comment\n", firstLine_c, firstColumn_c);BEGIN 0;}
<COMMENT>"*/"			          {column += yyleng;if(semic_state==1){BEGIN SEMICOLON;} else {BEGIN 0;}}
<COMMENT>.					        {column += yyleng;}

\"													{BEGIN STRLIT;strcpy(buffer,yytext); firstLine_s = yylineno; firstColumn_s = column; column += yyleng; errorstrlit=0; }
<STRLIT>\"									{strcat(buffer,"\"");column += yyleng; if(errorstrlit==0) { printlexlit("STRLIT",buffer); yylval.string=(char*)strdup(buffer); yytext = buffer; BEGIN SEMICOLON; if(flag==2) return STRLIT2;} else BEGIN 0;}
<STRLIT>\n|\r\n|\r     			{if (errorsLex) printf("Line %d, column %d: unterminated string literal\n",firstLine_s, firstColumn_s); line ++; column = 1; BEGIN 0;}
<STRLIT><<EOF>>							{if (errorsLex) printf("Line %d, column %d: unterminated string literal\n",firstLine_s, firstColumn_s); BEGIN 0;}
<STRLIT>{strlit}						{strcat(buffer,yytext); column += yyleng;}
<STRLIT>\\(.?)							{if (errorsLex) printf("Line %d, column %d: invalid escape sequence (%s)\n", firstLine_s,column, yytext); errorstrlit=1; column += yyleng;}


<SEMICOLON>{whitespace}			{column += yyleng;}
<SEMICOLON>";"							{printlex("SEMICOLON"); column += yyleng; BEGIN 0; if(flag==2) return SEMICOLON2;}
<SEMICOLON>\n|\r\n					{flagnewline=1;
  semiccolumn=column; printlex("SEMICOLON");line ++; column = 1; errorline=line; errorcolumn=column; BEGIN 0; if(flag==2) return SEMICOLON2;}
<SEMICOLON>"//".*				  	{printlex("SEMICOLON"); BEGIN 0; if(flag==2) return SEMICOLON2;}
<SEMICOLON>"/*"						  {column += yyleng;semic_state=1; BEGIN COMMENT;}
<SEMICOLON><<EOF>>					{printlex("SEMICOLON");BEGIN 0; if(flag==2) return SEMICOLON2;}
<SEMICOLON>""/.							{column += yyleng;BEGIN 0;}



{whitespace}                {column += yyleng;}
{carriagereturn}            {column += yyleng;}
{lineterminator}*	     {line ++; column = 1;}
.                           {firstLine = yylineno; firstColumn = column;if (errorsLex) printf("Line %d, column %d: illegal character (%s)\n",firstLine, column, yytext);column += yyleng;}
<<EOF>>                     {return 0;}
%%
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
  yyerrorflag=0;
  if(errorsSyn) {
	  if(flagnewline){
	  
	  
	    if(  	(strcmp(yytext,"\n")==0 || strcmp(yytext,"\r\n") ==0) && 			(column==errorcolumn && line== errorline)        ){
		printf ("Line %d, column %d: %s: %s\n", yylineno -1 , semiccolumn, s, yytext);
	    }
	    else{
	    	int aux= column;
	    	if(column>1) aux= (int)(column-strlen(yytext));
	    	printf ("Line %d, column %d: %s: %s\n", yylineno , aux, s, yytext);
	    	
	    	}
	    }
    	
    else{
	printf ("Line %d, column %d: %s: %s\n", yylineno, (int)(column-strlen(yytext)), s, yytext);
    }
  }
}

int main(int argc, char *argv[]){
  if(argc > 1 && strcmp(argv[1], "-l") == 0){
  	errorsLex = 1;
    	errorsSyn = 0;
    	flag = 1;
  	yyparse();
  }
  
  else if(argc > 1 && strcmp(argv[1], "-t") == 0){
    errorsLex = 1;
  	errorsSyn = 1;
  	flag = 2;
  	yyparse();
  	
  	if(yyerrorflag==2) printTree(0,root);
  	
  	
  	} 
  
  else{ 
  	errorsLex = 1;
  	errorsSyn = 1;
  	flag = 0;
  	yyparse();}

  yylex();
  return 0;
}

int yywrap(){
  return 1;
}
