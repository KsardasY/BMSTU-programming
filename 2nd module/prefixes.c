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


int main(int argc, char** argv) {
    char* s = argv[1];
    int n = 0;
    while (s[n] != '\0' && s[n] != '\n') {
        n++;
    }
    int p[n];
    prefix(s, p, n);
    int l, d;
    for (int i = 0; i < n; i++) {
        l = i + 1, d = l - p[i];
        if (p[i] != 0 && l % d == 0) {
            printf("%d %d\n", l, l / d);
        }
    }
    return 0;
}
