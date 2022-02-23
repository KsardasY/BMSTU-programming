# include <stdio.h>
# include <malloc.h>
# include <string.h>


int min(const int a, const int b) {
    if (a < b) return a;
    return b;
}


void delta1(const char *s, int **d, int m, int size, char b) {
    int a[size], x;
    for (int i = 0; i < size; i++) a[i] = -1;
    for (int j = 0; j < m; j++) for (int i = 0; i < size; i++) d[j][i] = m;
    for (int j = 0; j < m; j++) for (int i = 0; i < m; i++) {
        if (a[s[i] - b] != -1) d[j][s[i] - b] = m - a[s[i] - b] - 1;
        a[s[j] - b] = j;
    }
}


int simplebmsubst(const char *t, const char *s, int n, int m, int size) {
    char b = 33;
    int **d, k = m - 1, i;
    d = (int**)malloc(m * sizeof(int*));
    for (i = 0; i < m; i++)
        d[i]=(int *)malloc(size * sizeof(int));
    delta1(s, d, m, size, b);
    while (k < n) {
        i = m - 1;
        while (t[k] == s[i]) {
            if (i == 0) {
                for (int j = 0; j < m; j++) free(d[j]);
                free(d);
                return k;
            }
            i--;
            k--;
        }
        k += d[i][t[k] - b];
    }
    for (int j = 0; j < m; j++) free(d[j]);
    free(d);
    return n;
}


int main(int argc, char** argv) {
    char* s = argv[1], *t = argv[2];
    int n = 0, m = 0;
    while (s[m] != '\0' && s[m] != '\n') {
        m++;
    }
    while (t[n] != '\0' && t[n] != '\n') {
       n++;
    }
    int size = 126 - 33 + 1;
    printf("%d", simplebmsubst(t, s, n, m, size));
    return 0;
}
