# include <stdio.h>
# include <malloc.h>
# include <string.h>


unsigned long binsearch(unsigned long nel, int (*compare)(unsigned long i)) {
  unsigned long l = 0, r = nel, m;
  while (l < r - 1) {
    m = (l + r) / 2;
    if (compare(m) <= 0) {
      l = m;
    } else r = m;
  }
  if (compare(l) == 0) {
    return l;
  } else return nel;
}


int main(int argc, char** argv) {
	return 0;
}
