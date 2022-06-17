#ifndef TRIANGLELIST_TRIANGLELIST_H
#define TRIANGLELIST_TRIANGLELIST_H
#include <vector>
#include "RTriangle.h"
using namespace std;


class TriangleList {
public:
    class AIterator;
    TriangleList() = default;
    ~TriangleList() = default;
    RTriangle operator[](int i) const { return list[i]; }
    void add(const RTriangle r) {
        auto d = static_cast<RTriangle*>(operator new[] (n * sizeof(RTriangle)));
        for (int i = 0; i < n; i++) d[i] = list[i];
        list = static_cast<RTriangle*>(operator new[] (++n * sizeof(RTriangle)));
        for (int i = 0; i < n - 1; i++) list[i] = d[i];
        list[n - 1] = r;
        delete d;
    }

    int len() const { return n; }
    AIterator begin() { return list; }
    AIterator end() { return list + n; }
    class AIterator {
        friend class TriangleList;
    private:
        RTriangle* p;
    public:
        AIterator(RTriangle* t) : p(t) {};
        RTriangle& operator+ (int i) { return *(p + i); }
        RTriangle& operator- (int i) { return *(p - i); }
        RTriangle& operator++ (int) { return *p++; }
        RTriangle& operator-- (int) { return *p--; }
        RTriangle& operator++ () { return *++p; }
        RTriangle& operator-- () { return *--p; }
        bool operator!= (const AIterator& iter) { return p != iter.p; }
        bool operator== (const AIterator& iter) { return p == iter.p; }
        double operator* () { return p->s; }
    };
private:
    int n = 0;
    RTriangle* list = nullptr;
};


#endif