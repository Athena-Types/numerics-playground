use crate::exprs::Expr;

/// Note that we only care about stepping / reasoning about closed expressions.
pub fn is_val(e : &Expr) -> bool {
    match e {
        // Non-recursive values
        Expr::Unit => true,
        Expr::Var(_) => true,
        Expr::Num(_) => true,
        Expr::Op(_) => true,
        Expr::Lam(_, _, _) => true,
        Expr::PolyAbs(_, _) => true,

        // Recursive values
        Expr::Cart(e1, e2) => is_val(&*e1) && is_val(&*e2),
        Expr::Tens(e1, e2) => is_val(&*e1) && is_val(&*e2),
        Expr::In(_, e) => is_val(&*e),
        _ => false
    }
}


pub fn fun_sub(e : Expr, x : String, v : Expr) -> Expr {
    todo!()
}

pub fn bnd_sub(e : Expr, x : usize, i : Interval) -> Expr {
    todo!()
}

/// We only step closed, well-typed terms to closed, well-typed terms
pub fn interpret(e : Expr) -> Expr {
    if is_val(&e) {
        return e;
    }

    match e {
        Expr::App(e, f) => {
            let e_stepped = interpret(e);
            match e_stepped {
                Expr::Lam(x, ty, body) => fun_sub(body, x, f),
                _ => todo!("Not able to step! Is your program well-typed?"),
            }
        },
        Expr::PolyInst(e, i) => todo!(),
        Expr::Proj(i, e) => todo!(),
        Expr::Let(x, ty, e, f) => todo!(),
        Expr::LB(x, e, f) => todo!(),
        Expr::LCB(x, e, f) => todo!(),
        Expr::LP(x, y, e, f) => todo!(),
        Expr::Case(x, e1, e2) => todo!(),
        Expr::Rnd(m, e) => todo!(),
        Expr::Ret(e) => todo!(),
        Expr::Scale(s, e) => todo!(),
        Expr::Factor(e) => todo!(),
        _ => todo!()
    }
}
