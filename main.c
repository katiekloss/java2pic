#include "parser.h"
#include "objects.h"
#include "imdtcode.h"
#include <assert.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    // process flags here

    ImdtCode *bytecode;
    if(yyin = fopen(argv[1], "r"))
    {
        bytecode = (ImdtCode *) malloc(sizeof(ImdtCode));
        assert(bytecode != NULL);
        yyparse(bytecode);
        fclose(yyin);
    }
    dump_imdt_code(bytecode);
    return 0;
}
