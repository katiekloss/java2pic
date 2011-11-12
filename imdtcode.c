#include "objects.h"
#include "stdio.h"

void print_quad_instruction(Quad *instruction)
{
    switch(instruction->operand1->type)
    {
        case Pointer:
            printf("%s<0x%x> ", ((Variable *)instruction->operand1->addr)->name, instruction->operand1->addr);
            break;
        case Constant:
            printf("$%i ", instruction->operand1->value);
            break;
    }
    printf("%c ", instruction->operator);
    switch(instruction->operand2->type)
    {
        case Pointer:
            printf("%s<0x%x>", ((Variable *)instruction->operand2->addr)->name, instruction->operand2->addr);
            break;
        case Constant:
            printf("$%i", instruction->operand2->value);
            break;
    }
}

void dump_imdt_code(ImdtCode *bytecode)
{
    printf("Global variables:\n");
    List *globals = (List *) bytecode->globals;
    while(globals->data != NULL)
    {
        Variable *var = (Variable *) globals->data;
        printf("%s<0x%x>\n", var->name, var);
        globals = globals->next;
    }
    printf("\n");

    printf("Functions and intermediate code:\n\n");
    List *functions = (List *) bytecode->functions;
    while(functions->data != NULL)
    {
        Function *function = (Function *) functions->data;
        printf("Function name: %s\n", function->name);
        List *symbols = (List *) function->symbol_table;
        printf("Function variables: ");
        while(symbols->data != NULL)
        {
            Variable *symbol = (Variable *) symbols->data;
            printf("%s<0x%x>, ", symbol->name, symbol);
            symbols = symbols->next;
        }
        printf("\n");
        printf("Function intermediate code:\n");
        printf("Opcode Operand\t\tOperand\t\tResult\n-------------------------------------------------------\n");
        List *statements = (List *) function->statements;
        while(statements->data != NULL)
        {
            Quad *statement = (Quad *) statements->data;
            printf("  %c    ", statement->operator);
            
            QuadOperand *operand1 = (QuadOperand *) statement->operand1;
            switch(operand1->type)
            {
                case Constant:
                    printf("$%i\t\t", operand1->value);
                    break;
                case Pointer:
                    printf("%s<0x%x>\t", ((Variable *)operand1->addr)->name, operand1->addr);
            }
            
            QuadOperand *operand2 = (QuadOperand *) statement->operand2;
            switch(operand2->type)
            {
                case Constant:
                    printf("$%i\t\t", operand2->value);
                    break;
                case Pointer:
                    printf("%s<0x%x>\t", ((Variable *)operand2->addr)->name, operand2->addr);
            }

            QuadOperand *result = (QuadOperand *) statement->result;
            switch(statement->operator)
            {
                case '+':
                case '-':
                case '/':
                case '*':
                    if(result != NULL)
                    {
                        printf("%s<0x%x>\n", ((Variable *)result->addr)->name, result->addr);
                        break;
                    }
                default:
                    printf("null\n");
            }

            statements = statements->next;
        }
        printf("\n");
        functions = functions->next;
    }

    printf("\n");
}
