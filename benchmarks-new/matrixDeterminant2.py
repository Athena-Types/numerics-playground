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


def ex0(a, b, c, d, e, f, g, h, i):
    return ((a * (e * i)) + ((g * (b * f)) + (c * (d * h)))) - (
        (e * (c * g)) + ((i * (b * d)) + (a * (f * h)))
    )


## randomly sample from floats in input space
import random

a = random.uniform(-10, 10)
b = random.uniform(-10, 10)
c = random.uniform(-10, 10)
d = random.uniform(-10, 10)
e = random.uniform(-10, 10)
f = random.uniform(-10, 10)
g = random.uniform(-10, 10)
h = random.uniform(-10, 10)
i = random.uniform(-10, 10)
print(ex0(a, b, c, d, e, f, g, h, i))
