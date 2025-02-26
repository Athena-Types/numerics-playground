x1p = float<ieee_64,ne>(Mx1p);
x1n = float<ieee_64,ne>(Mx1n);
x2p = float<ieee_64,ne>(Mx2p);
x2n = float<ieee_64,ne>(Mx2n);
x3p = float<ieee_64,ne>(Mx3p);
x3n = float<ieee_64,ne>(Mx3n);

Mpos = ((((((((((2 * Mx1p) + (0 * Mx1n)) * Mx2p) + (((2 * Mx1n) + (2 * Mx1n)) * Mx2n)) * Mx3p) + (((((2 * Mx1p) + (0 * Mx1n)) * Mx2n) + (((2 * Mx1p) + (0 * Mx1n)) * Mx2n)) * Mx3n)) + ((((3 * Mx3p) + (0 * Mx3n)) * Mx3p) + (((3 * Mx3n) + (3 * Mx3n)) * Mx3n))) + ((((((Mx2p * Mx1p) + (Mx2n * Mx1n)) * Mx2p) + (((Mx2p * Mx1n) + (Mx2p * Mx1n)) * Mx2n)) * Mx3n) + (((((Mx2p * Mx1p) + (Mx2n * Mx1n)) * Mx2p) + (((Mx2p * Mx1n) + (Mx2p * Mx1n)) * Mx2n)) * Mx3n))) + ((((3 * Mx3p) + (0 * Mx3n)) * Mx3p) + (((3 * Mx3n) + (3 * Mx3n)) * Mx3n))) + Mx2n);
Mneg = ((((((((((2 * Mx1p) + (0 * Mx1n)) * Mx2p) + (((2 * Mx1n) + (2 * Mx1n)) * Mx2n)) * Mx3n) + (((((2 * Mx1p) + (0 * Mx1n)) * Mx2p) + (((2 * Mx1n) + (2 * Mx1n)) * Mx2n)) * Mx3n)) + ((((3 * Mx3p) + (0 * Mx3n)) * Mx3n) + (((3 * Mx3p) + (0 * Mx3n)) * Mx3n))) + ((((((Mx2p * Mx1p) + (Mx2n * Mx1n)) * Mx2p) + (((Mx2p * Mx1n) + (Mx2p * Mx1n)) * Mx2n)) * Mx3p) + (((((Mx2p * Mx1p) + (Mx2n * Mx1n)) * Mx2n) + (((Mx2p * Mx1p) + (Mx2n * Mx1n)) * Mx2n)) * Mx3n))) + ((((3 * Mx3p) + (0 * Mx3n)) * Mx3n) + (((3 * Mx3p) + (0 * Mx3n)) * Mx3n))) + Mx2p);
Mex0 = (Mpos - Mneg);

pos float<ieee_64,ne>= ((((((((((float<ieee_64,ne>(2) * x1p) + (float<ieee_64,ne>(0) * x1n)) * x2p) + (((float<ieee_64,ne>(2) * x1n) + (float<ieee_64,ne>(2) * x1n)) * x2n)) * x3p) + (((((float<ieee_64,ne>(2) * x1p) + (float<ieee_64,ne>(0) * x1n)) * x2n) + (((float<ieee_64,ne>(2) * x1p) + (float<ieee_64,ne>(0) * x1n)) * x2n)) * x3n)) + ((((float<ieee_64,ne>(3) * x3p) + (float<ieee_64,ne>(0) * x3n)) * x3p) + (((float<ieee_64,ne>(3) * x3n) + (float<ieee_64,ne>(3) * x3n)) * x3n))) + ((((((x2p * x1p) + (x2n * x1n)) * x2p) + (((x2p * x1n) + (x2p * x1n)) * x2n)) * x3n) + (((((x2p * x1p) + (x2n * x1n)) * x2p) + (((x2p * x1n) + (x2p * x1n)) * x2n)) * x3n))) + ((((float<ieee_64,ne>(3) * x3p) + (float<ieee_64,ne>(0) * x3n)) * x3p) + (((float<ieee_64,ne>(3) * x3n) + (float<ieee_64,ne>(3) * x3n)) * x3n))) + x2n);
neg float<ieee_64,ne>= ((((((((((float<ieee_64,ne>(2) * x1p) + (float<ieee_64,ne>(0) * x1n)) * x2p) + (((float<ieee_64,ne>(2) * x1n) + (float<ieee_64,ne>(2) * x1n)) * x2n)) * x3n) + (((((float<ieee_64,ne>(2) * x1p) + (float<ieee_64,ne>(0) * x1n)) * x2p) + (((float<ieee_64,ne>(2) * x1n) + (float<ieee_64,ne>(2) * x1n)) * x2n)) * x3n)) + ((((float<ieee_64,ne>(3) * x3p) + (float<ieee_64,ne>(0) * x3n)) * x3n) + (((float<ieee_64,ne>(3) * x3p) + (float<ieee_64,ne>(0) * x3n)) * x3n))) + ((((((x2p * x1p) + (x2n * x1n)) * x2p) + (((x2p * x1n) + (x2p * x1n)) * x2n)) * x3p) + (((((x2p * x1p) + (x2n * x1n)) * x2n) + (((x2p * x1p) + (x2n * x1n)) * x2n)) * x3n))) + ((((float<ieee_64,ne>(3) * x3p) + (float<ieee_64,ne>(0) * x3n)) * x3n) + (((float<ieee_64,ne>(3) * x3p) + (float<ieee_64,ne>(0) * x3n)) * x3n))) + x2p);
ex0 float<ieee_64,ne>= (pos - neg);

{ ((((((((((((Mx1p >= 0) /\ (Mx1p <= 0)) /\ (Mx2p >= 0)) /\ (Mx2p <= 0)) /\ (Mx3p >= 0)) /\ (Mx3p <= 0)) /\ ((Mx1n >= -15) /\ (Mx1n <= 15))) /\ (Mx1p = 0)) /\ ((Mx2n >= -15) /\ (Mx2n <= 15))) /\ (Mx2p = 0)) /\ ((Mx3n >= -15) /\ (Mx3n <= 15))) /\ (Mx3p = 0)) /\ (Mx1p in [0, 0] /\ Mx1n in [-15, 15] /\ Mx2p in [0, 0] /\ Mx2n in [-15, 15] /\ Mx3p in [0, 0] /\ Mx3n in [-15, 15])
  -> |ex0 - Mex0| in ? }

