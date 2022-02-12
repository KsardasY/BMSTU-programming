# include <stdio.h>
# include <malloc.h>
# include <math.h>


void key(const char *s, int *keys, int nel, char b) {
    for (int i = 0; i < nel; i++) keys[s[i] - b]++;
}


void distributionsort(const char *s, char *sd, const int *keys, int m, int n, char b) {
    int d[26], k;
    d[0] = keys[0];
    for (int i = 1; i < m; i++) {
        d[i] = d[i - 1] + keys[i];
    }
    for (int j = n - 1; j >= 0; j--) {
        k = s[j] - b;
        d[k]--;
        sd[d[k]] = s[j];
    }
}


int main() {
    int m = (int) pow(10, 6), *keys = malloc(sizeof(int) * 26), n = 0;
    char* s = malloc(m), b = 'a';
    fgets(s, m, stdin);
    while (s[n] != '\0' && s[n] != '\n' && s[n] != '\t' && s[n] != ' ') {
        n++;
    }
    for (char i = 0; i < 26; i++) {
        keys[i] = 0;
    }
    key(s, keys, n, b);
    char* sd = malloc(n + 1);
    distributionsort(s, sd, keys, 26, n, b);
    sd[n] = '\0';
    free(s);
    free(keys);
    printf("%s", sd);
    free(sd);
    return 0;
}
