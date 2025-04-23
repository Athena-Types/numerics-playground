type symbol = Base.string
val symbol_of_sexp : Sexplib0.Sexp.t -> symbol
val sexp_of_symbol : symbol -> Sexplib0.Sexp.t
type ratnum = Base.bool * Base.string
val ratnum_of_sexp : Sexplib0.Sexp.t -> ratnum
val sexp_of_ratnum : ratnum -> Sexplib0.Sexp.t
type decnum = Base.bool * Base.string
val decnum_of_sexp : Sexplib0.Sexp.t -> decnum
val sexp_of_decnum : decnum -> Sexplib0.Sexp.t
type hexnum = Base.bool * Base.string
val hexnum_of_sexp : Sexplib0.Sexp.t -> hexnum
val sexp_of_hexnum : hexnum -> Sexplib0.Sexp.t
type number =
    Rat : ratnum -> number
  | Dec : decnum -> number
  | Hex : hexnum -> number
  | Digits : decnum * decnum * decnum -> number
val number_of_sexp : Sexplib0.Sexp.t -> number
val sexp_of_number : number -> Sexplib0.Sexp.t
val number_to_float : number -> Base.Float.t
type dimension = SymDim : symbol -> dimension | NumDim : number -> dimension
val dimension_of_sexp : Sexplib0.Sexp.t -> dimension
val sexp_of_dimension : dimension -> Sexplib0.Sexp.t
type data =
    SymData : symbol -> data
  | NumData : number -> data
  | StringData : Base.string -> data
  | Data : data Base.list -> data
val data_of_sexp : Sexplib0.Sexp.t -> data
val sexp_of_data : data -> Sexplib0.Sexp.t
type property = symbol * data
val property_of_sexp : Sexplib0.Sexp.t -> property
val sexp_of_property : property -> Sexplib0.Sexp.t
type argument = {
  sym : symbol;
  prop : property Base.list;
  dim : dimension Base.list;
}
val argument_of_sexp : Sexplib0.Sexp.t -> argument
val sexp_of_argument : argument -> Sexplib0.Sexp.t
val update_arg_sym : argument -> symbol -> argument
type constant = Base.string
val constant_of_sexp : Sexplib0.Sexp.t -> constant
val sexp_of_constant : constant -> Sexplib0.Sexp.t
type operation =
    Plus : operation
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
  | Neq : operation
  | And : operation
  | Or : operation
  | Not : operation
  | Isfinite : operation
  | Isinf : operation
  | Isnan : operation
  | Isnormal : operation
  | Signbit : operation
val operation_of_sexp : Sexplib0.Sexp.t -> operation
val sexp_of_operation : operation -> Sexplib0.Sexp.t
val equal_operation : operation -> operation -> Ppx_deriving_runtime.bool
type fpexpr =
    Num : number -> fpexpr
  | Const : constant -> fpexpr
  | Sym : symbol -> fpexpr
  | Op : operation * fpexpr Base.list -> fpexpr
  | If : fpexpr * fpexpr * fpexpr -> fpexpr
  | Let : (symbol * fpexpr) Base.list * fpexpr -> fpexpr
  | LetStar : (symbol * fpexpr) Base.list * fpexpr -> fpexpr
  | While : fpexpr *
      ((symbol * fpexpr * fpexpr) Base.list * fpexpr) -> fpexpr
  | WhileStar : fpexpr *
      ((symbol * fpexpr * fpexpr) Base.list * fpexpr) -> fpexpr
  | For :
      ((symbol * fpexpr) Base.list * (symbol * fpexpr * fpexpr) Base.list *
       fpexpr) -> fpexpr
  | ForStar :
      ((symbol * fpexpr) Base.list * (symbol * fpexpr * fpexpr) Base.list *
       fpexpr) -> fpexpr
  | Tensor : (symbol * fpexpr) Base.list * fpexpr -> fpexpr
  | TensorStar : (symbol * fpexpr) Base.list * fpexpr -> fpexpr
  | Cast : fpexpr -> fpexpr
  | Array : fpexpr Base.list -> fpexpr
  | Not : property Base.list * fpexpr -> fpexpr
val fpexpr_of_sexp : Sexplib0.Sexp.t -> fpexpr
val sexp_of_fpexpr : fpexpr -> Sexplib0.Sexp.t
type fpcore =
    symbol Base.option * argument Base.list * property Base.list * fpexpr
val fpcore_of_sexp : Sexplib0.Sexp.t -> fpcore
val sexp_of_fpcore : fpcore -> Sexplib0.Sexp.t
val load_fpcore : string -> Base.Sexp.t
val load_fpcores : string -> Base.Sexp.t list
val op_table : (string * operation) list
val const_table : string list
val lookup_op : Base.string -> operation Base.option
val lookup_const : Base.string -> Base.bool
val lookup_arg : argument Base.list -> Base.string -> argument Base.option
val all_but_last : 'a Base.list -> 'a Base.list
val match_regex : Base.string -> Base.string -> Base.bool
val parse_number : Base.string -> number Base.option
val parse_symbol : Base.Sexp.t -> symbol Base.option
val parse_fpexpr : argument Base.list -> Base.Sexp.t -> fpexpr Base__Option.t
val parse_dim : Base.Sexp.t -> dimension Base.option
val parse_data : Base.Sexp.t -> data Base.option
val parse_property :
  Base.Sexp.t Base.list -> property Base.list * Base.Sexp.t Base.list
val parse_arg : Base.Sexp.t -> argument Base.option
val parse_args : Base.Sexp.t -> argument Base.list
val string_join_list : Base.String.t list -> Base.String.t -> Base.String.t
val print_argument : argument -> symbol
val wrap_paren : Base.String.t -> Base.String.t
val print_optional_sym : Base.String.t option -> Base.String.t
val print_num : number -> Base.string
val print_data : data -> symbol
val print_property : Base.String.t * data -> Base.String.t
val print_op : operation -> Base.string
val print_fpexpr : fpexpr -> Base.string
val print_fpcore :
  Base.String.t option * argument Base.List.t *
  (Base.String.t * data) Base.List.t * fpexpr -> Base.String.t
val parse_fpcore : Base.Sexp.t -> fpcore Base.option
