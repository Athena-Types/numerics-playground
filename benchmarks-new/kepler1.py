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


def ex0(x1, x2, x3, x4):
    return (
        (
            (
                (
                    (
                        ((x1 * x4) * (((-x1 + x2) + x3) - x4))
                        + (x2 * (((x1 - x2) + x3) + x4))
                    )
                    + (x3 * (((x1 + x2) - x3) + x4))
                )
                - ((x2 * x3) * x4)
            )
            - (x1 * x3)
        )
        - (x1 * x2)
    ) - x4


## randomly sample from floats in input space
import random

x1 = random.uniform(4, 159 / 25)
x2 = random.uniform(4, 159 / 25)
x3 = random.uniform(4, 159 / 25)
x4 = random.uniform(4, 159 / 25)
print(ex0(x1, x2, x3, x4))
