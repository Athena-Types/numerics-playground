x = float<ieee_64,ne>(Mx);

Mex0 = ((((1 + (5e-1 * Mx)) - ((125e-3 * Mx) * Mx)) + (((625e-4 * Mx) * Mx) * Mx)) - ((((390625e-7 * Mx) * Mx) * Mx) * Mx));

ex0 float<ieee_64,ne>= ((((float<ieee_64,ne>(1) + (float<ieee_64,ne>(5e-1) * x)) - ((float<ieee_64,ne>(125e-3) * x) * x)) + (((float<ieee_64,ne>(625e-4) * x) * x) * x)) - ((((float<ieee_64,ne>(390625e-7) * x) * x) * x) * x));

{ ((Mx >= 0) /\ (Mx <= 1)) /\ (Mx in [0, 1])
  -> |ex0 - Mex0| in ? }

