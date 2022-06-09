#include "declaration.h"
#include "range.h"


RangeList::RangeList() = default;

RangeList::~RangeList() { delete this->arr; }

Range RangeList::operator[](int i) const { return this->arr[i]; }

void RangeList::add(const Range r) {
    auto d = static_cast<Range*>(operator new[] (this->n * sizeof(Range)));
    for (int i = 0; i < n; i++) d[i] = this->arr[i];
    this->arr = static_cast<Range*>(operator new[] (++this->n * sizeof(Range)));
    for (int i = 0; i < this->n - 1; i++) this->arr[i] = d[i];
    this->arr[n - 1] = r;
    delete d;
}

int RangeList::len() const {
    return this->n;
}

bool RangeList::presense(double x) const {
    int i = 0;
    while (i < this->n && !this->arr[i].between(x)) { i++; }
    if (i == this->n) return false;
    return true;
}


void RangeList::extend(const RangeList& rl) {
    auto d = static_cast<Range*>(operator new[] (this->n * sizeof(Range)));
    for (int i = 0; i < n; i++) d[i] = this->arr[i];
    this->n += rl.n;
    this->arr = static_cast<Range*>(operator new[] (this->n * sizeof(Range)));
    for (int i = 0; i < this->n - rl.n; i++) this->arr[i] = d[i];
    for (int i = 0; i < rl.n; i++) this->arr[i + this->n - rl.n] = rl.arr[i];
    delete d;
}
