import numpy as np
from typing import NoReturn, List, Tuple


def method(
        diagonal: List[float],
        upper_diagonal: List[float],
        lower_diagonal: List[float],
        vector: List[float]
) -> Tuple[int, List]:
    if diagonal[0] == 0:
        return 0, list()
    alpha = [-upper_diagonal[0] / diagonal[0]]
    beta = [vector[0] / diagonal[0]]

    for a, b, c in zip(
        diagonal[1:-1],
        upper_diagonal[1:],
        lower_diagonal[1:]
    ):
        if not (abs(a) >= abs(b + c) and abs(a / b) >= 1):
            return 1, list()

    for a, b, c, d in zip(
            diagonal[1:-1],
            upper_diagonal[:-1],
            lower_diagonal[1:],
            vector[1:]
    ):
        beta.append((d - c * beta[-1]) / (c * alpha[-1] + a))
        alpha.append((- b) / (c * alpha[-1] + a))
    reversed_res = [(vector[-1] - lower_diagonal[-1] * beta[-1]) / (lower_diagonal[-1] * alpha[-1] + diagonal[-1])]
    for a, b in zip(alpha, beta):
        reversed_res.append(a * reversed_res[-1] + b)
    return 2, reversed_res[::-1]


def get_mae(x: List[float], y: List[float]) -> List[float]:
    return list(np.absolute(np.array(x, np.float64) - np.array(y, np.float64)))


def main() -> NoReturn:
    diagonal = [4/3, 4/3, 4/3, 4/3]
    upper_diagonal = [1/3, 1/3, 1/3]
    lower_diagonal = [1/3, 1/3, 1/3]
    vector = [5/3, 6/3, 6/3, 5/3]
    answer = [1, 1, 1, 1]
    ans, res = method(
        diagonal,
        upper_diagonal,
        lower_diagonal,
        vector
    )
    if ans == 0:
        print("Не выполнено необходимое условие")
    elif ans == 1:
        print("Не выполнено достаточное условие")
    else:
        print(f"Ответ: {res}")
        mae = get_mae(res, answer)
        print(f"Погрешность: {mae}")


if __name__ == "__main__":
    main()
