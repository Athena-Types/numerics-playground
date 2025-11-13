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


def ex0(x1, x2):
    a = ((x1 * x1) + x2) - 11.0
    b = (x1 + (x2 * x2)) - 7.0
    return (a * a) + (b * b)


## randomly sample from floats in input space
import random

x1 = random.uniform(-5, 5)
x2 = random.uniform(-5, 5)
print(ex0(x1, x2))
