%{
#include "objects.h"
#include "list.h"
#include "symbol_table.h"
#include "imdtcode.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>
//#define YYDEBUG 1

#define PRINT_LEVEL()   for(int i = 0; i < level; i++) printf("\t");

int yylex(void);
int yyerror(ImdtCode *, char *);
List * build_printf_list(List *parameters);

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
List *function_call_list = NULL;

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
                memset(this, 0, sizeof(Variable));
                this->name = strdup((char *)$3);
                assert(this->name != NULL);
                this->type = $1;
                this->value = 0;
                this->global = 0;
                append_to_list(table_chain->data, this);

                if(current_function != NULL)
                    append_to_list(current_function->symbol_table, this);
                else
                    this->global = 1;
                
                PRINT_LEVEL();
                printf("Variable: %s\n", this->name);
                $$ = this->type;
            }
            | TypeName IDENTIFIER
            {
                Variable *this = (Variable *) malloc(sizeof(Variable));
                assert(this != NULL);
                memset(this, 0, sizeof(Variable));
                this->name = strdup((char *)$2);
                assert(this->name != NULL);
                this->type = $1;
                this->value = 0;
                this->global = 0;
                append_to_list(table_chain->data, this);
                
                if(current_function != NULL)
                    append_to_list(current_function->symbol_table, this);
                else
                    this->global = 1;

                PRINT_LEVEL();
                printf("Variable: %s\n", this->name);
                $$ = this->type;
            }
            ;

Assignments : Assignments Assignment
            | Assignment
            ;

Assignment  : TypeName IDENTIFIER '=' Expression ';'
            {
                Variable *this = (Variable *) malloc(sizeof(Variable));
                assert(this != NULL);
                memset(this, 0, sizeof(Variable));
                this->name = strdup((char *)$2);
                assert(this->name != NULL);
                this->type = $1;
                this->value = 0;
                this->global = 0;
                append_to_list(table_chain->data, this);
                
                if(current_function != NULL)
                    append_to_list(current_function->symbol_table, this);
                else
                    this->global = 1;

                QuadOperand *result = (QuadOperand *) malloc(sizeof(QuadOperand));
                assert(result != NULL);
                result->type = Pointer;
                result->addr = this;
                ((Quad *)$4)->result = result;
                
                PRINT_LEVEL();
                printf("Declaration assignment: %s = ", this->name);
                print_quad_instruction((Quad *)$4);
                printf("\n");

            }
            | TypeName IDENTIFIER '=' CONSTANT ';'
            {
                Variable *this = (Variable *) malloc(sizeof(Variable));
                assert(this != NULL);
                memset(this, 0, sizeof(Variable));
                this->name = strdup((char *)$2);
                assert(this->name != NULL);
                this->type = $1;
                this->value = $4;
                this->global = 0;
                append_to_list(table_chain->data, this);
                
                if(current_function != NULL)
                    append_to_list(current_function->symbol_table, this);
                else
                    this->global = 1;

                PRINT_LEVEL();
                printf("Variable: %s = %i\n", this->name, this->value);
            }
            | IDENTIFIER '=' Expression ';'
            {
                Variable *this = (Variable *) search_table_chain(table_chain, (char *)$1);
                QuadOperand *result = (QuadOperand *) malloc(sizeof(QuadOperand));
                assert(result != NULL);
                result->type = Pointer;
                result->addr = this;
                ((Quad *)$3)->result = result;

                PRINT_LEVEL();
                printf("Operation: %s = ", $1);
                print_quad_instruction((Quad *)$3);
                printf("\n");
            }
            | IDENTIFIER '=' CONSTANT ';'
            {
                PRINT_LEVEL();
                printf("Assignment: %s = %i\n", $1, $3);

                Variable *this = search_table_chain(table_chain, (char *)$1);
                assert(this != NULL);
                
                QuadOperand *operand1 = (QuadOperand *) malloc(sizeof(QuadOperand));
                assert(operand1 != NULL);
                operand1->type = Constant;
                operand1->value = 0;

                QuadOperand *operand2 = (QuadOperand *) malloc(sizeof(QuadOperand));
                assert(operand2 != NULL);
                operand2->type = Constant;
                operand2->value = $3;

                QuadOperand *result = (QuadOperand *) malloc(sizeof(QuadOperand));
                assert(result != NULL);
                result->type = Pointer;
                result->addr = this;

                Quad *instruction = (Quad *) malloc(sizeof(Quad));
                assert(instruction != NULL);

                instruction->operator = '+';
                instruction->operand1 = operand1;
                instruction->operand2 = operand2;
                instruction->result = result;

                append_to_list(current_function->statements, instruction);
            }
            ;

