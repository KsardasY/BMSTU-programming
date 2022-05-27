#include <stdio.h>
#include <string.h>
#include <malloc.h>


char* concat(char **s, int n){
	int l = 0, t, d[n];
    for (int i = 0; i < n; i++) {
        t = 0;
        while (s[i][t] != '\0' && s[i][t] != '\n') t++;
        d[i] = t;
        l += t;
    }
    int p = 0;
    char *a = malloc((l + 1) * sizeof(char));
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < d[i]; j++) {
            a[p] = s[i][j];
            p++;
        }
    }
	a[l] = '\0';
	return a;
}


int main(void) {
    int n;
    scanf("%d ", &n);
    char** a = malloc(n * sizeof(char*));
    for (int i = 0; i < n; i++) a[i] = malloc(1000 * sizeof(char));
    for (int i = 0; i < n; i++) scanf("%s", a[i]);
    char *s = concat(a, n);
    printf("%s", s);
    for (int i = 0; i < n; i++) free(a[i]);
    free(a);
    free(s);
    return 0;
}
