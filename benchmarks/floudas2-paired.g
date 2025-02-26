x1p = float<ieee_64,ne>(Mx1p);
x1n = float<ieee_64,ne>(Mx1n);
x2p = float<ieee_64,ne>(Mx2p);
x2n = float<ieee_64,ne>(Mx2n);

Mpos = (Mx1n + Mx2n);
Mneg = (Mx1p + Mx2p);
Mex0 = (Mpos - Mneg);

pos float<ieee_64,ne>= (x1n + x2n);
neg float<ieee_64,ne>= (x1p + x2p);
ex0 float<ieee_64,ne>= (pos - neg);

{ ((((((((((Mx1p >= 0) /\ (Mx1p <= 0)) /\ (Mx2p >= 0)) /\ (Mx2p <= 0)) /\ ((Mx1n >= 0) /\ (Mx1n <= 3))) /\ (Mx1p = 0)) /\ ((Mx2n >= 0) /\ (Mx2n <= 4))) /\ (Mx2p = 0)) /\ (((((2 * (((Mx1p - Mx1n) * (Mx1p - Mx1n)) * ((Mx1p - Mx1n) * (Mx1p - Mx1n)))) - ((8 * ((Mx1p - Mx1n) * (Mx1p - Mx1n))) * (Mx1p - Mx1n))) + ((8 * (Mx1p - Mx1n)) * (Mx1p - Mx1n))) - (Mx2p - Mx2n)) >= 0)) /\ (((((((4 * (((Mx1p - Mx1n) * (Mx1p - Mx1n)) * ((Mx1p - Mx1n) * (Mx1p - Mx1n)))) - ((32 * ((Mx1p - Mx1n) * (Mx1p - Mx1n))) * (Mx1p - Mx1n))) + ((88 * (Mx1p - Mx1n)) * (Mx1p - Mx1n))) - (96 * (Mx1p - Mx1n))) + 36) - (Mx2p - Mx2n)) >= 0)) /\ (Mx1p in [0, 0] /\ Mx1n in [0, 3] /\ Mx2p in [0, 0] /\ Mx2n in [0, 4])
  -> |ex0 - Mex0| in ? }

