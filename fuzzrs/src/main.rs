use std::fs;
use std::path::PathBuf;
use structopt::StructOpt;
use std::collections::HashMap;
use std::sync::atomic::AtomicUsize;

use fuzzrs::parser::*;
use fuzzrs::exprs::Float;
use fuzzrs::{RawLang, Rule};
use pest::Parser;

#[derive(StructOpt, Debug)]
#[structopt(name = "fuzzrs")]
struct Opt {
    #[structopt(short, long)]
    post: Option<Float>,

    //#[structopt(short, long, parse(from_occurrences))]
    //verbose: u8,

    /// Output file
    #[structopt(short, long, parse(from_os_str))]
    input: PathBuf,
}

fn main() {
    let opt = Opt::from_args();

    let prog = fuzzrs::parser::start(opt.input);

    //println!("program: {:?}", prog);
    let mut eps_c = AtomicUsize::new(0);
    let (ctx, ty) = fuzzrs::typer::infer(HashMap::new(), prog.clone(), &eps_c);
    //println!("final ctx: {:?}", ctx);
    //println!("final ty: {:#?}", ty);
    let bound_a_priori_rel = fuzzrs::analysis::a_priori_bound_rel(ty.clone());
    println!("final bound (pre, rel): {:?}", bound_a_priori_rel);
    let bound_a_priori_abs = fuzzrs::analysis::a_priori_bound_abs(ty.clone());
    println!("final bound (pre, abs): {:?}", bound_a_priori_abs.unwrap());
    if let Some(val) = opt.post {
        let bound_a_post_rel = fuzzrs::analysis::a_posteriori_bound_rel(ty.clone(), val);
        println!("final bound (post, rel): {:?}", bound_a_post_rel.unwrap());
    }

    // let prog = RawLang::parse(Rule::program, &file);
}
