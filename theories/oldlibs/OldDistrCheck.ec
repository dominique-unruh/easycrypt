(* -------------------------------------------------------------------- *)
require import AllCore Distr StdRing StdOrder.
(*---*) import RField RealOrder.

lemma mu_bounded (d : 'a distr) (p : 'a -> bool) :
  0%r <= mu d p <= 1%r by rewrite mu_bounded.

lemma mu_false (d : 'a distr): mu d pred0 = 0%r by rewrite mu0.

(* mu_sub from Distr *)
lemma mu_sub (d : 'a distr) (p q : 'a -> bool) :
  p <= q => mu d p <= mu d q by move => ?; rewrite mu_sub.

lemma mu_supp_in (d:'a distr) p :
  mu d p = mu d predT <=>
  support d <= p.
proof.
split => [|supportP]; 1: by smt(mu_in_weight).
rewrite weightE_support; smt(mu_eq_support).
qed.

lemma mu_or (d : 'a distr) (p q : 'a -> bool) :
  mu d (predU p q) = mu d p + mu d q - mu d (predI p q) by rewrite mu_or.

lemma pw_eq (d d' : 'a distr) : (forall p, mu d p = mu d' p) <=> d = d'
  by smt(eq_distr).

(* Not needed and not sure it holds as it relies on the fact that
   weight d = weight d'
lemma uniform_unique (d d' : 'a distr):
  support d = support d' =>
  is_uniform d  =>
  is_uniform d' =>
  d = d'.
*)

(** Lemmas *)
(* witness_support from Distr *)
lemma witness_nzero P (d:'a distr):
  0%r < mu d P => (exists x, P x ).
proof.
  have: P <> pred0 => (exists x, P x).
    apply absurd=> /=.
    have -> h: (!exists (x:'a), P x) = forall (x:'a), !P x by smt.
    by apply fun_ext=> x; rewrite h.
  smt.
qed.

lemma ew_eq (d d':'a distr):
  (forall p, mu d p = mu d' p) => d = d'.
proof.
move=> ew_eq; rewrite -pw_eq=> x.
by rewrite ew_eq.
qed.

lemma nosmt mu_or_le (d:'a distr) (p q:'a -> bool) r1 r2:
  mu d p <= r1 => mu d q <= r2 =>
  mu d (predU p q) <= r1 + r2 by smt.

(* mu_and *)
lemma nosmt mu_and  (d:'a distr) (p q:'a -> bool):
  mu d (predI p q) = mu d p + mu d q - mu d (predU p q) by smt.

lemma nosmt mu_and_le_l (d:'a distr) (p q:'a -> bool) r:
  mu d p <= r =>
  mu d (predI p q) <= r.
proof.
apply (ler_trans (mu d p)).
by apply mu_sub; rewrite /predI=> x.
qed.

lemma nosmt mu_and_le_r (d:'a distr) (p q:'a -> bool) r :
  mu d q <= r =>
  mu d (predI p q) <= r.
proof.
apply (ler_trans (mu d q)).
by apply mu_sub; rewrite /predI=> x.
qed.

lemma mu_supp (d:'a distr):
  mu d (support d) = mu d predT.
proof. by rewrite mu_supp_in. qed.

lemma mu_eq (d:'a distr) (p q:'a -> bool):
  p == q => mu d p = mu d q.
proof.
by move=> ext_p_q; congr=> //; apply fun_ext.
qed.

lemma mu_disjoint (d:'a distr) (p q:('a -> bool)):
  (predI p q) <= pred0 =>
  mu d (predU p q) = mu d p + mu d q.
proof.
move=> and_p_q_false; rewrite mu_or.
have ->: (predI p q) = pred0 by apply subpred_asym.
by rewrite mu_false.
qed.

lemma mu_not (d:'a distr) (p:('a -> bool)):
  mu d (predC p) = mu d predT - mu d p.
proof.
have: mu d (predC p) + mu d p = mu d predT; [rewrite -mu_disjoint | smt].
  (* rewrite seems to unroll too much *)
+ by rewrite predCI; apply/(subpred_refl<:'a> pred0).
+ by rewrite predCU.
qed.

lemma mu_split (d:'a distr) (p q:('a -> bool)):
  mu d p = mu d (predI p q) + mu d (predI p (predC q)).
proof.
rewrite -mu_disjoint; first smt.
by apply mu_eq=> x; rewrite /predI /predC /predU !(andbC (p x)) orDandN.
qed.

lemma mu_support (p:('a -> bool)) (d:'a distr):
  mu d p = mu d (predI p (support d)).
proof.
apply/ler_anti; split => [|_]; last by apply/mu_sub/predIsubpredl.
have ->: forall (p q:'a -> bool), (predI p q) = predC (predU (predC p) (predC q)).
  by (move=> p1 p2; apply fun_ext; delta; smt). (* delta *)
by rewrite mu_not mu_or !mu_not mu_supp; smt.
qed.

lemma witness_support P (d:'a distr):
  0%r < mu d P <=> (exists x, P x /\ 0%r < mu1 d x).
proof.
split=> [|[] x [x_in_P x_in_d]].
  rewrite mu_support=> nzero.
  apply witness_nzero in nzero; case nzero=> x.
  rewrite /predI //= => p_supp.
  by exists x.
have: mu d (pred1 x) <= mu d P /\ 0%r < mu d (pred1 x); last smt.
split=> [|//=].
by rewrite mu_sub // /Core.(<=) /pred1 => x0 <<-.
qed.

lemma mu_sub_support (d:'a distr) (p q:('a -> bool)):
  (predI p (support d)) <= (predI q (support d)) =>
  mu d p <= mu d q.
proof.
by move=> ple_p_q; rewrite (mu_support p) (mu_support q);
   apply mu_sub.
qed.

lemma mu_eq_support (d:'a distr) (p q:('a -> bool)):
  (predI p (support d)) = (predI q (support d)) =>
  mu d p = mu d q.
proof.
by move=> eq_supp;
   rewrite (mu_support p) (mu_support q);
   apply mu_eq; rewrite eq_supp.
qed.

lemma weight_0_mu (d:'a distr):
  weight d = 0%r => forall p, mu d p = 0%r by smt.

lemma mu_one (P:'a -> bool) (d:'a distr):
  P == predT =>
  weight d = 1%r =>
  mu d P = 1%r.
proof.
move=> heq <-.
congr=> //.
by apply fun_ext.
qed.
