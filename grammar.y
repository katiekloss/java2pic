%{
#include "objects.h"
#include "list.h"
#include "symbol_table.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>
//#define YYDEBUG 1

#define PRINT_LEVEL()   for(int i = 0; i < level; i++) printf("\t");

/* This stores all of the symbol tables we use.
 *
 * When we enter a new function, we create a new table chain,
 * defined as [function_table, global_table]. When we enter
 * a new scope, we create a new symbol table and push it to
 * the head of the chain, destroying it when the scope is exited.
 *
 * Any subsequent variable declarations get pushed to the first
 * table in the chain, and any variable references will reference
 * the first instance of that variable we find searching the stack
 * from scope->function->global.
 */
List *table_chain;

Function *current_function = NULL;
int level = 0;
%}

%parse-param {ImdtCode *program}

%token ADD
%token CLASS CONSTANT
%token DIVIDE
%token IDENTIFIER INT
%token MULTIPLY
%token PUBLIC
%token STATIC STRING STRINGARRAY SUBTRACT
%token VOID
%start Program

%%

Program : CLASS IDENTIFIER
        {
            // Initialize global symbol table
            program->globals = (List *) create_list();
            assert(program->globals != NULL);
            
            program->functions = (List *) create_list();
            assert(program->functions != NULL);
            
            table_chain = (List *) create_list();
            append_to_list(table_chain, program->globals);
            printf("Intermediate code unit:\n");
            level++;
        }
        '{' ProgramBody '}'
        {
            printf("Declared functions:\n");
            List *function_list = program->functions;
            while(function_list->data != NULL)
            {
                Function *this_function = function_list->data;
                printf("Function: %s\n", this_function->name);
                function_list = function_list->next;
            }
        }            
        ;

ProgramBody : Declarations Assignments Functions
            | Assignments Functions
            | Declarations Functions
            | Functions
            ;

Declarations : Declarations Declaration
             | Declaration
             ;

Declaration : Declaration ';'
            | Declaration ',' IDENTIFIER
            {
                Variable *this = (Variable *) malloc(sizeof(Variable));
                assert(this != NULL);
                this->name = strdup((char *)$3);
                assert(this->name != NULL);
                this->type = $1;
                this->value = NULL;
                append_to_list(table_chain->data, this);

                if(current_function != NULL) append_to_list(current_function->symbol_table, this);
                
                PRINT_LEVEL();
                printf("Variable: %s\n", this->name);
                $$ = this->type;

                // emit declaration
            }
            | TypeName IDENTIFIER
            {
                Variable *this = (Variable *) malloc(sizeof(Variable));
                assert(this != NULL);
                this->name = strdup((char *)$2);
                assert(this->name != NULL);
                this->type = $1;
                this->value = NULL;
                append_to_list(table_chain->data, this);
                
                if(current_function != NULL) append_to_list(current_function->symbol_table, this);

                PRINT_LEVEL();
                printf("Variable: %s\n", this->name);
                $$ = this->type;

                // emit declaration
            }
            ;

Assignments : Assignments Assignment
            | Assignment
            ;

Assignment  : TypeName IDENTIFIER '=' Expression ';'
            {
                Variable *this = (Variable *) malloc(sizeof(Variable));
                assert(this != NULL);
                this->name = strdup((char *)$2);
                assert(this->name != NULL);
                this->type = $1;
                this->value = NULL;
                append_to_list(table_chain->data, this);
                
                if(current_function != NULL) append_to_list(current_function->symbol_table, this);

                PRINT_LEVEL();
                printf("Declaration assignment: %s = %s\n", this->name, $4);

                // emit declaration Operation and assignment Operation
            }
            | TypeName IDENTIFIER '=' CONSTANT ';'
            {
                Variable *this = (Variable *) malloc(sizeof(Variable));
                assert(this != NULL);
                this->name = strdup((char *)$2);
                assert(this->name != NULL);
                this->type = $1;
                this->value = $4;
                append_to_list(table_chain->data, this);
                
                if(current_function != NULL) append_to_list(current_function->symbol_table, this);

                PRINT_LEVEL();
                printf("Variable: %s = %i\n", this->name, this->value);

                // emit a declaration operation and an assignment Operation
            }
            | IDENTIFIER '=' Expression ';'
            {
                PRINT_LEVEL();
                printf("Operation: %s = %s\n", $1, $3);
                // emit an operator operation 
            }
            | IDENTIFIER '=' CONSTANT ';'
            {
                PRINT_LEVEL();
                printf("Assignment: %s = %i\n", $1, $3);
                // emit an assignment operation
            }
            ;

