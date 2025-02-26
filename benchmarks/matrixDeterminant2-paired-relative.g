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

Mpos = ((((Map * ((Mep * Mip) + (Men * Min))) + (Man * ((Mep * Min) + (Mep * Min)))) + (((Mgp * ((Mbp * Mfp) + (Mbn * Mfn))) + (Mgn * ((Mbp * Mfn) + (Mbp * Mfn)))) + ((Mcp * ((Mdp * Mhp) + (Mdn * Mhn))) + (Mcn * ((Mdp * Mhn) + (Mdp * Mhn)))))) + (((Mep * ((Mcp * Mgn) + (Mcp * Mgn))) + (Mep * ((Mcp * Mgn) + (Mcp * Mgn)))) + (((Mip * ((Mbp * Mdn) + (Mbp * Mdn))) + (Mip * ((Mbp * Mdn) + (Mbp * Mdn)))) + ((Map * ((Mfp * Mhn) + (Mfp * Mhn))) + (Map * ((Mfp * Mhn) + (Mfp * Mhn)))))));
Mneg = ((((Map * ((Mep * Min) + (Mep * Min))) + (Map * ((Mep * Min) + (Mep * Min)))) + (((Mgp * ((Mbp * Mfn) + (Mbp * Mfn))) + (Mgp * ((Mbp * Mfn) + (Mbp * Mfn)))) + ((Mcp * ((Mdp * Mhn) + (Mdp * Mhn))) + (Mcp * ((Mdp * Mhn) + (Mdp * Mhn)))))) + (((Mep * ((Mcp * Mgp) + (Mcn * Mgn))) + (Men * ((Mcp * Mgn) + (Mcp * Mgn)))) + (((Mip * ((Mbp * Mdp) + (Mbn * Mdn))) + (Min * ((Mbp * Mdn) + (Mbp * Mdn)))) + ((Map * ((Mfp * Mhp) + (Mfn * Mhn))) + (Man * ((Mfp * Mhn) + (Mfp * Mhn)))))));
Mex0 = (Mpos - Mneg);

pos float<ieee_64,ne>= ((((ap * ((ep * ip) + (en * in))) + (an * ((ep * in) + (ep * in)))) + (((gp * ((bp * fp) + (bn * fn))) + (gn * ((bp * fn) + (bp * fn)))) + ((cp * ((dp * hp) + (dn * hn))) + (cn * ((dp * hn) + (dp * hn)))))) + (((ep * ((cp * gn) + (cp * gn))) + (ep * ((cp * gn) + (cp * gn)))) + (((ip * ((bp * dn) + (bp * dn))) + (ip * ((bp * dn) + (bp * dn)))) + ((ap * ((fp * hn) + (fp * hn))) + (ap * ((fp * hn) + (fp * hn)))))));
neg float<ieee_64,ne>= ((((ap * ((ep * in) + (ep * in))) + (ap * ((ep * in) + (ep * in)))) + (((gp * ((bp * fn) + (bp * fn))) + (gp * ((bp * fn) + (bp * fn)))) + ((cp * ((dp * hn) + (dp * hn))) + (cp * ((dp * hn) + (dp * hn)))))) + (((ep * ((cp * gp) + (cn * gn))) + (en * ((cp * gn) + (cp * gn)))) + (((ip * ((bp * dp) + (bn * dn))) + (in * ((bp * dn) + (bp * dn)))) + ((ap * ((fp * hp) + (fn * hn))) + (an * ((fp * hn) + (fp * hn)))))));
ex0 float<ieee_64,ne>= (pos - neg);

{ ((((((((((((((((((((((((((((((((((((Map >= 0) /\ (Map <= 0)) /\ (Mbp >= 0)) /\ (Mbp <= 0)) /\ (Mcp >= 0)) /\ (Mcp <= 0)) /\ (Mdp >= 0)) /\ (Mdp <= 0)) /\ (Mep >= 0)) /\ (Mep <= 0)) /\ (Mfp >= 0)) /\ (Mfp <= 0)) /\ (Mgp >= 0)) /\ (Mgp <= 0)) /\ (Mhp >= 0)) /\ (Mhp <= 0)) /\ (Mip >= 0)) /\ (Mip <= 0)) /\ ((Man >= -10) /\ (Man <= 10))) /\ (Map = 0)) /\ ((Mbn >= -10) /\ (Mbn <= 10))) /\ (Mbp = 0)) /\ ((Mcn >= -10) /\ (Mcn <= 10))) /\ (Mcp = 0)) /\ ((Mdn >= -10) /\ (Mdn <= 10))) /\ (Mdp = 0)) /\ ((Men >= -10) /\ (Men <= 10))) /\ (Mep = 0)) /\ ((Mfn >= -10) /\ (Mfn <= 10))) /\ (Mfp = 0)) /\ ((Mgn >= -10) /\ (Mgn <= 10))) /\ (Mgp = 0)) /\ ((Mhn >= -10) /\ (Mhn <= 10))) /\ (Mhp = 0)) /\ ((Min >= -10) /\ (Min <= 10))) /\ (Mip = 0)) /\ (Map in [0, 0] /\ Man in [-10, 10] /\ Mbp in [0, 0] /\ Mbn in [-10, 10] /\ Mcp in [0, 0] /\ Mcn in [-10, 10] /\ Mdp in [0, 0] /\ Mdn in [-10, 10] /\ Mep in [0, 0] /\ Men in [-10, 10] /\ Mfp in [0, 0] /\ Mfn in [-10, 10] /\ Mgp in [0, 0] /\ Mgn in [-10, 10] /\ Mhp in [0, 0] /\ Mhn in [-10, 10] /\ Mip in [0, 0] /\ Min in [-10, 10])
  -> ex0 -/ Mex0 in ? }

