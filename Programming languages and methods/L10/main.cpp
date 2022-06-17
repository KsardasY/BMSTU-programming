#include <iostream>
#include "TriangleList.h"
#include "RTriangle.h"
using namespace std;

int main() {
    TriangleList a;
    a.add(RTriangle(6, 8));
    a.add(RTriangle(36, 15));
    a.add(RTriangle(8, 12));
    auto it = TriangleList::AIterator(a.begin());
    while (it != a.end()) {
        cout << *it << ' ';
        it++;
    }
    return 0;
}
