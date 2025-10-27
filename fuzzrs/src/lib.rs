// use pest::Parser;
use pest_derive::Parser;

#[derive(Parser)]
#[grammar = "lang.pest"]
pub struct RawLang;
