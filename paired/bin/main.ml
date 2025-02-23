open Parsexp_io
open Re2
open Ppx_sexp_conv_lib
open Base
open List
open String
open Int

type symbol = string [@@deriving sexp]

type ratnum = bool * string [@@deriving sexp] (* sign bit, digits *)
type decnum = bool * string [@@deriving sexp] (* sign bit, digits *)
type hexnum = bool * string [@@deriving sexp](* sign bit, digits *)

type number = 
  | Rat : ratnum -> number
  | Dec : decnum -> number (* need to change how this gets displayed *)
  | Hex : hexnum -> number (* need to change how this gets displayed *)
  | Digits : decnum * decnum * decnum -> number
[@@deriving sexp]

type dimension = 
  | SymDim : symbol -> dimension
  | NumDim : number -> dimension (*can be any number in the spec*)
[@@deriving sexp]

type data = 
  | SymData : symbol -> data
  | NumData : number -> data
  | StringData : string -> data
  | Data : data list -> data
[@@deriving sexp]

type property = (symbol * data) [@@deriving sexp]
(*type property = string [@@deriving sexp]*)

type argument = {sym : symbol; prop : property list; dim : dimension list}
[@@deriving sexp]

let update_arg_sym (arg: argument) (new_sym : symbol) =
  {arg with sym = new_sym }

type constant = string (* placeholder *)
[@@deriving sexp]

type operation =
  | Plus : operation
  | Minus : operation
  | Times : operation
  | Divide : operation
  | Fabs : operation
  | Fma : operation
  | Exp : operation
  | Exp2 : operation
  | Expm1 : operation
  | Log : operation
  | Log10 : operation
  | Log2 : operation
  | Log1p : operation
  | Pow : operation
  | Sqrt : operation
  | Cbrt : operation
  | Hypot : operation
  | Sin : operation
  | Cos : operation
  | Tan : operation
  | Asin : operation
  | Acos : operation
  | Atan : operation
  | Atan2 : operation
  | Sinh : operation
  | Cosh : operation
  | Tanh : operation
  | Asinh : operation
  | Acosh : operation
  | Atanh : operation
  | Erf : operation
  | Erfc : operation
  | Tgamma : operation
  | Lgamma : operation
  | Ceil : operation
  | Floor : operation
  | Fmod : operation
  | Remainder : operation
  | Fmax : operation
  | Fmin : operation
  | Fdim : operation
  | Copysign : operation
  | Trunc : operation
  | Round : operation
  | Nearbyint : operation
  | Lt : operation
  | Gt : operation
  | Leq : operation
  | Geq : operation
  | Eq : operation
  | Neq : operation (* unclear semantics with multiple args, but allowed in spec? *)
  | And : operation
  | Or : operation
  | Not : operation
  | Isfinite : operation
  | Isinf : operation
  | Isnan : operation
  | Isnormal : operation
  | Signbit : operation
[@@deriving sexp, eq]

type fpexpr = 
  | Num : number -> fpexpr
  | Const : constant -> fpexpr
  | Sym : symbol -> fpexpr
  | Op : operation * fpexpr list -> fpexpr (* non-zero repetition *)
  | If : fpexpr * fpexpr * fpexpr -> fpexpr
  | Let : (symbol * fpexpr) list * fpexpr -> fpexpr
  | LetStar : (symbol * fpexpr) list * fpexpr -> fpexpr
  | While : fpexpr * ((symbol * fpexpr * fpexpr) list * fpexpr) -> fpexpr
  | WhileStar : fpexpr * ((symbol * fpexpr * fpexpr) list * fpexpr) -> fpexpr
  | For : ((symbol * fpexpr) list * (symbol * fpexpr * fpexpr) list * fpexpr) -> fpexpr
  | ForStar : ((symbol * fpexpr) list * (symbol * fpexpr * fpexpr) list * fpexpr) -> fpexpr
  | Tensor : (symbol * fpexpr) list * fpexpr -> fpexpr
  | TensorStar : (symbol * fpexpr) list * fpexpr -> fpexpr
  | Cast : fpexpr -> fpexpr
  | Array : fpexpr list -> fpexpr
  | Not : property list * fpexpr -> fpexpr
[@@deriving sexp]


type fpcore = symbol option * argument list * property list * fpexpr 
[@@deriving sexp]

