use std::collections::HashMap;
use std::sync::atomic::*;
use std::iter::zip;

use crate::exprs::Expr::Var;
use crate::exprs::Op;
use crate::exprs::*;
use crate::typer::Interval::*;
use crate::typer::Interval;

pub fn lookup_op(o : Op, eps_c : &AtomicUsize) -> Ty {
    let e1 = eps_c.fetch_add(1, Ordering::SeqCst);
    let e2 = eps_c.fetch_add(1, Ordering::SeqCst);
    match o {
        Op::Add => Ty::Forall(e1, Box::new(Ty::Forall(e2, Box::new(Ty::Fun(
            Box::new(Ty::Cart(
                    Box::new(Ty::Num(Eps(e1))), 
                    Box::new(Ty::Num(Eps(e2)))
                    )), 
            Box::new(
                Ty::Num(Interval::IOp(Op::Add, vec![Eps(e1), Eps(e2)]))
            )
        ))))),
        Op::Sub => Ty::Forall(e1, Box::new(Ty::Forall(e2, Box::new(Ty::Fun(
            Box::new(Ty::Cart(
                    Box::new(Ty::Num(Eps(e1))), 
                    Box::new(Ty::Num(Eps(e2)))
                    )), 
            Box::new(
                Ty::Num(Interval::IOp(Op::Sub, vec![Eps(e1), Eps(e2)]))
            )
        ))))),
        Op::Mul => Ty::Forall(e1, Box::new(Ty::Forall(e2, Box::new(Ty::Fun(
            Box::new(Ty::Tens(
                    Box::new(Ty::Num(Eps(e1))), 
                    Box::new(Ty::Num(Eps(e2)))
                    )), 
            Box::new(
                Ty::Num(Interval::IOp(Op::Mul, vec![Eps(e1), Eps(e2)]))
            )
        ))))),
    }
}

pub fn subtype(sub : Ty, sup : Ty) -> bool {
    eprintln!("subtype op: {:?} {:?}", sub, sup);
    sup == sub
}

pub fn zero_ctx(c : CtxSkeleton) -> Ctx {
    let mut ctx = Ctx::new();
    for (y, ty_l) in c.iter() {
        ctx.insert(y.to_string(), (0.0, ty_l.clone()));
    }
    ctx
}

type Sub = HashMap<usize, Interval>;

pub fn make_subs(v : Vec<Interval>, i : Vec<Interval>) -> Sub {
    let mut map: HashMap<usize, Interval> = HashMap::new();
    let mut map = HashMap::new();
    for (eps, interval) in zip(v, i) {
        match eps {
            Eps(e) => {
                map.insert(e, interval);
            },
            _ => todo!("not expected!")
        }
    }
    map
}

pub fn sub_eps(i : Interval, s : &Sub) -> Interval {
    eprintln!("sub {:?} with interval {:?}", s, i);
    match i {
        Eps(v) => match s.get(&v) {
            Some(new_v) => new_v.clone(),
            None => i
        },
        Const(_, _) => i,
        IOp(o, intvs) => 
            IOp(o, intvs.into_iter().map(|x| sub_eps(x, s)).collect()),
    }
}

pub fn sub_ty(t : Ty, s : &Sub) -> Ty {
    match t {
        Ty::Unit => t,
        Ty::NumErased => panic!("Should not see an erased type!"),
        Ty::Num(interval) => Ty::Num(sub_eps(interval, s)),
        Ty::Tens(t0, t1) => {
            let t0n = sub_ty(*t0, s);
            let t1n = sub_ty(*t1, s);
            Ty::Tens(Box::new(t0n), Box::new(t1n))
        },
        Ty::Cart(t0, t1) => {
            let t0n = sub_ty(*t0, s);
            let t1n = sub_ty(*t1, s);
            Ty::Cart(Box::new(t0n), Box::new(t1n))
        },
        Ty::Sum(t0, t1) => {
            let t0n = sub_ty(*t0, s);
            let t1n = sub_ty(*t1, s);
            Ty::Sum(Box::new(t0n), Box::new(t1n))
        },
        Ty::Fun(t0, t1) => {
            let t0n = sub_ty(*t0, s);
            let t1n = sub_ty(*t1, s);
            Ty::Fun(Box::new(t0n), Box::new(t1n))
        },
        Ty::Bang(sens, t) => {
            let tn = sub_ty(*t, s);
            Ty::Bang(sens, Box::new(tn))
        },
        Ty::Monad(g, t) => {
            let tn = sub_ty(*t, s);
            Ty::Monad(g, Box::new(tn))
        },
        Ty::Forall(eps, t) => {
            let mut cap_avoiding = s.clone();
            cap_avoiding.remove(&eps);
            let tn = sub_ty(*t, &cap_avoiding);
            Ty::Forall(eps, Box::new(tn))
            //panic!("Should not see forall here!")
        },
        Ty::Hole => panic!("Should not see hole here!"),
    }
}

