from typing import NoReturn
import numpy as np
import matplotlib.pyplot as plt
from scipy import interpolate


def z6(a: float, b: float, x: float) -> float:
    return 1 / (a * x + b)


def arith_mean(a: float, b: float) -> float:
    return (a+b)/2


def geometric_mean(a: float, b: float) -> float:
    return (a * b) ** 0.5


def harmonic_mean(a: float, b: float) -> float:
    return 2 / (1 / a + 1 / b)


def main() -> NoReturn:
    n = 9
    x = list(np.linspace(1, 5, n))
    y = [2.20, 2.02, 1.49, 1.3, 0.45, 0.46, 0.33, 0.41, 0.25]
    xa, ya = arith_mean(x[0], x[-1]), arith_mean(y[0], y[-1])
    xg, yg = geometric_mean(x[0], x[-1]), geometric_mean(y[0], y[-1])
    xh, yh = harmonic_mean(x[0], x[-1]), harmonic_mean(y[0], y[-1])
    xs = np.linspace(1, 5, 100)
    z = interpolate.interp1d(x, y)
    min_delt, idx = 1000, 0
    za, zg, zh = z(xa), z(xg), z(xh)
    diff = np.abs(za - ya)
    if diff < min_delt:
        min_delt = diff
        idx = 1
    diff = np.abs(zg - yg)
    if diff < min_delt:
        min_delt = diff
        idx = 2
    diff = np.abs(za - yg)
    if diff < min_delt:
        min_delt = diff
        idx = 3
    diff = np.abs(zg - ya)
    if diff < min_delt:
        min_delt = diff
        idx = 4
    diff = np.abs(zh - ya)
    if diff < min_delt:
        min_delt = diff
        idx = 5
    diff = np.abs(za - yh)
    if diff < min_delt:
        min_delt = diff
        idx = 6
    diff = np.abs(zh - yh)
    if diff < min_delt:
        min_delt = diff
        idx = 7
    diff = np.abs(zh - yg)
    if diff < min_delt:
        min_delt = diff
        idx = 8
    diff = np.abs(zg - yh)
    if diff < min_delt:
        min_delt = diff
        idx = 9
    print(idx)
    plt.plot(xs, z(xs), label='Функция')
    x_squared_sum = sum([(1 / x[i]) ** 2 for i in range(n)])
    x_sum = sum([(1 / x[i]) for i in range(n)])
    y_sum = sum([(y[i]) for i in range(n)])
    xy_sum = sum([(y[i] / x[i]) for i in range(n)])
    A = np.asarray([[x_squared_sum, x_sum], [x_sum, n + 1]])
    B = np.asarray([xy_sum, y_sum]).T
    a, b = np.linalg.inv(A) @ B
    z_xs = [z6(a, b, x_) for x_ in xs]
    diff = 1 / np.sqrt(n) * sum([(z6(a, b, x_i) - y_i) ** 2 for x_i, y_i in zip(x, y)])
    plt.plot(xs, z_xs, label=f'Приближение, delta={round(diff, 3)}')
    plt.legend()
    plt.show()


if __name__ == "__main__":
    main()
