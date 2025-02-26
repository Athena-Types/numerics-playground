x1 = float<ieee_64,ne>(Mx1);
x2 = float<ieee_64,ne>(Mx2);
x3 = float<ieee_64,ne>(Mx3);
x4 = float<ieee_64,ne>(Mx4);

Mex0 = ((((((((Mx1 * Mx4) * (((-Mx1 + Mx2) + Mx3) - Mx4)) + (Mx2 * (((Mx1 - Mx2) + Mx3) + Mx4))) + (Mx3 * (((Mx1 + Mx2) - Mx3) + Mx4))) - ((Mx2 * Mx3) * Mx4)) - (Mx1 * Mx3)) - (Mx1 * Mx2)) - Mx4);

ex0 float<ieee_64,ne>= ((((((((x1 * x4) * (((-x1 + x2) + x3) - x4)) + (x2 * (((x1 - x2) + x3) + x4))) + (x3 * (((x1 + x2) - x3) + x4))) - ((x2 * x3) * x4)) - (x1 * x3)) - (x1 * x2)) - x4);

{ (((((Mx1 >= 4) /\ (Mx1 <= 636e-2)) /\ ((Mx2 >= 4) /\ (Mx2 <= 636e-2))) /\ ((Mx3 >= 4) /\ (Mx3 <= 636e-2))) /\ ((Mx4 >= 4) /\ (Mx4 <= 636e-2))) /\ (Mx1 in [4, 636e-2] /\ Mx2 in [4, 636e-2] /\ Mx3 in [4, 636e-2] /\ Mx4 in [4, 636e-2])
  -> ex0 -/ Mex0 in ? }