pub fn step_ty(t : Ty) -> Ty {
    t
}

pub fn inst<'a>(t : Ty, v : &'a mut Vec<usize>, eps_c : &AtomicUsize) -> (Ty, &'a mut Vec<usize>) {
    match t {
        Ty::Unit => (t, v),
        Ty::NumErased => {
            let eps = eps_c.fetch_add(1, Ordering::SeqCst);
            v.push(eps);
            (Ty::Num(Interval::Eps(eps)), v)
        },
        Ty::Tens(t0, t1) => {
            let (t0n, v) = inst(*t0, v, eps_c);
            let (t1n, v) = inst(*t1, v, eps_c);
            (Ty::Tens(Box::new(t0n), Box::new(t1n)), v)
        }
        Ty::Cart(t0, t1) => {
            let (t0n, v) = inst(*t0, v, eps_c);
            let (t1n, v) = inst(*t1, v, eps_c);
            (Ty::Cart(Box::new(t0n), Box::new(t1n)), v)
        }
        Ty::Sum(t0, t1) => {
            let (t0n, v) = inst(*t0, v, eps_c);
            let (t1n, v) = inst(*t1, v, eps_c);
            (Ty::Sum(Box::new(t0n), Box::new(t1n)), v)
        }
        Ty::Fun(t0, t1) => {
            let (t0n, v) = inst(*t0, v, eps_c);
            let (t1n, v) = inst(*t1, v, eps_c);
            (Ty::Fun(Box::new(t0n), Box::new(t1n)), v)
        }
        Ty::Bang(s, t) => {
            let (tn, v) = inst(*t, v, eps_c);
            (Ty::Bang(s, Box::new(tn)), v)
        }
        Ty::Monad(g, t) => {
            let (tn, v) = inst(*t, v, eps_c);
            (Ty::Monad(g, Box::new(tn)), v)
        }
        Ty::Forall(eps, t) => panic!("Not supposed to be encountering foralls!"),
        _ => panic!("Unhandled case!")
    }
}

pub fn strip_foralls<'a>(t : Ty, v : &'a mut Vec<usize>) -> (&'a mut Vec<usize>, Ty) {
    match t {
        Ty::Forall(eps, t) => {
            v.push(eps);
            strip_foralls(*t, v)
        }
        _ => (v, t)
    }
}

pub fn elim<'a>(t : Ty, v : &'a mut Vec<Interval>) -> &'a mut Vec<Interval> {
    eprintln!("elim {:?} in vector {:?}", t, v);
    match t {
        Ty::Unit => v,
        Ty::NumErased => panic!("We should not see erased terms!"),
        Ty::Num(i) => {
            v.push(i);
            v
        } 
        Ty::Tens(t0, t1) => {
            elim(*t0, v);
            elim(*t1, v);
            v
        }
        Ty::Cart(t0, t1) => {
            elim(*t0, v);
            elim(*t1, v);
            v
        }
        Ty::Sum(t0, t1) => {
            elim(*t0, v);
            elim(*t1, v);
            v
        }
        Ty::Fun(t0, t1) => {
            elim(*t0, v);
            elim(*t1, v);
            v
        }
        Ty::Bang(_, t) => {
            elim(*t, v);
            v
        }
        Ty::Monad(_, t) => {
            elim(*t, v);
            v
        }
        Ty::Forall(eps, t) => panic!("Not supposed to be encountering foralls!"),
        _ => panic!("Unhandled case!")
    }
}

