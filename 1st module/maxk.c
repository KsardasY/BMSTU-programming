# include <stdio.h>


int main (int argc, char **argv) {
  int n, k, j = 0;
  long long s = 0, m = 0;
  scanf("%d", &n);
  int a[n];
  for (int i = 0; i < n; i++) {
    scanf("%d", &a[i]);
  }
  scanf("%d", &k);
  while (j < k) {
    s += a[j];
    j++;
  }
  m = s;
  for (int i = j; i < n; i++) {
    s += a[i] - a[i - k];
    if (s > m) {
      m = s;
    }
  }
  printf("%lld", m);
  return 0;
}
