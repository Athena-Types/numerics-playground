open Fpcore
open Base
open List
open String
open Int

let cli =
  let open Option.Let_syntax in
  let%bind filename = List.nth (Array.to_list (Sys.get_argv ())) 1 in
  let unparsed_prog = load_fpcore filename in
  parse_fpcore unparsed_prog

let () = 
  match cli with
  | Some prog ->
    print_endline "Raw internal representation:";
    print_endline (Sexp.to_string_hum (sexp_of_fpcore prog));
    print_endline "Pretty external representation:";
    print_endline (print_fpcore prog);
  | None -> print_endline "Parse bad";