let load_fpcore filename = 
  match Parsexp_io.load (module Parsexp.Single) ~filename with
  | Ok f -> print_endline "Loaded fpcore file"; f
  | Error _ -> failwith "Not a valid sexp!"

let op_table = 
  [ 
    ("+", Plus); ("-", Minus); ("*", Times); 
    ("/", Divide); ("fabs", Fabs); ("fma", Fma); 
    ("exp", Exp); ("exp2", Exp2); ("expm1", Expm1); 
    ("log", Log); ("log10", Log10); ("log2", Log2); 
    ("log1p", Log1p); ("pow", Pow); ("sqrt", Sqrt);
    ("cbrt", Cbrt); ("hypot", Hypot); ("sin", Sin); 
    ("cos", Cos); ("tan", Tan); ("asin", Asin); 
    ("acos", Acos); ("atan", Atan); ("atan2", Atan2); 
    ("sinh", Sinh); ("cosh", Cosh); ("tanh", Tanh); 
    ("asinh", Asinh); ("acosh", Acosh); ("atanh", Atanh); 
    ("erf", Erf); ("erfc", Erfc); ("tgamma", Tgamma);
    ("lgamma", Lgamma); ("ceil", Ceil); ("floor", Floor);
    ("fmod", Fmod); ("remainder", Remainder); ("fmax", Fmax);
    ("fmin", Fmin); ("fdim", Fdim); ("copysign", Copysign);
    ("trunc", Trunc); ("round", Round); ("nearbyint", Nearbyint); 
    ("<", Lt); (">", Gt); ("<=", Leq); (">=", Geq); ("==", Eq); 
    ("!=", Neq); ("&&", And); ("||", Or); ("!", Not); 
    ("isfinite", Isfinite); ("isinf", Isinf); ("isnan", Isnan); 
    ("isnormal", Isnormal); ("signbit", Signbit)
]
let const_table = 
  [ 
    "E"; "LOG2E"; "LOG10E"; "LN2";
    "LN10"; "PI"; "PI_2"; "PI_4";
    "M_1_PI"; "M_2_PI"; "M_2_SQRTPI";
    "SQRT2"; "SQRT1_2"; "INFINITY";
    "NAN"; "TRUE"; "FALSE"
  ]

let lookup_op (op_str : string) : operation option = 
  let open Option.Let_syntax in
  let%bind result = (List.nth (List.filter op_table (fun x -> String.equal op_str (fst x))) 0) in
  Some (snd result)

let lookup_const (const : string) : bool =
  List.exists const_table (String.equal const)

let lookup_arg (args : argument list) (arg_str : string) : argument option = 
  let open Option.Let_syntax in
  List.nth (List.filter args 
    (fun x -> String.equal (x.sym) arg_str )) 0

(* TODO: make fail loudly if the list is empty*)
let all_but_last (l : 'a list) : ('a list) =
  List.take l ((List.length l) - 1)

let match_regex (regex_expr : string) (candidate : string) : bool =
  let re = Re2.create_exn regex_expr in
  Re2.matches re candidate

let parse_number (a : string) : number option = 
  (*print_endline ("number parsed: " ^ a);*)
  if match_regex "^[+]?[0-9]+/[0-9]*[1-9][0-9]*$" a then Some (Rat (true, a))
  else if match_regex "^-[0-9]+/[0-9]*[1-9][0-9]*$" a then Some (Rat (false, a))
  else if match_regex "^[+]?0x([0-9a-f]+(\\.[0-9a-f]+)?|\\.[0-9a-f]+)(p[-+]?[0-9]+)?$" a then Some (Hex (true, a))
  else if match_regex "^-0x([0-9a-f]+(\\.[0-9a-f]+)?|\\.[0-9a-f]+)(p[-+]?[0-9]+)?$" a then Some (Hex (false, a))
  else if match_regex "^[+]?([0-9]+(\\.[0-9]+)?|\\.[0-9]+)(e[-+]?[0-9]+)?$" a then Some (Dec (true, a))
  else if match_regex "^-([0-9]+(\\.[0-9]+)?|\\.[0-9]+)(e[-+]?[0-9]+)?$" a then Some (Dec (false, a))
  else None

