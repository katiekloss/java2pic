#include "objects.h"
#include <stdlib.h>
#include <stdio.h>

void codegen_pic(FILE *, ImdtCode *);
void write_globals();
void write_functions();
void write_preamble();
void allocate_variables(List *);
