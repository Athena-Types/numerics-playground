x1 = float<ieee_64,ne>(Mx1);
x2 = float<ieee_64,ne>(Mx2);
x3 = float<ieee_64,ne>(Mx3);
x4 = float<ieee_64,ne>(Mx4);
x5 = float<ieee_64,ne>(Mx5);
x6 = float<ieee_64,ne>(Mx6);

Mex0 = ((((((-Mx2 * Mx3) - (Mx1 * Mx4)) + (Mx2 * Mx5)) + (Mx3 * Mx6)) - (Mx5 * Mx6)) + (Mx1 * (((((-Mx1 + Mx2) + Mx3) - Mx4) + Mx5) + Mx6)));

ex0 float<ieee_64,ne>= ((((((-x2 * x3) - (x1 * x4)) + (x2 * x5)) + (x3 * x6)) - (x5 * x6)) + (x1 * (((((-x1 + x2) + x3) - x4) + x5) + x6)));

{ (((((((Mx1 >= 4) /\ (Mx1 <= 63504e-4)) /\ ((Mx2 >= 4) /\ (Mx2 <= 63504e-4))) /\ ((Mx3 >= 4) /\ (Mx3 <= 63504e-4))) /\ ((Mx4 >= 4) /\ (Mx4 <= 63504e-4))) /\ ((Mx5 >= 4) /\ (Mx5 <= 63504e-4))) /\ ((Mx6 >= 4) /\ (Mx6 <= 63504e-4))) /\ (Mx1 in [4, 63504e-4] /\ Mx2 in [4, 63504e-4] /\ Mx3 in [4, 63504e-4] /\ Mx4 in [4, 63504e-4] /\ Mx5 in [4, 63504e-4] /\ Mx6 in [4, 63504e-4])
  -> |ex0 - Mex0| in ? }