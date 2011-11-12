#ifndef _LIST_H
#define _LIST_H

typedef struct list
{
    void *data;
    struct list *next;
} List;

List * create_list();
void append_to_list(List *, void *);
List * push_to_list(List *, void *);
List * pop_from_list(List *);
int list_length(List *);
int list_index(List *, void *);
#endif
