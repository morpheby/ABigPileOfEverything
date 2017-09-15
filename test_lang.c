#include <stdio.h>
#include <stdlib.h>

typedef struct ListStruct list_t;
typedef int value_t;
struct ListStruct {
    list_t *prev, *next;
    value_t value;
};

typedef void *(*allocFunct_t)(size_t sz);

/* Returns head of the list */
list_t *create_list(value_t *array, size_t count, allocFunct_t allocFunct) {
    if (count == 0) {
        return 0;
    }
    
    list_t *head = allocFunct(sizeof(list_t)), *tail = head;
    head->prev = 0;
    head->value = *(array++);
    
    while(--count) {
        tail->next = allocFunct(sizeof(list_t));
        tail->next->prev = tail;
        tail = tail->next;
        tail->value = *(array++);
    }
    
    tail->next = 0;
    
    return head;
}

int main() {
    int t[] = {1, 2, 3, 4};
    int i;
    list_t *list = create_list(t, 4, malloc);
    for (i = 0; i < 3; ++i) {
        printf("%d ", list->value);
        list = list->next;
    }
    printf("%d ", list->value);
    printf("\n");
    for (i = 0; i < 4; ++i) {
        printf("%d ", list->value);
        list = list->prev;
    }
    printf("\n");
    return 0;
}
