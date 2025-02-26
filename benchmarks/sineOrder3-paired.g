xp = float<ieee_64,ne>(Mxp);
xn = float<ieee_64,ne>(Mxn);

Mpos = (((954929658551372e-15 * Mxp) + (0 * Mxn)) + ((12900613773279798e-17 * ((((Mxp * Mxp) + (Mxn * Mxn)) * Mxn) + (((Mxp * Mxp) + (Mxn * Mxn)) * Mxn))) + (12900613773279798e-17 * ((((Mxp * Mxp) + (Mxn * Mxn)) * Mxn) + (((Mxp * Mxp) + (Mxn * Mxn)) * Mxn)))));
Mneg = (((954929658551372e-15 * Mxn) + (954929658551372e-15 * Mxn)) + ((12900613773279798e-17 * ((((Mxp * Mxp) + (Mxn * Mxn)) * Mxp) + (((Mxp * Mxn) + (Mxp * Mxn)) * Mxn))) + (0 * ((((Mxp * Mxp) + (Mxn * Mxn)) * Mxn) + (((Mxp * Mxp) + (Mxn * Mxn)) * Mxn)))));
Mex0 = (Mpos - Mneg);

pos float<ieee_64,ne>= (((float<ieee_64,ne>(954929658551372e-15) * xp) + (float<ieee_64,ne>(0) * xn)) + ((float<ieee_64,ne>(12900613773279798e-17) * ((((xp * xp) + (xn * xn)) * xn) + (((xp * xp) + (xn * xn)) * xn))) + (float<ieee_64,ne>(12900613773279798e-17) * ((((xp * xp) + (xn * xn)) * xn) + (((xp * xp) + (xn * xn)) * xn)))));
neg float<ieee_64,ne>= (((float<ieee_64,ne>(954929658551372e-15) * xn) + (float<ieee_64,ne>(954929658551372e-15) * xn)) + ((float<ieee_64,ne>(12900613773279798e-17) * ((((xp * xp) + (xn * xn)) * xp) + (((xp * xn) + (xp * xn)) * xn))) + (float<ieee_64,ne>(0) * ((((xp * xp) + (xn * xn)) * xn) + (((xp * xp) + (xn * xn)) * xn)))));
ex0 float<ieee_64,ne>= (pos - neg);

{ (((Mxp >= 0) /\ (Mxp <= 0)) /\ (((Mxp - Mxn) >= -2) /\ ((Mxp - Mxn) <= 2))) /\ (Mxp in [0, 0])
  -> |ex0 - Mex0| in ? }

