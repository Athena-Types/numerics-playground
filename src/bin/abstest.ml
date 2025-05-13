open Fpcore
open Base
open List
open String
open Int
open Z
open Float
open Q
open Random

(* supported options *)
let unit_roundoff = div_2exp one (53)
let debug = false

(* currently unsupported options *)
let sterbenz = false
let shared = true (* perform this using fpcore transformations? *)

(* should refactor these funcs into the shared library *)
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

(* todo: make sure that random will error if intervals cross-over, or, add
    validation check. *)
let sample_from_interval i : Q.t =
  match i with
  | (Inclusive lb, Inclusive ub) -> 
      let lb_q = of_float lb in
      let ub_q = of_float ub in
      let sample_num = 
        Z.of_int
        (int_incl 
        (Z.to_int ((Z.mul (num lb_q) (den ub_q))))
        (Z.to_int ((Z.mul (num ub_q) (den lb_q)))))
        in
      let sample_den = Z.mul (den lb_q) (den ub_q) in
      make sample_num sample_den
  | (Exclusive lb, Inclusive ub) ->
      let lb_q = of_float lb in
      let ub_q = of_float ub in
      let sample_num = 
        Z.of_int
        (int_incl 
        (Z.to_int (Z.add (Z.mul (num lb_q) (den ub_q)) (Z.of_int (1))))
        (Z.to_int ((Z.mul (num ub_q) (den lb_q)))))
        in
      let sample_den = Z.mul (den lb_q) (den ub_q) in
      make sample_num sample_den
  | (Inclusive lb, Exclusive ub) ->
      let lb_q = of_float lb in
      let ub_q = of_float ub in
      let sample_num = 
        Z.of_int
        (int_incl 
        (Z.to_int ((Z.mul (num lb_q) (den ub_q))))
        (Z.to_int (Z.sub (Z.mul (num ub_q) (den lb_q)) (Z.of_int 1))))
        in
      let sample_den = Z.mul (den lb_q) (den ub_q) in
      make sample_num sample_den
  | (Exclusive lb, Exclusive ub) ->
      let lb_q = of_float lb in
      let ub_q = of_float ub in
      let sample_num = 
        Z.of_int
        (int_incl 
        (Z.to_int (Z.add (Z.mul (num lb_q) (den ub_q)) (Z.of_int 1)))
        (Z.to_int (Z.sub (Z.mul (num ub_q) (den lb_q)) (Z.of_int 1))))
        in
      let sample_den = Z.mul (den lb_q) (den ub_q) in
      make sample_num sample_den

let rec sample_intervals interval_env =
  Map.map interval_env (fun x -> sample_from_interval x)

let rho eps_up input : Q.t = 
  if eps_up
  then 
    if input >= of_int 0 
    then input * (one + unit_roundoff)
    else input * (one - unit_roundoff)
  else 
    if input >= of_int 0 
    then input * (one - unit_roundoff)
    else input * (one + unit_roundoff)

let rec interpret_expr fpexpr sample_env round eps_up ?(debug=false) =
  let open Option.Let_syntax in
  let rec eval_arith op sample_env args round eps_up ?(debug=false) : Q.t option =
    let rnd = if round then rho eps_up else (fun x -> x) in
    if debug then print_endline ("Eps up?: " ^ (Bool.to_string eps_up));
    (match op with
    | Plus -> 
      let%bind x = List.nth args 0 in
      let%bind y = List.nth args 1 in
      let%bind x_evaled = interpret_expr x sample_env round eps_up ~debug in
      let%bind y_evaled = interpret_expr y sample_env round eps_up ~debug in
      Some (rnd (x_evaled + y_evaled))
    | Minus ->
      let%bind x = List.nth args 0 in
      (match List.nth args 1 with
      | Some y -> 
        let%bind x_evaled = interpret_expr x sample_env round eps_up ~debug in
        let%bind y_evaled = interpret_expr y sample_env round (not eps_up) ~debug in
        Some (rnd (x_evaled - y_evaled))
      | None -> 
        let%bind x_evaled = interpret_expr x sample_env round (not eps_up) ~debug in
        Some (- x_evaled))
    | Times ->
      let%bind x = List.nth args 0 in
      let%bind y = List.nth args 1 in
      let%bind x_evaled = interpret_expr x sample_env round eps_up ~debug in
      let%bind y_evaled = interpret_expr y sample_env round eps_up ~debug in
      Some (rnd (x_evaled * y_evaled))
    | Divide ->
      let%bind x = List.nth args 0 in
      let%bind y = List.nth args 1 in
      let%bind x_evaled = interpret_expr x sample_env round eps_up ~debug in
      let%bind y_evaled = interpret_expr y sample_env round (not eps_up) ~debug in
      Some (rnd (x_evaled / y_evaled))
    | _ -> failwith "not implemented") in
  let%bind evaled = (match fpexpr with
  | Num n -> Some (of_float (number_to_float n))
  | Const c -> Map.find sample_env c
  | Sym s -> Map.find sample_env s
  | Op (op, args) ->
      eval_arith op sample_env args round eps_up ~debug
  | Let (bindings, expr) ->
      let%bind ev_binds = 
        Option.all 
        (List.map bindings (fun x -> interpret_expr (snd x) sample_env round
        eps_up ~debug)) in
      let names = List.map bindings fst in
      let new_env = 
        Map.of_alist_exn(module String) (List.zip_exn names ev_binds) in
      let merged_env = Map.merge new_env sample_env in
      interpret_expr expr new_env round eps_up ~debug
  | _ -> failwith "not implemented") in
  if debug then print_endline (print_fpexpr fpexpr ^ " evaled to (approx!) " ^ Float.to_string
  (to_float evaled))
  else ();
  Some evaled

let cli =
  let open Option.Let_syntax in
  let args = Array.to_list (Sys.get_argv ()) in
  let%bind seed = List.nth args 2 in
  if debug then print_endline ("seed is "^ seed);
  Random.init (int_of_string seed);
  let%bind filename = List.nth args 1 in
  let unparsed_prog = load_fpcore filename in
  let%bind prog = parse_fpcore unparsed_prog in
  match prog with
  | (_, args, props, fpexpr) -> 
      let interval_env = parse_properties props in
      let sample_env = sample_intervals interval_env in
      let%bind approx = interpret_expr fpexpr sample_env true true ~debug:debug in
      let%bind exact = interpret_expr fpexpr sample_env false true ~debug:debug in
      Some (abs (approx - exact))

let () = 
  let open Option.Let_syntax in
  match cli with
  | Some result -> 
      let result_fp = to_float result in
      print_endline ("error was (approx!): " ^ (Float.to_string result_fp))
      (* print_endline (to_string result)*)
  | _ -> failwith "Not able to interpret"
