x1 = float<ieee_64,ne>(Mx1);
x2 = float<ieee_64,ne>(Mx2);

Ma = (((Mx1 * Mx1) + Mx2) - 11);
Mb = ((Mx1 + (Mx2 * Mx2)) - 7);
Mex0 = ((Ma * Ma) + (Mb * Mb));

a float<ieee_64,ne>= (((x1 * x1) + x2) - float<ieee_64,ne>(11));
b float<ieee_64,ne>= ((x1 + (x2 * x2)) - float<ieee_64,ne>(7));
ex0 float<ieee_64,ne>= ((a * a) + (b * b));

{ (((Mx1 >= -5) /\ (Mx1 <= 5)) /\ ((Mx2 >= -5) /\ (Mx2 <= 5))) /\ (Mx1 in [-5, 5] /\ Mx2 in [-5, 5])
  -> ex0 -/ Mex0 in ? }