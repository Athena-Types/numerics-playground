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


def ex0(x1, x2, x3):
    return ((-(x1 * x2) - ((2.0 * x2) * x3)) - x1) - x3


## randomly sample from floats in input space
import random

x1 = random.uniform(-15, 15)
x2 = random.uniform(-15, 15)
x3 = random.uniform(-15, 15)
print(ex0(x1, x2, x3))
