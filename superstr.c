# include <stdio.h>
# include <malloc.h>
# include <string.h>
# include <math.h>


int overlay(char a[], char b[]) {
  if (a[2] == b[3]) return 1;
  else return 0;
}


int main(int argc, char** argv) {
  // char a[2][1000];
  // for (int i = 0; i < 2; i++) {
  //   fgets(a[i], 5, stdin);
  // }
  // printf("%d\n", equal(a[0], a[1]));
  // for (int j = 0; j < 2; j++) {
  //   int i = 0;
  //   while (i < 1000 && a[j][i] != '\0') {
  //     printf("%c", a[j][i]);
  //     i++;
  //   }
  //   printf("%c", '\n');
  // }

  int n, m = pow(2, 31) - 1;
  scanf("%d", &n);
  int b[n];
  char a[n][m];
  for (int i = 0; i < n; i++) {
    fgets(a[i], m, stdin);
  }
  for (int j = 0; j < n; j++) {
    for (int i = 0; i < n; i++) {
      b[i] = 0;
    }
    b[j] = 1;
    for (int l = 0; l < n - 2; l++) {
      m = 0;
    }
  }


  // fgets(a, 5, stdin);
  // int i = 0;
  // while (a[i] != '\0') {
  //   printf("%c", a[i]);
  //   i++;
  // }
  // for (int i = 0; i < n; i++) printf("%c", a[i]);
	return 0;
}
