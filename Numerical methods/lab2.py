from typing import NoReturn, Tuple, List
import numpy as np
from lab1 import method


def get_points(start: float, step: float, n_steps: int, func: str) -> Tuple[List, List]:
    res_x = list()
    res_y = list()
    for i in range(n_steps + 1):
        x = start + i * step
        res_x.append(x)
        res_y.append(eval(func))
    return res_x, res_y


def get_coefs(x: List[float], y: List[float]) -> Tuple[int, Tuple]:
    h = x[1] - x[0]
    ans, c = method(
        [4] * (len(x) - 2),
        [1] * (len(x) - 3),
        [1] * (len(x) - 3),
        [3 * (x_ - 2 * y_ + z) / h ** 2 for x_, y_, z in zip(y[:-2], y[1:-1], y[2:])]
    )
    if ans != 2:
        return ans, tuple()
    else:
        c = [0] + c + [0]
        d = [(c_next - c_curr) / (3 * h) for c_curr, c_next in zip(c[:-1], c[1:])]
        b = [(y_next - y_curr) / h - h * (c_next + 2 * c_curr) / 3 for y_curr, y_next, c_curr, c_next in zip(
            y[:-1], y[1:], c[:-1], c[1:])]
        a = y[:-1]
        c = c[:-1]
        return 2, (a, b, c, d)


def make_spline(
        x: List[float],
        x_intermediate: List[float],
        a: List[float],
        b: List[float],
        c: List[float],
        d: List[float]
) -> List[float]:
    res = [a_ + b_ * (x_ - x_i) + c_ * (x_ - x_i) ** 2 + d_ * (x_ - x_i) ** 3
           for a_, b_, c_, d_, x_, x_i in zip(a, b, c, d, x_intermediate, x[:-1])]
    return res


def main() -> NoReturn:
    start = 0
    stop = np.pi / 2
    n_steps = int(input("Введите количество разбиений: "))
    func = "np.cos(x) ** 3 * np.sin(2 * x)"
    step = (stop - start) / n_steps
    x, y = get_points(start, step, n_steps, func)
    ans, res = get_coefs(x, y)
    if ans == 0:
        print("Не выполнено необходимое условие")
    elif ans == 1:
        print("Не выполнено достаточное условие")
    else:
        a, b, c, d = res
        x_intermediate, y_intermediate = get_points(start + (step / 2), step, n_steps - 1, func)
        y_spline = make_spline(x, x_intermediate, a, b, c, d)
        print(f"\t\t\t\tx\t\t\t\t\ty\t\t\ty_spline\t\t\t\tdifference")
        for x_, y_, y_s in zip(x_intermediate, y_intermediate, y_spline):
            print(f"{x_}\t{y_}\t{y_s}\t{abs(y_s - y_)}")


if __name__ == "__main__":
    main()
