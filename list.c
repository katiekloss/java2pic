/* Implements a simple append-only linked list */

#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "list.h"

List * create_list()
{
    List *new_list = (List *) malloc(sizeof(List));
    assert(new_list != NULL);
    new_list->data = NULL;
    new_list->next = NULL;
    return new_list;
}

void append_to_list(List *list, void *data_ptr)
{
    while(list->next != NULL) list = list->next;
    
    List *new_node = (List *) malloc(sizeof(List));
    assert(new_node != NULL);

    list->next = new_node;
    list->data = data_ptr;

    new_node->data = NULL;
    new_node->next = NULL;
}

List * prepend_to_list(List *list, void *data_ptr)
{
    List *new_head = (List *) malloc(sizeof(List));
    assert(new_head != NULL);

    new_head->next = list;
    new_head->data = data_ptr;

    return new_head;
}
