#include <iostream>
#include "Seq.h"
using namespace std;


int main() {
    Seq<int> a;
    a.add(4);
    a.add(1);
    a.add(2);
    Seq<int>b;
    b.add(3);
    b.add(1);
    b.add(-2);
    Seq<int> c = b - a, d = a + b, e = a * b;
    for (int i = 0; i < c.size(); i++) {
        cout << c[i] << endl;
    }
    cout << endl;
    for (int i = 0; i < d.size(); i++) {
        cout << d[i] << endl;
    }
    cout << endl;
    for (int i = 0; i < e.size(); i++) {
        cout << e[i] << endl;
    }
    return 0;
}
