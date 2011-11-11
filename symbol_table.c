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

Variable * search_table_chain(List *table_chain, char *name)
{
    while(table_chain->data != NULL)
    {
        List *symbol_table = (List *)table_chain->data;
        while(symbol_table->data != NULL)
        {
            if(!strcmp(((Variable *)symbol_table->data)->name, name)) return (Variable *)symbol_table->data;
            symbol_table = symbol_table->next;
        }
        table_chain = table_chain->next;
    }
}
