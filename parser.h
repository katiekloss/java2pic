#ifndef _PARSER_H
#define _PARSER_H

#include <stdio.h>
#include "y.tab.h"

extern FILE *yyin;
extern int yyparse(void);

int yydebug = 1;
#endif
