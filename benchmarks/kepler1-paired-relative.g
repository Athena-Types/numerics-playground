x1p = float<ieee_64,ne>(Mx1p);
x1n = float<ieee_64,ne>(Mx1n);
x2p = float<ieee_64,ne>(Mx2p);
x2n = float<ieee_64,ne>(Mx2n);
x3p = float<ieee_64,ne>(Mx3p);
x3n = float<ieee_64,ne>(Mx3n);
x4p = float<ieee_64,ne>(Mx4p);
x4n = float<ieee_64,ne>(Mx4n);

Mpos = ((((((((((Mx1p * Mx4p) + (Mx1n * Mx4n)) * (((Mx1n + Mx2p) + Mx3p) + Mx4n)) + (((Mx1p * Mx4n) + (Mx1p * Mx4n)) * (((Mx1p + Mx2n) + Mx3n) + Mx4p))) + ((Mx2p * (((Mx1p + Mx2n) + Mx3p) + Mx4p)) + (Mx2n * (((Mx1n + Mx2p) + Mx3n) + Mx4n)))) + ((Mx3p * (((Mx1p + Mx2p) + Mx3n) + Mx4p)) + (Mx3n * (((Mx1n + Mx2n) + Mx3p) + Mx4n)))) + ((((Mx2p * Mx3p) + (Mx2n * Mx3n)) * Mx4n) + (((Mx2p * Mx3p) + (Mx2n * Mx3n)) * Mx4n))) + ((Mx1p * Mx3n) + (Mx1p * Mx3n))) + ((Mx1p * Mx2n) + (Mx1p * Mx2n))) + Mx4n);
Mneg = ((((((((((Mx1p * Mx4p) + (Mx1n * Mx4n)) * (((Mx1p + Mx2n) + Mx3n) + Mx4p)) + (((Mx1p * Mx4p) + (Mx1n * Mx4n)) * (((Mx1p + Mx2n) + Mx3n) + Mx4p))) + ((Mx2p * (((Mx1n + Mx2p) + Mx3n) + Mx4n)) + (Mx2p * (((Mx1n + Mx2p) + Mx3n) + Mx4n)))) + ((Mx3p * (((Mx1n + Mx2n) + Mx3p) + Mx4n)) + (Mx3p * (((Mx1n + Mx2n) + Mx3p) + Mx4n)))) + ((((Mx2p * Mx3p) + (Mx2n * Mx3n)) * Mx4p) + (((Mx2p * Mx3n) + (Mx2p * Mx3n)) * Mx4n))) + ((Mx1p * Mx3p) + (Mx1n * Mx3n))) + ((Mx1p * Mx2p) + (Mx1n * Mx2n))) + Mx4p);
Mex0 = (Mpos - Mneg);

pos float<ieee_64,ne>= ((((((((((x1p * x4p) + (x1n * x4n)) * (((x1n + x2p) + x3p) + x4n)) + (((x1p * x4n) + (x1p * x4n)) * (((x1p + x2n) + x3n) + x4p))) + ((x2p * (((x1p + x2n) + x3p) + x4p)) + (x2n * (((x1n + x2p) + x3n) + x4n)))) + ((x3p * (((x1p + x2p) + x3n) + x4p)) + (x3n * (((x1n + x2n) + x3p) + x4n)))) + ((((x2p * x3p) + (x2n * x3n)) * x4n) + (((x2p * x3p) + (x2n * x3n)) * x4n))) + ((x1p * x3n) + (x1p * x3n))) + ((x1p * x2n) + (x1p * x2n))) + x4n);
neg float<ieee_64,ne>= ((((((((((x1p * x4p) + (x1n * x4n)) * (((x1p + x2n) + x3n) + x4p)) + (((x1p * x4p) + (x1n * x4n)) * (((x1p + x2n) + x3n) + x4p))) + ((x2p * (((x1n + x2p) + x3n) + x4n)) + (x2p * (((x1n + x2p) + x3n) + x4n)))) + ((x3p * (((x1n + x2n) + x3p) + x4n)) + (x3p * (((x1n + x2n) + x3p) + x4n)))) + ((((x2p * x3p) + (x2n * x3n)) * x4p) + (((x2p * x3n) + (x2p * x3n)) * x4n))) + ((x1p * x3p) + (x1n * x3n))) + ((x1p * x2p) + (x1n * x2n))) + x4p);
ex0 float<ieee_64,ne>= (pos - neg);

{ ((((((((((((((((Mx1p >= 0) /\ (Mx1p <= 0)) /\ (Mx2p >= 0)) /\ (Mx2p <= 0)) /\ (Mx3p >= 0)) /\ (Mx3p <= 0)) /\ (Mx4p >= 0)) /\ (Mx4p <= 0)) /\ ((Mx1p >= 4) /\ (Mx1p <= 636e-2))) /\ (Mx1n = 0)) /\ ((Mx2p >= 4) /\ (Mx2p <= 636e-2))) /\ (Mx2n = 0)) /\ ((Mx3p >= 4) /\ (Mx3p <= 636e-2))) /\ (Mx3n = 0)) /\ ((Mx4p >= 4) /\ (Mx4p <= 636e-2))) /\ (Mx4n = 0))
  -> ex0 -/ Mex0 in ? }

