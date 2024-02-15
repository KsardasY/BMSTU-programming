import ctypes
import multiprocessing as mp
import numpy as np
import time
from typing import NoReturn


def mp_calculate_worker(n, queue, res, a, b) -> NoReturn:
    res = np.reshape(np.frombuffer(res), (n, n))
    while True:
        job = queue.get()
        if job is None:
            break
        for i in range(job[0], job[1]):
            for j in range(n):
                for k in range(n):
                    res[i][j] += a[i][k] * b[k][j]
        queue.task_done()
    queue.task_done()


def mp_calculate(n, a, b, e, stream_number) -> NoReturn:
    res = mp.RawArray(ctypes.c_double, n * n)
    jobs = [(i * (n // stream_number) + min(i, n % stream_number),
             (i + 1) * (n // stream_number) + min(i + 1, n % stream_number)) for i in range(stream_number)]
    n_cpu = mp.cpu_count()
    queue = mp.JoinableQueue()
    for job in jobs:
        queue.put(job)
    for i in range(n_cpu):
        queue.put(None)
    workers = []
    for i in range(n_cpu):
        worker = mp.Process(target=mp_calculate_worker, args=(n, queue, res, a, b))
        workers.append(worker)
        worker.start()
    queue.join()
    e = np.reshape(np.frombuffer(res), (n, n))


def sp_calculate_string(n, a, b, c) -> NoReturn:
    for i in range(n):
        for j in range(n):
            for k in range(n):
                c[i][j] += a[i][k] * b[k][j]


def sp_calculate_column(n, a, b, d) -> NoReturn:
    for j in range(n):
        for i in range(n):
            for k in range(n):
                d[i][j] += a[i][k] * b[k][j]


def main():
    n = int(input("Введите размер матрицы: "))
    a = list(np.random.normal(size=(n, n)))
    b = list(np.random.normal(size=(n, n)))
    c = [[0] * n for _ in range(n)]
    start = time.time()
    sp_calculate_string(n, a, b, c)
    print(f"По строкам: {time.time() - start}")
    d = [[0] * n for _ in range(n)]
    start = time.time()
    sp_calculate_column(n, a, b, d)
    print(f"По столбцам: {time.time() - start}")
    print(c == d)
    e = [[1] * n for _ in range(n)]
    stream_number = int(input("Введите количество потоков: "))
    start = time.time()
    mp_calculate(n, a, b, e, stream_number)
    print(f"Параллельно: {time.time() - start}")
    print(c == d)


if __name__ == "__main__":
    main()
