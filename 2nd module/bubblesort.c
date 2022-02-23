# include <stdio.h>
# include <malloc.h>
# include <string.h>
# include <math.h>


void bubblesort(unsigned long nel, int (*compare)(unsigned long i, unsigned long j), void (*swap)(unsigned long i, unsigned long j)) {
  int tr = nel - 1, tl = 0, r = nel - 1, i, l = 0;
  char f = 1;
  while (l < r) {
    if (f == 1) {
      r = tr;
      tr = l;
      i = l;
      while (i < r) {
        if (compare(i + 1, i) == -1) {
          swap(i, i + 1);
          tr = i;
        }
      i++;
      }
      f = 0;
    } else {
      l = tl;
      tl = r;
      i = r;
      while (i > l) {
        if (compare(i - 1, i) == 1) {
          swap(i - 1, i);
          tl = i;
        }
        i--;
      }
      f = 1;
    }
  }
}


int main() {
	return 0;
}
