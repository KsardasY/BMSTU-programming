#include <string>
#include <iostream>
#include "range.h"
#include "declaration.h"
using namespace std;


ostream& operator<<(ostream& os, Range r){
    os << "(" << r.left << ", " << r.right << ")";
    return os;
}


int main() {
    cout.precision(2);
    std::cout.setf(std::ios::fixed);
    int n = 2, m = 3;
    RangeList rangelist1;
    rangelist1.add(Range(1, 2.5));
    rangelist1.add(Range(2.4, 5));
    for (int i = 0; i < n; i++) {
        cout << rangelist1[i] << endl;
    }
    cout << endl;
    RangeList rangelist2;
    rangelist2.add(Range(3.5, 4));
    rangelist2.add(Range(1.0111, 5));
    rangelist2.add(Range(-4, 8));
    for (int i = 0; i < m; i++) {
        cout << rangelist2[i] << endl;
    }
    cout << endl;
    rangelist1.extend(rangelist2);
    for (int i = 0; i < rangelist1.len(); i++) {
        cout << rangelist1[i] << endl;
    }
    return 0;
}
