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

List * push_to_list(List *list, void *data_ptr)
{
    List *new_head = (List *) malloc(sizeof(List));
    assert(new_head != NULL);

    new_head->next = list;
    new_head->data = data_ptr;

    return new_head;
}

List * pop_from_list(List *list)
{
    List *new_head = list->next;
    free(list);
    return new_head;
}

int list_length(List *list)
{
    int length = 0;
    while(list->data != NULL)
    {
        length++;
        list = list->next;
    }
    return length;
}

int list_index(List *list, void *ptr)
{
    List *list_node = list;
    while(list_node->data != NULL)
    {
        if(list_node->data == ptr)
        {
            return list_node - list;
        }
        list_node = list_node->next;
    }

    return -1;
}
