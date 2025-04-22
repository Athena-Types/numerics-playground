open Fpcore
open Base
open List
open String
open Int

(*let rec interpert_expr (expr: fpexpr) (func: fpexpr -> 'a -> 'k -> 'b) (state: 'a) : 'b =*)
(*let rec interpert_expr (expr: fpexpr) (func: fpexpr -> 'a -> 'b) (state: 'a) : 'b =*)
(*let rec interpert_expr expr k : 'b =*)
(*  match expr with *)
(*  | _ -> k expr func expr state interpert_expr*)

(* NB: The only constructs we consider are let and operations; all other constructs are unhandled. *)

(*let rec transform (expr: fpexpr) (state : argument list * int ref) (cont : fpexpr -> (fpexpr -> 'a -> 'k -> 'b) -> 'a)=*)
(*let rec transform (expr: fpexpr) (state : argument list * int ref) k =*)
(*  let (args, fresh) = state in*)
let rec transform (expr : fpexpr) (args : argument list) (fresh : int ref)
    (env : symbol -> fpexpr * fpexpr) : (fpexpr * fpexpr) option =
  let open Option.Let_syntax in
  match expr with
  | Op (operation, vars) -> (
      let%bind paired_args =
        Option.all (List.map vars (fun x -> transform x args fresh env))
      in
      match operation with
      (* TODO: move the let from the interpreter into the expression to allow analysis to share common subexpressions during analysis.*)
      | Plus ->
          let%bind larg_p, larg_n = nth paired_args 0 in
          let%bind rarg_p, rarg_n = nth paired_args 1 in
          Some (Op (Plus, [larg_p; rarg_p]), Op (Plus, [larg_n; rarg_n]))
      | Minus -> (
          let%bind larg_p, larg_n = nth paired_args 0 in
          match nth paired_args 1 with
          | Some (rarg_p, rarg_n) ->
              Some (Op (Plus, [larg_p; rarg_n]), Op (Plus, [larg_n; rarg_p]))
          | None ->
              Some (larg_n, larg_p) )
      | Times ->
          let%bind larg_p, larg_n = nth paired_args 0 in
          let%bind rarg_p, rarg_n = nth paired_args 1 in
          Some
            ( Op
                ( Plus
                , [Op (Times, [larg_p; rarg_p]); Op (Times, [larg_n; rarg_n])]
                )
            , Op
                ( Plus
                , [Op (Times, [larg_p; rarg_n]); Op (Times, [larg_p; rarg_n])]
                ) )
      | Divide ->
          failwith "unhandled operation divide"
      | _ ->
          failwith "unhandled operation"
      (* inline and compute paired version of (non-recursive) let exprs *) )
  | Let (binders, expr) ->
      let rec update_env env binders =
        match binders with
        | (hd_sym, hd_expr) :: tl -> (
          match transform hd_expr args fresh env with
          | Some (pexpr, nexpr) ->
              update_env
                (fun (x : symbol) ->
                  if String.equal x hd_sym then (pexpr, nexpr) else env x )
                tl
          | None ->
              update_env env tl )
        | [] ->
            env
      in
      let env' = update_env env binders in
      transform expr args fresh env'
  | Sym var ->
      Some (env var)
  | Num var ->
      let varp, varn =
        match var with
        | Rat (true, n) ->
            (Rat (true, n), Dec (true, "0"))
        | Rat (false, n) ->
            (Dec (true, "0"), Rat (true, n))
        | Dec (true, n) ->
            (Dec (true, n), Dec (true, "0"))
        | Dec (false, n) ->
            (Dec (true, "0"), Dec (true, n))
        | Hex (true, n) ->
            (Hex (true, n), Hex (true, "0"))
        | Hex (false, n) ->
            (Hex (true, "0"), Hex (true, n))
      in
      Some (Num varp, Num varn)
  | _ ->
      failwith "unhandled expr"
(*| _ -> interpert_expr expr transform_ops_expr state*)

let rec default_env args env =
  match args with
  | hd_arg :: tl_arg ->
      default_env tl_arg (fun x ->
          if String.equal hd_arg.sym x then
            (Sym (hd_arg.sym ^ "p"), Sym (hd_arg.sym ^ "m"))
          else env x )
  | [] ->
      env

(*let check_*)

(* If a condition looks like a <= x <= a for some constant a and program
   variable x, return true. Otherwise, return false. *)
(*let check_first_order (conds: data list) =*)

let rec transform_args args =
  match args with
  | hd_arg :: tl_arg ->
      update_arg_sym hd_arg (hd_arg.sym ^ "p")
      :: update_arg_sym hd_arg (hd_arg.sym ^ "m")
      :: transform_args tl_arg
  | [] ->
      []

let rec transform_cond (cond : data) (args : argument list) =
  match cond with
  | SymData sym -> (
    match lookup_arg args sym with
    | Some arg ->
        [Data [SymData "-"; SymData (arg.sym ^ "p"); SymData (arg.sym ^ "m")]]
    | None ->
        [SymData sym] )
  | NumData num ->
      [NumData num]
  | StringData s ->
      [StringData s]
  | Data [SymData "<="; NumData lb; SymData var; NumData ub] -> (
    match lookup_arg args var with
    | Some arg ->
        let lb_int = number_to_float lb in
        let ub_int = number_to_float ub in
        if
          Float.compare lb_int Float.zero <= 0
          (*then Data [(SymData "and"); Data [(SymData "<="); NumData (lb); SymData (arg.sym ^ "m"); NumData (ub)]; Data [(SymData "=="); SymData (arg.sym ^ "p"); SymData ("0")]]*)
        then
          [ Data [SymData "<="; NumData lb; SymData (arg.sym ^ "m"); NumData ub]
          ; Data [SymData "=="; SymData (arg.sym ^ "p"); SymData "0"] ]
        else if
          Float.compare ub_int Float.zero >= 0
          (*then Data [(SymData "and"); Data [(SymData "<="); NumData (lb); SymData (arg.sym ^ "p"); NumData (ub)]; Data [(SymData "=="); SymData (arg.sym ^ "m"); SymData ("0")]]*)
        then
          [ Data [SymData "<="; NumData lb; SymData (arg.sym ^ "p"); NumData ub]
          ; Data [SymData "=="; SymData (arg.sym ^ "m"); SymData "0"] ]
        else
          (*Data [(SymData "and"); Data [(SymData "<="); NumData (lb); SymData (arg.sym ^ "p"); SymData("0")]; Data [(SymData "<="); SymData("0"); SymData (arg.sym ^ "m"); NumData (ub)]]*)
          [ Data [SymData "<="; NumData lb; SymData (arg.sym ^ "p"); SymData "0"]
          ; Data [SymData "<="; SymData "0"; SymData (arg.sym ^ "m"); NumData ub]
          ]
    | None ->
        [cond] )
  | Data [SymData "<"; NumData lb; SymData var; NumData ub] -> (
    match lookup_arg args var with
    | Some arg ->
        let lb_int = number_to_float lb in
        let ub_int = number_to_float ub in
        if
          Float.compare lb_int Float.zero <= 0
          (*then Data [(SymData "and"); Data [(SymData "<="); NumData (lb); SymData (arg.sym ^ "m"); NumData (ub)]; Data [(SymData "=="); SymData (arg.sym ^ "p"); SymData ("0")]]*)
        then
          [ Data [SymData "<="; NumData lb; SymData (arg.sym ^ "m"); NumData ub]
          ; Data [SymData "=="; SymData (arg.sym ^ "p"); SymData "0"] ]
        else if
          Float.compare ub_int Float.zero >= 0
          (*then Data [(SymData "and"); Data [(SymData "<="); NumData (lb); SymData (arg.sym ^ "p"); NumData (ub)]; Data [(SymData "=="); SymData (arg.sym ^ "m"); SymData ("0")]]*)
        then
          [ Data [SymData "<="; NumData lb; SymData (arg.sym ^ "p"); NumData ub]
          ; Data [SymData "=="; SymData (arg.sym ^ "m"); SymData "0"] ]
        else
          (*Data [(SymData "and"); Data [(SymData "<"); NumData (lb); SymData (arg.sym ^ "p"); SymData("0")]; Data [(SymData "<"); SymData("0"); SymData (arg.sym ^ "m"); NumData (ub)]]*)
          [ Data [SymData "<"; NumData lb; SymData (arg.sym ^ "p"); SymData "0"]
          ; Data [SymData "<"; SymData "0"; SymData (arg.sym ^ "m"); NumData ub]
          ]
    | None ->
        [cond] )
  | Data dl ->
      (*let _ = print_endline ("transform cond: " ^ (string_of_int (List.length dl))) in*)
      [Data (List.join (List.map dl (fun x -> transform_cond x args)))]

let rec transform_conds (conds : data list) (args : argument list) =
  (*List.join (List.map conds (fun x -> transform_cond x args))*)
  match conds with
  | [SymData "<="; NumData lb; SymData var; NumData ub] -> (
    match lookup_arg args var with
    | Some arg ->
        let lb_int = number_to_float lb in
        let ub_int = number_to_float ub in
        if Float.compare lb_int Float.zero >= 0 then
          [ Data
              [ SymData "and"
              ; Data
                  [SymData "<="; NumData lb; SymData (arg.sym ^ "m"); NumData ub]
              ; Data [SymData "=="; SymData (arg.sym ^ "p"); SymData "0"] ] ]
          (*then (Data [(SymData "<="); NumData (lb); SymData (arg.sym ^ "m"); NumData (ub)]) :: (Data [(SymData "=="); SymData (arg.sym ^ "p"); SymData ("0")]) :: []*)
        else if Float.compare ub_int Float.zero <= 0 then
          [ Data
              [ SymData "and"
              ; Data
                  [SymData "<="; NumData lb; SymData (arg.sym ^ "p"); NumData ub]
              ; Data [SymData "=="; SymData (arg.sym ^ "m"); SymData "0"] ] ]
          (*then (Data [(SymData "<="); NumData (lb); SymData (arg.sym ^ "p"); NumData (ub)]) :: (Data [(SymData "=="); SymData (arg.sym ^ "m"); SymData ("0")]) :: []*)
        else
          [ Data
              [ SymData "and"
              ; Data
                  [ SymData "<="
                  ; NumData lb
                  ; SymData (arg.sym ^ "p")
                  ; SymData "0" ]
              ; Data
                  [ SymData "<="
                  ; SymData "0"
                  ; SymData (arg.sym ^ "m")
                  ; NumData ub ] ] ]
        (*(Data [(SymData "<="); NumData (lb); SymData (arg.sym ^ "p"); SymData("0")]) :: (Data [(SymData "<="); SymData("0"); SymData (arg.sym ^ "m"); NumData (ub)]) :: []*)
    | None ->
        conds )
  | [SymData "<"; NumData lb; SymData var; NumData ub] -> (
    match lookup_arg args var with
    | Some arg ->
        let lb_int = number_to_float lb in
        let ub_int = number_to_float ub in
        (*let _ =  print_endline ("here" ^ (string_of_int (Float.compare lb_int Float.zero))) in*)
        (*let _ =  print_endline ("here" ^ (string_of_int (Float.compare ub_int Float.zero))) in*)
        if Float.compare lb_int Float.zero >= 0 then
          [ Data
              [ SymData "and"
              ; Data
                  [SymData "<="; NumData lb; SymData (arg.sym ^ "m"); NumData ub]
              ; Data [SymData "=="; SymData (arg.sym ^ "p"); SymData "0"] ] ]
          (*then (Data [(SymData "<"); NumData (lb); SymData (arg.sym ^ "m"); NumData (ub)]) :: (Data [(SymData "=="); SymData (arg.sym ^ "p"); SymData ("0")]) :: []*)
        else if Float.compare ub_int Float.zero <= 0 then
          [ Data
              [ SymData "and"
              ; Data
                  [SymData "<="; NumData lb; SymData (arg.sym ^ "p"); NumData ub]
              ; Data [SymData "=="; SymData (arg.sym ^ "m"); SymData "0"] ] ]
          (*then (Data [(SymData "<"); NumData (lb); SymData (arg.sym ^ "p"); NumData (ub)]) :: (Data [(SymData "=="); SymData (arg.sym ^ "m"); SymData ("0")]) :: []*)
        else
          [ Data
              [ SymData "and"
              ; Data
                  [SymData "<"; NumData lb; SymData (arg.sym ^ "p"); SymData "0"]
              ; Data
                  [SymData "<"; SymData "0"; SymData (arg.sym ^ "m"); NumData ub]
              ] ]
        (*(Data [(SymData "<"); NumData (lb); SymData (arg.sym ^ "p"); SymData("0")]) :: (Data [(SymData "<"); SymData("0"); SymData (arg.sym ^ "m"); NumData (ub)]) :: []*)
    | None ->
        conds )
  | SymData sym :: tl -> (
    match lookup_arg args sym with
    | Some arg ->
        Data [SymData "-"; SymData (arg.sym ^ "p"); SymData (arg.sym ^ "m")]
        :: transform_conds tl args
    | None ->
        SymData sym :: transform_conds tl args )
  | NumData num :: tl ->
      NumData num :: transform_conds tl args
  | StringData s :: tl ->
      StringData s :: transform_conds tl args
  | Data dl :: tl -> (
      (*let _ = print_endline ("transform cond: " ^ (string_of_int (List.length dl))) in*)
      let conds = transform_conds dl args in
      match conds with
      | Data conds' :: [] ->
          Data conds' :: transform_conds tl args
      | _ ->
          Data conds :: transform_conds tl args )
  | [] ->
      []

(*flatten_and (and a (or b c)) = [a; (or b c)]*)
(*flatten_and (and a (and b c)) = [a; b; c]*)
let rec flatten_and (conds : data) : data list =
  match conds with
  | Data (SymData "and" :: Data (SymData "and" :: tl') :: tl) ->
      let flattened_head = flatten_and (Data (SymData "and" :: tl')) in
      let flattened_rest = flatten_and (Data (SymData "and" :: tl)) in
      List.append flattened_head flattened_rest
  | Data (SymData "and" :: hd :: tl) ->
      let flattened_rest = flatten_and (Data (SymData "and" :: tl)) in
      hd :: flattened_rest
  | Data (SymData "and" :: []) ->
      []
  | _ ->
      [conds]

(* TODO: find a better way to transform preconds such that FPBench can process it *)
let rec transform_preconds new_preconds (props : data) (args : argument list) =
  match props with
  (*| Data (SymData ("and") :: conds) -> Data (List.append (SymData ("and") :: new_preconds) (transform_conds conds args))*)
  | Data (SymData "and" :: conds) ->
      Data (SymData "and" :: transform_conds conds args)
  (*| Data (SymData ("or") :: conds) -> Data (SymData ("or") :: transform_conds conds args)*)
  (*| Data (conds) -> Data (List.append (SymData ("and") :: new_preconds) (transform_conds conds args))*)
  (*| Data (conds) -> Data (SymData ("and") :: transform_conds conds arg)*)
  | Data conds ->
      Data (SymData "and" :: transform_conds conds args)
  (*| Data (conds) -> Data (SymData ("and") :: new_preconds)*)
  | _ ->
      failwith "failed to transform preconds"

let rec gen_new_preconds (args : argument list) =
  match args with
  | hd_arg :: tl_arg ->
      Data [SymData "<="; NumData (Dec (true, "0")); SymData (hd_arg.sym ^ "p")]
      :: Data
           [SymData "<="; NumData (Dec (true, "0")); SymData (hd_arg.sym ^ "m")]
      :: gen_new_preconds tl_arg
  | [] ->
      []

let rec transform_props (props : property list) (args : argument list) =
  let new_preconds = gen_new_preconds args in
  match props with
  | hd_prop :: tl_props -> (
    match hd_prop with
    | ":pre", data ->
        ( ":pre"
        , Data
            ( SymData "and"
            :: flatten_and (transform_preconds new_preconds data args) ) )
        :: tl_props
    | _ ->
        hd_prop :: transform_props tl_props args )
  | [] ->
      (":pre", Data (SymData "and" :: new_preconds)) :: props

let transform_ops_fpcore (prog : fpcore) : fpcore option =
  let open Option.Let_syntax in
  match prog with
  | symbol, args, props, expr ->
      let env =
        default_env args (fun x -> failwith ("unhandled env lookup: " ^ x))
      in
      let%bind pos_prog, neg_prog = transform expr args (ref 0) env in
      let transformed_args = transform_args args in
      let transformed_props = transform_props props args in
      Some
        ( symbol
        , transformed_args
        , transformed_props
        , Let
            ( [("pos", pos_prog); ("neg", neg_prog)]
            , Op (Minus, [Sym "pos"; Sym "neg"]) ) )
(*Op (Minus, [pos_prog; neg_prog])*)

let transform_prog (prog : fpcore) : fpcore option = transform_ops_fpcore prog

let cli =
  let open Option.Let_syntax in
  let%bind filename = List.nth (Array.to_list (Sys.get_argv ())) 1 in
  let unparsed_prog = load_fpcore filename in
  parse_fpcore unparsed_prog

let main = 
  let open Option.Let_syntax in
  let%bind prog = cli in
  let%bind transformed_prog = transform_prog prog in
  let _ = print_endline (print_fpcore transformed_prog) in
  Some "transform good"

let () =
  let prog = Option.value main ~default:"transform bad" in
  ()
(*Printf.eprintf result*)
