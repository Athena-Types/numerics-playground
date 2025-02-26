x1 = float<ieee_64,ne>(Mx1);
x2 = float<ieee_64,ne>(Mx2);
x3 = float<ieee_64,ne>(Mx3);
x4 = float<ieee_64,ne>(Mx4);
x5 = float<ieee_64,ne>(Mx5);
x6 = float<ieee_64,ne>(Mx6);

Mex0 = ((((((((Mx1 * Mx4) * (((((-Mx1 + Mx2) + Mx3) - Mx4) + Mx5) + Mx6)) + ((Mx2 * Mx5) * (((((Mx1 - Mx2) + Mx3) + Mx4) - Mx5) + Mx6))) + ((Mx3 * Mx6) * (((((Mx1 + Mx2) - Mx3) + Mx4) + Mx5) - Mx6))) - ((Mx2 * Mx3) * Mx4)) - ((Mx1 * Mx3) * Mx5)) - ((Mx1 * Mx2) * Mx6)) - ((Mx4 * Mx5) * Mx6));

ex0 float<ieee_64,ne>= ((((((((x1 * x4) * (((((-x1 + x2) + x3) - x4) + x5) + x6)) + ((x2 * x5) * (((((x1 - x2) + x3) + x4) - x5) + x6))) + ((x3 * x6) * (((((x1 + x2) - x3) + x4) + x5) - x6))) - ((x2 * x3) * x4)) - ((x1 * x3) * x5)) - ((x1 * x2) * x6)) - ((x4 * x5) * x6));

{ (((((((Mx1 >= 4) /\ (Mx1 <= 636e-2)) /\ ((Mx2 >= 4) /\ (Mx2 <= 636e-2))) /\ ((Mx3 >= 4) /\ (Mx3 <= 636e-2))) /\ ((Mx4 >= 4) /\ (Mx4 <= 636e-2))) /\ ((Mx5 >= 4) /\ (Mx5 <= 636e-2))) /\ ((Mx6 >= 4) /\ (Mx6 <= 636e-2))) /\ (Mx1 in [4, 636e-2] /\ Mx2 in [4, 636e-2] /\ Mx3 in [4, 636e-2] /\ Mx4 in [4, 636e-2] /\ Mx5 in [4, 636e-2] /\ Mx6 in [4, 636e-2])
  -> |ex0 - Mex0| in ? }