let parse_symbol (s : Sexp.t) : symbol option =
  match s with 
  | Sexp.Atom a ->
    if match_regex "[a-zA-Z~!@$%^&*_\\-+=<>.?/:][a-zA-Z0-9~!@$%^&*_\\-+=<>.?/:]*" a
    then Some a
    else None
  | _ -> failwith ("Tried to parse as symbol: " ^ Sexp.to_string_hum s)

let rec parse_fpexpr (vars : argument list) (s : Sexp.t) : fpexpr option = 
  let open Option.Let_syntax in
  match s with 
  | Sexp.Atom a -> 
      if lookup_const a
      then Some (Const a)
      else 
        (match lookup_arg vars a with
        | Some var -> Some (Sym var.sym)
        | None -> 
            (match parse_number a with
            | Some num -> Some (Num num)
            (* Some programs in the benchmark do not declare every argument, e.g. himmilbeau,
               so it is good to fall back to declaring an atom as a symbol. *)
            | None -> Some (Sym a))) 
  | Sexp.List l ->
    let parse_bind (x : Sexp.t) : (symbol * fpexpr) = 
      (match x with 
      | Sexp.List ((Sexp.Atom symbol) :: unparsed_expr :: []) -> 
          (match parse_fpexpr vars unparsed_expr with
          | Some expr -> (symbol, expr)
          | None -> failwith ("Bad expression parse of: " ^ Sexp.to_string unparsed_expr))
      | _ -> failwith ("Malformed binding: " ^ Sexp.to_string x)) in
    match l with
    | Sexp.Atom "if" :: tl -> 
        if (List.length tl) > 3 then failwith "Too many args to if expression!"
        else
          let%bind cond = (List.nth tl 0) >>= parse_fpexpr vars in
          let%bind b1 = (List.nth tl 1) >>= parse_fpexpr vars in
          let%bind b2 = (List.nth tl 2) >>= parse_fpexpr vars in
          Some (If (cond, b1, b2))
    | Sexp.Atom "let" :: (Sexp.List unparsed_bindings) :: expr :: [] -> 
        let bindings = (List.map unparsed_bindings parse_bind) in
        let%bind expr = parse_fpexpr vars expr in
        Some (Let (bindings, expr))
    | Sexp.Atom "let*" :: (Sexp.List unparsed_bindings) :: expr :: [] -> 
        let bindings = (List.map unparsed_bindings parse_bind) in
        let%bind expr = parse_fpexpr vars expr in
        Some (LetStar (bindings, expr))
    | Sexp.Atom op_str :: unparsed_args -> 
        (match lookup_op op_str with 
        | Some op -> 
          (match Option.all (List.map unparsed_args (parse_fpexpr vars)) with 
          | Some parsed_args -> Some (Op (op, parsed_args))
          | _ -> failwith ("Unhandled or invalid expression " ^ Sexp.to_string_hum s))
        | _ -> failwith ("Unhandled or invalid expression " ^ Sexp.to_string_hum s))
    | _ -> failwith ("Unhandled or invalid expression " ^ Sexp.to_string_hum s)

let parse_dim (s : Sexp.t) : dimension option =
  match s with
  | Sexp.Atom d ->
      (match parse_number d with
      | Some dim -> Some (NumDim dim) (* number *)
      | None -> Some (SymDim d))      (* symbol *)
  | Sexp.List _ -> failwith ("Bad dim: " ^ Sexp.to_string_hum s)

let rec parse_data (s : Sexp.t) : data option =
  let open Option.Let_syntax in
  match s with
  | Sexp.Atom e -> 
    (match parse_number e with
    | Some n -> Some (NumData n)
    | None -> 
      (match parse_symbol s with 
      | Some s -> Some (SymData s)
      | None -> Some (StringData e)))
    (*(match parse_symbol s with *)
    (*| Some s -> Some (SymData s)*)
    (*| None -> *)
    (*    (match parse_number e with*)
    (*    | Some n -> Some (NumData n)*)
    (*    | None -> Some (StringData e)))*)
  | Sexp.List l -> 
      let%bind data = (Option.all (List.map l parse_data)) in 
      Some (Data data)

let parse_property (s : Sexp.t list) : property list * Sexp.t list =
  let open Option.Let_syntax in
  let rec go (p : property list) (s : Sexp.t list) = 
    match s with 
    | Sexp.Atom unparsed_key :: unparsed_value :: rem ->
        let%bind key = parse_symbol (Sexp.Atom unparsed_key) in
        let%bind value = parse_data unparsed_value in
        go ((key, value) :: p) rem
    | _ -> Some (p, s) in
  match go [] s with
  | Some (props, rem) -> (List.rev props, rem)
  | None -> ([], s)

