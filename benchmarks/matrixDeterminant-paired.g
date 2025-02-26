ap = float<ieee_64,ne>(Map);
an = float<ieee_64,ne>(Man);
bp = float<ieee_64,ne>(Mbp);
bn = float<ieee_64,ne>(Mbn);
cp = float<ieee_64,ne>(Mcp);
cn = float<ieee_64,ne>(Mcn);
dp = float<ieee_64,ne>(Mdp);
dn = float<ieee_64,ne>(Mdn);
ep = float<ieee_64,ne>(Mep);
en = float<ieee_64,ne>(Men);
fp = float<ieee_64,ne>(Mfp);
fn = float<ieee_64,ne>(Mfn);
gp = float<ieee_64,ne>(Mgp);
gn = float<ieee_64,ne>(Mgn);
hp = float<ieee_64,ne>(Mhp);
hn = float<ieee_64,ne>(Mhn);
ip = float<ieee_64,ne>(Mip);
in = float<ieee_64,ne>(Min);

Mpos = (((((((Map * Mep) + (Man * Men)) * Mip) + (((Map * Men) + (Map * Men)) * Min)) + ((((Mbp * Mfp) + (Mbn * Mfn)) * Mgp) + (((Mbp * Mfn) + (Mbp * Mfn)) * Mgn))) + ((((Mcp * Mdp) + (Mcn * Mdn)) * Mhp) + (((Mcp * Mdn) + (Mcp * Mdn)) * Mhn))) + ((((((Mcp * Mep) + (Mcn * Men)) * Mgn) + (((Mcp * Mep) + (Mcn * Men)) * Mgn)) + ((((Mbp * Mdp) + (Mbn * Mdn)) * Min) + (((Mbp * Mdp) + (Mbn * Mdn)) * Min))) + ((((Map * Mfp) + (Man * Mfn)) * Mhn) + (((Map * Mfp) + (Man * Mfn)) * Mhn))));
Mneg = (((((((Map * Mep) + (Man * Men)) * Min) + (((Map * Mep) + (Man * Men)) * Min)) + ((((Mbp * Mfp) + (Mbn * Mfn)) * Mgn) + (((Mbp * Mfp) + (Mbn * Mfn)) * Mgn))) + ((((Mcp * Mdp) + (Mcn * Mdn)) * Mhn) + (((Mcp * Mdp) + (Mcn * Mdn)) * Mhn))) + ((((((Mcp * Mep) + (Mcn * Men)) * Mgp) + (((Mcp * Men) + (Mcp * Men)) * Mgn)) + ((((Mbp * Mdp) + (Mbn * Mdn)) * Mip) + (((Mbp * Mdn) + (Mbp * Mdn)) * Min))) + ((((Map * Mfp) + (Man * Mfn)) * Mhp) + (((Map * Mfn) + (Map * Mfn)) * Mhn))));
Mex0 = (Mpos - Mneg);

pos float<ieee_64,ne>= (((((((ap * ep) + (an * en)) * ip) + (((ap * en) + (ap * en)) * in)) + ((((bp * fp) + (bn * fn)) * gp) + (((bp * fn) + (bp * fn)) * gn))) + ((((cp * dp) + (cn * dn)) * hp) + (((cp * dn) + (cp * dn)) * hn))) + ((((((cp * ep) + (cn * en)) * gn) + (((cp * ep) + (cn * en)) * gn)) + ((((bp * dp) + (bn * dn)) * in) + (((bp * dp) + (bn * dn)) * in))) + ((((ap * fp) + (an * fn)) * hn) + (((ap * fp) + (an * fn)) * hn))));
neg float<ieee_64,ne>= (((((((ap * ep) + (an * en)) * in) + (((ap * ep) + (an * en)) * in)) + ((((bp * fp) + (bn * fn)) * gn) + (((bp * fp) + (bn * fn)) * gn))) + ((((cp * dp) + (cn * dn)) * hn) + (((cp * dp) + (cn * dn)) * hn))) + ((((((cp * ep) + (cn * en)) * gp) + (((cp * en) + (cp * en)) * gn)) + ((((bp * dp) + (bn * dn)) * ip) + (((bp * dn) + (bp * dn)) * in))) + ((((ap * fp) + (an * fn)) * hp) + (((ap * fn) + (ap * fn)) * hn))));
ex0 float<ieee_64,ne>= (pos - neg);

{ ((((((((((((((((((((((((((((((((((((Map >= 0) /\ (Map <= 0)) /\ (Mbp >= 0)) /\ (Mbp <= 0)) /\ (Mcp >= 0)) /\ (Mcp <= 0)) /\ (Mdp >= 0)) /\ (Mdp <= 0)) /\ (Mep >= 0)) /\ (Mep <= 0)) /\ (Mfp >= 0)) /\ (Mfp <= 0)) /\ (Mgp >= 0)) /\ (Mgp <= 0)) /\ (Mhp >= 0)) /\ (Mhp <= 0)) /\ (Mip >= 0)) /\ (Mip <= 0)) /\ ((Man >= -10) /\ (Man <= 10))) /\ (Map = 0)) /\ ((Mbn >= -10) /\ (Mbn <= 10))) /\ (Mbp = 0)) /\ ((Mcn >= -10) /\ (Mcn <= 10))) /\ (Mcp = 0)) /\ ((Mdn >= -10) /\ (Mdn <= 10))) /\ (Mdp = 0)) /\ ((Men >= -10) /\ (Men <= 10))) /\ (Mep = 0)) /\ ((Mfn >= -10) /\ (Mfn <= 10))) /\ (Mfp = 0)) /\ ((Mgn >= -10) /\ (Mgn <= 10))) /\ (Mgp = 0)) /\ ((Mhn >= -10) /\ (Mhn <= 10))) /\ (Mhp = 0)) /\ ((Min >= -10) /\ (Min <= 10))) /\ (Mip = 0)) /\ (Map in [0, 0] /\ Man in [-10, 10] /\ Mbp in [0, 0] /\ Mbn in [-10, 10] /\ Mcp in [0, 0] /\ Mcn in [-10, 10] /\ Mdp in [0, 0] /\ Mdn in [-10, 10] /\ Mep in [0, 0] /\ Men in [-10, 10] /\ Mfp in [0, 0] /\ Mfn in [-10, 10] /\ Mgp in [0, 0] /\ Mgn in [-10, 10] /\ Mhp in [0, 0] /\ Mhn in [-10, 10] /\ Mip in [0, 0] /\ Min in [-10, 10])
  -> |ex0 - Mex0| in ? }

