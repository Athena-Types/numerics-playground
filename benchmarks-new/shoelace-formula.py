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


def ex0(x1, y1, x2, y2, x3, y3):
    s1 = (x1 * y2) - (y1 * x2)
    s2 = (x2 * y3) - (y2 * x3)
    s3 = (x3 * y1) - (y3 * x1)
    return 0.5 * ((s1 + s2) + s3)


## randomly sample from floats in input space
import random

x1 = random.uniform(1, 1000)
x2 = random.uniform(1, 1000)
x3 = random.uniform(1, 1000)
y1 = random.uniform(1, 1000)
y2 = random.uniform(1, 1000)
y3 = random.uniform(1, 1000)
print(ex0(x1, y1, x2, y2, x3, y3))
