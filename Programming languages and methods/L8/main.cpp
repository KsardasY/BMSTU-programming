#include <iostream>
#include "Operation.h"
using namespace std;


int main() {
    int a = 2, b = 3;
    Operation<'=', int*, int> calc1;
    Operation<'+', int, int> calc2;
    calc1.Calculate(&a, calc2.Calculate(a, b));
    cout << a << endl;
    return 0;
}
