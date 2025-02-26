x0p = float<ieee_32,ne>(Mx0p);
x0n = float<ieee_32,ne>(Mx0n);
x1p = float<ieee_32,ne>(Mx1p);
x1n = float<ieee_32,ne>(Mx1n);
x2p = float<ieee_32,ne>(Mx2p);
x2n = float<ieee_32,ne>(Mx2n);

Mpos = ((((Mx0p + Mx1p) + Mx2n) + ((Mx1p + Mx2p) + Mx0n)) + ((Mx2p + Mx0p) + Mx1n));
Mneg = ((((Mx0n + Mx1n) + Mx2p) + ((Mx1n + Mx2n) + Mx0p)) + ((Mx2n + Mx0n) + Mx1p));
Mex0 = (Mpos - Mneg);

pos float<ieee_32,ne>= ((((x0p + x1p) + x2n) + ((x1p + x2p) + x0n)) + ((x2p + x0p) + x1n));
neg float<ieee_32,ne>= ((((x0n + x1n) + x2p) + ((x1n + x2n) + x0p)) + ((x2n + x0n) + x1p));
ex0 float<ieee_32,ne>= (pos - neg);

{ ((((((((((((Mx0p >= 0) /\ (Mx0p <= 0)) /\ (Mx1p >= 0)) /\ (Mx1p <= 0)) /\ (Mx2p >= 0)) /\ (Mx2p <= 0)) /\ ((Mx0p >= 1) /\ (Mx0p <= 2))) /\ (Mx0n = 0)) /\ ((Mx1p >= 1) /\ (Mx1p <= 2))) /\ (Mx1n = 0)) /\ ((Mx2p >= 1) /\ (Mx2p <= 2))) /\ (Mx2n = 0))
  -> ex0 -/ Mex0 in ? }

