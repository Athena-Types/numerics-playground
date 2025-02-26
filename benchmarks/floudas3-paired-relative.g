x1p = float<ieee_64,ne>(Mx1p);
x1n = float<ieee_64,ne>(Mx1n);
x2p = float<ieee_64,ne>(Mx2p);
x2n = float<ieee_64,ne>(Mx2n);

Mpos = ((((0 * Mx1p) + (-12 * Mx1n)) + ((7 * Mx2n) + (7 * Mx2n))) + ((Mx2p * Mx2p) + (Mx2n * Mx2n)));
Mneg = ((((0 * Mx1n) + (0 * Mx1n)) + ((7 * Mx2p) + (0 * Mx2n))) + ((Mx2p * Mx2n) + (Mx2p * Mx2n)));
Mex0 = (Mpos - Mneg);

pos float<ieee_64,ne>= ((((float<ieee_64,ne>(0) * x1p) + (float<ieee_64,ne>(-12) * x1n)) + ((float<ieee_64,ne>(7) * x2n) + (float<ieee_64,ne>(7) * x2n))) + ((x2p * x2p) + (x2n * x2n)));
neg float<ieee_64,ne>= ((((float<ieee_64,ne>(0) * x1n) + (float<ieee_64,ne>(0) * x1n)) + ((float<ieee_64,ne>(7) * x2p) + (float<ieee_64,ne>(0) * x2n))) + ((x2p * x2n) + (x2p * x2n)));
ex0 float<ieee_64,ne>= (pos - neg);

{ ((((((((Mx1p >= 0) /\ (Mx1p <= 0)) /\ (Mx2p >= 0)) /\ (Mx2p <= 0)) /\ ((Mx1n >= 0) /\ (Mx1n <= 2))) /\ (Mx1p = 0)) /\ ((Mx2n >= 0) /\ (Mx2n <= 3))) /\ (Mx2p = 0)) /\ (Mx1p in [0, 0] /\ Mx1n in [0, 2] /\ Mx2p in [0, 0] /\ Mx2n in [0, 3])
  -> ex0 -/ Mex0 in ? }

