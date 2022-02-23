# include <stdio.h>


int main (int argc, char ** argv) {
  int n;
  long long a;
  scanf("%d %lld", &n, &a);
  long long pol1, der = 0, pol = 0;
  if (n != 0) {
    for (int i = n; i >= 0; i--) {
      scanf("%lld", &pol1);
      pol = (pol1 + pol);
      if (i != 0) {
        pol = pol * a;
      }
      der = der + pol1 * i;
      if (i > 1) {
        der = der * a;
      }
    }
  }
  printf("%lld %lld", pol, der);
}