Require Import Reals Reals.Reals Reals.RIneq Reals.Rdefinitions.
Local Open Scope R_scope.

(* A module for a floating point precision representation with error parameter delta. *)
Module NumberExpr.
  Parameter delta: R.

  (* Type of error (could be sigma type of reals below a delta)*)
  Definition error : Type := { x : R | Rabs x <= Rabs delta }.
  (* Delta can be positive or negative, because we take the absolute value.
     This is the same as forcing delta to be non-negative; however, it's a
     little more annoying to model this in Coq. *)

  (* Real-valued expressions, no error whatsoever. *)
  Inductive exprR : Type :=
    | injR : R -> exprR
    | addR : exprR -> exprR -> exprR
    | subR : exprR -> exprR -> exprR
    | mulR : exprR -> exprR -> exprR.

  Fixpoint real_eval (exp : exprR) : R :=
    match exp with
      | injR r => r
      | addR a b => real_eval a + real_eval b
      | subR a b => real_eval a - real_eval b
      | mulR a b => real_eval a * real_eval b
    end.

  (* Floating point expressions, which take in an error bounded by delta in each
     step. *)
  Inductive exprF : Type :=
    | injF : error ->
             R -> exprF
    | addF : error ->
             exprF -> exprF -> exprF
    | subF : error ->
             exprF -> exprF -> exprF
    | mulF : error ->
             exprF -> exprF -> exprF.

  (* Evaluating our floats without error *)
  Fixpoint float_ideal_eval (exp : exprF) : R :=
    match exp with
      | injF _ r => r
      | addF _ a b => float_ideal_eval a + float_ideal_eval b
      | subF _ a b => float_ideal_eval a - float_ideal_eval b
      | mulF _ a b => float_ideal_eval a * float_ideal_eval b
    end.

  (* Evaluating our floats with roundoff error *)
  Fixpoint float_round_eval (exp : exprF) : R :=
    match exp with
      | injF err r => r * (1 + proj1_sig err)
      | addF err a b =>
          (float_round_eval a + float_round_eval b) * (1 + proj1_sig err)
      | subF err a b =>
          (float_round_eval a - float_round_eval b) * (1 + proj1_sig err)
      | mulF err a b =>
          (float_round_eval a * float_round_eval b) * (1 + proj1_sig err)
    end.

  (* Our paired representation, as well as expressions on pairs. *)
  Notation P := (exprF * exprF).

  Definition convertR (x : R * R) : R :=
    match x with
      | (a, b) => a - b
    end.

  (* Helper lemma, which is helpful to register in the hint database. *)
  Lemma rabs_zero_leq_everything : forall a, Rabs 0 <= Rabs a.
  Proof.
    intros.
    unfold Rabs.
    destruct Rcase_abs.
    * apply Rlt_irrefl in r. contradiction.
    * destruct Rcase_abs; auto with real.
  Defined.
  Hint Resolve rabs_zero_leq_everything: real.
  Obligation Tactic := Tactics.program_simpl; auto with real.

  Program Fixpoint convertF (x : exprF * exprF) : exprF :=
    match x with
      | (a, b) => subF 0 a b
    end.

  Inductive exprP : Type :=
    | injP : error ->
             R -> exprP
    | addP : error -> error ->
             exprP -> exprP -> exprP
    | subP : error -> error ->
             exprP -> exprP -> exprP
    | mulP : error -> error -> error -> error -> error -> error ->
             exprP -> exprP -> exprP.

  (* Should be the same as ideal_eval when composed with sub *)
  Fixpoint paired_ideal_eval (exp : exprP) : (R * R) :=
    match exp with
      | injP _ r =>
          match Rlt_le_dec r 0 with
            | left _ => (0, - r)
            | right _ => (r, 0)
          end
      | addP _ _ a b =>
          let '((x1, y1) , (x2, y2)) := (paired_ideal_eval a, paired_ideal_eval b) in
          (x1 + x2, y1 + y2)
      | subP _ _ a b =>
          let '((x1, y1) , (x2, y2)) := (paired_ideal_eval a, paired_ideal_eval b) in
          (x1 + y2, x2 + y1)
      | mulP _ _ _ _ _ _ a b =>
          let '((x1, y1) , (x2, y2)) := (paired_ideal_eval a, paired_ideal_eval b) in
          (x1 * x2 + y1 * y2, x1 * y2 + y1 * x2)
    end.

  Program Fixpoint paired_round_eval (exp : exprP) : (exprF * exprF) :=
    match exp with
      | injP e r =>
          match Rlt_le_dec r 0 with
            | left _ => (injF 0 0, injF e (-r))
            | right _ => (injF e r, injF 0 0)
          end
      | addP e1 e2 a b =>
          let '((x1, y1) , (x2, y2)) := (paired_round_eval a, paired_round_eval b) in
          (addF e1 x1 x2, addF e2 y1 y2)
      | subP e1 e2 a b =>
          let '((x1, y1) , (x2, y2)) := (paired_round_eval a, paired_round_eval b) in
          (addF e1 x1 y2, addF e2 x2 y1)
      | mulP e1 e2 e3 e4 e5 e6 a b =>
          let '((x1, y1) , (x2, y2)) := (paired_round_eval a, paired_round_eval b) in
          (addF e2 (mulF e1 x1 x2) (mulF e3 y1 y2), addF e5 (mulF e4 x1 y2) (mulF e6 y1 x2))
    end.

  (* Some sanity check theorems to make sure everything is set up reasonably.
     First, we strip the error terms for exprF and exprP. *)
  Fixpoint ignore_error_f (f : exprF) : exprR :=
    match f with
      | injF _ r => injR r
      | addF _ a b => addR (ignore_error_f a) (ignore_error_f b)
      | subF _ a b => subR (ignore_error_f a) (ignore_error_f b)
      | mulF _ a b => mulR (ignore_error_f a) (ignore_error_f b)
    end.

  Fixpoint ignore_error_p (p : exprP) : exprR :=
    match p with
      | injP _ r => injR r
      | addP _ _ a b => addR (ignore_error_p a) (ignore_error_p b)
      | subP _ _ a b => subR (ignore_error_p a) (ignore_error_p b)
      | mulP _ _ _ _ _ _ a b => mulR (ignore_error_p a) (ignore_error_p b)
    end.

  (* This theorem checks that converting a paired expression to a floating
     expression by throwing away the error terms is the same as evaluating under
     the ideal paired semantics. *)
  Theorem ideal_p_evals_equiv : forall p,
      real_eval (ignore_error_p p) = convertR (paired_ideal_eval p).
  Proof.
    intros.
    induction p.
    * simpl. destruct (Rlt_le_dec r 0).
      - simpl. ring_simplify. reflexivity.
      - simpl. ring_simplify. reflexivity.
    * simpl. rewrite IHp1. rewrite IHp2.
      remember (paired_ideal_eval p1) as n.
      remember (paired_ideal_eval p2) as m.
      unfold convertR.
      destruct n. destruct m.
      ring_simplify.
      reflexivity.
    * simpl. rewrite IHp1. rewrite IHp2.
      remember (paired_ideal_eval p1) as n.
      remember (paired_ideal_eval p2) as m.
      unfold convertR.
      destruct n. destruct m.
      ring_simplify.
      reflexivity.
    * simpl. rewrite IHp1. rewrite IHp2.
      remember (paired_ideal_eval p1) as n.
      remember (paired_ideal_eval p2) as m.
      unfold convertR.
      destruct n. destruct m.
      ring_simplify.
      reflexivity.
  Defined.
End NumberExpr.
