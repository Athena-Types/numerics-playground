x1 = float<ieee_64,ne>(Mx1);
x2 = float<ieee_64,ne>(Mx2);
x3 = float<ieee_64,ne>(Mx3);
x4 = float<ieee_64,ne>(Mx4);
x5 = float<ieee_64,ne>(Mx5);
x6 = float<ieee_64,ne>(Mx6);

Mex0 = ((((((-25 * ((Mx1 - 2) * (Mx1 - 2))) - ((Mx2 - 2) * (Mx2 - 2))) - ((Mx3 - 1) * (Mx3 - 1))) - ((Mx4 - 4) * (Mx4 - 4))) - ((Mx5 - 1) * (Mx5 - 1))) - ((Mx6 - 4) * (Mx6 - 4)));

ex0 float<ieee_64,ne>= ((((((float<ieee_64,ne>(-25) * ((x1 - float<ieee_64,ne>(2)) * (x1 - float<ieee_64,ne>(2)))) - ((x2 - float<ieee_64,ne>(2)) * (x2 - float<ieee_64,ne>(2)))) - ((x3 - float<ieee_64,ne>(1)) * (x3 - float<ieee_64,ne>(1)))) - ((x4 - float<ieee_64,ne>(4)) * (x4 - float<ieee_64,ne>(4)))) - ((x5 - float<ieee_64,ne>(1)) * (x5 - float<ieee_64,ne>(1)))) - ((x6 - float<ieee_64,ne>(4)) * (x6 - float<ieee_64,ne>(4))));

{ (((((((((((((Mx1 >= 0) /\ (Mx1 <= 6)) /\ ((Mx2 >= 0) /\ (Mx2 <= 6))) /\ ((Mx3 >= 1) /\ (Mx3 <= 5))) /\ ((Mx4 >= 0) /\ (Mx4 <= 6))) /\ ((Mx5 >= 0) /\ (Mx5 <= 6))) /\ ((Mx6 >= 0) /\ (Mx6 <= 10))) /\ (((((Mx3 - 3) * (Mx3 - 3)) + Mx4) - 4) >= 0)) /\ (((((Mx5 - 3) * (Mx5 - 3)) + Mx6) - 4) >= 0)) /\ (((2 - Mx1) + (3 * Mx2)) >= 0)) /\ (((2 + Mx1) - Mx2) >= 0)) /\ (((6 - Mx1) - Mx2) >= 0)) /\ (((Mx1 + Mx2) - 2) >= 0)) /\ (Mx1 in [0, 6] /\ Mx2 in [0, 6] /\ Mx3 in [1, 5] /\ Mx4 in [0, 6] /\ Mx5 in [0, 6] /\ Mx6 in [0, 10])
  -> |ex0 - Mex0| in ? }

