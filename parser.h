#ifndef _PARSER_H
#define _PARSER_H

#include <stdio.h>
#include "y.tab.h"
#include "objects.h"

extern FILE *yyin;
extern int yyparse(ImdtCode *program);

int yydebug = 1;
#endif
