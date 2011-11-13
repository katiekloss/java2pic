#include "objects.h"
#include "codegen_pic.h"
#include "list.h"
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

    printf("Generating preamble\n");
    write_preamble();
    printf("Generating global variables\n");
    write_globals();
    printf("Generating function variables and code\n");
    write_functions();
    printf("Code generation complete\n");
}

void write_preamble()
{
    // TODO: All of that "initializing ports" crap will go here
    fprintf(output, "; Initializing stack frame pointer\n");
    fprintf(output, "\tmovlw 0x4f\n");
    fprintf(output, "\tmovwf 0x0c\n\n");
}

void write_globals()
{
    int globals_width = list_length(bytecode->globals);
    printf("Need to allocate %i bytes for global variables\n", globals_width);
    if(globals_width == 0) return;

    fprintf(output, ";Declaring global variables\n");
    fprintf(output, "\tmovlw %i\n", globals_width);
    fprintf(output, "\tsubwf 0x0c\n\n"); // Move frame pointer to make room for globals
    
    allocate_variables(bytecode->globals);
}

void write_functions()
{
    List *functions = (List *) bytecode->functions;
    while(functions->data != NULL)
    {
        Function *function = functions->data;
        // Write function label
        fprintf(output, "%s:\n", function->name);

        int frame_width = list_length(function->symbol_table) + 1;
        printf("Need to allocate %i byte stack frame for function %s\n", frame_width, function->name);
        fprintf(output, "; Saving frame pointer\n");
        fprintf(output, "\tmovf 0x0c, 0\n"); // Load top of stack - 1 into FSR
        fprintf(output, "\taddlw -1\n");
        fprintf(output, "\tmovwf 0x04\n");
        fprintf(output, "\tmovf 0x0c, 0\n"); // Store the current frame pointer into the top of the stack
        fprintf(output, "\tmovwf 0x00\n");
        fprintf(output, "\tmovlw %i\n", frame_width); // Now set the new frame pointer
        fprintf(output, "\tsubwf 0x0c\n\n");

        allocate_variables(function->symbol_table);

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

void allocate_variables(List *symbol_table)
{
    int offset = 0;
    while(symbol_table->data != NULL)
    {
        Variable *variable = symbol_table->data;
        fprintf(output, "; Allocating variable '%s'\n", variable->name);
        fprintf(output, "\tmovf 0x0c, 0\n"); // Load next stack position
        fprintf(output, "\taddlw %i\n", offset);
        fprintf(output, "\tmovwf 0x04\n");
        fprintf(output, "\tmovlw %i\n", variable->value); // Store this variable there
        fprintf(output, "\tmovwf 0x00\n\n");

        offset++;
        symbol_table = symbol_table->next;
    }
}
