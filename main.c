#include "parser.h"
#include "objects.h"
#include <assert.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    // process flags here
    if(yyin = fopen(argv[1], "r"))
    {
        ImdtCode *bytecode = (ImdtCode *) malloc(sizeof(ImdtCode));
        assert(bytecode != NULL);
        yyparse(bytecode);
        fclose(yyin);
    }
    return 0;
}
