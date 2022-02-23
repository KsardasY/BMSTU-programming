# include <stdio.h>
# include <malloc.h>
# include <string.h>


void revarray(void *base, size_t nel, size_t width) {
  char *tmp = malloc(width);
  for (size_t i = 0; i < nel / 2; i++) {
    char *from = (char*)base + i * width, *to = (char*)base + (nel - i - 1) * width;
    memcpy(tmp, from, width);
    memcpy(from, to, width);
    memcpy(to, tmp, width);
  }
  free(tmp);
}


int main(int argc, char** argv) {
  // int n = 4;
	// double a[] = { 3.1415926535897932384626433832795, 2.7182818284590452353602874713527, 1.380649e-23, 6.02214076e+23 };
  // int b[] = { 1, 2, 3, 4 };
  // revarray(&b, n, sizeof(int));
  // printf("\n------------\n");
  // for (int i = 0; i < 4; i++) printf("%d ", b[i]);
  // printf("\n+++++++++++++++++\n");
  // for (int i = 0; i < n; i++) printf("%e ", a[i]);
  // revarray(&a, n, sizeof(double));
  // printf("\n------------\n");
  // for (int i = 0; i < n; i++) printf("%e ", a[i]);
	return 0;
}