let parse_arg (s : Sexp.t) : argument option = 
  let open Option.Let_syntax in
  match s with
  | Sexp.Atom symbol -> 
      let%bind sym = parse_symbol s in 
      Some {sym = sym; prop = []; dim = []}
  | Sexp.List (Sexp.Atom "!" :: tail) -> 
      let (props, remainder) = parse_property tail in
      let%bind unparsed_sym = (List.nth remainder 0) in
      let%bind sym = parse_symbol unparsed_sym in
      let%bind dims = Option.all (List.map (List.drop remainder 1) parse_dim) in
      Some {sym = sym; prop = props; dim = dims}
  | Sexp.List (Sexp.Atom symbol :: dimensions) -> 
      let%bind sym = parse_symbol (Sexp.Atom symbol) in
      let%bind dims = Option.all (List.map dimensions parse_dim) in
      Some {sym = symbol; prop = []; dim = dims}

let parse_args (s : Sexp.t) : argument list =
  match s with
  | Sexp.List args -> 
      (match Option.all (List.map args parse_arg) with
      | Some args -> args
      | None -> [])
  | Sexp.Atom e -> failwith ("Args should be a list, instead got: " ^ e)

let rec string_join_list strings separator = 
  match strings with 
  | hd_str :: tl_strs ->
      (match tl_strs with
       | _ :: _ -> hd_str ^ separator ^ string_join_list tl_strs separator
       | [] -> hd_str)
  | [] -> ""

(* assume no property or dims to translate *)
let print_argument arg = 
  if (List.is_empty arg.prop) && (List.is_empty arg.dim) 
  then arg.sym
  else failwith "non empty prop or dim; unhandled"

let wrap_paren str = "(" ^ str ^ ")"

let print_optional_sym sym =
  match sym with
  | Some s -> wrap_paren s
  | None -> ""

let rec print_num num = 
  match num with
  | Rat (sign, rnum) -> rnum
  | Dec (sign, dnum) -> dnum
  | Hex (sign, hnum) ->  hnum
  | Digits (d1, d2, d3) -> 
      "(digits " ^ print_num (Dec d1) ^ " " ^ print_num (Dec d2) ^ " " ^ print_num (Dec d3) ^ ")"

let rec print_data data =
  match data with
  | SymData sym -> sym
  | NumData num -> print_num num
  | StringData s -> s
  | Data dl -> "(" ^ (string_join_list (List.map dl print_data) " ") ^ ")"

let print_property (sym, data) = sym ^ " " ^ print_data data

let print_op (operation) : string = 
  let open Option.Let_syntax in
  match (List.nth (List.filter op_table (fun x -> equal_operation operation (snd x))) 0) with
  | Some op_entry -> fst op_entry
  | None -> failwith "could not find op in lookup table"

let rec print_expr expr = 
  match expr with 
  | Num num -> print_num num
  | Const c -> c
  | Sym sym -> sym
  | Op (op, args) -> "(" ^ print_op op ^ " " ^ (string_join_list (List.map args print_expr) " ") ^ ")"
  | Let (bindings, expr) -> 
      "(let " ^ wrap_paren 
                  (string_join_list 
                    (List.map bindings 
                      (fun (v, e) -> "(" ^ v ^ " " ^ (print_expr e) ^ ")")) " ")
              ^ " " 
              ^ print_expr expr
      ^ ")"
  | _ -> failwith "unhandled expression to print"

let print_fpcore (sym, args, props, expr) =
  let sym_str = print_optional_sym sym in
  let args_str = "(" ^ (string_join_list (List.map args print_argument) " ") ^ ")" in
  let props_str = (string_join_list (List.map props print_property) "\n") in
  let expr_str = print_expr expr in
  "(FPCore " ^ sym_str ^ args_str ^ "\n" ^ props_str ^ "\n" ^ expr_str ^ ")"

