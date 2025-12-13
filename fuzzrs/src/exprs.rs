use std::cell::RefCell;
use std::collections::HashMap;
use std::ops;
use std::rc::Rc;

#[derive(Debug, Clone, PartialEq, Copy)]
pub enum Op {
    Add,
    Mul,
    Sub,
}

pub type Float = f64;

/// Trapped multiplication.
pub fn tmul(a: &Float, b: &Float) -> Float {
    if *a == 0.0 || *b == 0.0 {
        return 0.0;
    }
    return a * b;
}

#[derive(Debug, Clone, PartialEq)]
pub enum Interval {
    Eps(usize),
    Const((Float, Float, Float), (Float, Float, Float), bool),
    IOp(Op, Vec<Interval>),
}

#[derive(Debug, Clone, PartialEq)]
pub enum Ty {
    Hole,
    Unit,
    NumErased,
    Num(Interval),
    Tens(Rc<RefCell<Ty>>, Rc<RefCell<Ty>>),
    Cart(Rc<RefCell<Ty>>, Rc<RefCell<Ty>>),
    Sum(Rc<RefCell<Ty>>, Rc<RefCell<Ty>>),
    Fun(Rc<RefCell<Ty>>, Rc<RefCell<Ty>>),
    Bang(Float, Rc<RefCell<Ty>>),
    Monad(Float, Rc<RefCell<Ty>>),
    Forall(usize, Rc<RefCell<Ty>>),
}

//impl PartialEq for Ty {
//    fn eq(&self, other: &Self) -> bool {
//        eprintln!("{:?} =? {:?}", self, other);
//        match (self, other) {
//            (Ty::Hole, Ty::Hole) => true,
//            (Ty::Unit, Ty::Unit) => true,
//            (Ty::NumErased, Ty::NumErased) => true,
//            (Ty::Num(i0), Ty::Num(i1)) => i0==i1,
//            (Ty::Tens(t0l, t0r), Ty::Tens(t1l, t1r)) =>
//                (*t0l == *t1l) && (*t0r == *t1r),
//            (Ty::Cart(t0l, t0r), Ty::Cart(t1l, t1r)) =>
//                (*t0l == *t1l) && (*t0r == *t1r),
//            (Ty::Sum(t0l, t0r), Ty::Sum(t1l, t1r)) =>
//                (*t0l == *t1l) && (*t0r == *t1r),
//            (Ty::Fun(t0l, t0r), Ty::Fun(t1l, t1r)) =>
//                (*t0l == *t1l) && (*t0r == *t1r),
//            (Ty::Bang(s0, t0), Ty::Bang(s1, t1)) =>
//                (s0 == s1) && (*t0==*t1),
//            (Ty::Monad(g0, t0), Ty::Monad(g1, t1)) =>
//                (g0 == g1) && (*t0==*t1),
//            (Ty::Forall(eps_0, t0), Ty::Forall(eps_1, t1)) =>
//                (eps_0 == eps_1) && (*t0==*t1),
//            _ => false,
//        }
//    }
//}

#[derive(Debug, Clone, PartialEq)]
pub enum Expr {
    // ExpHole,
    Unit,
    Var(Rc<str>),
    Num(Float),
    Op(Op),
    Lam(Box<Expr>, Rc<RefCell<Ty>>, Box<Expr>),
    App(Box<Expr>, Box<Expr>),
    PolyAbs(usize, Box<Expr>),
    PolyInst(Box<Expr>, Box<Interval>),
    //Inst(Box<Expr>, Box<Expr>),
    Proj(usize, Box<Expr>),
    Cart(Box<Expr>, Box<Expr>),
    Tens(Box<Expr>, Box<Expr>),

