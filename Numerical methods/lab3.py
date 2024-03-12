from typing import NoReturn, Callable, Tuple
import numpy as np
from scipy import integrate


def function(x: float) -> float:
    return np.cos(x) ** 3 * np.sin(2 * x)


def richardson_coef(
        integral: float,
        integral_ex: float,
        k: int
) -> float:
    return (integral - integral_ex) / (2 ** k - 1)


def rectangle_method(
        func: Callable,
        start: float,
        step: float,
        n_steps: int,
        stop: float = 0
) -> float:
    return sum([func(start + step * (i - 0.5)) for i in range(1, n_steps + 1)]) * step


def trapezoid_method(
        func: Callable,
        start: float,
        step: float,
        n_steps: int,
        stop: float
) -> float:
    return ((func(start) + func(stop)) / 2 + sum([func(start + i * step) for i in range(1, n_steps)])) * step


def simpson_method(
        func: Callable,
        start: float,
        step: float,
        n_steps: int,
        stop: float = 0
) -> float:
    s1 = sum(func(start + i * step) for i in range(1, n_steps))
    s2 = sum(func(start + (i - 0.5) * step) for i in range(1, n_steps + 1))
    s3 = sum(func(start + (i - 1) * step) for i in range(1, n_steps + 2))
    return (s1 + 4 * s2 + s3) * step / 6


def find_num_iteration(
        method: Callable,
        func: Callable,
        start: float,
        stop: float,
        k: int = 2,
        eps: float = 1e-2
) -> Tuple[float, float, float]:
    n_splits = 1
    r_coef = eps + 1
    integral = np.inf
    iteration = 0
    while abs(r_coef) >= eps:
        n_splits *= 2
        iteration += 1
        step = (stop - start) / n_splits
        integral_ex = integral
        integral = method(func, start, step, n_splits, stop)
        r_coef = richardson_coef(integral, integral_ex, k)
    return iteration, integral, r_coef


def main() -> NoReturn:
    start = 0
    stop = np.pi / 2
    eps = 1e-3
    integral = integrate.quad(function, start, stop)[0]
    m_parameters = {
        "Rectangle": {"k": 2, "method": rectangle_method},
        "Trapezoid": {"k": 2, "method": trapezoid_method},
        "Simpson\t": {"k": 3, "method": simpson_method}
    }
    parameters = {"func": function, "start": start, "stop": stop, "eps": eps}
    print(f"Значение интеграла: {integral}")
    print(f"\t\t\tn\t\t\t\t\t I\t\t\t\t\t\t R\t\t\t\t\tI+R")
    for m in m_parameters:
        n, i, r = find_num_iteration(**parameters, **m_parameters[m])
        print(f"{m}\t{2 ** n}\t{i}\t{r}\t{r + i}")


if __name__ == "__main__":
    main()
