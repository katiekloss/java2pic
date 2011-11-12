#include "objects.h"
#include "codegen_pic.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

FILE *output;
ImdtCode *bytecode;

void codegen_pic(FILE *file, ImdtCode *program)
{
    printf("Starting code generation\n");
    output = file;
    bytecode = program;

    write_preamble();
    write_globals();
    write_functions();
    printf("Code generation complete\n");
}

void write_preamble()
{
}

void write_globals()
{
}

void write_functions()
{
    List *functions = (List *) bytecode->functions;
    while(functions->data != NULL)
    {
        Function *function = functions->data;
        // Write function label
        fprintf(output, "%s:\n", function->name);

        int frame_width = function_variables_size(function) + 1;
        printf("Need to allocate %i byte stack frame for function %s\n", frame_width, function->name);
        fprintf(output, "; Saving frame pointer\n");
        fprintf(output, "\tmovf 0x0c, 0\n"); // Load top of stack - 1 into FSR
        fprintf(output, "\taddlw -1\n");
        fprintf(output, "\tmovwf 0x04\n");
        fprintf(output, "\tmovf 0x0c, 0\n"); // Store the current frame pointer into the top of the stack
        fprintf(output, "\tmovwf 0x00\n");
        fprintf(output, "\tmovlw %i\n", frame_width); // Now set the new frame pointer
        fprintf(output, "\tsubwf 0x0c\n\n");

        List *variables = function->symbol_table;
        int offset = 0;
        while(variables->data != NULL)
        {
            Variable *variable = variables->data;
            fprintf(output, "; Allocating variable '%s'\n", variable->name);
            fprintf(output, "\tmovf 0x0c, 0\n"); // Load next stack position
            fprintf(output, "\taddlw %i\n", offset);
            fprintf(output, "\tmovwf 0x04\n");
            fprintf(output, "\tmovlw %i\n", variable->value); // Store this variable there
            fprintf(output, "\tmovwf 0x00\n\n");

            offset++;
            variables = variables->next;
        }

        fprintf(output, "; Function body goes here\n\n");

        // Restore previous frame pointer and return
        fprintf(output, "; Restoring previous frame pointer\n");
        fprintf(output, "\tmovf 0x0c, 0\n");
        fprintf(output, "\taddlw %i\n", frame_width);
        fprintf(output, "\tmovf 0x00, 0\n");
        fprintf(output, "\tmovwf 0x0c\n");
        fprintf(output, "\treturn\n");
        functions = functions->next;
    }
}

int function_variables_size(Function *function)
{
    List *variables = function->symbol_table;
    int size = 0;
    while(variables->data != NULL)
    {
        Variable *var = variables->data;
        size += 1;
        variables = variables->next;
    }
    return size;
}
