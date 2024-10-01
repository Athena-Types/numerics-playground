Require Import Reals Reals.Reals Reals.RIneq Reals.Rdefinitions.
Local Open Scope R_scope.
Require Import Lra.

(* A module for a floating point precision representation with error parameter delta. *)
Module NumberExpr.
  Parameter delta: R.

  (* Type of error (could be sigma type of reals below a delta)*)
  Definition error : Type := { x : R | Rabs x <= Rabs delta }.
  (* Delta can be positive or negative, because we take the absolute value.
     This is the same as forcing delta to be non-negative; however, it's a
     little more annoying to model this in Coq. *)

  (** * Defining expressions *)

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

  Program Definition err0 : error := 0.

  Program Fixpoint convertF (x : exprF * exprF) : exprF :=
    match x with
      | (a, b) => subF err0 a b
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

  Fixpoint paired_round_eval (exp : exprP) : (exprF * exprF) :=
    match exp with
      | injP e r =>
          match Rlt_le_dec r 0 with
            | left _ => (injF err0 0, injF e (-r))
            | right _ => (injF e r, injF err0 0)
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

  Fixpoint zero_errors_P (exp : exprP) : exprP :=
  match exp with
    | injP _ r => injP err0 r
    | subP _ _ a b=> subP err0 err0 (zero_errors_P a) (zero_errors_P b)
    | addP _ _ a b => addP err0 err0 (zero_errors_P a) (zero_errors_P b)
    | mulP _ _ _ _ _ _ a b =>
        mulP err0 err0 err0 err0 err0 err0 (zero_errors_P a) (zero_errors_P b)
  end.

  (* Proof that when we have zero errors when rounding, it is equivalent to the
     ideal computation *)
  Theorem zero_errors_when_rounding_is_ideal : forall p,
      float_round_eval (convertF (paired_round_eval (zero_errors_P p))) =
        convertR (paired_ideal_eval p).
  Proof.
    intros.
    induction p.
    * simpl.
      destruct (Rlt_le_dec r 0); simpl; field_simplify_eq; reflexivity.
    * unfold paired_ideal_eval. fold paired_ideal_eval.
      unfold convertR in *.
      remember (paired_ideal_eval p1) as n. remember (paired_ideal_eval p2) as m.
      destruct n. destruct m.
      replace (r + r1 - (r0 + r2)) with ((r - r0) + (r1-r2))
        by (field_simplify_eq; reflexivity).
      rewrite <- IHp1. rewrite <- IHp2.
      simpl.
      remember (paired_round_eval (zero_errors_P p1)) as n'.
      remember (paired_round_eval (zero_errors_P p2)) as m'.
      destruct n'. destruct m'.
      simpl.
      field_simplify.
      reflexivity.
    * unfold paired_ideal_eval. fold paired_ideal_eval.
      unfold convertR in *.
      remember (paired_ideal_eval p1) as n. remember (paired_ideal_eval p2) as m.
      destruct n. destruct m.
      replace (r + r2 - (r1 + r0)) with ((r - r0) - (r1-r2))
        by (field_simplify_eq; reflexivity).
      rewrite <- IHp1. rewrite <- IHp2.
      simpl.
      remember (paired_round_eval (zero_errors_P p1)) as n'.
      remember (paired_round_eval (zero_errors_P p2)) as m'.
      destruct n'. destruct m'.
      simpl.
      field_simplify.
      reflexivity.
    * unfold paired_ideal_eval. fold paired_ideal_eval.
      unfold convertR in *.
      remember (paired_ideal_eval p1) as n. remember (paired_ideal_eval p2) as m.
      destruct n. destruct m.
      replace (r * r1 + r0 * r2 - (r * r2 + r0 * r1)) with ((r - r0) * (r1-r2))
        by (field_simplify_eq; reflexivity).
      rewrite <- IHp1. rewrite <- IHp2.
      simpl.
      remember (paired_round_eval (zero_errors_P p1)) as n'.
      remember (paired_round_eval (zero_errors_P p2)) as m'.
      destruct n'. destruct m'.
      simpl.
      field_simplify.
      reflexivity.
  Defined.

  (** * Defining absolute error, relative error, and relative precision metrics *)

  (* Below are definitions for the absolute error between rounded and ideal
     computations, for both float and paired expressions respectively *)
  Definition abs_errorF (f : exprF) : R :=
    Rabs (
        float_round_eval f -
        real_eval (ignore_error_f f)
      ).

  Definition abs_errorP (p : exprP) : R :=
    Rabs (
        float_round_eval (convertF (paired_round_eval p)) -
        real_eval (ignore_error_p p)
      ).

  (* Here is an equivalent definition of abs_errorP, using abs_errorF. *)
  Definition abs_errorP_alt (p : exprP) : R :=
    abs_errorF (convertF (paired_round_eval p)).

  (* Proof that [abs_errorP] and [abs_errorP_alt] are pointwise equal. *)
  Theorem abs_errorP_equiv : forall p, abs_errorP p = abs_errorP_alt p.
  Proof.
    intro.
    unfold abs_errorP. unfold abs_errorP_alt.
    unfold abs_errorF.
    f_equal.
    f_equal.
    induction p; simpl.
    * destruct (Rlt_le_dec r 0); simpl; field_simplify_eq; reflexivity.
    * remember (paired_round_eval p1) as n.
      remember (paired_round_eval p2) as m.
      destruct n. destruct m.
      rewrite IHp1. rewrite IHp2.
      simpl.
      field_simplify_eq.
      reflexivity.
    * remember (paired_round_eval p1) as n.
      remember (paired_round_eval p2) as m.
      destruct n. destruct m.
      rewrite IHp1. rewrite IHp2.
      simpl.
      field_simplify_eq.
      reflexivity.
    * remember (paired_round_eval p1) as n.
      remember (paired_round_eval p2) as m.
      destruct n. destruct m.
      rewrite IHp1. rewrite IHp2.
      simpl.
      field_simplify_eq.
      reflexivity.
  Defined.

  (* TODO: add relative metrics. *)

  (** * Bounding worst-case errors between representations *)

  (* First, we need a definition for what it means for two floating and paired
     expressions to be equivalent (ignoring error). *)
  Fixpoint f_p_equiv (f : exprF) (p : exprP) : Prop :=
    match (f, p) with
      | (injF _ r1, injP _ r2) => r1 = r2
      | (addF _ e1 e2, addP _ _ e3 e4) => f_p_equiv e1 e3 /\ f_p_equiv e2 e4
      | (subF _ e1 e2, subP _ _ e3 e4) => f_p_equiv e1 e3 /\ f_p_equiv e2 e4
      | (mulF _ e1 e2, mulP _ _ _ _ _ _ e3 e4) => f_p_equiv e1 e3 /\ f_p_equiv e2 e4
      | _ => False
    end.
  Ltac distribute :=
        repeat
          (try rewrite ->! Rmult_plus_distr_r;
           try rewrite ->! Rmult_plus_distr_l).

  Theorem abs_error_bounds_hold : forall f, exists p, f_p_equiv f p /\ abs_errorF f <= abs_errorP p.
  Proof.
    intros.
    induction f.
    * exists (injP e r). simpl.
      split; auto.
      rewrite abs_errorP_equiv.
      unfold abs_errorP_alt.
      simpl.
      destruct (Rlt_le_dec r 0); unfold convertF; unfold abs_errorF.
      - assert (real_eval (ignore_error_f (injF e r))
                =
                real_eval (ignore_error_f (subF err0 (injF err0 0) (injF e (- r)))))
        by (simpl; field_simplify_eq; reflexivity).
        rewrite H. simpl.
        right. f_equal.
        field_simplify_eq. reflexivity.
      - assert (real_eval (ignore_error_f (injF e r))
                =
                real_eval (ignore_error_f (subF err0 (injF err0 0) (injF e (- r)))))
        by (simpl; field_simplify_eq; reflexivity).
        rewrite H. simpl.
        right. f_equal.
        field_simplify_eq. reflexivity.
    * destruct IHf1. destruct IHf2.
      exists (addP e err0 x x0).
      destruct H. destruct H0.
      split.
      - simpl. auto.
      - rewrite abs_errorP_equiv in *.
        unfold abs_errorP_alt in *.
        simpl.
        remember (paired_round_eval x).
        remember (paired_round_eval x0).
        destruct p. destruct p0.
        unfold convertF.
        unfold abs_errorF in *.
        simpl in *.
        replace (1 + 0) with 1 in * by lra.
        assert (forall x : R, x * 1 = x) by (auto with real).
        rewrite ->! H3 in *.
        distribute.
        replace ((float_round_eval f1 + float_round_eval f2) * (1 + proj1_sig e))
                  with ((float_round_eval f1 + float_round_eval f2) + ((float_round_eval f1 + float_round_eval f2) * proj1_sig e))
        by lra.
        distribute.
        give_up.
    Admitted.
End NumberExpr.
