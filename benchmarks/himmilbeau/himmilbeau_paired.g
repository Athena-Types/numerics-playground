@rnd = float<ieee_64, up>;

# (a1p, a1n) = x1 * x1
a1p = (x1p * x1p) + (x1n * x1n);
a1n = (x1p * x1n) + (x1p * x1n);

# (a2p, a2n) = (x1 * x1) + x2
a2p = a1p + x2p;
a2n = a1n + x2n;

# (a3p, a3n) = ((x1 * x1) + x2) - 11
a3p = a2p;
a3n = a2n + 11;

# (b1p, b1n) = x2 * x2
b1p = (x2p * x2p) + (x2n * x2n);
b1n = (x2p * x2n) + (x2p * x2n);

# (b2p, b2n) = x1 + (x2 * x2)
b2p = x1p + b1p;
b2n = x1n + b1n;

# (b3p, b3n) = (x1 + (x2 * x2)) - 7
b3p = b2p;
b3n = b2n + 7;

# (f1p, f1n) = (a * a)
f1p = (a3p * a3p) + (a3n * a3n);
f1n = (a3p * a3n) + (a3p * a3n);

# (f2p, f2n) = (b * b)
f2p = (b3p * b3p) + (b3n * b3n);
f2n = (b3p * b3n) + (b3p * b3n);

# (f3p, f3n) = (a * a) + (b * b)
f3p = f1p + f2p;
f3n = f1n + f2n;

# bounds on first part: f3p in [170, 14250 {14250, 2^(13.7987)}]
# { x1p in [0,5] /\ x1n in [0,5] /\ x2p in [0,5] /\ x2n in [0,5] -> f3p in ? }

# bounds on second part: f3n in [0, 14080 {14080, 2^(13.7814)}]
# { x1p in [0,5] /\ x1n in [0,5] /\ x2p in [0,5] /\ x2n in [0,5] -> f3n in ? }

# tightest expression would be: (f3n / f3p - f3n)

# bound 1 (should be tightest expression)
# { x1p in [0,5] /\ x1n in [0,5] /\ x2p in [0,5] /\ x2n in [0,5] /\ f3p <> f3n) -> (f3n / (f3p - f3n)) in ? }
# { x1p in [0,5] /\ x1n in [0,5] /\ x2p in [0,5] /\ x2n in [0,5] /\ (f3p - f3n) <> 0 -> (f3n / (f3p - f3n)) in ? }

# bound 2
# { x1p in [0,5] /\ x1n in [0,5] /\ x2p in [0,5] /\ x2n in [0,5] -> (f3p / (f3p - f3n)) in ? }

#######################  rounded exprs  #######################

x1pr = x1p;
x1nr = x1n;
x2pr = x2p;
x2nr = x2n;

# (a1p, a1n) rnd= x1 * x1
a1pr rnd= (x1pr * x1pr) + (x1nr * x1nr);
a1nr rnd= (x1pr * x1nr) + (x1pr * x1nr);

# (a2p, a2n) rnd= (x1 * x1) + x2
a2pr rnd= a1pr + x2pr;
a2nr rnd= a1nr + x2nr;

# (a3p, a3n) rnd= ((x1 * x1) + x2) - 11
a3pr = a2pr;
a3nr rnd= a2nr + 11;

# (b1p, b1n) rnd= x2 * x2
b1pr rnd= (x2pr * x2pr) + (x2nr * x2nr);
b1nr rnd= (x2pr * x2nr) + (x2pr * x2nr);

# (b2p, b2n) rnd= x1 + (x2 * x2)
b2pr rnd= x1pr + b1pr;
b2nr rnd= x1nr + b1nr;

# (b3p, b3n) rnd= (x1 + (x2 * x2)) - 7
b3pr = b2pr;
b3nr rnd= b2nr + 7;

# (f1p, f1n) rnd= (a * a)
f1pr rnd= (a3pr * a3pr) + (a3nr * a3nr);
f1nr rnd= (a3pr * a3nr) + (a3pr * a3nr);

# (f2p, f2n) rnd= (b * b)
f2pr rnd= (b3pr * b3pr) + (b3nr * b3nr);
f2nr rnd= (b3pr * b3nr) + (b3pr * b3nr);

# (f3p, f3n) rnd= (a * a) + (b * b)
f3pr rnd= f1pr + f2pr;
f3nr rnd= f1nr + f2nr;

# bounds on first part: f3pr in [170, 14250 {14250, 2^(13.7987)}]
# { x1p in [0,5] /\ x1n in [0,5] /\ x2p in [0,5] /\ x2n in [0,5] -> f3pr in ? }

# bounds on second part: f3nr in [0, 14080 {14080, 2^(13.7814)}]
# { x1p in [0,5] /\ x1n in [0,5] /\ x2p in [0,5] /\ x2n in [0,5] -> f3nr in ? }

# a posterori bound (bound #4):
# delta = 6.66133814775e-16
# ln(e^(-delta) + ((e^delta) - (e^-delta)) * (2^13.7987) / r)
