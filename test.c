#include "list.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>

int main()
{
    printf("Testing lists...\n");
    List *list = (List *) create_list();
    assert(list != NULL);
    assert(list->data == NULL);
    assert(list->next == NULL);

    int w = 42;
    int x = 1;
    int y = 2;
    int z = 3;

    append_to_list(list, &x);
    assert(*(int *)(list->data) == 1);
    assert(list->next != NULL);

    append_to_list(list, &y);
    assert(*(int *)(list->next->data) == 2);
    assert(list->next->next != NULL);
    
    append_to_list(list, &z);
    assert(*(int *)(list->next->next->data) == 3);
    assert(list->next->next->next != NULL);

    assert(list->next->next->next->data == NULL);
    assert(list->next->next->next->next == NULL);


    list = (List *) push_to_list(list, &w);
    assert(*(int *)(list->data) == 42);
    assert(list->next != NULL);

    list = (List *) pop_from_list(list);
    assert(*(int *)(list->data) == 1);

    assert(list_length(list) == 3);
    assert(list_index(list, &y) == 1);
    assert(list_index(list, &w) == -1);
    
    printf("List tests passed\n");
    return 0;
}
