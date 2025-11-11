use std::fs;
use std::path::PathBuf;
use structopt::StructOpt;
use std::collections::HashMap;
use std::sync::atomic::AtomicUsize;

use fuzzrs::parser::*;
use fuzzrs::{RawLang, Rule};
use pest::Parser;

#[derive(StructOpt, Debug)]
#[structopt(name = "fuzzrs")]
struct Opt {
    #[structopt(short, long)]
    debug: bool,

    #[structopt(short, long, parse(from_occurrences))]
    verbose: u8,

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
    let bound_a_priori = fuzzrs::analysis::a_priori_bound(ty.clone());
    let bound_a_post = fuzzrs::analysis::a_posteriori_bound(ty.clone(), 1000.0);
    //println!("final ctx: {:?}", ctx);
    println!("final ty: {:#?}", ty);
    println!("final bound (pre): {:#?}", bound_a_priori);
    println!("final bound (post): {:#?}", bound_a_post);

    // let prog = RawLang::parse(Rule::program, &file);
}
