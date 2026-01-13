use log::{debug, info, warn};
use std::cell::RefCell;
use std::collections::HashMap;
use std::iter::zip;
use std::rc::Rc;
use std::sync::atomic::*;
//use std::cmp::max;
use crate::analysis::max;
use crate::analysis::min;

use crate::exprs::Expr::Var;
use crate::exprs::Op;
use crate::exprs::Op::*;
use crate::exprs::*;
use crate::typer::Interval;
use crate::typer::Interval::*;

use crate::exprs::tmul;

// TODO: add sanity check that bounds maintain the interval invariant

pub fn lookup_op(o: Op, eps_c: &AtomicUsize) -> Ty {
    let e1 = eps_c.fetch_add(1, Ordering::SeqCst);
    let e2 = eps_c.fetch_add(1, Ordering::SeqCst);
    match o {
        Op::Add => Ty::Forall(
            e1,
            Rc::new(RefCell::new(Ty::Forall(
                e2,
                Rc::new(RefCell::new(Ty::Fun(
                    Rc::new(RefCell::new(Ty::Cart(
                        Rc::new(RefCell::new(Ty::Num(Eps(e1)))),
                        Rc::new(RefCell::new(Ty::Num(Eps(e2)))),
                    ))),
                    Rc::new(RefCell::new(Ty::Num(Interval::IOp(Op::Add, vec![
                        Eps(e1),
                        Eps(e2),
                    ])))),
                ))),
            ))),
        ),
        Op::Sub => Ty::Forall(
            e1,
            Rc::new(RefCell::new(Ty::Forall(
                e2,
                Rc::new(RefCell::new(Ty::Fun(
                    Rc::new(RefCell::new(Ty::Cart(
                        Rc::new(RefCell::new(Ty::Num(Eps(e1)))),
                        Rc::new(RefCell::new(Ty::Num(Eps(e2)))),
                    ))),
                    Rc::new(RefCell::new(Ty::Num(Interval::IOp(Op::Sub, vec![
                        Eps(e1),
                        Eps(e2),
                    ])))),
                ))),
            ))),
        ),
        Op::Mul => Ty::Forall(
            e1,
            Rc::new(RefCell::new(Ty::Forall(
                e2,
                Rc::new(RefCell::new(Ty::Fun(
                    Rc::new(RefCell::new(Ty::Tens(
                        Rc::new(RefCell::new(Ty::Num(Eps(e1)))),
                        Rc::new(RefCell::new(Ty::Num(Eps(e2)))),
                    ))),
                    Rc::new(RefCell::new(Ty::Num(Interval::IOp(Op::Mul, vec![
                        Eps(e1),
                        Eps(e2),
                    ])))),
                ))),
            ))),
        ),
    }
}

pub fn subtype(sub: Rc<RefCell<Ty>>, sup: Rc<RefCell<Ty>>) -> bool {
    debug!("subtype op: {:?} {:?}", sub, sup);
    *sup.borrow() == *sub.borrow()
}

pub fn zero_ctx(c: &CtxSkeleton) -> Ctx {
    let mut ctx = Ctx::new();
    for (y, ty_l) in c.iter() {
        ctx.insert(y.clone(), (0.0, ty_l.clone()));
    }
    ctx
}

type Sub = HashMap<usize, Interval>;

pub fn make_subs(v: Vec<Interval>, i: Vec<Interval>) -> Sub {
    let mut map: HashMap<usize, Interval> = HashMap::new();
    let mut map = HashMap::new();
    for (eps, interval) in zip(v, i) {
        match eps {
            Eps(e) => {
                map.insert(e, interval);
            }
            _ => todo!("not expected!"),
        }
    }
    map
}

pub fn sub_eps(i: Interval, s: &Sub) -> Interval {
    debug!("sub {:?} with interval {:?}", s, i);
    match i {
        Eps(v) => match s.get(&v) {
            Some(new_v) => new_v.clone(),
            None => i,
        },
        Const(_, _, _) => i,
        IOp(o, intvs) => {
            step_interval_incremental(IOp(o, intvs.into_iter().map(|x| sub_eps(x, s)).collect()))
        }
    }
}

