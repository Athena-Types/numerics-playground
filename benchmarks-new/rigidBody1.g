x1 = float<ieee_64,zr>(Mx1);
x2 = float<ieee_64,zr>(Mx2);
x3 = float<ieee_64,zr>(Mx3);

Mex0 = (((-(Mx1 * Mx2) - ((2 * Mx2) * Mx3)) - Mx1) - Mx3);

ex0 float<ieee_64,zr>= (((-(x1 * x2) - ((float<ieee_64,zr>(2) * x2) * x3)) - x1) - x3);

{ ((((Mx1 >= -15) /\ (Mx1 <= 15)) /\ ((Mx2 >= -15) /\ (Mx2 <= 15))) /\ ((Mx3 >= -15) /\ (Mx3 <= 15))) /\ (Mx1 in [-15, 15] /\ Mx2 in [-15, 15] /\ Mx3 in [-15, 15])
  -> |ex0 - Mex0| in ? }

