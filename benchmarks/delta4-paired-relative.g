x1p = float<ieee_64,ne>(Mx1p);
x1n = float<ieee_64,ne>(Mx1n);
x2p = float<ieee_64,ne>(Mx2p);
x2n = float<ieee_64,ne>(Mx2n);
x3p = float<ieee_64,ne>(Mx3p);
x3n = float<ieee_64,ne>(Mx3n);
x4p = float<ieee_64,ne>(Mx4p);
x4n = float<ieee_64,ne>(Mx4n);
x5p = float<ieee_64,ne>(Mx5p);
x5n = float<ieee_64,ne>(Mx5n);
x6p = float<ieee_64,ne>(Mx6p);
x6n = float<ieee_64,ne>(Mx6n);

Mpos = (((((((Mx2n * Mx3p) + (Mx2p * Mx3n)) + ((Mx1p * Mx4n) + (Mx1p * Mx4n))) + ((Mx2p * Mx5p) + (Mx2n * Mx5n))) + ((Mx3p * Mx6p) + (Mx3n * Mx6n))) + ((Mx5p * Mx6n) + (Mx5p * Mx6n))) + ((Mx1p * (((((Mx1n + Mx2p) + Mx3p) + Mx4n) + Mx5p) + Mx6p)) + (Mx1n * (((((Mx1p + Mx2n) + Mx3n) + Mx4p) + Mx5n) + Mx6n))));
Mneg = (((((((Mx2n * Mx3n) + (Mx2n * Mx3n)) + ((Mx1p * Mx4p) + (Mx1n * Mx4n))) + ((Mx2p * Mx5n) + (Mx2p * Mx5n))) + ((Mx3p * Mx6n) + (Mx3p * Mx6n))) + ((Mx5p * Mx6p) + (Mx5n * Mx6n))) + ((Mx1p * (((((Mx1p + Mx2n) + Mx3n) + Mx4p) + Mx5n) + Mx6n)) + (Mx1p * (((((Mx1p + Mx2n) + Mx3n) + Mx4p) + Mx5n) + Mx6n))));
Mex0 = (Mpos - Mneg);

pos float<ieee_64,ne>= (((((((x2n * x3p) + (x2p * x3n)) + ((x1p * x4n) + (x1p * x4n))) + ((x2p * x5p) + (x2n * x5n))) + ((x3p * x6p) + (x3n * x6n))) + ((x5p * x6n) + (x5p * x6n))) + ((x1p * (((((x1n + x2p) + x3p) + x4n) + x5p) + x6p)) + (x1n * (((((x1p + x2n) + x3n) + x4p) + x5n) + x6n))));
neg float<ieee_64,ne>= (((((((x2n * x3n) + (x2n * x3n)) + ((x1p * x4p) + (x1n * x4n))) + ((x2p * x5n) + (x2p * x5n))) + ((x3p * x6n) + (x3p * x6n))) + ((x5p * x6p) + (x5n * x6n))) + ((x1p * (((((x1p + x2n) + x3n) + x4p) + x5n) + x6n)) + (x1p * (((((x1p + x2n) + x3n) + x4p) + x5n) + x6n))));
ex0 float<ieee_64,ne>= (pos - neg);

{ ((((((((((((((((((((((((Mx1p >= 0) /\ (Mx1p <= 0)) /\ (Mx2p >= 0)) /\ (Mx2p <= 0)) /\ (Mx3p >= 0)) /\ (Mx3p <= 0)) /\ (Mx4p >= 0)) /\ (Mx4p <= 0)) /\ (Mx5p >= 0)) /\ (Mx5p <= 0)) /\ (Mx6p >= 0)) /\ (Mx6p <= 0)) /\ ((Mx1p >= 4) /\ (Mx1p <= 63504e-4))) /\ (Mx1n = 0)) /\ ((Mx2p >= 4) /\ (Mx2p <= 63504e-4))) /\ (Mx2n = 0)) /\ ((Mx3p >= 4) /\ (Mx3p <= 63504e-4))) /\ (Mx3n = 0)) /\ ((Mx4p >= 4) /\ (Mx4p <= 63504e-4))) /\ (Mx4n = 0)) /\ ((Mx5p >= 4) /\ (Mx5p <= 63504e-4))) /\ (Mx5n = 0)) /\ ((Mx6p >= 4) /\ (Mx6p <= 63504e-4))) /\ (Mx6n = 0))
  -> ex0 -/ Mex0 in ? }

