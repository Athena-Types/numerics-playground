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


def ex0(x0, x1, x2):
    p0 = (x0 + x1) - x2
    p1 = (x1 + x2) - x0
    p2 = (x2 + x0) - x1
    return (p0 + p1) + p2


## randomly sample from floats in input space
import random

x1 = random.uniform(1, 2)
x2 = random.uniform(1, 2)
x3 = random.uniform(1, 2)
print(ex0(x1, x2, x3))
