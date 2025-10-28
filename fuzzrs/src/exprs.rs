use std::collections::HashMap;

#[derive(Debug, Clone, PartialEq)]
pub enum Op {
    Add,
    Mul,
    Sub,
}

pub type Float = f64;

#[derive(Debug, Clone, PartialEq)]
pub enum Interval {
    Eps(String),
    Const((Float, Float), (Float, Float)),
    IOp(Op, Vec<Interval>),
}

#[derive(Debug, Clone, PartialEq)]
pub enum Ty {
    Hole,
    Unit,
    NumErased,
    Num(Interval, Interval),
    Ten(Box<Ty>, Box<Ty>),
    Cart(Box<Ty>, Box<Ty>),
    Sum(Box<Ty>, Box<Ty>),
    Fun(Box<Ty>, Box<Ty>),
    Bang(Float, Box<Ty>),
    Monad(Float, Box<Ty>),
    Forall(String, Box<Ty>),
}

#[derive(Debug, Clone, PartialEq)]
pub enum Expr {
    Unit,
    Var(String),
    Num(Float, Float),
    Op(Op),
    Lam(Box<Expr>, Box<Ty>, Box<Expr>),
    App(Box<Expr>, Box<Expr>),
    PolyAbs(Box<Interval>, Box<Expr>),
    PolyInst(Box<Expr>, Box<Expr>),
    Inst(Box<Expr>, Box<Expr>),
    Proj(usize, Box<Expr>),
    Cart(Box<Expr>, Box<Expr>),
    Tens(Box<Expr>, Box<Expr>),

    // the ty here is optional (will usually be a hole)
    Let(Box<Expr>, Box<Ty>, Box<Expr>, Box<Expr>),
    LB(Box<Expr>, Box<Expr>, Box<Expr>),
    LCB(Box<Expr>, Box<Expr>, Box<Expr>),
    LP(Box<Expr>, Box<Expr>, Box<Expr>, Box<Expr>),
    Case(Box<Expr>, Box<Expr>, Box<Expr>),
    In(usize, Box<Expr>),
    Rnd(Box<Expr>),
    Ret(Box<Expr>),
    Scale(Float, Box<Expr>),
    Factor(Box<Expr>),
}

pub type CtxSkeleton = HashMap<String, (Expr, Ty)>;
pub type Ctx = HashMap<String, (Expr, Ty)>;
// pub struct Ctx {
//     program: Expr,
//     context: HashMap<String, Expr>,
// }
//
// impl Ctx {
//     pub fn new(program: Expr, context: HashMap<String, (Expr, Ty)>) -> Ctx {
//         Ctx {
//             program: program,
//             context: context,
//         }
//     }
// }