    // the ty here is optional (will usually be a hole)
    Let(Box<Expr>, Rc<RefCell<Ty>>, Box<Expr>, Box<Expr>),
    LB(Box<Expr>, Box<Expr>, Box<Expr>),
    LCB(Box<Expr>, Box<Expr>, Box<Expr>),
    LP(Box<Expr>, Box<Expr>, Box<Expr>, Box<Expr>),
    Case(Box<Expr>, Box<Expr>, Box<Expr>),
    In(usize, Box<Expr>),
    Rnd(usize, Box<Expr>),
    Ret(Box<Expr>),
    Scale(Float, Box<Expr>),
    Factor(Box<Expr>),
}

pub type CtxSkeleton = HashMap<Rc<str>, Rc<RefCell<Ty>>>;

//pub type Ctx = HashMap<String, (Float, Ty)>;

#[derive(Debug, Clone, PartialEq)]
pub struct Ctx {
    lookup: HashMap<Rc<str>, (Float, Rc<RefCell<Ty>>)>,
}

impl Ctx {
    pub fn insert(
        &mut self,
        k: Rc<str>,
        v: (Float, Rc<RefCell<Ty>>),
    ) -> Option<(Float, Rc<RefCell<Ty>>)> {
        self.lookup.insert(k, v)
    }
    pub fn get(&mut self, k: &Rc<str>) -> Option<&(Float, Rc<RefCell<Ty>>)> {
        self.lookup.get(k)
    }
    pub fn remove(&mut self, k: &Rc<str>) -> Option<(Float, Rc<RefCell<Ty>>)> {
        self.lookup.remove(k)
    }
    pub fn new() -> Ctx {
        Ctx {
            lookup: HashMap::new(),
        }
    }
}

//impl ops::Mul<Float> for Ctx {
//    type Output = Ctx;
//
//    fn mul(self, s: Float) -> Ctx {
//        Ctx {
//            lookup: self
//                .lookup
//                .iter()
//                .map(|(x, (sen, ty))| (x.clone(), (s * sen, ty.clone())))
//                .collect(),
//        }
//    }
//}

//impl ops::Add<Ctx> for Ctx {
//    type Output = Ctx;
//
//    fn add(self, c: Ctx) -> Ctx {
//        let mut new_ctx = c.clone().lookup;
//        for (x, (sens, ty)) in self.lookup {
//            if let Some((o_sens, o_ty)) = new_ctx.get(&x) {
//                new_ctx.insert(x.to_string(), (o_sens + sens, ty));
//            } else {
//                new_ctx.insert(x.to_string(), (sens, ty));
//            }
//        }
//        Ctx { lookup: new_ctx }
//    }
//}

//impl ops::BitOr<Ctx> for Ctx {
//    type Output = Ctx;
//
//    fn bitor(self, c: Ctx) -> Ctx {
//        let mut new_ctx = c.clone().lookup;
//        for (x, (sens, ty)) in self.lookup {
//            if let Some((o_sens, o_ty)) = new_ctx.get(&x) {
//                new_ctx.insert(x.to_string(), (o_sens.max(sens), ty));
//            } else {
//                new_ctx.insert(x.to_string(), (sens, ty));
//            }
//        }
//        Ctx { lookup: new_ctx }
//    }
//}

impl ops::MulAssign<Float> for Ctx {
    fn mul_assign(&mut self, rhs: Float) {
        for (s, ty) in self.lookup.values_mut() {
            *s *= rhs;
        }
    }
}

impl ops::AddAssign<Ctx> for Ctx {
    fn add_assign(&mut self, c: Ctx) {
        for (x, (s_right, ty)) in c.lookup {
            match self.lookup.get_mut(&x) {
                Some((s_left, ty)) => *s_left += s_right,
                None => {self.insert(x, (s_right, ty));}
            }
        }
    }
}
impl ops::BitOrAssign<Ctx> for Ctx {
    fn bitor_assign(&mut self, c: Ctx) {
        for (x, (s_right, ty)) in c.lookup {
            match self.lookup.get_mut(&x) {
                Some((s_left, ty)) => *s_left = s_left.max(s_right),
                None => {self.insert(x, (s_right, ty));}
            }
        }
    }
}
