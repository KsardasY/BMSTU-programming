import numpy as np
from typing import NoReturn, Callable, Tuple
from lab1 import get_mae


def f(x1: float, x2: float) -> float:
    return x1 ** 2 + x2 ** 2 + x1 ** 4 * x2 ** 4 + 0.1 * x1 + 0.2 * x2


def der1_x1(x1: float, x2: float) -> float:
    return 2 * x1 + 4 * x1 ** 3 * x2 ** 4 + 0.1


def der1_x2(x1: float, x2: float) -> float:
    return 2 * x2 + 4 * x2 ** 3 * x1 ** 4 + 0.2


def der2_x1(x1: float, x2: float) -> float:
    return 2 + 12 * x1 ** 2 * x2 ** 4


def der2_x2(x1: float, x2: float) -> float:
    return 2 + 12 * x2 ** 2 * x1 ** 4


def der2_x1x2(x1: float, x2: float) -> float:
    return 16 * x1 ** 3 * x2 ** 3


def grad(x1: float, x2: float) -> np.ndarray:
    return np.array([der1_x1(x1, x2), der1_x2(x1, x2)])


def grad_descent(
        grad: Callable,
        x: np.ndarray,
        eps: float
) -> Tuple[np.ndarray, int]:
    diff = eps + 1
    n = 0
    while diff > eps:
        lr = (der1_x1(*x) ** 2 + der1_x2(*x) ** 2) / ((der2_x1(*x) * der1_x1(*x) ** 2) +
                                                      2 * (der2_x1x2(*x) * der1_x1(*x) * der1_x2(*x)) +
                                                      (der2_x2(*x) * der1_x2(*x) ** 2))
        g = grad(*x)
        x = x - lr * g
        n += 1
        diff = max(np.abs(g))
    return x, n


def main() -> NoReturn:
    eps = 1e-3
    x = np.array([0, 0])
    x, n = grad_descent(grad, x, eps)
    print(f"Количество шагов схождения: {n}")
    print("Полученное решение: ({:.3f}, {:.2f})".format(x[0], x[1]))
    print(f"Аналитическое решение: (-0.05, -0.1)")


if __name__ == "__main__":
    main()
