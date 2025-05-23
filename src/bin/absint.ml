open Fpcore
open Base
open List
open String
open Int

type bound = 
  | Inclusive : float -> bound (* e.g. [0, 1] *)
  | Exclusive : float -> bound (* e.g. (0, 1) *)

type interval = bound * bound

let extract_float_from_bound b =
  match b with
  | Inclusive f -> f
  | Exclusive f -> f

let compare b1 b2 = 
  let f1 = extract_float_from_bound b1 in
  let f2 = extract_float_from_bound b2 in
  Float.compare f1 f2

let print_interval (i : interval) = 
  match i with
  | (Inclusive lb, Inclusive ub) -> 
      Printf.sprintf "[%.10f, %.10f]" lb ub
  | (Exclusive lb, Inclusive ub) ->
      Printf.sprintf "(%.10f, %.10f]" lb ub
  | (Inclusive lb, Exclusive ub) ->
      Printf.sprintf "[%.10f, %.10f)" lb ub
  | (Exclusive lb, Exclusive ub) ->
      Printf.sprintf "(%.10f, %.10f)" lb ub

let exact_interval b : interval = (Exclusive b, Exclusive b)

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

let lift_unop_to_bound (op : float -> float) (b : bound) =
  match b with
  | Inclusive f -> Inclusive (op f)
  | Exclusive f -> Exclusive (op f)

let lift_binop_to_bound (op : float -> float -> float) (b1 : bound) (b2 : bound) =
  match b1 with
  | Inclusive f1 -> 
      (match b2 with
      | Inclusive f2 -> Inclusive (op f1 f2)
      | Exclusive f2 -> Exclusive (op f1 f2))
  | Exclusive f1 -> 
      (match b2 with
      | Inclusive f2 -> Exclusive (op f1 f2)
      | Exclusive f2 -> Exclusive (op f1 f2))

let ( * ) = lift_binop_to_bound Float.( * )
let ( + ) = lift_binop_to_bound Float.add
let ( - ) = lift_binop_to_bound Float.sub
let ( neg ) = lift_unop_to_bound Float.neg
let ( min ) = lift_binop_to_bound Float.min
let ( max ) = lift_binop_to_bound Float.max

let eval_arith op intervals : interval option = 
  let open Option.Let_syntax in
  match op with
  | Plus -> 
    let%bind (x_lb, x_ub) = List.nth intervals 0 in
    let%bind (y_lb, y_ub) = List.nth intervals 1 in
    Some (x_lb + y_lb, x_ub + y_ub)
  | Minus ->
    let%bind (x_lb, x_ub) = List.nth intervals 0 in
    (match List.nth intervals 1 with
    | Some (y_lb, y_ub) -> 
        let bounds = [x_lb - y_lb; x_lb - y_ub; x_ub - y_lb; x_ub - y_ub] in
        let%bind min_bnd = List.min_elt ~compare:compare bounds in
        let%bind max_bnd = List.max_elt ~compare:compare bounds in
        Some (min_bnd, max_bnd)
    | None -> Some (min (neg x_ub) (neg x_lb), max (neg x_ub) (neg x_lb)))
  | Times ->
    let%bind (x_lb, x_ub) = List.nth intervals 0 in
    let%bind (y_lb, y_ub) = List.nth intervals 1 in
    let bounds = [x_lb * y_lb; x_lb * y_ub; x_ub * y_lb; x_ub * y_ub] in
    let%bind min_bnd = List.min_elt ~compare:compare bounds in
    let%bind max_bnd = List.max_elt ~compare:compare bounds in
    Some (min_bnd, max_bnd)
  | _ -> failwith "not implemented"
  (*| Fabs ->*)
  (*  let%bind (x_lb, x_ub) = List.nth intervals 0 in*)

let rec interpret_expr prog interval_env ?(debug=false) = 
  let open Option.Let_syntax in
  let%bind evaled = match prog with
  | Num n -> Some (exact_interval (number_to_float n))
  | Const c -> Map.find interval_env c
  | Sym s -> Map.find interval_env s
  | Op (op, args) ->
      let%bind ev_args = 
        Option.all 
          (List.map args (fun x -> interpret_expr x interval_env ~debug)) in
      eval_arith op ev_args 
  | Let (bindings, expr) ->
      let%bind ev_binds = 
        Option.all 
        (List.map bindings (fun x -> interpret_expr (snd x) interval_env ~debug) ) in
      let names = List.map bindings fst in
      let new_env = 
        Map.of_alist_exn(module String) (List.zip_exn names ev_binds) in
      let merged_env = Map.merge new_env interval_env in
      interpret_expr expr new_env ~debug
  | _ -> failwith "not implemented" in
  if debug then print_endline (print_interval evaled ^ " was " ^ (print_fpexpr
  prog))
  else ();
  Some evaled

let cli =
  let open Option.Let_syntax in
  let%bind filename = List.nth (Array.to_list (Sys.get_argv ())) 1 in
  let unparsed_prog = load_fpcore filename in
  let%bind prog = parse_fpcore unparsed_prog in
  match prog with
  | (_, args, props, fpexpr) -> 
      let interval_env = parse_properties props in
      interpret_expr fpexpr interval_env ~debug:false

let () = 
  let open Option.Let_syntax in
  match cli with
  | Some result -> print_endline (print_interval result)
  | _ -> failwith "Not able to interpret"
