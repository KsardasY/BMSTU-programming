import numpy as np
from lab1 import method, get_mae
from typing import NoReturn, List, Tuple, Callable
from functools import partial


def common_f(a: int, b: int, c: int, d: int, x: float) -> float:
    return a * x ** 3 + b * x ** 2 + c * x + d


def derivative(
        a: int,
        b: int,
        c: int,
) -> Callable:
    return lambda x: 3 * a * x ** 2 + 2 * b * x + c


def second_derivative(
        a: int,
        b: int
) -> Callable:
    return lambda x: 6 * a * x + 2 * b


def binsearch(
        func: Callable,
        left: float,
        right: float,
        eps: float = 1e-3
) -> Tuple[float, int]:
    n_steps = 0
    while right - left > 2 * eps:
        mid = (right + left) / 2
        if func(mid) * func(left) < 0:
            right = mid
        else:
            left = mid
        n_steps += 1
    return (right + left) / 2, n_steps


def newton(
        func: Callable,
        left: float,
        right: float,
        derivative: Callable,
        second_derivative: Callable,
        eps: float = 1e-3
) -> Tuple[float, int]:
    n_steps = 0
    x_cur = left if np.sign(func(left)) == np.sign(second_derivative(left)) else right
    condition = True
    while condition:
        x_ex = x_cur
        x_cur = x_ex - func(x_ex) / derivative(x_ex)
        condition = (func(x_cur) * func(x_cur + np.sign(x_cur - x_ex) * eps) >= 0)
        n_steps += 1
    return x_cur, n_steps


def main() -> NoReturn:
    a, b, c, d = 1, 3, -8, 1
    f = partial(common_f, a, b, c, d)
    der = derivative(a, b, c)
    second_der = second_derivative(a, b)
    ranges = [(-6, -4), (0, 1), (1, 2)]
    for left, right in ranges:
        print(binsearch(f, left, right), newton(f, left, right, der, second_der))


if __name__ == "__main__":
    main()
