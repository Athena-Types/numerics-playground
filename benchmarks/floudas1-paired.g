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

Mpos = (((((((0 * (((Mx1p + 0) * (Mx1p + 0)) + ((Mx1n + 2) * (Mx1n + 2)))) + (-25 * (((Mx1p + 0) * (Mx1n + 2)) + ((Mx1p + 0) * (Mx1n + 2))))) + (((Mx2p + 0) * (Mx2n + 2)) + ((Mx2p + 0) * (Mx2n + 2)))) + (((Mx3p + 0) * (Mx3n + 1)) + ((Mx3p + 0) * (Mx3n + 1)))) + (((Mx4p + 0) * (Mx4n + 4)) + ((Mx4p + 0) * (Mx4n + 4)))) + (((Mx5p + 0) * (Mx5n + 1)) + ((Mx5p + 0) * (Mx5n + 1)))) + (((Mx6p + 0) * (Mx6n + 4)) + ((Mx6p + 0) * (Mx6n + 4))));
Mneg = (((((((0 * (((Mx1p + 0) * (Mx1n + 2)) + ((Mx1p + 0) * (Mx1n + 2)))) + (0 * (((Mx1p + 0) * (Mx1n + 2)) + ((Mx1p + 0) * (Mx1n + 2))))) + (((Mx2p + 0) * (Mx2p + 0)) + ((Mx2n + 2) * (Mx2n + 2)))) + (((Mx3p + 0) * (Mx3p + 0)) + ((Mx3n + 1) * (Mx3n + 1)))) + (((Mx4p + 0) * (Mx4p + 0)) + ((Mx4n + 4) * (Mx4n + 4)))) + (((Mx5p + 0) * (Mx5p + 0)) + ((Mx5n + 1) * (Mx5n + 1)))) + (((Mx6p + 0) * (Mx6p + 0)) + ((Mx6n + 4) * (Mx6n + 4))));
Mex0 = (Mpos - Mneg);

pos float<ieee_64,ne>= (((((((float<ieee_64,ne>(0) * (((x1p + float<ieee_64,ne>(0)) * (x1p + float<ieee_64,ne>(0))) + ((x1n + float<ieee_64,ne>(2)) * (x1n + float<ieee_64,ne>(2))))) + (float<ieee_64,ne>(-25) * (((x1p + float<ieee_64,ne>(0)) * (x1n + float<ieee_64,ne>(2))) + ((x1p + float<ieee_64,ne>(0)) * (x1n + float<ieee_64,ne>(2)))))) + (((x2p + float<ieee_64,ne>(0)) * (x2n + float<ieee_64,ne>(2))) + ((x2p + float<ieee_64,ne>(0)) * (x2n + float<ieee_64,ne>(2))))) + (((x3p + float<ieee_64,ne>(0)) * (x3n + float<ieee_64,ne>(1))) + ((x3p + float<ieee_64,ne>(0)) * (x3n + float<ieee_64,ne>(1))))) + (((x4p + float<ieee_64,ne>(0)) * (x4n + float<ieee_64,ne>(4))) + ((x4p + float<ieee_64,ne>(0)) * (x4n + float<ieee_64,ne>(4))))) + (((x5p + float<ieee_64,ne>(0)) * (x5n + float<ieee_64,ne>(1))) + ((x5p + float<ieee_64,ne>(0)) * (x5n + float<ieee_64,ne>(1))))) + (((x6p + float<ieee_64,ne>(0)) * (x6n + float<ieee_64,ne>(4))) + ((x6p + float<ieee_64,ne>(0)) * (x6n + float<ieee_64,ne>(4)))));
neg float<ieee_64,ne>= (((((((float<ieee_64,ne>(0) * (((x1p + float<ieee_64,ne>(0)) * (x1n + float<ieee_64,ne>(2))) + ((x1p + float<ieee_64,ne>(0)) * (x1n + float<ieee_64,ne>(2))))) + (float<ieee_64,ne>(0) * (((x1p + float<ieee_64,ne>(0)) * (x1n + float<ieee_64,ne>(2))) + ((x1p + float<ieee_64,ne>(0)) * (x1n + float<ieee_64,ne>(2)))))) + (((x2p + float<ieee_64,ne>(0)) * (x2p + float<ieee_64,ne>(0))) + ((x2n + float<ieee_64,ne>(2)) * (x2n + float<ieee_64,ne>(2))))) + (((x3p + float<ieee_64,ne>(0)) * (x3p + float<ieee_64,ne>(0))) + ((x3n + float<ieee_64,ne>(1)) * (x3n + float<ieee_64,ne>(1))))) + (((x4p + float<ieee_64,ne>(0)) * (x4p + float<ieee_64,ne>(0))) + ((x4n + float<ieee_64,ne>(4)) * (x4n + float<ieee_64,ne>(4))))) + (((x5p + float<ieee_64,ne>(0)) * (x5p + float<ieee_64,ne>(0))) + ((x5n + float<ieee_64,ne>(1)) * (x5n + float<ieee_64,ne>(1))))) + (((x6p + float<ieee_64,ne>(0)) * (x6p + float<ieee_64,ne>(0))) + ((x6n + float<ieee_64,ne>(4)) * (x6n + float<ieee_64,ne>(4)))));
ex0 float<ieee_64,ne>= (pos - neg);

{ ((((((((((((((((((((((((((((((Mx1p >= 0) /\ (Mx1p <= 0)) /\ (Mx2p >= 0)) /\ (Mx2p <= 0)) /\ (Mx3p >= 0)) /\ (Mx3p <= 0)) /\ (Mx4p >= 0)) /\ (Mx4p <= 0)) /\ (Mx5p >= 0)) /\ (Mx5p <= 0)) /\ (Mx6p >= 0)) /\ (Mx6p <= 0)) /\ ((Mx1n >= 0) /\ (Mx1n <= 6))) /\ (Mx1p = 0)) /\ ((Mx2n >= 0) /\ (Mx2n <= 6))) /\ (Mx2p = 0)) /\ ((Mx3p >= 1) /\ (Mx3p <= 5))) /\ (Mx3n = 0)) /\ ((Mx4n >= 0) /\ (Mx4n <= 6))) /\ (Mx4p = 0)) /\ ((Mx5n >= 0) /\ (Mx5n <= 6))) /\ (Mx5p = 0)) /\ ((Mx6n >= 0) /\ (Mx6n <= 10))) /\ (Mx6p = 0)) /\ ((((((Mx3p - Mx3n) - 3) * ((Mx3p - Mx3n) - 3)) + (Mx4p - Mx4n)) - 4) >= 0)) /\ ((((((Mx5p - Mx5n) - 3) * ((Mx5p - Mx5n) - 3)) + (Mx6p - Mx6n)) - 4) >= 0)) /\ (((2 - (Mx1p - Mx1n)) + (3 * (Mx2p - Mx2n))) >= 0)) /\ (((2 + (Mx1p - Mx1n)) - (Mx2p - Mx2n)) >= 0)) /\ (((6 - (Mx1p - Mx1n)) - (Mx2p - Mx2n)) >= 0)) /\ ((((Mx1p - Mx1n) + (Mx2p - Mx2n)) - 2) >= 0))
  -> |ex0 - Mex0| in ? }

