#ifndef _LIST_H
#define _LIST_H

typedef struct list
{
    void *data;
    struct list *next;
} List;

#endif
