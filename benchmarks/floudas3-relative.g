x1 = float<ieee_64,ne>(Mx1);
x2 = float<ieee_64,ne>(Mx2);

Mex0 = (((-12 * Mx1) - (7 * Mx2)) + (Mx2 * Mx2));

ex0 float<ieee_64,ne>= (((float<ieee_64,ne>(-12) * x1) - (float<ieee_64,ne>(7) * x2)) + (x2 * x2));

{ (((Mx1 >= 0) /\ (Mx1 <= 2)) /\ ((Mx2 >= 0) /\ (Mx2 <= 3))) /\ (Mx1 in [0, 2] /\ Mx2 in [0, 3])
  -> ex0 -/ Mex0 in ? }

