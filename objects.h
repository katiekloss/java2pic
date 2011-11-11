#ifndef OBJECTS_H
#define OBJECTS_H

#include "list.h"
#include <stdint.h>

typedef struct {
    char *name;
    char type;
    uint8_t value;
} Variable;

typedef struct {
    char *name;
    List *parameters;
    List *symbol_table;
    List *statements;
} Function;

typedef struct {
    char operator;
    void *operand1;
    void *operand2;
} Operation;

typedef struct {
    List *globals;
    List *functions;
} ImdtCode;
#endif
