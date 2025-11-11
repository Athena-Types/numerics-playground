use crate::exprs::Expr::Var;
use crate::exprs::Op;
use crate::exprs::*;

pub fn max(f0 : Float, f1 : Float) -> Float {
    if (f1 > f0) || (f0.is_nan()) {
        return f1;
    }
    f0
}

pub fn min(f0 : Float, f1 : Float) -> Float {
    if f1 > f0 || (! f1.is_nan()) {
        return f0;
    }
    f1
}

pub fn a_priori_bound(t : Ty) -> Float {
    match t {
        Ty::Fun(t0, t1) => a_priori_bound(*t1),
        Ty::Monad(q, m_ty) => 
            match *m_ty {
                Ty::Num(Interval::Const((rl, al, bl),(rh, ah, bh))) => {
                    let e_u = q.exp();
                    let e_neg_u = (-q).exp();

                    let b_1_1 = e_u + ah * (1.0 / rl) * (e_neg_u - e_u);
                    let b_1_2 = e_neg_u + al * (1.0 / rh) * (e_u - e_neg_u);
                    let b_1 = max(b_1_1.ln().abs(), b_1_2.ln().abs());

                    let b_2_1 = e_u + bh * (1.0 / rl) * (e_u - e_neg_u);
                    let b_2_2 = e_u + bl * (1.0 / rh) * (e_neg_u - e_u);
                    let b_2 = max(b_2_1.ln().abs(), b_2_2.ln().abs());
                    eprintln!("b_1: {:?} {:?}", b_1_1.ln().abs(), b_1_2.ln().abs());
                    eprintln!("b_2: {:?} {:?}", b_2_1.ln().abs(), b_2_2.ln().abs());
                    let bnd = min(b_1, b_2);
                    eprintln!("{:?}", bnd);
                    bnd
                }
                _ => todo!("Not supported!"),
            }
        _ => todo!("Not supported!"),
    }
}

pub fn a_posteriori_bound(t : Ty, r_actual : Float) -> Float {
    match t {
        Ty::Fun(t0, t1) => a_posteriori_bound(*t1, r_actual),
        Ty::Monad(q, m_ty) => 
            match *m_ty {
                Ty::Num(Interval::Const((_rl, al, bl),(_rh, ah, bh))) => {
                    let e_u = q.exp();
                    let e_neg_u = (-q).exp();

                    let b_1_1 = e_u + ah * (1.0 / r_actual) * (e_neg_u - e_u);
                    let b_1_2 = e_neg_u + al * (1.0 / r_actual) * (e_u - e_neg_u);
                    let b_1 = max(b_1_1.ln().abs(), b_1_2.ln().abs());

                    let b_2_1 = e_u + bh * (1.0 / r_actual) * (e_u - e_neg_u);
                    let b_2_2 = e_u + bl * (1.0 / r_actual) * (e_neg_u - e_u);
                    let b_2 = max(b_2_1.ln().abs(), b_2_2.ln().abs());
                    min(b_1, b_2)
                }
                _ => todo!("Not supported!"),
            }
        _ => todo!("Not supported!"),
    }
}
