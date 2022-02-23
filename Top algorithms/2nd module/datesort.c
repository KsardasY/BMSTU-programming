# include <stdio.h>
# include <malloc.h>
# include <math.h>


struct Date {
    int Day, Month, Year;
};


int key(const struct Date d, int ind) {
    int k[3] = {d.Day - 1, d.Month - 1, d.Year - 1970};
    return k[ind];
}


void distributionsort(const struct Date *a, struct Date *sd, const int *keys, int m, int n, int ind) {
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


void datesort(struct Date *a, struct Date *sd, int nel) {
    int len[3] = {31, 12, 61};
    for (int i = 0; i < 3; i++) {
        int keys[len[i]];
        for (int j = 0; j < len[i]; j++) keys[j] = 0;
        for (int j = 0; j < nel; j++) keys[key(a[j], i)]++;
        distributionsort(a, sd, keys, len[i], nel, i);
        for (int j = 0; j < nel; j++) a[j] = sd[j];
    }
}


int main() {
    int n;
    scanf("%d", &n);
    struct Date a[n], *s = malloc(sizeof(struct Date) * n);
    for (int i = 0; i < n; i++) scanf("%d %d %d", &a[i].Year, &a[i].Month, &a[i].Day);
    datesort(a, s, n);
    free(s);
    for (int i = 0; i < n; i++) printf("%04d %02d %02d\n", a[i].Year, a[i].Month, a[i].Day);
    return 0;
}