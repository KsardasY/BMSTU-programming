# include <stdio.h>
# include <malloc.h>
# include <string.h>


void delta1(const char *s, int *d, int m, int size, char b) {
    for (int i = 0; i < size; i++) d[i] = m;
    for (int i = 0; i < m; i++) d[s[i] - b] = m - i - 1;
}


void suffix(const char *s, int *q, int m) {
    int t = m - 1;
    q[m - 1] = t;
    for (int i = m - 2; i >= 0; i--) {
        while (t < m - 1 && s[t] != s[i]) t = q[t + 1];
        if (s[t] == s[i]) t--;
        q[i] = t;
    }
}
int max(int a, int b) {
    if (a > b) return a;
    return b;
}

void delta2(const char *s, int* z, int m) {
    int q[m];
    suffix(s, q, m);
    int t = q[0];
    for (int i = 0; i < m; i++) {
        while (t < i) t = q[t + 1];
        z[i] = m + t - i;
    }
    for (int i = 0; i < m - 1; i++) {
        t = i;
        while (t < m - 1) {
            t = q[t + 1];
            if (s[i] != s[t]) {
                z[t] = m - i - 1;
            }
        }
    }
}


void bmsubst(const char *t, const char *s, int *a, int n, int m, int size) {
    char b = 33;
    int d[size], z[m], k = m - 1, i, j = 0, l, w;
    delta1(s, d, m, size, b);
    delta2(s, z, m);
    while (k < n) {
        i = m - 1;
        w = k + 1;
        l = j;
        while (t[k] == s[i]) {
            if (i == 0) {
                a[j] = k;
                j++;
            }
            i--;
            k--;
        }
        if (l < j) k = w;
        else k += max(d[t[k] - b], z[i]);
    }
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
    int a[n], size = 126 - 33 + 1;
    for (int i = 0; i < n; i++) a[i] = -1;
    bmsubst(t, s, a, n, m, size);
    for (int i = 0; a[i] != -1 && i < n; i++) printf("%d ", a[i]);
    return 0;
}
