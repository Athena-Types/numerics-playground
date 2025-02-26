x = float<ieee_64,ne>(Mx);

Mex0 = ((954929658551372e-15 * Mx) - (12900613773279798e-17 * ((Mx * Mx) * Mx)));

ex0 float<ieee_64,ne>= ((float<ieee_64,ne>(954929658551372e-15) * x) - (float<ieee_64,ne>(12900613773279798e-17) * ((x * x) * x)));

{ ((Mx >= -2) /\ (Mx <= 2)) /\ (Mx in [-2, 2])
  -> |ex0 - Mex0| in ? }

