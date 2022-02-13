# include <stdio.h>
# include <malloc.h>
# include <string.h>


void prefix(const char *s, int* p, int n) {
    p[0] = 0;
    int t = 0;
    for (int i = 1; i < n; i++) {
        while (t > 0 && s[t] != s[i]) {
            t = p[t - 1];
        }
        if (s[t] == s[i]) t++;
        p[i] = t;
    }
}


void kmpsubst(const char *t, const char *s, int n, int m, int *a, int *p) {
    prefix(s, p, m);
    int q = 0, k = 0, i = 0;
    while (k < n) {
        while (q > 0 && s[q] != t[k]) q = p[q - 1];
        if (s[q] == t[k]) q++;
        if (q == m) {
            a[i] = k - m + 1;
            i++;
            q = 0;
            k -= m - 2;
        } else {
            k++;
        }
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
    int a[n], p[m];
    for (int i = 0; i < n; i++) {
        a[i] = -1;
    }
    kmpsubst(t, s, n, m, a, p);
    for (int i = 0; a[i] != -1 && i < n; i++) printf("%d ", a[i]);
    return 0;
}
