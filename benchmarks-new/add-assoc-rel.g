x0 = float<ieee_64,zr>(Mx0);
x1 = float<ieee_64,zr>(Mx1);
x2 = float<ieee_64,zr>(Mx2);
x3 = float<ieee_64,zr>(Mx3);

Mex0 = ((Mx0 + Mx1) + (Mx2 + Mx3));

ex0 float<ieee_64,zr>= ((x0 + x1) + (x2 + x3));

{ (((((Mx0 >= 1) /\ (Mx0 <= 1000)) /\ ((Mx1 >= 1) /\ (Mx1 <= 1000))) /\ ((Mx2 >= 1) /\ (Mx2 <= 1000))) /\ ((Mx3 >= 1) /\ (Mx3 <= 1000))) /\ (Mx0 in [1, 1000] /\ Mx1 in [1, 1000] /\ Mx2 in [1, 1000] /\ Mx3 in [1, 1000])
  -> ex0 -/ Mex0 in ? }