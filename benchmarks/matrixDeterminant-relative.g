a = float<ieee_64,ne>(Ma);
b = float<ieee_64,ne>(Mb);
c = float<ieee_64,ne>(Mc);
d = float<ieee_64,ne>(Md);
e = float<ieee_64,ne>(Me1);
f = float<ieee_64,ne>(Mf);
g = float<ieee_64,ne>(Mg);
h = float<ieee_64,ne>(Mh);
i = float<ieee_64,ne>(Mi);

Mex0 = (((((Ma * Me1) * Mi) + ((Mb * Mf) * Mg)) + ((Mc * Md) * Mh)) - ((((Mc * Me1) * Mg) + ((Mb * Md) * Mi)) + ((Ma * Mf) * Mh)));

ex0 float<ieee_64,ne>= (((((a * e) * i) + ((b * f) * g)) + ((c * d) * h)) - ((((c * e) * g) + ((b * d) * i)) + ((a * f) * h)));

{ ((((((((((Ma >= -10) /\ (Ma <= 10)) /\ ((Mb >= -10) /\ (Mb <= 10))) /\ ((Mc >= -10) /\ (Mc <= 10))) /\ ((Md >= -10) /\ (Md <= 10))) /\ ((Me1 >= -10) /\ (Me1 <= 10))) /\ ((Mf >= -10) /\ (Mf <= 10))) /\ ((Mg >= -10) /\ (Mg <= 10))) /\ ((Mh >= -10) /\ (Mh <= 10))) /\ ((Mi >= -10) /\ (Mi <= 10))) /\ (Ma in [-10, 10] /\ Mb in [-10, 10] /\ Mc in [-10, 10] /\ Md in [-10, 10] /\ Me1 in [-10, 10] /\ Mf in [-10, 10] /\ Mg in [-10, 10] /\ Mh in [-10, 10] /\ Mi in [-10, 10])
  -> ex0 -/ Mex0 in ? }

