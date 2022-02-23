# include <stdio.h>


int main (int argc, char **argv) {
  long long a, b, m, d[63];
  for (int j = 62; j >= 0; j--) {
    d[j] = 0;
  }
  scanf("%lld %lld %lld", &a, &b, &m);
  a = a % m;
  b = b % m;
  int i = 0;
  while (b > 0) {
    d[i] = b % 2;
    b = b / 2;
    i++;
  }
  int g = 62;
  while (d[g] == 0 && g >= 0) {
    g--;
  }
  unsigned long long r = 0;
  for (int j = g; j > 0; j--) {
    r = (((r + (a * d[j]) % m) % m) * 2) % m;
  }
  r = (r + (a * d[0])) % m;
  printf("%llu", r);
  return 0;
}
