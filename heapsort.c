# include <stdio.h>
# include <malloc.h>
# include <string.h>
# include <math.h>


int compare(const  void *a, const void *b) {
    int k = 0, i = 0;
    char *c = NULL;
    c = (char*) a;
    while (c[i] != '\0') {
        if (c[i] == 'a') k++;
        i++;
    }
    c = (char*) b;
    i = 0;
    while (c[i] != '\0') {
        if (c[i] == 'a') k--;
        i++;
    }
    return k;
}


void heapify(void *base, size_t nel, size_t ind, size_t width, int (*compare)(const void *a, const void *b)) {
    char f = 1, *ui = NULL, *ul = NULL, *uj = NULL, *ur = NULL, *tmp = malloc(width);
    int l, r, j, i = (int) ind;
    while (f) {
        l = 2 * i + 1;
        r = l + 1;
        j = i;
        uj = (char*) base + j * width;
        ui = (char*) base + i * width;
        if (l < nel) ul = (char*) base + l * width;
        if (r < nel) ur = (char*) base + r * width;
        if (l < nel && compare(ui, ul) < 0) {
            i = l;
            ui = ul;
        }
        if (r < nel && compare(ui, ur) < 0) {
            i = r;
            ui = ur;
        }
        if (i == j) f = 0;
        else {
            memcpy(tmp, uj, width);
            memcpy(uj, ui, width);
            memcpy(ui, tmp, width);
        }
    }
    free(tmp);
}


void buildheap(void *base, size_t nel, size_t width, int (*compare)(const void *a, const void *b)) {
    int i = (int) nel / 2 - 1;
    while (i >= 0) {
        heapify(base, nel, i, width, compare);
        i--;
    }
}


void hsort(void *base, size_t nel, size_t width, int (*compare)(const void *a, const void *b)) {
    buildheap(base, nel, width, compare);
    int i = (int) nel - 1;
    char *ui = NULL, *u0 = NULL, *tmp = malloc(width);
    while (i > 0) {
        u0 = (char*) base;
        ui = (char*) base + i * width;
        memcpy(tmp, u0, width);
        memcpy(u0, ui, width);
        memcpy(ui, tmp, width);
        heapify(base, i, 0, width, compare);
        i--;
    }
    free(tmp);
}


int main() {
    int n;
    scanf("%d\n", &n);
    char words[n][1000];
    for (int i = 0; i < n; i++) {
        fgets(words[i], 1000, stdin);
    }
    hsort(words, n, sizeof(char) * 1000, compare);
    for (int i = 0; i < n; i++) {
        printf("%s ", words[i]);
    }
    return 0;
}