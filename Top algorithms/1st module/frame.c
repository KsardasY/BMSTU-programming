#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <stdlib.h>


int main(int argc, char** argv) {
    if (argc != 4) printf("Usage: frame <height> <width> <text>");
    else {
        int n = atoi(argv[1]), m = atoi(argv[2]);
        char* s = argv[3];
        int l = 0;
        while (s[l] != '\0' && s[l] != '\n') l++;
        if (l > m - 2) printf("Error");
        else {
            char a[m + 1];
            a[m + 1] = '\0';
            for (int i = 0; i < m; i++) a[i] = '*';
            printf("%s\n", a);
            int ind = (n - 1) / 2;
            for (int i = 1; i < m - 1; i++) a[i] = ' ';
            for (int i = 1; i < ind; i++) printf("%s\n", a);
            int d = (m - l - 2) / 2;
            for (int i = 0; i < l; i++) a[d + 1 + i] = s[i];
            printf("%s\n", a);
            for (int i = 0; i < l; i++) a[d + 1 + i] = ' ';
            for (int i = ind + 1; i < n - 1; i++) printf("%s\n", a);
            for (int i = 1; i < m - 1; i++) a[i] = '*';
            printf("%s\n", a);
            free(a);
        }
    }
    return 0;
}