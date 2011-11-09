#include "parser.h"

int main(int argc, char *argv[])
{
    // process flags here
    if(yyin = fopen(argv[1], "r"))
    {
        yyparse();
        fclose(yyin);
    }
    return 0;
}
