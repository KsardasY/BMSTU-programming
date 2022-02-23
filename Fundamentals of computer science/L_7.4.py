def mem(f):
    a = {}

    def wrapper(*args):
        if args not in a:
            a[args] = f(*args)
        return a[args]

    return wrapper


@mem
def fibonacci(n):
    if n <= 2:
        return 1
    return fibonacci(n - 1) + fibonacci(n - 2)


print(fibonacci(6))
