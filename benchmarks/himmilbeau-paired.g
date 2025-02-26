x1p = float<ieee_64,ne>(Mx1p);
x1n = float<ieee_64,ne>(Mx1n);
x2p = float<ieee_64,ne>(Mx2p);
x2n = float<ieee_64,ne>(Mx2n);

Mpos = (((((((Mx1p * Mx1p) + (Mx1n * Mx1n)) + Mx2p) + 0) * ((((Mx1p * Mx1p) + (Mx1n * Mx1n)) + Mx2p) + 0)) + (((((Mx1p * Mx1n) + (Mx1p * Mx1n)) + Mx2n) + 11) * ((((Mx1p * Mx1n) + (Mx1p * Mx1n)) + Mx2n) + 11))) + ((((Mx1p + ((Mx2p * Mx2p) + (Mx2n * Mx2n))) + 0) * ((Mx1p + ((Mx2p * Mx2p) + (Mx2n * Mx2n))) + 0)) + (((Mx1n + ((Mx2p * Mx2n) + (Mx2p * Mx2n))) + 7) * ((Mx1n + ((Mx2p * Mx2n) + (Mx2p * Mx2n))) + 7))));
Mneg = (((((((Mx1p * Mx1p) + (Mx1n * Mx1n)) + Mx2p) + 0) * ((((Mx1p * Mx1n) + (Mx1p * Mx1n)) + Mx2n) + 11)) + (((((Mx1p * Mx1p) + (Mx1n * Mx1n)) + Mx2p) + 0) * ((((Mx1p * Mx1n) + (Mx1p * Mx1n)) + Mx2n) + 11))) + ((((Mx1p + ((Mx2p * Mx2p) + (Mx2n * Mx2n))) + 0) * ((Mx1n + ((Mx2p * Mx2n) + (Mx2p * Mx2n))) + 7)) + (((Mx1p + ((Mx2p * Mx2p) + (Mx2n * Mx2n))) + 0) * ((Mx1n + ((Mx2p * Mx2n) + (Mx2p * Mx2n))) + 7))));
Mex0 = (Mpos - Mneg);

pos float<ieee_64,ne>= (((((((x1p * x1p) + (x1n * x1n)) + x2p) + float<ieee_64,ne>(0)) * ((((x1p * x1p) + (x1n * x1n)) + x2p) + float<ieee_64,ne>(0))) + (((((x1p * x1n) + (x1p * x1n)) + x2n) + float<ieee_64,ne>(11)) * ((((x1p * x1n) + (x1p * x1n)) + x2n) + float<ieee_64,ne>(11)))) + ((((x1p + ((x2p * x2p) + (x2n * x2n))) + float<ieee_64,ne>(0)) * ((x1p + ((x2p * x2p) + (x2n * x2n))) + float<ieee_64,ne>(0))) + (((x1n + ((x2p * x2n) + (x2p * x2n))) + float<ieee_64,ne>(7)) * ((x1n + ((x2p * x2n) + (x2p * x2n))) + float<ieee_64,ne>(7)))));
neg float<ieee_64,ne>= (((((((x1p * x1p) + (x1n * x1n)) + x2p) + float<ieee_64,ne>(0)) * ((((x1p * x1n) + (x1p * x1n)) + x2n) + float<ieee_64,ne>(11))) + (((((x1p * x1p) + (x1n * x1n)) + x2p) + float<ieee_64,ne>(0)) * ((((x1p * x1n) + (x1p * x1n)) + x2n) + float<ieee_64,ne>(11)))) + ((((x1p + ((x2p * x2p) + (x2n * x2n))) + float<ieee_64,ne>(0)) * ((x1n + ((x2p * x2n) + (x2p * x2n))) + float<ieee_64,ne>(7))) + (((x1p + ((x2p * x2p) + (x2n * x2n))) + float<ieee_64,ne>(0)) * ((x1n + ((x2p * x2n) + (x2p * x2n))) + float<ieee_64,ne>(7)))));
ex0 float<ieee_64,ne>= (pos - neg);

{ ((((((((Mx1p >= 0) /\ (Mx1p <= 0)) /\ (Mx2p >= 0)) /\ (Mx2p <= 0)) /\ ((Mx1n >= -5) /\ (Mx1n <= 5))) /\ (Mx1p = 0)) /\ ((Mx2n >= -5) /\ (Mx2n <= 5))) /\ (Mx2p = 0)) /\ (Mx1p in [0, 0] /\ Mx1n in [-5, 5] /\ Mx2p in [0, 0] /\ Mx2n in [-5, 5])
  -> |ex0 - Mex0| in ? }

