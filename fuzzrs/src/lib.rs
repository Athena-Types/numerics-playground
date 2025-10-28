// use pest::Parser;
use pest_derive::Parser;

#[derive(Parser)]
#[grammar = "lang.pest"]
pub struct RawLang;

pub mod exprs;
pub mod parser;
pub mod typer;
