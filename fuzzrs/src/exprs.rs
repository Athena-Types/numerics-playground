pub enum Op {
    Add,
    Mul,
    Sub
}

pub enum Interval {
    Eps(String),
    Const(f64, f64),
    IOp(Op, Vec<Interval>)
}


pub enum Expr {
    Var(String),
    Num(f64, f64),
    Op(Op),
    Lam(Box<Expr>, Box<Expr>),
    App(Box<Expr>, Box<Expr>),
    PolyAbs(Box<Interval>, Box<Expr>),
    PolyInst(Box<Expr>, Box<Expr>),
    Inst(Box<Expr>, Box<Expr>),
    Proj(usize, Box<Expr>),
    Cart(Box<Expr>, Box<Expr>),
    Tens(Box<Expr>, Box<Expr>),

    Let(Box<Expr>, Box<Expr>, Box<Expr>),
    LetBind(Box<Expr>, Box<Expr>, Box<Expr>),
    LetPair(Box<Expr>, Box<Expr>, Box<Expr>, Box<Expr>),
    Case(Box<Expr>, Box<Expr>, Box<Expr>),
    In(usize, Box<Expr>),
    Rnd(Box<Expr>),
    Ret(Box<Expr>),
    Scale(Box<Expr>),
    Factor(Box<Expr>),
}
