# include <stdio.h>
# include <math.h>


int main(int argc, char** argv) {
    long long n, l;
    scanf("%lld", &n);
    if (n < 0) {
      n = -n;
    }
    l = floor(sqrt(n)) + 1;
    char a[l];
    for (int i = 0; i < l; i++) {
        a[i] = 1;
    }
    a[0] = a[1] = 0;
    for (int i = 2; i < l; i++) {
        if ((a[i] == 1) && (i * i < l)) {
            for (int j = i * i; j < l; j += i) {
                a[j] = 0;
            }
        }
    }
    int i = 2, z = 0;
    while (i < l) {
      if (n % i == 0) {
        z = i;
        n /= i;
      } else i++;
    }
    if (n < z) {
        n = z;
    }
    printf("%lld", n);
	return 0;
}