let parse_fpcore (s : Sexp.t) : fpcore option = 
  let open Option.Let_syntax in
  let%bind prog = 
    (match s with
    | Sexp.Atom _ -> failwith "Not a valid fpcore file"
    | Sexp.List l -> 
        match l with
        | Sexp.Atom a :: tail -> 
            if (String.equal a "FPCore") then 
              let%bind (sym, tail_opt) = List.nth tail 0 >>= fun item ->
                  (match item with 
                  | Sexp.Atom b -> Some (Some b, tl tail)
                  | Sexp.List _ -> Some (None, Some tail)) in (* try again; parse as args *)
              let%bind tail' = tail_opt in
              let%bind unparsed_args = List.nth tail' 0 in
              let args = parse_args unparsed_args in
              let new_tail = List.drop tail' 1 in
              let props = fst (parse_property (List.take new_tail ((List.length new_tail) - 1))) in
              let%bind unparsed_expr = List.last new_tail in 
              let%bind expr = parse_fpexpr args unparsed_expr in
              Some (sym, args, props, expr)
            else failwith ("Not a valid fpcore file:" ^ a)
        | _ -> failwith "Not a valid fpcore file") in
  Some prog

let mk_fresh_var (fresh : int ref) : fpexpr = 
  let var = Sym ("v " ^ string_of_int (!fresh)) in
  incr fresh;
  var

