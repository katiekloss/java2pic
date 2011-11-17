#include "parser.h"
#include "objects.h"
#include "imdtcode.h"
#include "codegen_pic.h"
#include <assert.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[])
{
    // process flags here

    ImdtCode *bytecode;
    int optimize_level = 1;
    char *filename;

    if(argc > 1)
    {
        for(int i = 1; i < argc; i++)
        {
            if(!strncmp(argv[i], "-O0", 3))
            {
                optimize_level = 0;
            }
            else if(!strncmp(argv[i], "-O1", 3))
            {
                optimize_level = 1;
            }
            else if(!strncmp(argv[i], "-O2", 3))
            {
                optimize_level = 2;
            }
            else
            {
                filename = strdup(argv[i]);
            }
        }
    }
    else
    {
        printf("Usage: java2pic [-O<optimization level>] filename.java\n");
        exit(0);
    }

    char *slash_pos = (char *) rindex(filename, '/') + 1;
    char *ext_pos = (char *) rindex(filename, '.') + 1;
    char *outputname = malloc(strlen(slash_pos));
    assert(outputname != NULL);
    strncpy(outputname, slash_pos, ext_pos - slash_pos);
    strcat(outputname, "asm");
    if(yyin = fopen(filename, "r"))
    {
        bytecode = (ImdtCode *) malloc(sizeof(ImdtCode));
        assert(bytecode != NULL);
        yyparse(bytecode);
        fclose(yyin);
    }

    dump_imdt_code(bytecode);

    FILE *output;
    if(output = fopen(outputname, "w"))
    {
        codegen_pic(output, bytecode);
        fclose(output);
    }

    return 0;
}
