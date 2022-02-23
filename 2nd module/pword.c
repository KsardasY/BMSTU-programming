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


char kmpsubst(const char *t, const char *s, int n, int m, int *p) {
    prefix(s, p, m);
    int q = 0, k = 0;
    while (k < n) {
        while (q > 0 && s[q] != t[k]) q = p[q - 1];
        if (s[q] == t[k]) q++;
        if (q == 0) return 0;
        if (q == m) {
            q = 0;
        }
        k++;
    }
    return 1;
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
    int p[m];
    if (kmpsubst(t, s, n, m, p)) printf("yes");
    else printf("no");
    return 0;
}