Expression  : IDENTIFIER Operator IDENTIFIER
            {
                Variable *operand1 = search_table_chain(table_chain, (char *)$1);
                assert(operand1 != NULL);
                
                QuadOperand *qoperand1 = (QuadOperand *) malloc(sizeof(QuadOperand));
                assert(qoperand1 != NULL);
                qoperand1->type = Pointer;
                qoperand1->addr = operand1;

                Variable *operand2 = search_table_chain(table_chain, (char *)$3);
                assert(operand2 != NULL);
                QuadOperand *qoperand2 = (QuadOperand *) malloc(sizeof(QuadOperand));
                assert(qoperand2 != NULL);
                qoperand2->type = Pointer;
                qoperand2->addr = operand2;

                Quad *instruction = (Quad *) malloc(sizeof(Quad));
                assert(instruction != NULL);

                instruction->operator = $2;
                instruction->operand1 = qoperand1;
                instruction->operand2 = qoperand2;
                instruction->result = NULL; // Filled by the Expression's parent
                
                if(function_call_list != NULL)
                    append_to_list(function_call_list, instruction);

                append_to_list(current_function->statements, instruction);
                $$ = instruction;
            }
            | IDENTIFIER Operator CONSTANT
            {
                Variable *operand = search_table_chain(table_chain, (char *)$1);
                assert(operand != NULL);

                QuadOperand *qoperand1 = (QuadOperand *) malloc(sizeof(QuadOperand));
                assert(qoperand1 != NULL);
                qoperand1->type = Pointer;
                qoperand1->addr = operand;
                
                QuadOperand *qoperand2 = (QuadOperand *) malloc(sizeof(QuadOperand));
                assert(qoperand2 != NULL);
                qoperand2->type = Constant;
                qoperand2->value = $3;

                Quad *instruction = (Quad *) malloc(sizeof(Quad));
                assert(instruction != NULL);

                instruction->operator = $2;
                instruction->operand1 = qoperand1;
                instruction->operand2 = qoperand2;
                instruction->result = NULL;

                if(function_call_list != NULL)
                    append_to_list(function_call_list, instruction);
    
                append_to_list(current_function->statements, instruction);
                $$ = instruction;
            }
            | CONSTANT Operator IDENTIFIER
            {
                Variable *operand = search_table_chain(table_chain, (char *)$3);
                assert(operand != NULL);

                QuadOperand *qoperand1 = (QuadOperand *) malloc(sizeof(QuadOperand));
                assert(qoperand1 != NULL);
                qoperand1->type = Constant;
                qoperand1->value = $1;

                QuadOperand *qoperand2 = (QuadOperand *) malloc(sizeof(QuadOperand));
                assert(qoperand2 != NULL);
                qoperand2->type = Pointer;
                qoperand2->addr = operand;

                Quad *instruction = (Quad *) malloc(sizeof(Quad));
                assert(instruction != NULL);
                
                instruction->operator = $2;
                instruction->operand1 = qoperand1;
                instruction->operand2 = qoperand2;
                instruction->result = NULL;

                if(function_call_list != NULL)
                    append_to_list(function_call_list, instruction);
    
                append_to_list(current_function->statements, instruction);
                $$ = instruction;
            }
            | CONSTANT Operator CONSTANT
            {
                QuadOperand *qoperand1 = (QuadOperand *) malloc(sizeof(QuadOperand));
                assert(qoperand1 != NULL);
                qoperand1->type = Constant;
                qoperand1->value = $1;

                QuadOperand *qoperand2 = (QuadOperand *) malloc(sizeof(QuadOperand));
                assert(qoperand2 != NULL);
                qoperand2->type = Constant;
                qoperand2->value = $3;

                Quad *instruction = (Quad *) malloc(sizeof(Quad));
                assert(instruction != NULL);

                instruction->operator = $2;
                instruction->operand1 = qoperand1;
                instruction->operand2 = qoperand2;
                instruction->result = NULL;

                if(function_call_list != NULL)
                    append_to_list(function_call_list, instruction);
                
                append_to_list(current_function->statements, instruction);
                $$ = instruction;
            }
            | '(' Expression ')'
            {
                $$ = $2;
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

FunctionCall : IDENTIFIER '('
             {
                 function_call_list = malloc(sizeof(List *));
                 assert(function_call_list != NULL);
             }
             FunctionCallParameters ')' ';'
             {
                 QuadOperand *call_list = (QuadOperand *) malloc(sizeof(QuadOperand));
                 assert(call_list != NULL);
                 call_list->type = LinkedList;
                 call_list->addr = function_call_list;

                 QuadOperand *name = (QuadOperand *) malloc(sizeof(QuadOperand));
                 assert(name != NULL);
                 name->type = String;
                 if(!strncmp($1, "System.out.printf", 17))
                 {
                     name->name = strdup("printf");
                     call_list->addr = build_printf_list(function_call_list);
                 }
                 else
                     name->name = strdup($1);

                 Quad *instruction = (Quad *) malloc(sizeof(Quad));
                 assert(instruction != NULL);
                 instruction->operator = 'c';
                 instruction->operand1 = name;
                 instruction->operand2 = call_list;

                 append_to_list(current_function->statements, instruction);
                 
                 function_call_list = NULL;
                 PRINT_LEVEL();
                 printf("Function call: %s\n", $1);
             }
             | IDENTIFIER '(' ')' ';'
             {
                 QuadOperand *name = (QuadOperand *) malloc(sizeof(QuadOperand));
                 assert(name != NULL);
                 name->type = String;
                 name->name = strdup($1);

                 Quad *instruction = (Quad *) malloc(sizeof(Quad));
                 assert(instruction != NULL);
                 instruction->operator = 'c';
                 instruction->operand1 = name;
                 instruction->operand2 = NULL;

                 append_to_list(current_function->statements, instruction);

                 function_call_list = NULL;
                 PRINT_LEVEL();
                 printf("Function call: %s\n", $1);
             }
             ;
FunctionCallParameters : FunctionCallParameters ',' FunctionCallParameter
                       | FunctionCallParameter
                       ;

FunctionCallParameter : Expression
                      {
                          // This gets optimized out in the code generator to use a
                          // temporary register instead of a stack variable
                          Variable *temp = (Variable *) malloc(sizeof(Variable));
                          assert(temp != NULL);
                          memset(temp, 0, sizeof(Variable));
                          temp->name = strdup("temp");
                          temp->temporary = 1;

                          QuadOperand *operand = (QuadOperand *) malloc(sizeof(QuadOperand));
                          assert(operand != NULL);
                          operand->type = Pointer;
                          operand->addr = temp;
                          ((Quad *)$1)->result = operand;
                      }
                      | IDENTIFIER
                      {
                          Variable *this = (Variable *) search_table_chain(table_chain, (char *)$1);
                          append_to_list(function_call_list, this);
                      }
                      | CONSTANT
                      | STRING
                      {
                          append_to_list(function_call_list, $1);
                      }
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
              table_chain = (List *) pop_from_list(table_chain);
              level--;
          }
          ;

FunctionParameters : FunctionParameters ',' Declaration
                   | Declaration
                   |
                   ;

%%


int yyerror (ImdtCode *program, char *s)
{
    printf("I'm a teapot!\n");
}

List * build_printf_list(List *parameters)
{
    char *format = (char *) parameters->data;
    List *variables = parameters->next;
    List *expanded = create_list();
    for(int i = 0; i < strlen(format); )
    {
        if(format[i] == '%')
        {
            append_to_list(expanded, (Variable *)variables->data);
            variables = variables->next;
            i += 2;
        } else if (format[i] == '\\') {
            Variable *this = (Variable *) malloc(sizeof(Variable));
            assert(this != NULL);
            this->type = 'c';

            i++;
            if(format[i] == 'n')
            {
                this->value = '\n';
            } else if(format[i] == 't') {
                this->value = '\t';
            }
            i++;
        } else {
            Variable *this = (Variable *) malloc(sizeof(Variable));
            assert(this != NULL);
            this->type = 'c';
            this->value = format[i];
            i++;
        }
    }

    return expanded;
}
