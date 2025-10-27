use pest::Parser;

use std::collections::HashMap;
use std::fs;

use fuzzrs::{RawLang, Rule};

#[test]
fn test_parse_floats() {
    let unparsed_file = fs::read_to_string("tests/parse/parse.float").expect("cannot read file");

    let mut counter = 0;
    for line in unparsed_file.lines().into_iter() {
        let float = RawLang::parse(Rule::float, &line).expect("unsuccessful parse");
        println!("{:?}", float);
        counter += 1;
    }

    assert_eq!(counter, 8);
}

#[test]
fn test_parse_programs() {
    let paths = fs::read_dir("tests/parse/programs").unwrap();

    for path in paths {
        let file = fs::read_to_string(path.unwrap().path()).expect("File not found!");

        let prog = RawLang::parse(Rule::program, &file).unwrap();
        println!("{:?}", prog);
    }
}
