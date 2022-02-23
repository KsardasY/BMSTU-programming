#include <stdio.h>

unsigned long peak(unsigned long nel, int (*less)(unsigned long i, unsigned long j)) {
    unsigned long m, l = 0, r = nel - 1;
    while (l < r){
        m = (l + r) / 2;
        if (less(m, m + 1) > 0) l = m + 1;
        else if(less(m, m - 1)) r = m - 1;
        else return m;
    }
    return l;
}