Expression  : IDENTIFIER Operator IDENTIFIER
            {
                Variable *operand1 = search_table_chain(table_chain, (char *)$1);
                assert(operand1 != NULL);
                Variable *operand2 = search_table_chain(table_chain, (char *)$3);
                assert(operand2 != NULL);
                $$ = (char *)malloc(50);
                assert($$ != NULL);
                sprintf($$, "%s %c %s", operand1->name, $2, operand2->name);
            }
            | IDENTIFIER Operator CONSTANT
            {
                Variable *operand = search_table_chain(table_chain, (char *)$1);
                assert(operand != NULL);
                $$ = (char *)malloc(50);
                assert($$ != NULL);
                sprintf($$, "%s %c %i", operand->name, $2, $3);
            }
            | CONSTANT Operator IDENTIFIER
            {
                Variable *operand = search_table_chain(table_chain, (char *)$3);
                assert(operand != NULL);
                $$ = (char *)malloc(50);
                assert($$ != NULL);
                sprintf($$, "%i %c %s", $1, $2, operand->name);

            }
            | CONSTANT Operator CONSTANT
            {
                $$ = (char *)malloc(50);
                assert($$ != NULL);
                sprintf($$, "%i %c %i", $1, $2, $3);
            }
            ;

Statements : Statements Statement
           | Statements '{'
           {
               List *scope_table = (List *) create_list();
               assert(scope_table != NULL);
               table_chain = push_to_list(table_chain, scope_table);
               level++;
           }
           Statements '}'
           {
               table_chain = (List *) pop_from_list(table_chain);
               level--;
           }
           | Statement
           ;

Statement   : Declaration
            | Assignment
            | FunctionCall
            ;

FunctionCall : IDENTIFIER '(' FunctionCallParameters ')' ';'
             {
                 PRINT_LEVEL();
                 printf("Function call: %s\n", $1);
             }
             | IDENTIFIER '(' ')' ';'
             {
                 PRINT_LEVEL();
                 printf("Function call: %s\n", $1);
             }
             ;
FunctionCallParameters : FunctionCallParameters FunctionCallParameter
                       | FunctionCallParameter
                       ;

FunctionCallParameter : Expression
                      | IDENTIFIER
                      | CONSTANT
                      | String
                      ;

Operator    : ADD { $$ = '+'; }
            | SUBTRACT { $$ = '-'; }
            | MULTIPLY { $$ = '*'; }
            | DIVIDE { $$ = '/'; }
            ;

TypeName    : INT { $$ = 'i'; }
            | VOID { $$ = 'v'; }
            | STRINGARRAY { $$ = 'a'; } /* TODO: Fix this! */
            ;

String      : String ADD STRING
            | String ADD IDENTIFIER
            | STRING
            ;

Functions : Functions Function
          | Function
          ;

Function  : TypeName IDENTIFIER '(' 
          {
              Function *this_function = (Function *) malloc(sizeof(Function));
              assert(this_function != NULL);
              append_to_list(program->functions, this_function);
              
              this_function->name = strdup((char *)$2);
              assert(this_function->name != NULL);
              
              this_function->symbol_table = (List *) create_list();
              this_function->statements = (List *) create_list();

              PRINT_LEVEL();
              printf("Function: %s\n", this_function->name);

              List *function_table = (List *) create_list();
              assert(function_table != NULL);
              table_chain = (List *) push_to_list(table_chain, function_table);

              current_function = this_function;
              level++;
          }
          FunctionParameters ')' '{' Statements '}'
          {
              table_chain = pop_from_list(table_chain);
              level--;
          }
          ;

FunctionParameters : FunctionParameters ',' Declaration
                   | Declaration
                   |
                   ;

%%


int yyerror (s)
     char *s;
{
    printf ("I'm a teapot!\n");
}
