# include <stdio.h>
# include <malloc.h>
# include <string.h>
# include <math.h>

unsigned long fib(unsigned long n) {
  unsigned long a = 0, b = 1, z;
  while (b < n) {
    z = b;
    b += a;
    a = z;
  }
  return a;
}


void shellsort(unsigned long nel, int (*compare)(unsigned long i, unsigned long j), void (*swap)(unsigned long i, unsigned long j)) {
  long long d = fib(nel), i, l;
  char f = 1;
  while (d > 0) {
    i = 1;
    while (i < nel) {
      l = i - 1;
      if (l >= 0 && compare(l, i) == 1) {
        swap(l + 1, l);
        l -= d;
      }
      while (l >= 0 && compare(l, l + d) == 1) {
        swap(l + d, l);
        l -= d;
      }
      i++;
    }
    d--;
  }
}


int main() {
	return 0;
}
