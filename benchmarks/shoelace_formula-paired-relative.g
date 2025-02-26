x1p = float<ieee_64,ne>(Mx1p);
x1n = float<ieee_64,ne>(Mx1n);
y1p = float<ieee_64,ne>(My1p);
y1n = float<ieee_64,ne>(My1n);
x2p = float<ieee_64,ne>(Mx2p);
x2n = float<ieee_64,ne>(Mx2n);
y2p = float<ieee_64,ne>(My2p);
y2n = float<ieee_64,ne>(My2n);
x3p = float<ieee_64,ne>(Mx3p);
x3n = float<ieee_64,ne>(Mx3n);
y3p = float<ieee_64,ne>(My3p);
y3n = float<ieee_64,ne>(My3n);

Mpos = ((5e-1 * (((((Mx1p * My2p) + (Mx1n * My2n)) + ((My1p * Mx2n) + (My1p * Mx2n))) + (((Mx2p * My3p) + (Mx2n * My3n)) + ((My2p * Mx3n) + (My2p * Mx3n)))) + (((Mx3p * My1p) + (Mx3n * My1n)) + ((My3p * Mx1n) + (My3p * Mx1n))))) + (0 * (((((Mx1p * My2n) + (Mx1p * My2n)) + ((My1p * Mx2p) + (My1n * Mx2n))) + (((Mx2p * My3n) + (Mx2p * My3n)) + ((My2p * Mx3p) + (My2n * Mx3n)))) + (((Mx3p * My1n) + (Mx3p * My1n)) + ((My3p * Mx1p) + (My3n * Mx1n))))));
Mneg = ((5e-1 * (((((Mx1p * My2n) + (Mx1p * My2n)) + ((My1p * Mx2p) + (My1n * Mx2n))) + (((Mx2p * My3n) + (Mx2p * My3n)) + ((My2p * Mx3p) + (My2n * Mx3n)))) + (((Mx3p * My1n) + (Mx3p * My1n)) + ((My3p * Mx1p) + (My3n * Mx1n))))) + (5e-1 * (((((Mx1p * My2n) + (Mx1p * My2n)) + ((My1p * Mx2p) + (My1n * Mx2n))) + (((Mx2p * My3n) + (Mx2p * My3n)) + ((My2p * Mx3p) + (My2n * Mx3n)))) + (((Mx3p * My1n) + (Mx3p * My1n)) + ((My3p * Mx1p) + (My3n * Mx1n))))));
Mex0 = (Mpos - Mneg);

pos float<ieee_64,ne>= ((float<ieee_64,ne>(5e-1) * (((((x1p * y2p) + (x1n * y2n)) + ((y1p * x2n) + (y1p * x2n))) + (((x2p * y3p) + (x2n * y3n)) + ((y2p * x3n) + (y2p * x3n)))) + (((x3p * y1p) + (x3n * y1n)) + ((y3p * x1n) + (y3p * x1n))))) + (float<ieee_64,ne>(0) * (((((x1p * y2n) + (x1p * y2n)) + ((y1p * x2p) + (y1n * x2n))) + (((x2p * y3n) + (x2p * y3n)) + ((y2p * x3p) + (y2n * x3n)))) + (((x3p * y1n) + (x3p * y1n)) + ((y3p * x1p) + (y3n * x1n))))));
neg float<ieee_64,ne>= ((float<ieee_64,ne>(5e-1) * (((((x1p * y2n) + (x1p * y2n)) + ((y1p * x2p) + (y1n * x2n))) + (((x2p * y3n) + (x2p * y3n)) + ((y2p * x3p) + (y2n * x3n)))) + (((x3p * y1n) + (x3p * y1n)) + ((y3p * x1p) + (y3n * x1n))))) + (float<ieee_64,ne>(5e-1) * (((((x1p * y2n) + (x1p * y2n)) + ((y1p * x2p) + (y1n * x2n))) + (((x2p * y3n) + (x2p * y3n)) + ((y2p * x3p) + (y2n * x3n)))) + (((x3p * y1n) + (x3p * y1n)) + ((y3p * x1p) + (y3n * x1n))))));
ex0 float<ieee_64,ne>= (pos - neg);

{ (0 in [0, 0])
  -> ex0 -/ Mex0 in ? }

