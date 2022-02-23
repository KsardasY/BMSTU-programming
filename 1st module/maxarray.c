# include <stdio.h>
# include <malloc.h>
# include <string.h>


int maxarray(void *base, size_t nel, size_t width, int (*compare) (void *a, void *b)) {
  char *m = malloc(width);
  int ind = 0;
  memcpy(m, base, width);
  for (size_t i = 1; i < nel; i++) {
    char *from = (char*)base + i * width;
    if (compare(from, m) > 0) {
      ind = (int) i;
      memcpy(m, from, width);
    }
  }
  free(m);
  return ind;
}


int main(int argc, char** argv) {
	return 0;
}
