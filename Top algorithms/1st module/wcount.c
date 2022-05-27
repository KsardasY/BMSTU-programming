#include <stdio.h>
#include <string.h>
#include <malloc.h>


int wcount(char *s) {
	int c = 0, i = 0;
    char f = 1;
    while (s[i] != '\0' && s[i] != '\n') {
        if (s[i] != ' ' && s[i] != '\t') {
            if (f) {
                c++;
                f = 0;
            }
        } else f = 1;
        i++;
    }
    return c;
}


int main() {
    int l = 1000;
    char* s = malloc(sizeof(char) * l);
    fgets(s, l, stdin);
    printf("%d", wcount(s));
    free(s);
    return 0;
}
