# include <stdio.h>
# include <math.h>


int main(int argc, char** argv) {
  int n, m;
  scanf("%d %d", &n, &m);
  int a[n][m], b[n][2], c[m][2];
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
      scanf("%d", &a[i][j]);
    }
  }
  for (int i = 0; i < n; i++) {
    b[i][0] = -pow(2, 31);
    b[i][1] = -1;
  }
  for (int j = 0; j < m; j++) {
    c[j][0] = pow(2, 31) - 1;
    c[j][1] = -1;
  }
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
      if (a[i][j] >= b[i][0]) {
        b[i][0] = a[i][j];
        b[i][1] = j;
      }
      if (a[i][j] <= c[j][0]) {
        c[j][0] = a[i][j];
        c[j][1] = i;
      }
    }
  }
  int i = 0, z = -2, j;
  while (i < n) {
    j = 0;
    while (j < m && !(b[i][1] == j && i == c[j][1])) {
      j++;
    }
    if (j != m) {
      z = i;
      i = n;
    }
    i++;
  }
  if (i == n) {
    printf("none");
  } else printf("%d %d", z, j);
	return 0;
}