(*let rec interpert_expr (expr: fpexpr) (func: fpexpr -> 'a -> 'k -> 'b) (state: 'a) : 'b =*)
(*let rec interpert_expr (expr: fpexpr) (func: fpexpr -> 'a -> 'b) (state: 'a) : 'b =*)
(*let rec interpert_expr expr k : 'b =*)
(*  match expr with *)
(*  | _ -> k expr func expr state interpert_expr*)

(* NB: The only constructs we consider are let and operations; all other constructs are unhandled. *)

(*let rec transform (expr: fpexpr) (state : argument list * int ref) (cont : fpexpr -> (fpexpr -> 'a -> 'k -> 'b) -> 'a)=*)
(*let rec transform (expr: fpexpr) (state : argument list * int ref) k =*)
(*  let (args, fresh) = state in*)
let rec transform (expr: fpexpr) (args : argument list) (fresh : int ref) (env : symbol -> fpexpr * fpexpr): (fpexpr * fpexpr) option =
  let open Option.Let_syntax in
  match expr with 
  | Op (operation, vars) ->
      let%bind paired_args = Option.all (List.map vars (fun x -> transform x args fresh env)) in
      (match operation with 
      (* TODO: move the let from the interpreter into the expression to allow analysis to share common subexpressions during analysis.*)
      | Plus -> 
          let%bind (larg_p, larg_n) = nth paired_args 0 in
          let%bind (rarg_p, rarg_n) = nth paired_args 1 in
          Some (Op (Plus, [larg_p; rarg_p]), Op (Plus, [larg_n; rarg_n]))
      | Minus ->
          let%bind (larg_p, larg_n) = nth paired_args 0 in
          let%bind (rarg_p, rarg_n) = nth paired_args 1 in
          Some (Op (Plus, [larg_p; rarg_n]), Op (Plus, [larg_n; rarg_p]))
      | Times ->
          let%bind (larg_p, larg_n) = nth paired_args 0 in
          let%bind (rarg_p, rarg_n) = nth paired_args 1 in
          Some 
            ( Op (Plus, [Op (Times, [larg_p; rarg_p]); Op (Times, [larg_n; rarg_n])]),
              Op (Plus, [Op (Times, [larg_p; rarg_n]); Op (Times, [larg_p; rarg_n])]))
      | Divide -> failwith "unhandled operation divide"
      | _ -> failwith "unhandled operation")
      (* inline and compute paired version of (non-recursive) let exprs *)
  | Let (binders, expr) ->
      let rec update_env env binders = 
        (match binders with 
        | (hd_sym, hd_expr) :: tl -> 
            (match transform hd_expr args fresh env with 
             | Some (pexpr, nexpr) -> 
                 update_env 
                 (fun (x : symbol) -> 
                   print_endline hd_sym;  (* debug *)
                   if (String.equal x hd_sym) then (pexpr, nexpr) else env x) 
                 tl
             | None -> update_env env tl)
        | [] -> env) in
      let env' = update_env env binders in
      transform expr args fresh env'
  | Sym var -> Some (env var)
  | Num var -> 
      let (varp, varn) = 
        (match var with 
        | Rat (true, n) -> (Rat (true, n), Dec (true, "0"))
        | Rat (false, n) -> (Dec (true, "0"), Rat (true, n))
        | Dec (true, n) -> (Dec (true, n), Dec (true, "0"))
        | Dec (false, n) -> (Dec (true, "0"), Dec (true, n))
        | Hex (true, n) -> (Hex (true, n), Hex (true, "0"))
        | Hex (false, n) -> (Hex (true, "0"), Hex (true, n)))
        in
      Some (Num varp, Num varn)
  | _ -> failwith "unhandled expr"
  (*| _ -> interpert_expr expr transform_ops_expr state*)

let rec default_env args env = 
  match args with
  | hd_arg :: tl_arg -> 
      default_env 
      tl_arg
      (fun x -> if (String.equal hd_arg.sym x) then (Sym (hd_arg.sym ^ "p"), Sym (hd_arg.sym ^ "n")) else env x)
  | [] -> env

(*let check_*)

(* If a condition looks like a <= x <= a for some constant a and program 
   variable x, return true. Otherwise, return false. *)
(*let check_first_order (conds: data list) =*)

let rec transform_args args = 
  match args with
  | hd_arg :: tl_arg -> 
      update_arg_sym hd_arg (hd_arg.sym ^ "p") :: 
        update_arg_sym hd_arg (hd_arg.sym ^ "n") ::
          transform_args tl_arg
  | [] -> []

let rec transform_cond (cond: data) (args: argument list) =
  match cond with
  | SymData sym -> 
      (match lookup_arg args sym with
      | Some arg -> 
          print_endline ("looked up in transform_cond " ^ sym);
          Data [(SymData "-"); SymData (arg.sym ^ "p"); SymData (arg.sym ^ "n")]
      | None -> SymData sym)
  | NumData num -> NumData num
  | StringData s -> StringData s
  | Data dl -> Data (List.map dl (fun x -> transform_cond x args))

let rec transform_conds (conds: data list) (args: argument list) = 
  List.map conds (fun x -> transform_cond x args)

let rec transform_preconds new_preconds (props: data) (args: argument list) = 
  match props with 
  | Data (SymData ("and") :: conds) -> Data (List.append (SymData ("and") :: new_preconds) (transform_conds conds args))
  (*| Data (SymData ("or") :: conds) -> Data (SymData ("or") :: transform_conds conds args)*)
  | _ -> failwith "failed to transform preconds"

let rec gen_new_preconds args = 
  match args with
  | hd_arg :: tl_arg -> 
      (Data [(SymData "<="); (NumData (Dec (true, "0"))); SymData (hd_arg.sym ^ "p")]) :: 
        (Data [(SymData "<="); SymData (hd_arg.sym ^ "p"); (NumData (Dec (true, "0")))]) :: 
          gen_new_preconds tl_arg 
  | [] -> []

let rec transform_props (props: property list) (args : argument list) = 
  let new_preconds = gen_new_preconds args in
  match props with
  | hd_prop :: tl_props -> 
      (match hd_prop with
      | (":pre", data) -> (":pre", transform_preconds new_preconds data args) :: tl_props
      | _ -> hd_prop :: transform_props tl_props args)
  | [] -> props

let transform_ops_fpcore (prog : fpcore) : fpcore option = 
  let open Option.Let_syntax in
  match prog with 
  | (symbol, args, props, expr) -> 
      let env = default_env args (fun x -> failwith ("unhandled env lookup: " ^ x)) in
      let%bind (pos_prog, neg_prog) = transform expr args (ref 0) env in
      let transformed_args = transform_args args in
      let transformed_props = transform_props props args in
      Some (symbol, transformed_args, transformed_props, 
        Let 
        (
          [("pos", pos_prog); ("neg", neg_prog)], 
          Op (Minus, [Sym "pos"; Sym "neg"])
        ))

let transform_prog (prog: fpcore) : fpcore option = transform_ops_fpcore prog

let main =
  let open Option.Let_syntax in
  let%bind filename = List.nth (Array.to_list (Sys.get_argv ())) 1 in
  let unparsed_prog = load_fpcore filename in
  let%bind prog = parse_fpcore unparsed_prog in
  let _ = print_endline (print_fpcore prog) in
  let%bind transformed_prog = transform_prog prog in
  let _ = print_endline (print_fpcore transformed_prog) in
  Some "transform good"

let () = 
  let result = Option.value main ~default:"transform bad" in 
  print_endline result
