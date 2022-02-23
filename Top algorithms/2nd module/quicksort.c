# include <stdio.h>
# include <malloc.h>
# include <string.h>
# include <math.h>


int compare(const  void *a, const void *b) {
    int *x = (int*) a, *y = (int*) b;
    return *x - *y;
}


void selectsort(void *base, size_t nel, size_t width, int (*compare)(const  void *a, const void *b)) {
    int i, j = (int) nel - 1, k, *x = malloc(width);
    while (j > 0) {
        k = j;
        i = j - 1;
        while (i >= 0) {
            if (compare((char*) base + k * width, (char*) base + i * width) < 0) {
                k = i;
            }
            i--;
        }
        memcpy(x, (char*) base + j * width, width);
        memcpy((char*) base + j * width, (char*) base + k * width, width);
        memcpy((char*) base + k * width, x, width);
        j--;
    }
    free(x);
}


int partition(void *base, size_t left, size_t right, size_t width, int (*compare)(const  void *a, const void *b)) {
    int l = (int) left, i = l, j = l, h = (int) right;
    char* x = malloc(width);
    while (j < h) {
        if (compare((char*) base + j * width, (char*) base + h * width) < 0) {
            memcpy(x, (char*) base + j * width, width);
            memcpy((char*) base + j * width, (char*) base + i * width, width);
            memcpy((char*) base + i * width, x, width);
            i++;
        }
        j++;
    }
    memcpy(x, (char*) base + h * width, width);
    memcpy((char*) base + h * width, (char*) base + i * width, width);
    memcpy((char*) base + i * width, x, width);
    free(x);
    return i;
}


void quicksortrec(void *base, size_t m, size_t left, size_t right, size_t width, int (*compare)(const  void *a, const void *b)) {
    int l = (int) left, r = (int) right, b = (int) m, q;
    if (r - l + 1 < b) selectsort((char*) base + l * width, r - l + 1, width, compare);
    else {
        q = partition(base, l, r, width, compare);
        quicksortrec(base, m, l, q - 1, width, compare);
        quicksortrec(base, m, q + 1, r, width, compare);
    }
}


void quicksort(void *base, size_t nel, size_t m, size_t width, int (*compare)(const  void *a, const void *b)) {
    quicksortrec(base, m, 0, nel - 1, width, compare);
}


int main() {
    int n, m;
    scanf("%d %d", &n, &m);
    int a[n];
    for (int i = 0; i < n; i++) {
        scanf("%d", &a[i]);
    }
    quicksort(a, n, m, sizeof(int), compare);
    for (int i = 0; i < n; i++) {
        printf("%d ", a[i]);
    }
    return 0;
}