open Fpcore
open Base
open List
open String
open Int

type bound = 
  | Inclusive : float -> bound (* e.g. [0, 1] *)
  | Exclusive : float -> bound (* e.g. (0, 1) *)

type interval = bound * bound

let constraint_to_interval cond : string * interval = 
  match cond with
  | Data [SymData "<="; NumData lb; SymData var; NumData ub] ->
      (var, (Inclusive (number_to_float lb), Inclusive (number_to_float ub)))
  | Data [SymData "<"; NumData lb; SymData var; NumData ub] -> 
      (var, (Exclusive (number_to_float lb), Exclusive (number_to_float ub)))
  | Data [SymData ">="; NumData ub; SymData var; NumData lb] ->
      (var, (Inclusive (number_to_float lb), Inclusive (number_to_float ub)))
  | Data [SymData ">"; NumData ub; SymData var; NumData lb] ->
      (var, (Exclusive (number_to_float lb), Exclusive (number_to_float ub)))

let parse_constraints constrs =
  match constrs with
  | Data (SymData "and" :: conds) -> List.map conds constraint_to_interval
  | _ -> failwith "not supported"

let rec parse_properties props = 
  match props with 
  | hd_prop :: tl_props -> (
    match hd_prop with
    | ":pre", data -> Map.of_alist_exn(module String) (parse_constraints data)
    | _ -> parse_properties tl_props
    )
  | [] -> Map.empty(module String)


let eval_arith operation intervals = 
  match op with
  | Plus -> 
    let%bind x = List.nth args 0 in
    let%bind y = List.nth args 1 in
  | Minus ->
    let%bind x = List.nth args 0 in
    let%bind y = List.nth args 1 in
  | Times ->
    let%bind x = List.nth args 0 in
    let%bind y = List.nth args 1 in
  | Divide ->
    let%bind x = List.nth args 0 in
    let%bind y = List.nth args 1 in
  | Fabs ->
    let%bind x = List.nth args 0 


let interpret_expr prog env intervals = 
  let open Option.Let_syntax in
  match prog with
  | Num n -> Some (number_to_float n)
  | Const c -> Map.find env c
  | Sym s -> Map.find env s
  | Op (op, args) ->
      let ev_args = List.map (fun x => interpret_expr x env intervals) args in
      eval_arith op ev_args 
  | _ -> failwith "not implemented"

let cli =
  let open Option.Let_syntax in
  let%bind filename = List.nth (Array.to_list (Sys.get_argv ())) 1 in
  let unparsed_prog = load_fpcore filename in
  let%bind prog = parse_fpcore unparsed_prog in
  match prog with
  | (_, args, props, fpexpr) -> 
      let intervals = parse_properties props in
      let env = Map.empty(module String) in
      let result = interpret_expr fpexpr env intervals in
      Some ()

let main = 
  let open Option.Let_syntax in
  let%bind prog = cli in
  Some ()
  (*abstract_interpret prog*)
