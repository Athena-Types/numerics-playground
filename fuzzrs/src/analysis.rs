use crate::exprs::Expr::Var;
use std::cell::RefCell;
use std::rc::Rc;
use crate::exprs::Op;
use crate::exprs::*;
use log::debug;

// todo: prevent zeros earlier, more principled way of doig this
pub fn max(f0 : Float, f1 : Float) -> Float {
    if f1 == 0.0 {
        return f0;
    }
    if (f1 > f0) && (! f1.is_nan()) {
        return f1;
    }
    f0
}

pub fn min(f0 : Float, f1 : Float) -> Float {
    if f1 == 0.0 {
        return f0;
    }
    if f1 > f0 && (! f0.is_nan()) {
        return f0;
    }
    f1
}

pub fn a_priori_bound_rel(t : Rc<RefCell<Ty>>) -> Option<Float> {
    match *t.borrow() {
        Ty::Fun(ref t0, ref t1) => a_priori_bound_rel(t1.clone()),
        Ty::Monad(q, ref m_ty) => 
            match *m_ty.borrow() {
                Ty::Num(Interval::Const((r_down, a_down, b_down),(r_up, a_up, b_up))) => {
                    if r_down <= 0.0 {
                        return None;
                    }
                    let e_q = q.exp();
                    let e_neg_q = (-q).exp();

                    let mut b_1_1 = e_neg_q;
                    if a_up != 0.0 {
                        b_1_1 += a_up * (1.0 / r_down) * (e_q - e_neg_q);
                    } 

                    let mut b_1_2 = e_q;
                    if a_down != 0.0 {
                        b_1_2 += a_down * (1.0 / r_up) * (e_neg_q - e_q);
                    }
                    let b_1 = max(b_1_1.ln().abs(), b_1_2.ln().abs());

                    let mut b_2_1 = e_q;
                    if b_up != 0.0 {
                        b_2_1 += b_up * (1.0 / r_down) * (e_q - e_neg_q);
                    }

                    let mut b_2_2 = e_neg_q;
                    if b_down != 0.0 {
                        b_2_2 += b_down * (1.0 / r_up) * (e_neg_q - e_q);
                    }
                    let b_2 = max(b_2_1.ln().abs(), b_2_2.ln().abs());
                    debug!("b_1: {:?} {:?}", b_1_1.ln().abs(), b_1_2.ln().abs());
                    debug!("b_2: {:?} {:?}", b_2_1.ln().abs(), b_2_2.ln().abs());
                    let bnd = min(b_1, b_2);
                    debug!("{:?}", bnd);
                    Some(bnd)
                }
                _ => todo!("Not supported!"),
            }
        _ => todo!("Not supported!"),
    }
}

pub fn a_posteriori_bound_rel(t : Rc<RefCell<Ty>>, r_actual : Float) -> Option<Float> {
    match *t.borrow() {
        Ty::Fun(ref t0, ref t1) => a_posteriori_bound_rel(t1.clone(), r_actual),
        Ty::Monad(q, ref m_ty) => 
            match *m_ty.borrow() {
                Ty::Num(Interval::Const((r_down, a_down, b_down),(r_up, a_up, b_up))) => {
                    let e_q = (q).exp();
                    let e_neg_q = (-q).exp();
                    let e_2q = (2.0*q).exp();
                    let e_neg_2q = (-2.0*q).exp();
                    if 0.0 < r_actual {
                        let b_1_1 = e_neg_q + a_up * (1.0 / r_actual) * (1.0 - e_neg_2q);
                        let b_1_2 = e_neg_q + a_down * (1.0 / r_actual) * (1.0 - e_2q);
                        let b_1 = max(b_1_1.ln().abs(), b_1_2.ln().abs());

                        let b_2_1 = e_q + b_up * (1.0 / r_actual) * (e_2q - 1.0);
                        let b_2_2 = e_q + b_down * (1.0 / r_actual) * (e_neg_2q - 1.0);
                        let b_2 = max(b_2_1.ln().abs(), b_2_2.ln().abs());
                        //eprintln!("b_1: {:?} {:?}", b_1_1.ln().abs(), b_1_2.ln().abs());
                        //eprintln!("b_2: {:?} {:?}", b_2_1.ln().abs(), b_2_2.ln().abs());
                        let bnd = min(b_1, b_2);
                        //eprintln!("{:?}", bnd);
                        return Some(bnd);
                    } else {
                        let b_1_1 = e_neg_q + a_down * (1.0 / r_actual) * (1.0 - e_neg_2q);
                        let b_1_2 = e_neg_q + a_up * (1.0 / r_actual) * (1.0 - e_2q);
                        let b_1 = max(b_1_1.ln().abs(), b_1_2.ln().abs());

                        let b_2_1 = e_q + b_down * (1.0 / r_actual) * (e_2q - 1.0);
                        let b_2_2 = e_q + b_up * (1.0 / r_actual) * (e_neg_2q - 1.0);
                        let b_2 = max(b_2_1.ln().abs(), b_2_2.ln().abs());
                        //eprintln!("b_1: {:?} {:?}", b_1_1.ln().abs(), b_1_2.ln().abs());
                        //eprintln!("b_2: {:?} {:?}", b_2_1.ln().abs(), b_2_2.ln().abs());
                        let bnd = min(b_1, b_2);
                        //eprintln!("{:?}", bnd);
                        return Some(bnd);
                    }
                }
                _ => todo!("Not supported!"),
            }
        _ => todo!("Not supported!"),
    }
}

pub fn a_priori_bound_abs(t : Rc<RefCell<Ty>>) -> Option<Float> {
    match *t.borrow() {
        Ty::Fun(ref t0, ref t1) => a_priori_bound_abs(t1.clone()),
        Ty::Monad(q, ref m_ty) => 
            match *m_ty.borrow() {
                Ty::Num(Interval::Const((r_down, a_down, b_down),(r_up, a_up, b_up))) => {
                    let e_q = (q).exp();
                    let e_neg_q = (-q).exp();
                    let b1 = a_up * (1.0 - e_neg_q) - b_down * (1.0 - e_q);
                    let b2 = a_down * (1.0 - e_neg_q) - b_up * (1.0 - e_q);
                    let b3 = a_up * (e_q - 1.0) - b_down * (e_neg_q - 1.0);
                    let b4 = a_down * (e_q - 1.0) - b_up * (e_neg_q - 1.0);
                    //eprintln!("a priori abs bounds: {:?} {:?} {:?} {:?}", b1, b2, b3, b4);
                    return Some(max(max(b1, b2), max(b3, b4)));
                }
                _ => todo!("Not supported!"),
            }
        _ => todo!("Not supported!"),
    }
}
