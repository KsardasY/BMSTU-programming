# include <stdio.h>


int main (int argc, char **argv) {
  int a[8], b[8], k, n, z = 0, i = 0;
  for (int j = 0; j < 8; j++) {
    scanf("%d", &a[j]);
  }
  for (int j = 0; j < 8; j++) {
    scanf("%d", &b[j]);
  }
  while (i == z && i < 8) {
    k = 0;
    n = 0;
    for (int j = 0; j < 8; j++) {
      if (a[i] == a[j]) {
        k++;
      }
    }
    for (int j = 0; j < 8; j++) {
      if (a[i] == b[j]) {
        n++;
      }
    }
    if (k == n) {
      z++;
    }
    i++;
    if (i != z) {
      i = 9;
    }
  }
  if (i == z && i == 8) {
    printf("yes");
  } else {
    printf("no");
  }
  return 0;
}