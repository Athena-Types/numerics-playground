use std::fs;
use std::path::PathBuf;
use structopt::StructOpt;

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
    // let successful_include_parse_0 = RawLang::parse(Rule::include, "#include \"test_test/test.fz\"");
    // let successful_include_parse_1 = RawLang::parse(Rule::include, "#include \"test.fz\";");
    // let successful_include_parse_2 = RawLang::parse(Rule::include, "#include \"./test.fz\";");
    // let successful_include_parse_3 = RawLang::parse(
    //     Rule::function,
    //     "function i4 (x': ![0.5]num) (y: num) { 3.2 }",
    // );
    // let successful_include_parse_4 = RawLang::parse(Rule::body, "{ 3.2 }");
    //
    // // let successful_include_parse_3 = RawLang::parse(Rule::function, "function i4 (x': ![0.5]num) (y: num) {let-bind x = }");
    // println!("{:?}", successful_include_parse_0);
    // println!("{:?}", successful_include_parse_1);
    // println!("{:?}", successful_include_parse_2);
    // println!("{:?}", successful_include_parse_3);
    // println!("{:?}", successful_include_parse_4);
    // let successful_parse = RawLang::parse(Rule::float, "-273.15");
    // println!("{:?}", successful_parse);

    let opt = Opt::from_args();

    let prog = fuzzrs::parser::parse_file(opt.input);

    // let prog = RawLang::parse(Rule::program, &file);
    println!("{:?}", prog);
}
