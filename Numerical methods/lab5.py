import numpy as np
from lab1 import method, get_mae
from typing import NoReturn, List, Tuple


def y(x: float) -> float:
    return x + np.e ** - (2 * x)


def f(x: float) -> float:
    return -2 * x + 1


def setup_method(
        h: float,
        p: float,
        q: float,
        n: int,
        x: List,
        y_0: float,
        y_n: float
) -> Tuple[List[float], List[float], List[float], List[float]]:
    lower_diagonal = [1 - h * p / 2] * (n - 2)
    upper_diagonal = [1 + h * p / 2] * (n - 2)
    diagonal = [h ** 2 * q - 2] * (n - 1)
    vector = ([h ** 2 * f(x[0]) - y_0 * (1 + h / 2 * p)] + [h ** 2 * f(x_) for x_ in x[2:n - 1]] +
              [h ** 2 * f(x[-2]) - y_n * (1 + h / 2 * p)])
    return lower_diagonal, upper_diagonal, diagonal, vector


def main() -> NoReturn:
    n = 10
    p = 1
    q = -2
    y_0 = 1
    y_n = 1 + np.e ** (-2)
    h = 1 / n
    x = [x * h for x in range(n + 1)]
    lower_diagonal, upper_diagonal, diagonal, vector = setup_method(h, p, q, n, x, y_0, y_n)
    ans, res = method(
        diagonal,
        upper_diagonal,
        lower_diagonal,
        vector
    )
    answer = [y(x_) for x_ in x]
    if ans == 0:
        print("Не выполнено необходимое условие")
    elif ans == 1:
        print("Не выполнено достаточное условие")
    else:
        mae = get_mae([y_0] + res + [y_n], answer)
        for i, (x_, y_, y_ans, err) in enumerate(zip(x, [y_0] + res + [y_n], answer, mae)):
            print(f"{i + 1})\t{x_}\t{y_}\t{y_ans}\t{err}")


if __name__ == "__main__":
    main()
