use pest::Parser;
// use pest::ParseResult;
// use pest::error::Error;
use crate::exprs::Expr::*;
use crate::exprs::*;
use crate::{RawLang, Rule};
use pest::iterators::{Pair, Pairs};
use std::collections::HashMap;
use std::fs;
use std::path::PathBuf;
use std::vec;

pub fn parse_file(filename: PathBuf) -> (HashMap<String, (Expr, Ty)>, Expr) {
    let file = fs::read_to_string(&filename)
        .expect(&format!("File not found at {:?}!", filename).to_string());
    let pairs = RawLang::parse(Rule::program, &file).unwrap();
    parse_program(pairs, &filename)
}

pub fn parse_program(input: Pairs<'_, Rule>, loc: &PathBuf) -> (HashMap<String, (Expr, Ty)>, Expr) {
    let mut decl_pairs: HashMap<String, (Expr, Ty)> = HashMap::new();
    let mut body = Expr::Unit;

    for pair in input {
        for inner_pair in pair.into_inner() {
            for decl in inner_pair.clone().into_inner() {
                match decl.as_rule() {
                    Rule::include => {
                        let decls = parse_include(decl.clone(), &loc);
                        decl_pairs.extend(decls);
                    }
                    Rule::function => {
                        let (fname, e, ty) = parse_function(decl.clone());
                        decl_pairs.insert(fname, (e, ty));
                    }
                    Rule::name => {
                        body = parse_name(decl);
                    }
                    _ => unimplemented!("{:?}", inner_pair.clone()),
                }
            }
        }
    }

    (decl_pairs, body)
}

pub fn parse_include(input: Pair<'_, Rule>, loc: &PathBuf) -> HashMap<String, (Expr, Ty)> {
    let import = input.into_inner().next().unwrap();
    let mut new_loc = loc.parent().unwrap().to_path_buf().clone();
    let filename = import.as_span().as_str();
    new_loc.push(filename);

    // eprintln!("{:?}", new_loc);
    let (decls, body) = parse_file(new_loc.to_path_buf());
    decls
}

pub fn parse_eps(input: Pair<'_, Rule>) -> Float {
    match input.as_str() {
        "eps64_up" => 2.220446049250313e-16,
        "eps32_up" => 1.1920928955078125e-07,
        "eps16_up" => 0.0009765625,
        _ => input.as_str().to_string().parse::<Float>().unwrap(),
    }
}

pub fn parse_iop(input: Pair<'_, Rule>) -> Ty {
    unimplemented!("iop parse {:?}", input);
}

pub fn parse_ty(input: Pair<'_, Rule>) -> Ty {
    let mut inner_ty = input.into_inner().next().unwrap();
    if (inner_ty.as_rule() == Rule::r#type) || (inner_ty.as_rule() == Rule::atom_ty) {
        inner_ty = inner_ty.into_inner().next().unwrap();
    }
 
    // eprintln!("parse ty: {:?}", inner_ty);

    match inner_ty.as_rule() {
        Rule::unit => Ty::Unit,
        Rule::num => match inner_ty.into_inner().next() {
            Some(iop) => parse_iop(iop),
            None => Ty::NumErased,
        },
        Rule::tensor => {
            let mut components = inner_ty.into_inner();
            let l = Box::new(parse_ty(components.next().unwrap()));
            let r = Box::new(parse_ty(components.next().unwrap()));
            Ty::Ten(l, r)
        }
        Rule::cartesian => {
            let mut components = inner_ty.into_inner();
            let l = Box::new(parse_ty(components.next().unwrap()));
            let r = Box::new(parse_ty(components.next().unwrap()));
            Ty::Cart(l, r)
        }
        Rule::monad => {
            let mut components = inner_ty.into_inner();
            let grade = parse_eps(components.next().unwrap());
            let ty = Box::new(parse_ty(components.next().unwrap()));
            Ty::Monad(grade, ty)
        }
        Rule::bang => {
            let mut components = inner_ty.into_inner();
            let scale = parse_eps(components.next().expect("Scale not working!"));
            let ty = Box::new(parse_ty(components.next().unwrap()));
            Ty::Bang(scale, ty)
        }
        Rule::fun => {
            let mut components = inner_ty.into_inner();
            let ty1 = Box::new(parse_ty(components.next().unwrap()));
            let ty2 = Box::new(parse_ty(components.next().unwrap()));
            Ty::Fun(ty1, ty2)
        }
        _ => unimplemented!("parse ty rule matching {:?}", inner_ty),
    }
}

pub fn parse_arg(input: Pair<'_, Rule>) -> (String, Ty) {
    eprintln!("{:#?}", input);
    eprintln!("{:#?}", input.as_span());
    // unwrap if arg
    let mut components = input.clone().into_inner();
    // if (input.as_rule() == Rule::arg) {
    //     components = components.next().unwrap().into_inner();
    // }
    let name = components.next().unwrap().as_str();
    let ty = parse_ty(components.next().unwrap());
    (name.to_string(), ty)
}

