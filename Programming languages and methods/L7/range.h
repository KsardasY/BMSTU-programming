#include <string>
#ifndef LISTRANGE_RANGE_H
#define LISTRANGE_RANGE_H
using namespace std;


class Range {
public:
    double left;
    double right;

    Range(double left, double right) {
        this->left = left;
        this->right = right;
    }

    bool between(double coord) {
        return this->left < coord && coord < this->right;
    }
};


#endif
