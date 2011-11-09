#include "parser.h"

int main(int argc, char *argv[])
{
    printf("Processing %s\n", argv[1]);
    // process flags here
    if(yyin = fopen(argv[1], "r"))
    {
        yyparse();
        fclose(yyin);
    }
    return 0;
}
