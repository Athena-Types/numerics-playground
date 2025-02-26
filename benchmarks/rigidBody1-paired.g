x1p = float<ieee_64,ne>(Mx1p);
x1n = float<ieee_64,ne>(Mx1n);
x2p = float<ieee_64,ne>(Mx2p);
x2n = float<ieee_64,ne>(Mx2n);
x3p = float<ieee_64,ne>(Mx3p);
x3n = float<ieee_64,ne>(Mx3n);

Mpos = (((((Mx1p * Mx2n) + (Mx1p * Mx2n)) + ((((2 * Mx2p) + (0 * Mx2n)) * Mx3n) + (((2 * Mx2p) + (0 * Mx2n)) * Mx3n))) + Mx1n) + Mx3n);
Mneg = (((((Mx1p * Mx2p) + (Mx1n * Mx2n)) + ((((2 * Mx2p) + (0 * Mx2n)) * Mx3p) + (((2 * Mx2n) + (2 * Mx2n)) * Mx3n))) + Mx1p) + Mx3p);
Mex0 = (Mpos - Mneg);

pos float<ieee_64,ne>= (((((x1p * x2n) + (x1p * x2n)) + ((((float<ieee_64,ne>(2) * x2p) + (float<ieee_64,ne>(0) * x2n)) * x3n) + (((float<ieee_64,ne>(2) * x2p) + (float<ieee_64,ne>(0) * x2n)) * x3n))) + x1n) + x3n);
neg float<ieee_64,ne>= (((((x1p * x2p) + (x1n * x2n)) + ((((float<ieee_64,ne>(2) * x2p) + (float<ieee_64,ne>(0) * x2n)) * x3p) + (((float<ieee_64,ne>(2) * x2n) + (float<ieee_64,ne>(2) * x2n)) * x3n))) + x1p) + x3p);
ex0 float<ieee_64,ne>= (pos - neg);

{ ((((((((((((Mx1p >= 0) /\ (Mx1p <= 0)) /\ (Mx2p >= 0)) /\ (Mx2p <= 0)) /\ (Mx3p >= 0)) /\ (Mx3p <= 0)) /\ ((Mx1n >= -15) /\ (Mx1n <= 15))) /\ (Mx1p = 0)) /\ ((Mx2n >= -15) /\ (Mx2n <= 15))) /\ (Mx2p = 0)) /\ ((Mx3n >= -15) /\ (Mx3n <= 15))) /\ (Mx3p = 0)) /\ (Mx1p in [0, 0] /\ Mx1n in [-15, 15] /\ Mx2p in [0, 0] /\ Mx2n in [-15, 15] /\ Mx3p in [0, 0] /\ Mx3n in [-15, 15])
  -> |ex0 - Mex0| in ? }

