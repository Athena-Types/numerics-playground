x1 = float<ieee_64,ne>(Mx1);
x2 = float<ieee_64,ne>(Mx2);

Ma = (((Mx1 * Mx1) + Mx2) - 11);
Mb = ((Mx1 + (Mx2 * Mx2)) - 7);
Mex0 = ((Ma * Ma) + (Mb * Mb));

a float<ieee_64,ne>= (((x1 * x1) + x2) - float<ieee_64,ne>(11));
b float<ieee_64,ne>= ((x1 + (x2 * x2)) - float<ieee_64,ne>(7));
ex0 float<ieee_64,ne>= ((a * a) + (b * b));


# Absolute error
# { (Mx1 in [-5, 5] /\ Mx2 in [-5, 5]) -> |ex0 - Mex0| in ? }

# Relative error
# { (Mx1 in [-5, 5] /\ Mx2 in [-5, 5]) -> |ex0 - Mex0 / ex0| in ? }

# Relative error, restricted output
# { (Mx1 in [-5, 5] /\ Mx2 in [-5, 5] /\ ex0 in [0.000001, 20]) -> |ex0 - Mex0 / ex0| in ? }

# Relative error, a posterori
{ (Mx1 in [-5, 5] /\ Mx2 in [-5, 5] /\ ex0 = 1) -> |(ex0 - Mex0) / ex0| in ? }


