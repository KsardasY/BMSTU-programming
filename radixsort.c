# include <stdio.h>
# include <malloc.h>


union Int32 {
    int x;
    unsigned char bytes[4];
};


unsigned char key(union Int32 c, int ind) {
    if (ind != 3) return c.bytes[ind];
    else return c.bytes[3] - 128;
}


void distributionsort(union Int32 *a, union Int32 *sd, const int *keys, int m, int n, int ind) {
    int d[m], k;
    d[0] = keys[0];
    for (int i = 1; i < m; i++) {
        d[i] = d[i - 1] + keys[i];
    }
    for (int j = n - 1; j >= 0; j--) {
        k = key(a[j], ind);
        d[k]--;
        sd[d[k]] = a[j];
    }
}


void radixsort(union Int32 *a, union Int32 *sd, int nel) {
    int len = 256;
    for (int i = 0; i < 4; i++) {
        int keys[len];
        for (int j = 0; j < len; j++) keys[j] = 0;
        for (int j = 0; j < nel; j++) keys[key(a[j], i)]++;
        distributionsort(a, sd, keys, len, nel, i);
        for (int j = 0; j < nel; j++) a[j] = sd[j];
    }
}


int main() {
    int n;
    scanf("%d", &n);
    union Int32 a[n], *s = malloc(sizeof(union Int32) * n);
    for (int i = 0; i < n; i++) scanf("%d", &a[i].x);
    radixsort(a, s, n);
    free(s);
    for (int i = 0; i < n; i++) printf("%d ", a[i].x);
    return 0;
}