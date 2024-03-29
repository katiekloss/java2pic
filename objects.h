#ifndef OBJECTS_H
#define OBJECTS_H

#include "list.h"
#include <stdint.h>

typedef enum {
    Constant,
    Pointer,
    String,
    LinkedList
} OperandType;

typedef enum {
    Local,
    Global,
    Temporary
} Scope;

typedef struct {
    char *name;
    char type;
    uint8_t value;
    Scope scope;
} Variable;

typedef struct {
    char *name;
    List *parameters;
    List *symbol_table;
    List *statements;
} Function;

typedef struct {
    OperandType type;
    uint8_t value;
    void *addr;
    char *name;
} QuadOperand;

typedef struct {
    char operator;
    QuadOperand *operand1;
    QuadOperand *operand2;
    QuadOperand *result;
} Quad;

typedef struct {
    List *globals;
    List *functions;
} ImdtCode;
#endif
