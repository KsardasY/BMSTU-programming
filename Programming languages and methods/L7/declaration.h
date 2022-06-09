#ifndef LISTRANGE_DECLARATION_H
#define LISTRANGE_DECLARATION_H
#include "range.h"



class RangeList {
public:
    int n = 0;
    Range* arr = nullptr;
    RangeList();
    ~RangeList();
    Range operator[](int i) const;
    void add(Range r);
    int len() const;
    bool presense(int x) const;
    void extend(const RangeList& rl);
};


#endif //LISTRANGE_DECLARATION_H
