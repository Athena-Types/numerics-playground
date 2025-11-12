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

    println!("program: {:?}", prog);
    let mut eps_c = AtomicUsize::new(0);
    let (ctx, ty) = fuzzrs::typer::infer(HashMap::new(), prog.clone(), &eps_c);
    //println!("final ctx: {:?}", ctx);
    println!("final ty: {:#?}", ty);
    let bound_a_priori = fuzzrs::analysis::a_priori_bound(ty.clone());
    println!("final bound (pre): {:#?}", bound_a_priori);
    if let Some(val) = opt.post {
        let bound_a_post = fuzzrs::analysis::a_posteriori_bound(ty.clone(), val);
        println!("final bound (post): {:#?}", bound_a_post);
    }

    // let prog = RawLang::parse(Rule::program, &file);
}
