x1 = float<ieee_64,ne>(Mx1);
x2 = float<ieee_64,ne>(Mx2);
x3 = float<ieee_64,ne>(Mx3);

Mex0 = (((((((2 * Mx1) * Mx2) * Mx3) + ((3 * Mx3) * Mx3)) - (((Mx2 * Mx1) * Mx2) * Mx3)) + ((3 * Mx3) * Mx3)) - Mx2);

ex0 float<ieee_64,ne>= (((((((float<ieee_64,ne>(2) * x1) * x2) * x3) + ((float<ieee_64,ne>(3) * x3) * x3)) - (((x2 * x1) * x2) * x3)) + ((float<ieee_64,ne>(3) * x3) * x3)) - x2);

{ ((((Mx1 >= -15) /\ (Mx1 <= 15)) /\ ((Mx2 >= -15) /\ (Mx2 <= 15))) /\ ((Mx3 >= -15) /\ (Mx3 <= 15))) /\ (Mx1 in [-15, 15] /\ Mx2 in [-15, 15] /\ Mx3 in [-15, 15])
  -> ex0 in ? }