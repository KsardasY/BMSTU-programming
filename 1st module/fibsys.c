# include <stdio.h>
# include <malloc.h>
# include <stdlib.h>


int main (int argc, char **argv) {
  long long x;
  scanf("%lld", &x);
  if (x == 0) {
    printf("%d", 0);
  } else {
    long long i = 0, n = 2, *a = NULL;
    a = malloc(sizeof(long long) * n);
    a[0] = 1;
    a[1] = 2;
    while (x > a[i]) {
      i++;
      if (i == n) {
        n++;
        a = realloc(a, sizeof(long long) * n);
        a[i] = a[i - 1] + a[i - 2];
      }
    }
    if (a[n - 1] != x) {
      n--;
    }
    for (long long i = n - 1; i >= 0; i--) {
      if (a[i] > x) {
        printf("%d", 0);
      } else {
        printf("%d", 1);
        x -= a[i];
      }
    }
    free(a);
    a = NULL;
  }
  return 0;
}
