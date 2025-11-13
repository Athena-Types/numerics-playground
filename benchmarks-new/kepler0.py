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


def ex0(x1, x2, x3, x4, x5, x6):
    return ((((x2 * x5) + (x3 * x6)) - (x2 * x3)) - (x5 * x6)) + (
        x1 * (((((-x1 + x2) + x3) - x4) + x5) + x6)
    )


## randomly sample from floats in input space
import random

x1 = random.uniform(4, 159 / 25)
x2 = random.uniform(4, 159 / 25)
x3 = random.uniform(4, 159 / 25)
x4 = random.uniform(4, 159 / 25)
x5 = random.uniform(4, 159 / 25)
x6 = random.uniform(4, 159 / 25)
print(ex0(x1, x2, x3, x4, x5, x6))