pub fn parse_function(input: Pair<'_, Rule>) -> (String, Expr, Ty) {
    let mut innards = input.into_inner();
    let fname = match innards.next() {
        Some(name) => name.as_str(),
        _ => panic!("No name for function found!"),
    };

    let mut args: Vec<(String, Ty)> = innards
        .next()
        .expect("Args have no types!")
        .into_inner()
        .map(|x| parse_arg(x))
        .collect();
    // eprintln!("function type inputs: {:?}", args);

    let mut return_ty = Ty::Hole;
    if innards.len() == 2 {
        return_ty = parse_ty(innards.next().unwrap());
    }
    let body = parse_expr(innards.next().unwrap().into_inner().next().unwrap());

    let mut fun = body;
    if args.len() >= 1 {
        args.reverse();
        for (var, typ) in &args {
            fun = Expr::Lam(
                Box::new(Var(var.to_string())),
                Box::new(typ.clone()),
                Box::new(fun),
            );
        }
    }

    (fname.to_string(), fun, return_ty)
}

pub fn parse_expr(input: Pair<'_, Rule>) -> Expr {
    let mut inner_expr = input.clone();

    // unwrap if expr
    if (input.as_rule() == Rule::expr) || (input.as_rule() == Rule::atom) {
        inner_expr = inner_expr.into_inner().next().unwrap();
    }

    // eprintln!("parsed {:?}", inner_expr);
    let expr = match inner_expr.as_rule() {
        Rule::letassign => {
            let mut components = inner_expr.into_inner();
            let v = Box::new(parse_expr(components.next().unwrap()));
            let e = Box::new(parse_expr(components.next().unwrap()));
            let f = Box::new(parse_expr(components.next().unwrap()));
            Expr::Let(v, e, f)
        }
        Rule::lcb => {
            let mut components = inner_expr.into_inner();
            let v = Box::new(parse_expr(components.next().unwrap()));
            let e = Box::new(parse_expr(components.next().unwrap()));
            let f = Box::new(parse_expr(components.next().unwrap()));
            Expr::LCB(v, e, f)
        }
        Rule::lb => {
            let mut components = inner_expr.into_inner();
            let v = Box::new(parse_expr(components.next().unwrap()));
            let e = Box::new(parse_expr(components.next().unwrap()));
            let f = Box::new(parse_expr(components.next().unwrap()));
            Expr::LB(v, e, f)
        }
        Rule::lp => {
            let mut components = inner_expr.into_inner();
            let v1 = Box::new(parse_expr(components.next().unwrap()));
            let v2 = Box::new(parse_expr(components.next().unwrap()));
            let e = Box::new(parse_expr(components.next().unwrap()));
            let f = Box::new(parse_expr(components.next().unwrap()));
            Expr::LP(v1, v2, e, f)
        }
        Rule::name => parse_name(input),
        Rule::app => {
            let mut components = inner_expr.into_inner();
            let e1 = Box::new(parse_atom(components.next().unwrap()));
            let e2 = Box::new(parse_expr(components.next().unwrap()));
            Expr::App(e1, e2)
        }
        Rule::atom => parse_atom(input.into_inner().next().unwrap()),
        Rule::var => parse_name(input.into_inner().next().unwrap()),
        Rule::tens => {
            let mut components = inner_expr.into_inner();
            let e1 = Box::new(parse_atom(components.next().unwrap()));
            let e2 = Box::new(parse_expr(components.next().unwrap()));
            Expr::Tens(e1, e2)
        }
        Rule::cart => {
            let mut components = inner_expr.into_inner();
            let e1 = Box::new(parse_atom(components.next().unwrap()));
            let e2 = Box::new(parse_expr(components.next().unwrap()));
            Expr::Cart(e1, e2)
        }
        Rule::float => parse_float(input),
        Rule::scale => {
            let mut components = inner_expr.into_inner();
            let e = Box::new(parse_atom(components.next().unwrap()));
            let scale_factor = parse_eps(components.next().unwrap());
            Expr::Scale(scale_factor, e)
        }
        Rule::abs => {
            let mut innards = inner_expr.into_inner();
            let mut args: Vec<(String, Ty)> = innards
                .next()
                .expect("Args have no types!")
                .into_inner()
                .map(|x| parse_arg(x))
                .collect();

            let mut return_ty = Ty::Hole;
            if innards.len() == 2 {
                return_ty = parse_ty(innards.next().unwrap());
            }
            let body = parse_expr(innards.next().unwrap().into_inner().next().unwrap());

            let mut fun = body;
            if args.len() >= 1 {
                args.reverse();
                for (var, typ) in &args {
                    fun = Expr::Lam(
                        Box::new(Var(var.to_string())),
                        Box::new(typ.clone()),
                        Box::new(fun),
                    );
                }
            }
            fun
        }
        _ => todo!("unimplemented rule for {:?}", inner_expr),
    };
    expr
}

pub fn parse_float(input: Pair<'_, Rule>) -> Expr {
    let num = input.as_str().to_string().parse::<Float>().unwrap();
    if num >= 0.0 {
        return Expr::Num(0.0, num);
    } else {
        return Expr::Num(-num, 0.0);
    }
}

pub fn parse_atom(input: Pair<'_, Rule>) -> Expr {
    match input.as_rule() {
        Rule::var => parse_name(input.into_inner().next().unwrap()),
        Rule::float => todo!(),
        _ => parse_expr(input.into_inner().next().unwrap()),
        // _ => todo!(),
    }
}

pub fn parse_name(input: Pair<'_, Rule>) -> Expr {
    // eprintln!("parse name {:?}", input);
    Expr::Var(input.as_str().to_string())
}