pub fn sub_ty<'a>(t: &Rc<RefCell<Ty>>, s: &Sub) -> Rc<RefCell<Ty>> {
    let res = match *t.borrow() {
        Ty::Unit => Ty::Unit,
        Ty::NumErased => panic!("Should not see an erased type!"),
        //Ty::Num(interval) => Ty::Num(step_interval(sub_eps(interval.clone(), s)),
        Ty::Num(ref interval) => Ty::Num(sub_eps(interval.clone(), s)),
        Ty::Tens(ref t0, ref t1) => {
            let t0n = sub_ty(&t0, s);
            let t1n = sub_ty(&t1, s);
            Ty::Tens(t0n, t1n)
        }
        Ty::Cart(ref t0, ref t1) => {
            let t0n = sub_ty(&t0, s);
            let t1n = sub_ty(&t1, s);
            Ty::Cart(t0n, t1n)
        }
        Ty::Sum(ref t0, ref t1) => {
            let t0n = sub_ty(&t0, s);
            let t1n = sub_ty(&t1, s);
            Ty::Sum(t0n, t1n)
        }
        Ty::Fun(ref t0, ref t1) => {
            let t0n = sub_ty(&t0, s);
            let t1n = sub_ty(&t1, s);
            Ty::Fun(t0n, t1n)
        }
        Ty::Bang(sens, ref t) => {
            let tn = sub_ty(&t, s);
            Ty::Bang(sens, tn)
        }
        Ty::Monad(g, ref t) => {
            let tn = sub_ty(&t, s);
            Ty::Monad(g, tn)
        }
        Ty::Forall(eps, ref t) => {
            let mut cap_avoiding = s.clone();
            cap_avoiding.remove(&eps);
            let tn = sub_ty(&t, &cap_avoiding);
            Ty::Forall(eps, tn)
            //panic!("Should not see forall here!")
        }
        Ty::Hole => panic!("Should not see hole here!"),
    };
    Rc::new(RefCell::new(res))
}

pub fn step_interval_incremental(i: Interval) -> Interval {
    debug!("stepping {:?}", i);
    let res = match i {
        IOp(Add, v) => {
            let larg = &v[0];
            let rarg = &v[1];
            match (larg, rarg) {
                (
                    Const((r_l, a_l, b_l), (r_h, a_h, b_h), deg_l),
                    Const((r_l_a, a_l_a, b_l_a), (r_h_a, a_h_a, b_h_a), deg_r),
                ) =>{ 
                    let completely_same_sign = (0.0 <= *r_l && 0.0 <= *r_l_a) || (*r_h <= 0.0 && *r_h_a <= 0.0);
                    Const(
                        (r_l + r_l_a, a_l + a_l_a, b_l + b_l_a),
                        (r_h + r_h_a, a_h + a_h_a, b_h + b_h_a),
                        *deg_l && *deg_r && completely_same_sign
                    )
                }
                _ => IOp(Op::Add, v),
            }
        }
        IOp(Sub, v) => {
            let larg = &v[0];
            let rarg = &v[1];
            match (larg, rarg) {
                (
                    Const((r_l, a_l, b_l), (r_h, a_h, b_h), deg_l),
                    Const((r_l_a, a_l_a, b_l_a), (r_h_a, a_h_a, b_h_a), deg_r),
                ) => {
                    // do the stupid thing instead of casing
                    let r_min = min(min(r_l - r_h_a, r_h - r_h_a), min(r_l - r_l_a, r_h - r_l_a));
                    let r_max = max(max(r_l - r_h_a, r_h - r_h_a), max(r_l - r_l_a, r_h - r_l_a));

                    // this is a crude overapproximation; could be improved
                    let completely_different_sign = (0.0 <= *r_l && 0.0 <= *r_h_a) || (*r_h <= 0.0 && 0.0 <= *r_l_a);

                    Const(
                        (r_min, a_l + b_l_a, b_l + a_l_a),
                        (r_max, a_h + b_h_a, b_h + a_h_a),
                        *deg_l && *deg_r && (completely_different_sign)
                    )
                }
                _ => IOp(Op::Sub, v),
            }
        }
        IOp(Mul, v) => {
            let larg = &v[0];
            let rarg = &v[1];
            match (larg, rarg) {
                (
                    Const((r_l, a_l, b_l), (r_h, a_h, b_h), deg_l),
                    Const((r_l_a, a_l_a, b_l_a), (r_h_a, a_h_a, b_h_a), deg_r),
                ) => {
                    // do the stupid thing instead of casing
                    let r_min = min(min(r_l * r_h_a, r_h * r_h_a), min(r_l * r_l_a, r_h * r_l_a));
                    let r_max = max(max(r_l * r_h_a, r_h * r_h_a), max(r_l * r_l_a, r_h * r_l_a));

                    // if either component is degenerate, we can take the max (because the other
                    // will be zero)
                    if (*deg_l || *deg_r) {
                        Const(
                            (
                                r_min,
                                min((tmul(a_l, a_l_a)), (tmul(b_l, b_l_a))),
                                min((tmul(a_l, b_l_a)), (tmul(b_l, a_l_a))),
                            ),
                            (
                                r_max,
                                max((tmul(a_h, a_h_a)), (tmul(b_h, b_h_a))),
                                max((tmul(a_h, b_h_a)), (tmul(b_h, a_h_a))),
                            ),
                            *deg_l && *deg_r
                        )
                    } else {
                        Const(
                            (
                                r_min,
                                (tmul(a_l, a_l_a)) + (tmul(b_l, b_l_a)),
                                (tmul(a_l, b_l_a)) + (tmul(b_l, a_l_a)),
                            ),
                            (
                                r_max,
                                (tmul(a_h, a_h_a)) + (tmul(b_h, b_h_a)),
                                (tmul(a_h, b_h_a)) + (tmul(b_h, a_h_a)),
                            ),
                            *deg_l && *deg_r
                        )
                    }
                }
                _ => IOp(Op::Mul, v),
            }
        }
        Const(cl, ch, deg) => Const(cl, ch, deg),
        Eps(x) => Eps(x),
    };
    debug!("step to {:?}", res);
    res
}

