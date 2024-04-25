import numpy as np
from typing import NoReturn, List, Tuple
from lab1 import get_mae


def f1(x: float, y: float) -> float:
    return np.sin(y + 2) - x - 1.5


def f2(x: float, y: float) -> float:
    return y + np.cos(x - 2) - 0.5


def f(x: float, y: float) -> np.ndarray:
    return np.array([f1(x, y), f2(x, y)])


def jacobian(x: float, y: float) -> np.ndarray:
        return np.array([[-1, np.cos(y + 2)], [-np.sin(x - 2), 1]])


def newton_matrix(
        x: float,
        y: float,
        eps: float = 1e-2
) -> Tuple[Tuple[float, float], int]:
    x_cur, y_cur = x, y
    n_steps = 0
    condition = True
    while condition:
        y = np.linalg.solve(jacobian(x_cur, y_cur), -f(x_cur, y_cur))
        x_ex, y_ex = x_cur, y_cur
        x_cur, y_cur = x_ex + y[0], y_ex + y[1]
        condition = max(get_mae([x_cur, y_cur], [x_ex, y_ex])) > eps
        n_steps += 1
    return (x_cur, y_cur), n_steps


def main() -> NoReturn:
    eps = 1e-2
    x_start, y_start = -2, 2
    res, n_steps = newton_matrix(x_start, y_start, eps)
    print(f"Количество шагов схождения: {n_steps}")
    print(f"Финальное приближение: {res}")


if __name__ == "__main__":
    main()
