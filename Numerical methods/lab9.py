import numpy as np
from typing import NoReturn, Callable, List
from lab1 import get_mae
import matplotlib.pyplot as plt


def fft(y: np.ndarray) -> List[float]:
    if len(y) <= 1:
        return list(y)
    even = fft(y[0::2])
    odd = fft(y[1::2])
    result = [0] * len(y)
    angle = -2.0 * np.pi / len(y)
    for k in range(len(y) // 2):
        t = np.exp(1j * angle * k) * odd[k]
        result[k] = even[k] + t
        result[k + len(y) // 2] = even[k] - t
    return result


def ifft(y: np.ndarray) -> List[float]:
    conjugated = np.conj(y)
    transformed = fft(conjugated)
    return np.conj(transformed) / len(y)


def f_interpolated(y: List[float], n: int) -> Callable:
    n = len(y)
    y_complex = np.array(y, dtype=complex)
    fft_result = fft(y_complex)
    extended_fft = np.zeros(n, dtype=complex)
    extended_fft[:len(y) // 2] = fft_result[:len(y) // 2]
    extended_fft[n - len(y) // 2:] = fft_result[len(y) // 2:]
    interpolated_c = ifft(extended_fft)

    def interpolator(x: float) -> float:
        w = x % 1.0
        index = int(w * n) % n
        return interpolated_c[index].real

    return interpolator


def f(x: float) -> float:
    return (x - int(x)) * np.cos(2 * np.pi * x)


def main() -> NoReturn:
    n = 128
    x = np.arange(n) / n
    x_shifted = (np.arange(n) + 0.5) / n
    y = [f(x_) for x_ in x]
    pred_y = f_interpolated(y, n)
    intermediate_y = [f(x_) for x_ in x_shifted]
    pred_intermediate_y = [pred_y(x_) for x_ in x_shifted]
    plt.figure(figsize=(10, 6))
    plt.plot(x_shifted, intermediate_y, label="f(x)")
    plt.plot(x_shifted, pred_intermediate_y, label="interpolated f(x)", linestyle='--')
    plt.legend()
    plt.show()
    print(f"Погрешность: {max(get_mae(intermediate_y, pred_intermediate_y))}")


if __name__ == "__main__":
    main()
