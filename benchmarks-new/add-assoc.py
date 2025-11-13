import math


def fmax(x, y):
    if math.isnan(x):
        return y
    elif math.isnan(y):
        return x
    else:
        return max(x, y)


def fmin(x, y):
    if math.isnan(x):
        return y
    elif math.isnan(y):
        return x
    else:
        return min(x, y)


def ex0(x0, x1, x2, x3):
    return (x0 + x1) + (x2 + x3)


import random

x0 = random.uniform(1, 1000)
x1 = random.uniform(1, 1000)
x2 = random.uniform(1, 1000)
x3 = random.uniform(1, 1000)
print(ex0(x0, x1, x2, x3))
