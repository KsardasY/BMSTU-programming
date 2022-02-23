# include <stdio.h>
# include <malloc.h>
# include <string.h>
# include <math.h>


void segmenttree_update(int *t, int n, int i, char *s, char b) {
    int x, ind;
    for (int j = 0; s[j] !='\n' && s[j] != '\0'; j++) {
        x = pow(2, s[j] - b);
        ind = i + j + n;
        t[ind] = x;
        for (ind = ind / 2; ind > 0; ind /= 2) t[ind] = t[ind] ^ t[ind * 2 + 1];
        t[ind] = t[ind] ^ t[ind * 2 + 1];
    }
}


int segmenttree_query(const int *t, int n, int l, int r, int size) {
    int s = 0;
    char f = 1;
    if (l == r) s = t[l + n];
    else {
        l += n;
        r += n;
        while (l < r && f) {
            if (l % 2 != 0 && l + 1 < r) s ^= t[l++];
            if (r % 2 == 0 && l < r - 1) s ^= t[r--];
            if (r - l <= 1) {
                s ^= t[l] ^ t[r];
                f = 0;
            }
            if (f) {
                l /= 2;
                r /= 2;
            }
        }
    }
    int c = 0;
    for (int i = 0; i < size; i++) c += (s >> i) % 2;
    return c <= 1;
}


int main(int argc, char** argv) {
    char b = 'a';
    int lm = 1000001, n = 0, m;
    char s[lm];
    fgets(s, lm, stdin);
    while (s[n] != '\n' && s[n] != '\0') n++;
    int p = 1;
    while (p < n) p *= 2;
	int *z = (int*)malloc(p * sizeof(int));
    for (int i = 0; i < p; i++) z[i] = pow(2, s[i] - b);
    int *t = (int*)malloc(sizeof(int) * p * 2);
    for (int i = 0; i < p * 2; i++) t[i] = 0;
    for(int i = 0; i < p; i++) t[p + i] = z[i];
    free(z);
    for(int i = p - 1; i > 0; i--) t[i] = t[i * 2] ^ t[i * 2 + 1];
    scanf("%d", &m);
    char c[4], h[lm];
    int l, r, size = 'z' - b + 1;
    for (int j = 0; j < m; j++) {
        scanf("%s %d", c, &l);
        if (!(strcmp(c, "UPD"))) {
            scanf("%s", h);
            segmenttree_update(t, p, l, h, b);
        } else {
            scanf("%d", &r);
            if (segmenttree_query(t, p, l, r, size)) printf("YES\n");
            else printf("NO\n");
        }
    }
    free(t);
    return 0;
}
