use crate::exprs::Expr::Var;
use crate::exprs::Op;
use crate::exprs::*;
use std::collections::HashMap;
 use std::sync::atomic::AtomicUsize;

pub fn lookup_op(o : Op, eps_c : &AtomicUsize) -> Ty {
    match o {
        Op::Add => Ty::Fun(
            Box::new(Ty::Cart(Box::new(Ty::NumErased), Box::new(Ty::NumErased))), 
            Box::new(Ty::NumErased)
        ),
        Op::Sub => Ty::Fun(
            Box::new(Ty::Cart(Box::new(Ty::NumErased), Box::new(Ty::NumErased))), 
            Box::new(Ty::NumErased)
        ),
        Op::Mul => Ty::Fun(
            Box::new(Ty::Ten(Box::new(Ty::NumErased), Box::new(Ty::NumErased))), 
            Box::new(Ty::NumErased)
        ),
    }
}

pub fn subtype(sub : Ty, sup : Ty) -> bool {
    eprintln!("subtype op: {:?} {:?}", sub, sup);
    sup == sub
}

pub fn infer(c : CtxSkeleton, e : Expr, eps_c : &AtomicUsize) -> (Ctx, Ty) {
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
            let (sens, _) = theta.get(&x).expect("Var not found in env");

            if *ty_i != Ty::Hole {
                eprintln!("Checking if {:?} == {:?}:", tau, *ty_i);
                assert_eq!(tau, *ty_i)
            }

            ((gamma*(*sens)) + theta, ty)
        }
        Expr::Lam(box_x, ty_i, f) => {
            assert!(*ty_i != Ty::Hole);

            let x = match *box_x {
                Var(x) => x,
                _ => todo!(),
            };

            let mut c_ext= c.clone();
            c_ext.insert(x, (*ty_i).clone());

            let (gamma, tau) = infer(c_ext, *f, eps_c);
            (gamma, Ty::Fun(ty_i, Box::new(tau)))
        }
        Expr::App(e, f) => {
            let (gamma, tau_fun) = match *e {
                Expr::Op(o) => (Ctx::new(), lookup_op(o, eps_c)),
                fun => infer(c.clone(), fun, eps_c),
            };
            let (delta, tau_0) = infer(c.clone(), *f, eps_c);

            let tau_1 = match tau_fun {
                Ty::Fun(tau_0_sup, tau_1) => {
                    // make sure contravariant
                    assert!(subtype(tau_0, *tau_0_sup));
                    tau_1
                }
                _ => panic!("{:?} is not a function type!", tau_fun)
            };
            (gamma + delta, *tau_1)
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
            let mut ctx = Ctx::new();
            for (y, ty_l) in c.iter() {
                ctx.insert(y.to_string(), (0.0, ty_l.clone()));
            }
            (ctx, Ty::Unit)
        },
        _ => todo!("{:?}", e),
    }
}
