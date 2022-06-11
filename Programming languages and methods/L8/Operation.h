#ifndef CALC_OPERATION_H
#define CALC_OPERATION_H


template <char O, class L, class R>
class Operation {
public:
    Operation() = default;
    ~Operation() = default;
    L Calculate(L x, R y) {
        if (O == '+') return x + y;
        return x * y;
    }
};


template<class L, class R>
class Operation<'=', L, R> {
public:
    void Calculate(L x, R y) {
        *x = y;
    }
};


#endif
