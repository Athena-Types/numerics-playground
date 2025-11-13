x0 = float<ieee_64,zr>(Mx0);
x1 = float<ieee_64,zr>(Mx1);
x2 = float<ieee_64,zr>(Mx2);

Mp0 = ((Mx0 + Mx1) - Mx2);
Mp1 = ((Mx1 + Mx2) - Mx0);
Mp2 = ((Mx2 + Mx0) - Mx1);
Mex0 = ((Mp0 + Mp1) + Mp2);

p0 float<ieee_64,zr>= ((x0 + x1) - x2);
p1 float<ieee_64,zr>= ((x1 + x2) - x0);
p2 float<ieee_64,zr>= ((x2 + x0) - x1);
ex0 float<ieee_64,zr>= ((p0 + p1) + p2);

{ ((((Mx0 >= 1) /\ (Mx0 <= 2)) /\ ((Mx1 >= 1) /\ (Mx1 <= 2))) /\ ((Mx2 >= 1) /\ (Mx2 <= 2))) /\ (Mx0 in [1, 2] /\ Mx1 in [1, 2] /\ Mx2 in [1, 2])
  -> ex0 -/ Mex0 in ? }