pub fn infer(c : CtxSkeleton, e : Expr, eps_c : &AtomicUsize) -> (Ctx, Ty) {
    let e_debug = e.clone();
    match e {
        Expr::Var(x) => {
            let mut ty = Ty::Hole;
            let mut ctx = Ctx::new();
            for (y, ty_l) in c.iter() {
                if x == *y {
                    ctx.insert(y.to_string(), (1.0, ty_l.clone()));
                    ty = ty_l.clone();
                } else {
                    ctx.insert(y.to_string(), (0.0, ty_l.clone()));
                }
            }
            assert!(ty != Ty::Hole, "{:?} has no type in ctx {:?}!", x, c);
            (ctx, ty)
        }
        Expr::Let(box_x, ty_i, e, f) => {
            let (gamma, tau) = infer(c.clone(), *e, eps_c);
            let x = match *box_x {
                Var(x) => x,
                _ => todo!(),
            };

            let mut new_c = c.clone();
            new_c.insert(x.clone(), tau.clone());
            let (mut theta, ty) = infer(new_c, *f, eps_c);
            let (sens, _) = theta.remove(&x).expect("Var not found in env");

            if *ty_i != Ty::Hole {
                eprintln!("Checking if {:?} == {:?}:\n  {:?}", tau, *ty_i, e_debug);
                // TODO: generalize + assert that these are alpha-equiv
                //assert_eq!(tau, *ty_i)
            }

            ((gamma*(sens)) + theta, ty)
        }
        Expr::LCB(box_x, e, f) => {
            eprintln!("expr {:?} in ctx {:?}", e, c);
            let (gamma, mtau_0) = infer(c.clone(), *e, eps_c);
            let x = match *box_x {
                Var(x) => x,
                _ => todo!(),
            };
            let (s, tau_0) = match mtau_0 {
                Ty::Bang(s, tau_0) => (s, *tau_0),
                _ => panic!("Expected a bang type!")
            };

            let mut new_c = c.clone();
            new_c.insert(x.clone(), tau_0);
            let (mut theta, tau) = infer(new_c, *f, eps_c);

            let (ts, _) = theta.remove(&x).expect("Var not found in env").clone();
            let t = ts / s;
            ((gamma*t) + theta, tau)
        }
        Expr::LB(box_x, e, f) => {
            eprintln!("expr {:?} in ctx {:?}", e, c);
            let (gamma, mtau_0) = infer(c.clone(), *e, eps_c);
            let x = match *box_x {
                Var(x) => x,
                _ => todo!(),
            };
            let (r, tau_0) = match mtau_0 {
                Ty::Monad(r, tau_0) => (r, *tau_0),
                _ => panic!("Expected a monad type!")
            };

            let mut new_c = c.clone();
            new_c.insert(x.clone(), tau_0);
            let (mut theta, mtau) = infer(new_c, *f, eps_c);
            let (q, tau) = match mtau {
                Ty::Monad(q, tau) => (q, tau),
                _ => panic!("Expected a monad type!")
            };

            let (s, _) = theta.remove(&x).expect("Var not found in env").clone();
            ((gamma*s) + theta, Ty::Monad(s*r + q, Box::new(*tau)))
        }
        Expr::Lam(box_x, ty_i, f) => {
            eprintln!("{:?}", f);
            assert!(*ty_i != Ty::Hole);

            let x = match *box_x {
                Var(x) => x,
                _ => todo!(),
            };

            let mut eps_v = Vec::new();
            let (ty_with_eps, eps_v) = inst(*ty_i.clone(), &mut eps_v, eps_c);

            let mut c_ext= c.clone();
            c_ext.insert(x.clone(), ty_with_eps.clone());

            let (mut gamma, mut tau) = infer(c_ext, *f, eps_c);
            gamma.remove(&x).unwrap();

            tau = Ty::Fun(Box::new(ty_with_eps), Box::new(tau));

            for e in eps_v {
                tau = Ty::Forall(*e, Box::new(tau));
            }

            eprintln!("Inferred ctx (lam): {:?} \n Ty: {:?}", gamma, tau);
            (gamma, tau)
        }
        Expr::App(e, f) => {
            let (gamma, tau_fun) = match *e.clone() {
                Expr::Op(o) => (Ctx::new(), lookup_op(o, eps_c)),
                fun => infer(c.clone(), fun, eps_c),
            };
            let (delta, mut tau_0) = infer(c.clone(), *f.clone(), eps_c);

            // gather subs
            let mut forall_v = Vec::new();
            let (_, tau_fun_stripped) = strip_foralls(tau_fun.clone(), &mut forall_v);


            let tau_1 = match tau_fun_stripped {
                Ty::Fun(tau_0_sup, tau_1) => {
                    // find subs
                    let mut intervals = Vec::new();
                    intervals = elim(tau_0.clone(), &mut intervals).to_vec();
                    let mut eps_v = Vec::new();
                    eps_v = elim(*tau_0_sup.clone(), &mut eps_v).to_vec();
                    eprintln!("e {:?}", e);
                    eprintln!("f {:?}", f);
                    eprintln!("tau_0_sup {:?}", tau_0_sup);
                    eprintln!("eps_v {:?}", eps_v);
                    eprintln!("tau_0 {:?}", tau_0);
                    eprintln!("intervals {:?}", intervals);
                    let subs = make_subs(eps_v.to_vec(), intervals);
                    // perform subs
                    let tau_0_sup_sub = sub_ty(*tau_0_sup, &subs);
                    let tau_1_sub = sub_ty(*tau_1, &subs);
                    // make sure contravariant
                    assert!(
                        subtype(tau_0.clone(), tau_0_sup_sub.clone()), 
                        "{:?} is not subtype of {:?}", 
                        tau_0, 
                        tau_0_sup_sub
                    );
                    step_ty(tau_1_sub)
                }
                _ => panic!("{:?} is not a function type!", tau_fun)
            };
            eprintln!("Inferred ctx (app): {:?} \n Ty: {:?}", gamma.clone() + delta.clone(), tau_1.clone());
            (gamma + delta, tau_1)
        }
        Expr::Op(o) => todo!("should be handled by the app case!"),
        Expr::Rnd(m, e) => {
            let (gamma, tau) = infer(c.clone(), *e, eps_c);
            let g = match m {
                16 => 0.0009765625,
                32 => 1.192092895507812e-7,
                64 => 2.220446049250313e-16,
                _ => todo!("rounding not implemented for this")
            };
            (gamma, Ty::Monad(g, Box::new(tau)))
        },
        Expr::Unit => {
            let mut ctx = zero_ctx(c);
            (ctx, Ty::Unit)
        },
        Expr::Tens(e1, e2) => {
            let (gamma_0, tau_0) = infer(c.clone(), *e1, eps_c);
            let (gamma_1, tau_1) = infer(c.clone(), *e2, eps_c);
            (gamma_0 + gamma_1, Ty::Tens(Box::new(tau_0), Box::new(tau_1)))
        },
        Expr::Cart(e1, e2) => {
            let (gamma_0, tau_0) = infer(c.clone(), *e1, eps_c);
            let (gamma_1, tau_1) = infer(c.clone(), *e2, eps_c);
            (gamma_0 | gamma_1, Ty::Cart(Box::new(tau_0), Box::new(tau_1)))
        },
        Expr::Num(n) => {
            let mut ctx = zero_ctx(c);
            if n >= 0.0 {
                (ctx, Ty::Num(Interval::Const((n, n, 0.0), (n, n, 0.0))))
            } else {
                (ctx, Ty::Num(Interval::Const((n, 0.0, -n), (n, 0.0,-n))))
            }
        }
        Expr::PolyInst(e, i) => {
            let (gamma, tau) = infer(c.clone(), *e.clone(), eps_c);
            eprintln!("polyinst {:?}", e.clone());
            eprintln!("tau {:?}", tau);
            (gamma, rec_poly(tau, *i))
            //match tau {
            //    Ty::Forall(eps, ty) => {
            //        let mut sub = HashMap::new();
            //        sub.insert(eps, *i);
            //        (gamma, sub_ty(*ty, &sub))
            //    },
            //    _ => panic!("Can't instantiate when there is no forall!"),
            //}
        }
        _ => todo!("{:?}", e),
    }
}

pub fn rec_poly(tau: Ty, i : Interval) -> Ty {
    match tau {
        Ty::Forall(eps, ty) => {
            let mut sub = HashMap::new();
            sub.insert(eps, i);
            sub_ty(*ty, &sub)
        },
        Ty::Fun(t0, t1) => 
            Ty::Fun(t0, Box::new(rec_poly(*t1, i))),
        _ => panic!("Can't instantiate when there is no forall!"),
    }
}
