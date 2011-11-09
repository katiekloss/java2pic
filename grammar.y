%{
// include files go here
#define YYDEBUG 1
%}

%token ADD
%token CLASS CONSTANT
%token DIVIDE
%token IDENTIFIER INT
%token MULTIPLY
%token PUBLIC
%token STATIC STRING SUBTRACT
%token VOID
%start Program

%%

Program : PUBLIC CLASS IDENTIFIER '{' ProgramBody '}'
        ;

ProgramBody : Declarations Functions
            | Functions
            ;

Declarations : Declarations Declaration
             | Declaration
             ;

Declaration : Declaration ';'
            | Declaration ',' IDENTIFIER
            | TypeName IDENTIFIER
            ;

Assignment  : TypeName IDENTIFIER '=' Expression ';'
            | TypeName IDENTIFIER '=' CONSTANT ';'
            | IDENTIFIER '=' Expression ';'
            | IDENTIFIER '=' CONSTANT ';'
            ;

Expression  : IDENTIFIER Operator IDENTIFIER
            ;

Statements : Statements Statement
           | Statements '{' Statements '}'
           | Statement
           ;

Statement   : Declaration
            | Assignment
            | FunctionCall
            ;

FunctionCall : IDENTIFIER '(' FunctionCallParameters ')' ';'
             ;
FunctionCallParameters : FunctionCallParameters FunctionCallParameter
                       | FunctionCallParameter
                       ;

FunctionCallParameter : IDENTIFIER
                      | CONSTANT
                      | STRING
                      ;

Operator    : ADD
            | SUBTRACT
            | MULTIPLY
            | DIVIDE
            ;

TypeName    : INT
            | VOID
            ;

Functions : Functions Function
          | Function
          ;

Function  : FunctionType IDENTIFIER '(' FunctionParameters ')' '{' Statements '}'
          ;

FunctionType : PUBLIC TypeName
             | PUBLIC STATIC TypeName
             ;

FunctionParameters : Declaration
                   |
                   ;

%%


yyerror (s)
     char *s;
{
    printf ("I'm a teapot!\n");
}
