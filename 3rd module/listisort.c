#include <stdlib.h>
#include <stdio.h>

typedef struct Elem
{
    int value;
    struct Elem *next;
    struct Elem *prev;
}   elem_t;

typedef struct List
{
    elem_t *head;
    int     size;
} list_t;

void    add_elem(list_t *list, int value)
{
    elem_t *new_elem = (elem_t *) malloc(sizeof(elem_t));
    new_elem->value = value;
    if (list->size == 0)
    {
        list->head = new_elem;
        list->head->next = list->head->prev = new_elem;
    }
    else
    {
        new_elem->next = list->head;
        new_elem->prev = list->head->prev;
        list->head->prev->next = new_elem;
        list->head->prev = new_elem;
    }
    list->size++;
}

void    pop(list_t *list)
{
    if (list->size > 2)
    {
        elem_t *buf = list->head;
        list->head->prev->next = list->head->next;
        list->head->next->prev = list->head->prev;
        list->head = list->head->next;
        free(buf);
        list->size--;
    }
    else if (list->size > 0)
    {
        list->head = list->head->next;
        free(list->head->prev);
        if (list->size == 2)
            list->head->next = list->head->prev = list->head;
        list->size--;
    }
}

void    insertion_sort(list_t *list)
{
    list_t new_list = {0, 0};
    add_elem(&new_list, list->head->value);
    pop(list);
    while (list->size > 0)
    {
        int value = list->head->value;
        pop(list);
        elem_t *current = new_list.head;
        int i = 0;
        while (current->value < value && i < new_list.size)
        {
            current = current->next;
            i++;
        }
        if (i == new_list.size)
            add_elem(&new_list, value);
        else
        {
            elem_t *new_elem = (elem_t *) malloc(sizeof(elem_t));
            new_elem->value = value;
            new_elem->next = current;
            new_elem->prev = current->prev;
            current->prev->next = new_elem;
            current->prev = new_elem;
            if (i == 0)
                new_list.head = new_elem;
            new_list.size++;
        }
    }
    *list = new_list;
}

void    free_list(list_t list)
{
    elem_t *current = list.head;
    int i = 0;
    while (i++ < list.size - 1)
    {
        current = current->next;
        free(current->prev);
    }
    free(current);
}

int     main()
{
    int n;
    scanf("%d", &n);
    list_t list = {NULL, 0};
    for (int i = 0; i < n; i++)
    {
        int value;
        scanf("%d", &value);
        add_elem(&list, value);
    }
    insertion_sort(&list);
    int i = 0;
    elem_t *current = list.head;
    while (i++ < list.size)
    {
        printf("%d ", current->value);
        current = current->next;
    }
    printf("\n");
    free_list(list);
    return (0);
}
