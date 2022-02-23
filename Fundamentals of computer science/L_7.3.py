from random import randint
from sys import argv


def f3(l, n):
    return '\n'.join([''.join([chr(randint(32, 126)) for _ in range(l)]) for _ in range(n)])


if __name__ == "__main__":
    print(f3(int(argv[1]), int(argv[2])))
