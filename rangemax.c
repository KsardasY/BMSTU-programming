# include <stdio.h>
# include <malloc.h>
# include <string.h>


int max(int a, int b) {
    if (a > b) return a;
    return b;
}


void build(const int *a, int l, int r, int *t, int i) {
    int b = 2 * i + 1, c = b + 1;
    if (l == r) t[i] = a[l];
    else {
        int m = (l + r) / 2;
        build(a, l, m, t, b);
        build(a, m + 1, r, t, c);
        t[i] = max(t[b], t[c]);
    }
}


void segmenttree_build(int *a, int n, int **t) {
    build(a, 0, n - 1, *t, 0);
}


void update(int *t, int j, int x, int l, int r, int i) {
    int b = 2 * i + 1, c = b + 1;
    if (l == r) t[i] = x;
    else {
        int m = (l + r) / 2;
        if(j <= m) update(t, j, x, l, m, b);
        else update(t, j, x, m + 1, r, c);
        t[i] = max(t[b], t[c]);
    }
}


void segmenttree_update(int *t, int j, int x, int n) {
    update(t, j, x, 0, n - 1, 0);
}


int query(int *t, int l, int r, int a, int d, int i)
{
    int b = 2 * i + 1, c = b + 1;
    if (l == a && r == d) return t[i];
    int m = (a + d) / 2;
    if (r <= m) return query(t, l, r, a, m, b);
    if (l > m) return query(t, l, r, m + 1, d, c);
    return max(query(t, l, m, a, m, b), query(t, m + 1, r, m + 1, d, c));
}


int segmenttree_query(int *t, int n, int l, int r) {
    return query(t, l, r, 0, n - 1, 0);
}


int main(int argc, char** argv) {
    int n, m, l ,r;
    scanf("%d", &n);
    int a[n];
    for (int i = 0; i < n; i++) scanf("%d", &a[i]);
    int *t = (int*)malloc(sizeof(int) * 4 * n);
    segmenttree_build(a, n, &t);
    scanf("%d", &m);
    char s[4];
    for (int j = 0; j < m; j++) {
        scanf("%s %d %d", &s, &l, &r);
        if (!(strcmp(s, "UPD"))) segmenttree_update(t, l, r, n);
        else printf("%d\n", segmenttree_query(t, n, l, r));
    }
    free(t);
    return 0;
}
