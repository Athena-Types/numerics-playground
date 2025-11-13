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


def ex0(x):
    return (0.954929658551372 * x) - (0.12900613773279798 * ((x * x) * x))


## randomly sample from floats in input space
import random

x = random.uniform(-2, 2)
print(ex0(x))