pub fn inst<'a>(
    t: Rc<RefCell<Ty>>,
    v: &'a mut Vec<usize>,
    eps_c: &AtomicUsize,
) -> (Rc<RefCell<Ty>>, &'a mut Vec<usize>) {
    match *t.borrow() {
        Ty::Unit => (Rc::new(RefCell::new(Ty::Unit)), v),
        Ty::NumErased => {
            let eps = eps_c.fetch_add(1, Ordering::SeqCst);
            v.push(eps);
            ((Rc::new(RefCell::new(Ty::Num(Interval::Eps(eps))))), v)
        }
        Ty::Tens(ref t0, ref t1) => {
            let (t0n, v) = inst(t0.clone(), v, eps_c);
            let (t1n, v) = inst(t1.clone(), v, eps_c);
            ((Rc::new(RefCell::new(Ty::Tens(t0n, t1n)))), v)
        }
        Ty::Cart(ref t0, ref t1) => {
            let (t0n, v) = inst(t0.clone(), v, eps_c);
            let (t1n, v) = inst(t1.clone(), v, eps_c);
            ((Rc::new(RefCell::new(Ty::Cart(t0n, t1n)))), v)
        }
        Ty::Sum(ref t0, ref t1) => {
            let (t0n, v) = inst(t0.clone(), v, eps_c);
            let (t1n, v) = inst(t1.clone(), v, eps_c);
            ((Rc::new(RefCell::new(Ty::Sum(t0n, t1n)))), v)
        }
        Ty::Fun(ref t0, ref t1) => {
            let (t0n, v) = inst(t0.clone(), v, eps_c);
            let (t1n, v) = inst(t1.clone(), v, eps_c);
            ((Rc::new(RefCell::new(Ty::Fun(t0n, t1n)))), v)
        }
        Ty::Bang(s, ref t) => {
            let (tn, v) = inst(t.clone(), v, eps_c);
            ((Rc::new(RefCell::new(Ty::Bang(s, tn)))), v)
        }
        Ty::Monad(g, ref t) => {
            let (tn, v) = inst(t.clone(), v, eps_c);
            ((Rc::new(RefCell::new(Ty::Monad(g, tn)))), v)
        }
        Ty::Forall(eps, ref t) => panic!("Not supposed to be encountering foralls!"),
        _ => panic!("Unhandled case!"),
    }
}

pub fn strip_foralls<'a>(
    t: Rc<RefCell<Ty>>,
    v: &'a mut Vec<usize>,
) -> (&'a mut Vec<usize>, Rc<RefCell<Ty>>) {
    match *t.borrow() {
        Ty::Forall(eps, ref ty) => {
            v.push(eps);
            let (a, b) = strip_foralls(ty.clone(), v);
            return (a, b);
        }
        _ => (v, t.clone()), // memory leak here?
    }
}

