# include <stdio.h>
# include <malloc.h>
# include <stdlib.h>


int main (int argc, char **argv) {
  int n, m, e, p;
  unsigned int a = 0, b = 0;
  scanf("%d", &n);
  for (int i = 0; i < n; i++) {
    scanf("%d", &e);
    p = 1;
    for (int j = 0; j < e; j++) {
      p *= 2;
    }
    a += p;
  }
  scanf("%d", &m);
  for (int i = 0; i < m; i++) {
    scanf("%d", &e);
    p = 1;
    for (int j = 0; j < e; j++) {
      p *= 2;
    }
    b += p;
  }
  e = 0;
  while (b > 0) {
    if (b % 2 == 1 && a % 2 == 1) {
      printf("%d ", e);
    }
    e++;
    a /= 2;
    b /= 2;
  }
  return 0;
}