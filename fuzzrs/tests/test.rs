use std::collections::HashMap;
use std::fs;

use fuzzrs::{RawLang, Rule};
use pest::Parser;

#[test]
fn test_parse_floats() {
    let unparsed_file = fs::read_to_string("tests/parse/parse.float").expect("cannot read file");

    let mut counter = 0;
    for line in unparsed_file.lines().into_iter() {
        let float = RawLang::parse(Rule::float, &line).expect("unsuccessful parse");
        println!("{:?}", float);
        counter += 1;
    }

    assert_eq!(counter, 9);
}

#[test]
fn test_eps() {
    let eps = RawLang::parse(Rule::eps, "eps64_up").unwrap();
    println!("{:?}", eps);
}

#[test]
fn test_type() {
    let ty = RawLang::parse(Rule::r#type, "M[eps64_up]num").unwrap();
    println!("{:?}", ty);
}

#[test]
fn test_lex_programs() {
    let paths = fs::read_dir("tests/parse/programs").unwrap();

    for path in paths {
        let fname = path.unwrap().path();
        let file = fs::read_to_string(&fname).expect("File not found!");

        let prog = RawLang::parse(Rule::program, &file).expect(fname.to_str().unwrap());
        // println!("{:?}", prog);
    }
}

#[test]
fn test_parse_programs() {
    let paths = fs::read_dir("tests/examples").unwrap();

    let mut counter = 0;
    for path in paths {
        let p = path.as_ref().unwrap().path().clone();
        if let Some(ext) = p.extension() {
            if ext.to_str().unwrap() == "fz" {
                eprintln!("{:?}", p);
                let prog = fuzzrs::parser::parse_file(p);
                eprintln!("{:?}", prog);
                counter += 1;
            }
        }
    }
    assert_eq!(counter, 33);
}

#[test]
fn test_parse_programs_load_into_one_expr() {
    let paths = fs::read_dir("tests/examples").unwrap();

    let mut counter = 0;
    for path in paths {
        let p = path.as_ref().unwrap().path().clone();
        if let Some(ext) = p.extension() {
            if ext.to_str().unwrap() == "fz" {
                eprintln!("{:?}", p);
                let prog = fuzzrs::parser::start(p);
                eprintln!("{:?}", prog);
                counter += 1;
            }
        }
    }
    assert_eq!(counter, 33);
}
