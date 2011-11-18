#include "objects.h"
#include "codegen_pic.h"
#include "list.h"
#include "imdtcode.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

/* The code generator lays out the memory like this:
 * 
 * 0x0c: Stack pointer (points to topmost allocated byte on stack)
 * 0x0d: Temporary register
 * 0x0e: Last byte of stack
 * ... : Stack
 * 0x4e: Example global variable
 * 0x4f: First byte of stack
 *
 * A stack frame looks like this (inspired by x86 stack frame layout):
 *
 * 0x3a: Stack variable at offset 0 (stack pointer = 0x3a)
 * 0x3b: Stack variable at offset 1
 * 0x3c: Stack variable at offset 2
 * 0x3d: Saved stack pointer (this is moved into 0x0c at function return)
 * 0x3e: Start of previous stack frame
 */


FILE *output;
ImdtCode *bytecode;
int label_base = 0;
int temporary = 0x0d;

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
    fprintf(output, "\t#include <p16f884.inc>\n");
    fprintf(output, "\torg 0\n\n");
    fprintf(output, "\tbsf STATUS, RP0\n");
    fprintf(output, "\tclrf TRISB\n");
    fprintf(output, "\tbcf STATUS, RP0\n");
    fprintf(output, "; Initializing stack frame pointer\n");
    fprintf(output, "\tmovlw H'4f'\n");
    fprintf(output, "\tmovwf H'0c'\n\n");
}

void write_globals()
{
    int globals_width = list_length(bytecode->globals);
    printf("Need to allocate %i bytes for global variables\n", globals_width);
    if(globals_width == 0) return;

    fprintf(output, ";Declaring global variables\n");
    fprintf(output, "\tmovlw %i\n", globals_width);
    fprintf(output, "\tsubwf H'0c'\n\n"); // Move frame pointer to make room for globals
    
    allocate_variables(bytecode->globals);
}

void write_functions()
{
    fprintf(output, "main_loop:\n");
    fprintf(output, "\tcall func_main\n");
    fprintf(output, "\tgoto main_loop\n");

    List *functions = (List *) bytecode->functions;
    while(functions->data != NULL)
    {
        Function *function = functions->data;
        // Write function label
        fprintf(output, "func_%s:\n", function->name);

        // A stack frame needs 1 byte per static variable + 1 byte for saved frame pointer
        int frame_width = list_length(function->symbol_table) + 1;
        printf("Need to allocate %i byte stack frame for function %s\n", frame_width, function->name);

        fprintf(output, "; Saving frame pointer\n");
        fprintf(output, "\tmovf H'0c', 0\n"); // Load top of stack - 1 into FSR
        fprintf(output, "\taddlw -1\n");
        fprintf(output, "\tmovwf H'04'\n");
        fprintf(output, "\tmovf H'0c', 0\n"); // Store the current frame pointer into the top of the stack
        fprintf(output, "\tmovwf H'00'\n");
        fprintf(output, "\tmovlw %i\n", frame_width); // Now set the new frame pointer
        fprintf(output, "\tsubwf H'0c'\n\n");

        allocate_variables(function->symbol_table);

        List *quads = function->statements;
        while(quads->data != NULL)
        {
            Quad *quad = quads->data;
            write_quad(quad, function);
            quads = quads->next;
        }

        // Restore previous frame pointer and return
        fprintf(output, "; Restoring previous frame pointer\n");
        fprintf(output, "\tmovf H'0c', 0\n"); // Load previous frame pointer
        fprintf(output, "\taddlw %i\n", frame_width - 1);
        fprintf(output, "\tmovwf H'04'\n");
        fprintf(output, "\tmovf H'00', 0\n");
        fprintf(output, "\tmovwf H'0c'\n");
        fprintf(output, "\treturn\n\n");
        
        functions = functions->next;
    }

    fprintf(output, "\tend\n");
}

void allocate_variables(List *symbol_table)
{
    int offset = 0;
    while(symbol_table->data != NULL)
    {
        Variable *variable = symbol_table->data;
        fprintf(output, "; Allocating variable '%s'\n", variable->name);
        fprintf(output, "\tmovf H'0c', 0\n"); // Load next stack position
        fprintf(output, "\taddlw %i\n", offset);
        fprintf(output, "\tmovwf H'04'\n");
        fprintf(output, "\tmovlw %i\n", variable->value); // Store this variable there
        fprintf(output, "\tmovwf H'00'\n\n");

        offset++;
        symbol_table = symbol_table->next;
    }
}

