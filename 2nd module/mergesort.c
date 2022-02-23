# include <stdio.h>
# include <stdlib.h>
# include <malloc.h>
# include <string.h>
# include <math.h>


int compare(const  void *a, const void *b) {
    int *x = (int*) a, *y = (int*) b;
    return abs(*x) - abs(*y);
}


void insertionsort(void *base, size_t nel, size_t width, int (*compare)(const  void *a, const void *b)) {
    int n = (int) nel, l;
    char* x = malloc(width);
    for (int i = 1; i < n; i++) {
        memcpy(x, (char*) base + i * width, width);
        l = i - 1;
        while (l >= 0 && (compare((char*) base + l * width, x) > 0)) {
            memcpy((char*) base + (l + 1) * width, (char*) base + l * width, width);
            l--;
        }
        memcpy((char*) base + (l + 1) * width, x, width);
    }
    free(x);
}


void merge(void *base, size_t k, size_t l, size_t m, size_t width, int (*compare)(const  void *a, const void *b)) {
    char* d = malloc(((int) (m - k + 1)) * width);
    int i = (int) k, j = (int) l + 1, h = 0;
    while (h < m - k + 1) {
        if (j <= m && (i == l + 1 || compare((char*) base + j * width, (char*) base + i * width) < 0)) {
            memcpy(d + h * width, (char*) base + j * width, width);
            j++;
        } else {
            memcpy(d + h * width, (char*) base + i * width, width);
            i++;
        }
        h++;
    }
    memcpy((char*) base + (int) k * width, d, width * (m - k + 1));
    free(d);
}


void mergesortrec(void *base, size_t left, size_t right, size_t width, int (*compare)(const  void *a, const void *b)) {
    int l = left, r = right, m;
    if (r - l < 4) insertionsort((char*) base + l * width, r - l + 1, width, compare);
    else {
        if (l < r) {
            m = (l + r) / 2;
            mergesortrec(base, l, m, width, compare);
            mergesortrec(base, m + 1, r, width, compare);
            merge(base, l, m, r, width, compare);
        }
    }
}



void mergesort(void *base, size_t nel, size_t width, int (*compare)(const  void *a, const void *b)) {
    mergesortrec(base, 0, nel - 1, width, compare);
}


int main() {
    int n;
    scanf("%d", &n);
    int a[n];
    for (int i = 0; i < n; i++) {
        scanf("%d", &a[i]);
    }
    mergesort(a, n, sizeof(int), compare);
    for (int i = 0; i < n; i++) {
        printf("%d ", a[i]);
    }
    return 0;
}
