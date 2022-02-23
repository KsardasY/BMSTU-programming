# include <stdio.h>
# include <malloc.h>
# include <string.h>
# include <math.h>


int more(char s1[], char s2[]) {
    int i = 0;
    while (s1[i] == s2[i] && s1[i] != '\0') {
        i++;
    }
    if (s1[i] > s2[i]) return 1;
    else return 0;
}


void csort(char *src, char *dest) {
    int l = 0, j, k = 0, *ls = NULL, d, ind_c;
    char **w = NULL, *s = malloc(sizeof(char) * 1000);
    while (src[l] != '\0') {
        if (src[l] != ' ' && src[l] != '\n' && src[l] != '\t') {
            k++;
            j = l + 1;
            ind_c = 1;
            s[0] = src[l];
            while (src[j] != ' ' && src[j] != '\n' && src[j] != '\t' && src[j] != '\0') {
                s[ind_c] = src[j];
                ind_c++;
                j++;
            }
            s[ind_c] = '\0';
            ls = realloc(ls, sizeof(*ls) * k);
            ls[k - 1] = ind_c;
            w = realloc(w, sizeof(*w) * k);
            w[k - 1] = malloc(sizeof(**w) * 1000);
            memcpy(w[k - 1], s, ind_c);
            l = j;
        } else l++;
    }
    free(s);
    int c = k - 1;
    char *to = NULL;
    for (int i = 0; i < k; i++) {
        c += ls[i];
    }
    dest[c] = '\0';
    for (int i = 0; i < k; i++) {
        d = 0;
        for (int v = 0; v < k; v++) {
            if (v != i && (ls[i] > ls[v] || (ls[i] == ls[v] && i > v))) {
                d += 1 + ls[v];
            }
        }
        to = (char*)dest + sizeof(char) * d;
        memcpy(to, w[i], ls[i]);
        if (d + ls[i] != c) {
            dest[d + ls[i]] = ' ';
        }
    }
    for (int i = 0; i < k; i++) {
        free(w[i]);
    }
    free(w);
    free(ls);
}


int main() {
    char *a = malloc(sizeof(char) * 1000), *b = malloc(sizeof(char) * 1000);
    fgets(a, 1000, stdin);
    csort(a, b);
    printf("%s", b);
    free(a);
    free(b);
    return 0;
}