pub fn elim(t: Rc<RefCell<Ty>>, mut v: Vec<Interval>) -> Vec<Interval> {
    debug!("elim {:?} in vector {:?}", t, v);
    match *t.borrow() {
        Ty::Unit => v,
        Ty::NumErased => panic!("We should not see erased terms!"),
        Ty::Num(ref i) => {
            v.push(i.clone());
            v
        }
        Ty::Tens(ref t0, ref t1) => {
            v = elim(t0.clone(), v);
            v = elim(t1.clone(), v);
            v
        }
        Ty::Cart(ref t0, ref t1) => {
            v = elim(t0.clone(), v);
            v = elim(t1.clone(), v);
            v
        }
        Ty::Sum(ref t0, ref t1) => {
            v = elim(t0.clone(), v);
            v = elim(t1.clone(), v);
            v
        }
        Ty::Fun(ref t0, ref t1) => {
            v = elim(t0.clone(), v);
            v = elim(t1.clone(), v);
            v
        }
        Ty::Bang(_, ref t) => elim(t.clone(), v),
        Ty::Monad(_, ref t) => elim(t.clone(), v),
        Ty::Forall(eps, ref t) => panic!("Not supposed to be encountering foralls!"),
        _ => panic!("Unhandled case!"),
    }
}

// todo: make c.clone() not shared -- is this needed to enforce env senstivity?
pub fn infer(c: &CtxSkeleton, e: Expr, eps_c: &AtomicUsize) -> (Ctx, Rc<RefCell<Ty>>) {
    match e {
        Expr::Var(x) => {
            let mut ty = Rc::new(RefCell::new(Ty::Hole));
            let mut ctx = Ctx::new();
            for (y, ty_l) in c.iter() {
                if x == *y {
                    ctx.insert(y.clone(), (1.0, ty_l.clone()));
                    drop(ty);
                    ty = ty_l.clone();
                } else {
                    ctx.insert(y.clone(), (0.0, ty_l.clone()));
                }
            }
            assert!(
                *ty.borrow() != Ty::Hole,
                "{:?} has no type in ctx {:?}!",
                x,
                c
            );
            (ctx, ty)
        }
        Expr::Let(box_x, ty_i, e, f) => {
            debug!("expr {:?} in ctx {:?}", e, c);
            let (mut gamma, tau) = infer(&c, *e, eps_c);
            let x = match *box_x {
                Var(x) => x,
                _ => todo!(),
            };

            let mut new_c = c.clone();
            new_c.insert(x.clone(), tau);
            let (mut theta, ty) = infer(&new_c, *f, eps_c);
            let (sens, _) = theta.get(&x).expect("Var not found in env");

            if *ty_i.borrow() != Ty::Hole {
                //debug!("Checking if {:?} == {:?}:\n  {:?}", tau, *ty_i, e_debug);
                // TODO: generalize + assert that these are alpha-equiv
                //assert_eq!(tau, *ty_i)
            }

            gamma *= *sens;
            gamma += theta;
            (gamma, ty)
        }
        Expr::LCB(box_x, e, f) => {
            debug!("expr {:?} in ctx {:?}", e, c);
            let (mut gamma, mtau_0) = infer(&c, *e, eps_c);
            let x = match *box_x {
                Var(x) => x,
                _ => todo!(),
            };
            let (s, tau_0) = match *mtau_0.borrow() {
                Ty::Bang(s, ref tau_0) => (s, tau_0.clone()),
                _ => panic!("Expected a bang type!"),
            };

            let mut new_c = c.clone();
            new_c.insert(x.clone(), tau_0.clone());
            let (mut theta, tau) = infer(&new_c, *f, eps_c);

            let (ts, _) = theta.get(&x).expect("Var not found in env").clone();
            let t = ts / s;

            gamma *= t;
            gamma += theta;
            (gamma, tau)
        }
        Expr::LB(box_x, e, f) => {
            //debug!("expr {:?} in ctx {:?}", e, c);
            let (mut gamma, mtau_0) = infer(&c, *e, eps_c);
            let x = match *box_x {
                Var(x) => x,
                _ => todo!(),
            };
            let (r, tau_0) = match *mtau_0.borrow() {
                Ty::Monad(r, ref tau_0) => (r, tau_0.clone()),
                _ => panic!("Expected a monad type!"),
            };

            let mut new_c = c.clone();
            new_c.insert(x.clone(), tau_0.clone());
            let (mut theta, mtau) = infer(&new_c, *f, eps_c);
            let (q, tau) = match *mtau.borrow() {
                Ty::Monad(q, ref tau) => (q, tau.clone()),
                _ => panic!("Expected a monad type!"),
            };

            let (s, _) = theta.get(&x).expect("Var not found in env").clone();
            gamma *= s;
            gamma += theta;
            (
                gamma,
                Rc::new(RefCell::new(Ty::Monad(s * r + q, tau.clone()))),
            )
        }
        Expr::Lam(box_x, ty_i, f) => {
            //debug!("{:?}", f);
            assert!(*ty_i.borrow() != Ty::Hole);

            let x = match *box_x {
                Var(x) => x,
                _ => todo!(),
            };

            let mut eps_v = Vec::new();
            let (ty_with_eps, eps_v) = inst(ty_i, &mut eps_v, eps_c);

            let mut c_ext = c.clone();
            c_ext.insert(x.clone(), ty_with_eps.clone());

            let (mut gamma, mut tau) = infer(&c_ext, *f, eps_c);
            gamma.remove(&x).unwrap();

            tau = Rc::new(RefCell::new(Ty::Fun(ty_with_eps, tau)));

            for e in eps_v {
                tau = Rc::new(RefCell::new(Ty::Forall(*e, tau)));
            }

            //debug!("Inferred ctx (lam): {:?} \n Ty: {:?}", gamma, tau);
            (gamma, tau)
        }
        Expr::App(e, f) => {
            let (mut gamma, mut tau_fun) = match *e {
                Expr::Op(o) => (Ctx::new(), Rc::new(RefCell::new(lookup_op(o, eps_c)))),
                fun => infer(&c, fun, eps_c),
            };
            let (delta, tau_0) = infer(&c, *f, eps_c);

            // gather subs
            let mut forall_v = Vec::new();
            let (_, tau_fun_stripped) = strip_foralls(tau_fun.clone(), &mut forall_v);

            //debug!("e {:?} with type {:?}", e, tau_fun_stripped);
            //debug!("f {:?} with type {:?}", f, tau_0);
            let tau_1 = match *tau_fun_stripped.borrow() {
                Ty::Fun(ref tau_0_sup, ref tau_1) => {
                    // find subs
                    let mut intervals = Vec::new();
                    intervals = elim(tau_0.clone(), intervals);
                    let mut eps_v = Vec::new();
                    eps_v = elim(tau_0_sup.clone(), eps_v);
                    debug!("tau_0_sup {:?}", tau_0_sup);
                    debug!("eps_v {:?}", eps_v);
                    debug!("tau_0 {:?}", tau_0);
                    debug!("intervals {:?}", intervals);
                    let subs = make_subs(eps_v, intervals);
                    // perform subs
                    let tau_0_sup_sub = sub_ty(&tau_0_sup, &subs);
                    let tau_1_sub = sub_ty(&tau_1, &subs);
                    // make sure contravariant
                    assert!(
                        subtype(tau_0.clone(), tau_0_sup_sub.clone()),
                        "{:?} is not subtype of {:?}",
                        tau_0,
                        tau_0_sup_sub
                    );
                    tau_1_sub
                    //step_ty(tau_1_sub)
                }
                _ => panic!("{:?} is not a function type!", tau_fun),
            };
            gamma += delta;
            debug!(
                "Inferred ctx (app): {:?} \n Ty: {:?}",
                gamma,
                tau_1.clone()
            );
            (gamma, tau_1)
        }
        Expr::Op(o) => todo!("should be handled by the app case!"),
        Expr::Rnd(m, e) => {
            let (gamma, tau) = infer(&c, *e, eps_c);
            let g = match m {
                16 => 0.0009765625,
                32 => 1.192092895507812e-7,
                64 => 2.220446049250313e-16,
                _ => todo!("rounding not implemented for this"),
            };
            (gamma, Rc::new(RefCell::new(Ty::Monad(g, tau))))
        }
        Expr::Ret(e) => {
            let (gamma, tau) = infer(&c, *e, eps_c);
            (gamma, Rc::new(RefCell::new(Ty::Monad(0.0, tau))))
        }
        Expr::Unit => {
            let mut ctx = zero_ctx(&c);
            (ctx, Rc::new(RefCell::new(Ty::Unit)))
        }
        Expr::Tens(e1, e2) => {
            let (mut gamma_0, tau_0) = infer(&c, *e1, eps_c);
            let (gamma_1, tau_1) = infer(&c, *e2, eps_c);
            gamma_0 += gamma_1;
            (
                gamma_0,
                Rc::new(RefCell::new(Ty::Tens(tau_0, tau_1))),
            )
        }
        Expr::Cart(e1, e2) => {
            let (mut gamma_0, tau_0) = infer(&c, *e1, eps_c);
            let (gamma_1, tau_1) = infer(&c, *e2, eps_c);
            gamma_0 |= gamma_1;
            (
                gamma_0,
                Rc::new(RefCell::new(Ty::Cart(tau_0, tau_1))),
            )
        }
        Expr::Num(n) => {
            let mut ctx = zero_ctx(&c);
            if n >= 0.0 {
                (
                    ctx,
                    Rc::new(RefCell::new(Ty::Num(Interval::Const(
                        (n, n, 0.0),
                        (n, n, 0.0),
                        true
                    )))),
                )
            } else {
                (
                    ctx,
                    Rc::new(RefCell::new(Ty::Num(Interval::Const(
                        (n, 0.0, -n),
                        (n, 0.0, -n),
                        true
                    )))),
                )
            }
        }
        Expr::PolyInst(e, i) => {
            debug!("polyinst {:?}", e);
            let (gamma, tau) = infer(&c, *e, eps_c);
            debug!("tau {:?}", tau);
            //(gamma, step_ty(rec_poly(tau, *i)))
            (gamma, rec_poly(tau, *i))
        }
        Expr::Factor(e) => {
            let (gamma, tau) = infer(&c, *e, eps_c);
            debug!("factor ty: {:?}", tau);
            match *tau.borrow() {
                Ty::Cart(ref m0, ref m1) => match (m0.borrow().clone(), m1.borrow().clone()) {
                    (Ty::Monad(g0, t0), Ty::Monad(g1, t1)) => {
                        let mut max_g = g0;
                        if g1 > g0 {
                            max_g = g1;
                        }
                        (
                            gamma,
                            Rc::new(RefCell::new(Ty::Monad(
                                max_g,
                                Rc::new(RefCell::new(Ty::Cart(t0, t1))),
                            ))),
                        )
                    }
                    _ => panic!("Bad type passed to factor!"),
                },
                _ => panic!("Bad type passed to factor!"),
            }
        }
        Expr::Scale(s, e) => {
            let (mut gamma, tau) = infer(&c, *e, eps_c);
            gamma *= s;
            (gamma, Rc::new(RefCell::new(Ty::Bang(s, tau))))
        }
        Expr::LP(box_x, box_y, e, f) => {
            // TODO: really shouldn't be c .clone()
            let x = match *box_x {
                Var(x) => x,
                _ => todo!(),
            };
            let y = match *box_y {
                Var(y) => y,
                _ => todo!(),
            };
            let (mut gamma, paired_ty) = infer(&c, *e, eps_c);
            match *paired_ty.borrow() {
                Ty::Tens(ref tau_0, ref tau_1) => {
                    let mut new_c = c.clone();
                    new_c.insert(x.clone(), tau_0.clone());
                    new_c.insert(y.clone(), tau_1.clone());
                    let (mut theta, tau_fin) = infer(&new_c, *f, eps_c);
                    let (s0, _) = theta.get(&x).expect("Var not found in env").clone();
                    let (s1, _) = theta.get(&y).expect("Var not found in env").clone();
                    gamma *= max(s0, s1);
                    gamma += theta;
                    (gamma, tau_fin)
                }
                _ => panic!("Bad type passed to let-pair!"),
            }
        }
        _ => todo!("{:?}", e),
    }
}

pub fn rec_poly(tau: Rc<RefCell<Ty>>, i: Interval) -> Rc<RefCell<Ty>> {
    match *tau.borrow() {
        Ty::Forall(eps, ref ty) => {
            let mut sub = HashMap::new();
            sub.insert(eps, i);
            sub_ty(&ty, &sub)
        }
        Ty::Fun(ref t0, ref t1) => {
            Rc::new(RefCell::new(Ty::Fun(t0.clone(), rec_poly(t1.clone(), i))))
        }
        _ => panic!("Can't instantiate when there is no forall!"),
    }
}
