#include "cmath"
#include "RTriangle.h"


RTriangle::RTriangle(double a, double b) : s(a * b / 2), tg(a / b) {};

double RTriangle::get_a() { return sqrt(2 * s * tg); }

double RTriangle::get_b() { return sqrt(2 * s / tg); }
