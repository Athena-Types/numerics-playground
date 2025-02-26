x1 = float<ieee_64,ne>(Mx1);
x2 = float<ieee_64,ne>(Mx2);

Mex0 = (-Mx1 - Mx2);

ex0 float<ieee_64,ne>= (-x1 - x2);

{ (((((Mx1 >= 0) /\ (Mx1 <= 3)) /\ ((Mx2 >= 0) /\ (Mx2 <= 4))) /\ (((((2 * ((Mx1 * Mx1) * (Mx1 * Mx1))) - ((8 * (Mx1 * Mx1)) * Mx1)) + ((8 * Mx1) * Mx1)) - Mx2) >= 0)) /\ (((((((4 * ((Mx1 * Mx1) * (Mx1 * Mx1))) - ((32 * (Mx1 * Mx1)) * Mx1)) + ((88 * Mx1) * Mx1)) - (96 * Mx1)) + 36) - Mx2) >= 0)) /\ (Mx1 in [0, 3] /\ Mx2 in [0, 4])
  -> |ex0 - Mex0| in ? }

