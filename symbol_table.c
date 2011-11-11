#include "list.h"
#include "objects.h"
#include <string.h>

void print_symbol_table(List *symbol_table)
{
    printf("Name\tType\tValue\n------------------------------\n");
    while(symbol_table->next != NULL)
    {
        Variable table_entry = (Variable)*((Variable *)symbol_table->data);
        printf("%s\t%c\t%i\n", table_entry.name, table_entry.type, table_entry.value);
        symbol_table = symbol_table->next;
    }
}
