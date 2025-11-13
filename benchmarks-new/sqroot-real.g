x = float<ieee_64,zr>(Mx);

Mex0 = ((((1 + (5e-1 * Mx)) - ((125e-3 * Mx) * Mx)) + (((625e-4 * Mx) * Mx) * Mx)) - ((((390625e-7 * Mx) * Mx) * Mx) * Mx));

ex0 float<ieee_64,zr>= ((((float<ieee_64,zr>(1) + (float<ieee_64,zr>(5e-1) * x)) - ((float<ieee_64,zr>(125e-3) * x) * x)) + (((float<ieee_64,zr>(625e-4) * x) * x) * x)) - ((((float<ieee_64,zr>(390625e-7) * x) * x) * x) * x));

{ ((Mx >= 0) /\ (Mx <= 1)) /\ (Mx in [0, 1])
  -> ex0 in ? }