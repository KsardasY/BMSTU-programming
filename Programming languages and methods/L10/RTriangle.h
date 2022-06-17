#ifndef TRIANGLELIST_RTRIANGLE_H
#define TRIANGLELIST_RTRIANGLE_H


class RTriangle {
public:
    double s;
    RTriangle(double a, double b);
    ~RTriangle() = default;
    double get_a();
    double get_b();
private:
    double tg;
};


#endif