void write_quad(Quad *quad, Function *func)
{
    QuadOperand *operand1 = quad->operand1;
    QuadOperand *operand2 = quad->operand2;
    QuadOperand *result = quad->result;
    fprintf(output, "; '%c' operation\n", quad->operator);
    switch(quad->operator)
    {
        case '+':
        {
            Variable *resvar = (Variable *) result->addr;
            switch(operand1->type)
            {
                case Constant:
                    fprintf(output, "\tmovlw %i\n", operand1->value);
                    break;
                case Pointer:
                {
                    Variable *var = (Variable *) operand1->addr;
                    switch(var->scope)
                    {
                        int offset;
                        case Local:
                            offset = list_index(func->symbol_table, var);
                            fprintf(output, "\tmovf H'0c', 0\n");
                            fprintf(output, "\taddlw %i\n", offset);
                            fprintf(output, "\tmovwf H'04'\n");
                            fprintf(output, "\tmovf H'00', 0\n");
                            break;
                        case Global:
                            offset = list_length(bytecode->globals) - list_index(bytecode->globals, var);
                            fprintf(output, "\tmovf H'%x', 0\n", 0x4f - offset);
                            break;
                    }
                }
            }
            switch(operand2->type)
            {
                case Constant:
                    fprintf(output, "\taddlw %i\n", operand2->value);
                    fprintf(output, "\tmovwf H'0d'\n");
                    break;
                case Pointer:
                {
                    fprintf(output, "\tmovwf H'0d'\n");
                    Variable *var = (Variable *) operand2->addr;
                    switch(var->scope)
                    {
                        int offset;
                        case Local:
                            offset = list_index(func->symbol_table, var);
                            fprintf(output, "\tmovf H'0c', 0\n");
                            fprintf(output, "\taddlw %i\n", offset);
                            fprintf(output, "\tmovwf H'04'\n");
                            fprintf(output, "\tmovf H'00', 0\n");
                            break;
                        case Global:
                            offset = list_length(bytecode->globals) - list_index(bytecode->globals, var);
                            fprintf(output, "\tmovf H'%x', 0\n", 0x4f - offset);
                            break;
                    }
                    fprintf(output, "\taddwf H'0d'\n");
                    break;
                }
            }
            switch(resvar->scope)
            {
                int offset;
                case Local:
                    offset = list_index(func->symbol_table, resvar);
                    fprintf(output, "\tmovf H'0c', 0\n");
                    fprintf(output, "\taddlw %i\n", offset);
                    fprintf(output, "\tmovwf H'04'\n");
                    fprintf(output, "\tmovf H'0d', 0\n");
                    fprintf(output, "\tmovwf H'00'\n");
                    break;
                case Global:
                    offset = list_length(bytecode->globals) - list_index(bytecode->globals, resvar);
                    fprintf(output, "\tmovlw H'%x'\n", 0x4f - offset);
                    fprintf(output, "\tmovwf H'04'\n");
                    fprintf(output, "\tmovf H'0d', 0\n");
                    fprintf(output, "\tmovwf H'00'\n");
                    break;
                case Temporary:
                    break;
            }
            break;
        }

        case 'c':
            if(!strncmp(quad->operand1->name, "printf", 5))
            {
                List *characters = (List *) quad->operand2->addr; 
                while(characters->data != NULL)
                {
                    Variable *character = (Variable *) characters->data;
                    switch(character->type)
                    {
                        case 'c':
                            fprintf(output, "\tmovlw D'%i'\n", (uint8_t)character->value);
                            fprintf(output, "\tmovwf H'06'\n");
                            break;
                        case 'i':
                            if(character->scope = Temporary)
                            {
                                fprintf(output, "\tmovf H'0d', 0\n");
                                fprintf(output, "\tmovwf H'06'\n");
                                break;
                            }

                            int offset;
                            switch(character->scope)
                            {
                                case Local:
                                    offset = list_index(func->symbol_table, character);
                                    fprintf(output, "\tmovf H'0c', 0\n");
                                    fprintf(output, "\taddlw %i\n", offset);
                                    break;
                                case Global:
                                    offset = list_length(bytecode->globals) - list_index(bytecode->globals, character);
                                    fprintf(output, "\tmovf H'%x', 0\n", 0x4f - offset);
                            }
                            fprintf(output, "\tmovwf H'04'\n");
                            fprintf(output, "\tmovf H'00, 0\n");
                            fprintf(output, "\tmovwf H'06'\n");
                            break;
                    }

                    characters = characters->next;
                }
            } else {
                fprintf(output, "\tcall func_%s\n", quad->operand1->name);
            }

            break;

        default:
            fprintf(output, "\tINVALID OPERATOR %c\n", quad->operator);
    }
}

char * gen_label()
{
    char *label = (char *) malloc(6);
    assert(label != NULL);
    sprintf(label, "lbl_%i", label_base);
    label_base++;
    return label;
}
