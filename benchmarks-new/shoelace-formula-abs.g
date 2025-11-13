x1 = float<ieee_64,zr>(Mx1);
y1 = float<ieee_64,zr>(My1);
x2 = float<ieee_64,zr>(Mx2);
y2 = float<ieee_64,zr>(My2);
x3 = float<ieee_64,zr>(Mx3);
y3 = float<ieee_64,zr>(My3);

Ms1 = ((Mx1 * My2) - (My1 * Mx2));
Ms2 = ((Mx2 * My3) - (My2 * Mx3));
Ms3 = ((Mx3 * My1) - (My3 * Mx1));
Mex0 = (5e-1 * ((Ms1 + Ms2) + Ms3));

s1 float<ieee_64,zr>= ((x1 * y2) - (y1 * x2));
s2 float<ieee_64,zr>= ((x2 * y3) - (y2 * x3));
s3 float<ieee_64,zr>= ((x3 * y1) - (y3 * x1));
ex0 float<ieee_64,zr>= (float<ieee_64,zr>(5e-1) * ((s1 + s2) + s3));

{ (0 in [0, 0])
  -> |ex0 - Mex0| in ? }