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

    printf("List tests passed\n");
    return 0;
}
