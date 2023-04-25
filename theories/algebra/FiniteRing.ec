(* ==================================================================== *)
require import AllCore List Ring Int IntMin IntDiv RingStruct Finite.
require import FinType ZModP UnitRing.
require import Bigalg SubRing RingModule Real RealExp Quotient Counting.
require (*--*) Subtype.
(*---*) import StdOrder.IntOrder.


(* ==================================================================== *)
abstract theory SubFinite.
  type t, st.

  clone import FinType as TFT with
    type t <= t.

  clone import Subtype as Sub with
    type T  <= t ,
    type sT <= st.

  import Sub.

  clone import FinType as SFT with
    type t  <= st.

  theory SFin.
    (*TODO: Pierre-Yves: I thought because P is a pred it can't be used as an op in filter.
                         We need to replace pred by op everywhere in the StdLib anyway. *)
    lemma eq_enum : perm_eq SFT.enum (map insubd (filter P TFT.enum)).
    proof.
      apply/uniq_perm_eq; [by apply/SFT.enum_uniq| |].
      + apply/map_inj_in_uniq; [|by apply/filter_uniq/TFT.enum_uniq].
        move=> x y; rewrite !mem_filter => -[] Px _ [] Py _.
        by move/(congr1 val); rewrite !val_insubd Px Py.
      move=> x; rewrite SFT.enumP /= mapP; exists (val x).
      by rewrite valKd /= mem_filter valP TFT.enumP.
    qed.

    lemma eq_card : SFT.card = size (filter P TFT.enum).
    proof. by move: (perm_eq_size _ _ eq_enum); rewrite size_map. qed.
  end SFin.
end SubFinite.


(* -------------------------------------------------------------------- *)
abstract theory SubFiniteSub.
  type t, st.

  clone import FinType as TFT with
    type t <= t.

  clone import Subtype as Sub with
    type T  <= t ,
    type sT <= st.

  clone include SubFinite with
    type t      <- t,
    type st     <- st,
    theory TFT  <- TFT,
    theory Sub  <- Sub,
    op SFT.enum <= (choiceb (fun e => forall x , count (pred1 x) e = 1) witness)
    rename [theory] "TFT" as "Gone"
                    "Sub" as "Gone"
  proof SFT.enum_spec.

  realize SFT.enum_spec.
  proof.
    pose Q:= (fun e => forall x , count (pred1 x) e = 1).
    move: (choicebP Q witness _); last first.
    + (*TODO: Pierre-Yves: spooky, the following asserts false:*)
      (*rewrite /Q; move=> + x. move/(_ x).*)
      by move=> + x; move/(_ x).
    rewrite /Q => {Q}; exists (map insubd (filter P TFT.enum)).
    move => x; rewrite /senum count_map count_filter /predI /preim.
    rewrite -(enum_spec (val x)); apply/eq_count.
    move => y; rewrite /pred1 /=; split => [[<<- in_sub_y]|->>].
    + by rewrite val_insubd in_sub_y.
    by rewrite valKd /= valP.
  qed.
end SubFiniteSub.


(* ==================================================================== *)
abstract theory FiniteZModule.
  clone include ZModuleStruct.

  clone import FinType.FinType as FT with
    type t <= t.

  theory FZMod.
    import RL ZModStr FT.

    lemma gt0_order x :
      0 < order x.
    proof.
      case/ler_eqVlt: (ge0_order x) => // /eq_sym /order0P => inj_intmul.
      by have //: false; move: inj_intmul => /=; apply/not_injective_int.
    qed.
  
    import StdBigop.Bigint.
  
    lemma dvd_order_card x :
      order x %| FT.card.
    proof.
      have /(_ FT.enum):
        forall s , exists c ,
          uniq c /\
          (forall y z , y \in c => z \in c => eqv_orbit x y z => y = z) /\
          (mem s <= mem (flatten (map (fun y => map (RL.(+) y) (orbit_list x)) c))).
      + elim => [|y s [c] IHs]; [by exists [] => /=; rewrite flatten_nil|].
        move: IHs; pose l:= flatten _; case (y \in l) => [mem_y|Nmem_y];
        move => [uniq_ [forall_ mem_incl]].
        - by exists c; split => //; split => // z /= [->>|]; [apply/mem_y|apply/mem_incl].
        exists (y :: c); do!split => // [|z t|z] /=; [|move => [->>|mem_z] [->>|mem_t] //|].
        - move: Nmem_y; apply/contra; rewrite /l => {l mem_incl} mem_y; apply/flatten_mapP.
          exists y; split => //=; apply/mapP; exists zeror; rewrite addr0 /=.
          by apply/orbit_listP; rewrite ?gt0_order // orbit0.
        - rewrite /eqv_orbit orbit_listP ?gt0_order //; move: Nmem_y; rewrite /l -flatten_mapP.
          rewrite negb_exists => /= /(_ t); rewrite mem_t /= mapP negb_exists /= => /(_ (y - t)).
          by rewrite addrA addrAC subrr /= add0r.
        - rewrite eqv_orbit_sym /eqv_orbit orbit_listP ?gt0_order //.
          move: Nmem_y; rewrite /l -flatten_mapP.
          rewrite negb_exists => /= /(_ z); rewrite mem_z /= mapP negb_exists /= => /(_ (y - z)).
          by rewrite addrA addrAC subrr /= add0r.
        - by apply/forall_.
        rewrite flatten_cons -/l mem_cat; case => [->>|?]; [left|by right; apply/mem_incl].
        apply/mapP; exists zeror; rewrite addr0 /=.
        by apply/orbit_listP; rewrite ?gt0_order // orbit0.
      case => c; pose l:= flatten _; move => [uniq_ [forall_ mem_incl]].
      rewrite /card (perm_eq_size _ l).
      + apply/uniq_perm_eq; [by apply/FT.enum_uniq| |]; last first.
        - by move => ?; split; [apply/mem_incl|move => _; apply/FT.enumP].
        rewrite /l => {mem_incl l}; apply/uniq_flatten_map => //.
        - move => y /=; rewrite map_inj_in_uniq; [by move => ? ? _ _; apply/addrI|].
          by apply/uniq_orbit_list.
        move => y z mem_y mem_z /= /hasP [?] [] /mapP [t] [mem_t ->>] /mapP [u] [mem_u].
        move=> eq_.
        apply/forall_ => //; move: eq_; rewrite /eqv_orbit addrC -eqr_sub => <-.
        by apply/orbitB; apply/orbit_listP => //; apply/gt0_order.
      rewrite /l size_flatten sumzE (BIA.eq_big_seq _ (fun _ => order x)) /=.
      + move => ? /mapP [?] [+ ->>]; move => /mapP [?] /= [_ ->>].
        by rewrite size_map size_orbit_list.
      by rewrite BIA.sumr_const count_predT !size_map intmulz; apply/dvdz_mulr/dvdzz.
    qed.
  
    lemma isgeneratorP g :
      is_generator g <=> order g = card.
    proof.
      rewrite /is_generator -size_orbit_list; split => [orbit_|].
      + apply/perm_eq_size/uniq_perm_eq; [by apply/uniq_orbit_list|by apply/enum_uniq|].
        by move => x; rewrite -orbit_listP ?gt0_order // orbit_ enumP.
      move => eq_ x; move: (uniq_leq_size_perm_eq (orbit_list g) enum).
      rewrite orbit_listP ?gt0_order // uniq_orbit_list enum_uniq eq_ /card /= => /(_ _).
      + by move => ? _; apply/enumP.
      by move/perm_eq_mem => ->; apply/enumP.
    qed.
  
    op eq_order d x = order x = d.
  
    lemma few_small_order_exists_generator :
      (forall d , 0 <= d => d %| card =>
        size (to_seq (fun x => RL.intmul x d = zeror)) <= d) =>
      exists g , is_generator g.
    proof.
      move => forall_.
      have: forall d , 0 <= d => d %| card => size (to_seq (eq_order d)) <= phi (d).
      + move => d /ler_eqVlt [<<- _|lt0d dvdd_]; [rewrite phi_eq0 //|].
        - apply/size_le0/mem_eq0 => x; rewrite mem_to_seq; [by apply/is_finite_pred|].
          by rewrite /eq_order; apply/gtr_eqF/gt0_order.
        move: (size_ge0 (to_seq (eq_order d))).
        case /ler_eqVlt => [/eq_sym/size_eq0 ->/=|]; [by apply/phi_ge0|].
        rewrite -has_predT hasP => -[x] [mem_ _]; move: (sum_phi _ lt0d) => eq_d.
        move: (forall_ _ _ dvdd_); [by apply/ltzW|].
        move: mem_; rewrite mem_to_seq; [by apply/is_finite_pred|].
        move => eq_order_x; move: (size_orbit_list x); rewrite eq_order_x.
        move => eq_size_d; rewrite -{2}eq_size_d uniq_leq_size_perm_eq.
        - by apply/uniq_orbit_list.
        - by apply/uniq_to_seq.
        - move => ?; rewrite -orbit_listP ?gt0_order // => -[n] ->>.
          rewrite mem_to_seq /=; [by apply/is_finite_pred|].
          by rewrite -mulrM mulrC mulrM -eq_order_x intmul_order mul0i.
        move => eq_; move/perm_eq_size: eq_ (eq_); rewrite size_orbit_list eq_sym.
        move => eq_; move: eq_ (gt0_order x) => <-; rewrite ltrNge size_le0.
        pose P y := _ y _ = _; move => neq_; move: (to_seq_infinite P).
        move: neq_ => -> /=; rewrite /P => {P} is_finite_.
        move/(perm_eq_filter (eq_order d))/perm_eq_sym => eq_.
        move: (perm_eq_trans _ (to_seq (eq_order d)) _ _ eq_).
        - apply/uniq_perm_eq.
          * by apply/uniq_to_seq.
          * by apply/filter_uniq/uniq_to_seq.
          move => y; rewrite mem_to_seq ?is_finite_pred // mem_filter.
          rewrite -{1}(andbT (eq_order _ _)); apply/andb_id2l.
          rewrite eq_sym eqT => eq_order_y; rewrite mem_to_seq //=.
          by rewrite -eq_order_y; apply/intmul_order.
        move/perm_eq_size => ->; apply/lerr_eq; rewrite /phi.
        rewrite -(size_map (intmul x)); apply/perm_eq_size/uniq_perm_eq.
        - by apply/filter_uniq/uniq_orbit_list.
        - rewrite map_inj_in_uniq; [|by apply/coprimes_uniq].
          move => y z /coprimesP [copdy memy] /coprimesP [copdz memz].
          move/dvd2_order; rewrite -(IntID.subr_add2r (-1)) => /eq_mod.
          rewrite !modz_small ?gtr0_norm ?gt0_order //
            ?eq_order_x -?mem_range ?mem_range_subr //.
          by apply/IntID.addIr.
        move => y; rewrite mem_filter !mapP /=; split => [[eq_order_z] [z] [+ ->>]|].
        - rewrite range_iota /= => mem_; exists ((z - 1) %% d + 1); rewrite -eq_order_x.
          rewrite mulrSz intmul_modz_order -mulrSz /=; apply/coprimesP.
          rewrite mem_range_addr /=; split; last first.
          * by rewrite -{1}(gtr0_norm _ (gt0_order x)); apply/mem_range_mod/gtr_eqF/gt0_order.
          case/ltzE/ler_eqVlt: (gt0_order x) => [<-|gt1_orderx]; [by apply/coprime1z|].
          rewrite modz_small /=.
          * apply/mem_range; rewrite gtr0_norm ?gt0_order //; apply/mem_range_subr => /=.
            move: mem_; rewrite range_ltn ?gt0_order //=; case => [->>|]; last first.
            + by apply/mem_range_incl => //; apply/ltzW/ltzS.
            move: eq_order_z eq_order_x; rewrite mulr0z /eq_order order0 => <<-.
            by rewrite gtr_eqF.
          move: eq_order_z; rewrite /eq_order order_intmul ?gt0_order // -eq_order_x.
          rewrite -eqz_mul ?gcd_eq0 //=.
          * by apply/negb_and; rewrite gtr_eqF //; apply/gt0_order.
          rewrite eq_sym -subr_eq0 -mulN1r mulrC -mulrDl mulf_eq0 subr_eq0.
          by rewrite (gtr_eqF _ _ (gt0_order x)) /coprime.
        move => [z] [/coprimesP [coprimedz memz] ->>]; split.
        - by rewrite /eq_order order_intmul_coprime ?gt0_order // eq_order_x.
        exists (z %% d); rewrite range_iota /= -eq_order_x -{1}(gtr0_norm _ (gt0_order x)).
        by rewrite mem_range_mod ?gtr_eqF ?gt0_order //= intmul_modz_order.
      move => {forall_} forall_; move: (sum_phi _ card_gt0).
      move: (perm_eq_flatten_filter (fun d x => eq_order d x) enum (divisors card) _).
      + move => x _; rewrite count_filter; apply/count_eq1_eq; rewrite /predI.
        exists (order x) => /=; do!split.
        - apply/mem_range; rewrite -ltzS -ltr_subl_addr gt0_order /= ltzS.
          rewrite -(gtr0_norm (order _)) ?gt0_order // -(gtr0_norm card) ?card_gt0 //.
          by apply/dvdz_le; [apply/gtr_eqF/card_gt0|apply/dvd_order_card].
        - by apply/dvd_order_card.
        move => y; rewrite rem_filter ?range_uniq //.
        by rewrite mem_filter /predC1 /eq_order eq_sym; case => ->.
      move/perm_eq_size; rewrite {3}/card => ->; rewrite size_flatten sumzE.
      rewrite !BIA.big_mapT; move/lerr_eq => le_; move: (ler_ge_sum_eq_seq _ _ _ _ _ le_).
      + move => d /divisorsP [dvdd_ memd] _; rewrite /(\o) /=; move: (forall_ _ _ dvdd_).
        - by move:memd; apply/mem_range_le.
        apply/ler_trans/lerr_eq/perm_eq_size/uniq_perm_eq.
        - by apply/filter_uniq/enum_uniq.
        - by apply/uniq_to_seq.
        move => x; rewrite mem_filter /= mem_to_seq; [by apply/is_finite_pred|].
        by rewrite enumP.
      move => /(_ card _ _).
      + by apply/divisors_id/card_gt0.
      + by rewrite /predT.
      rewrite /(\o) /= => eq_; move: (phi_gt0 card _).
      + by apply/ltzS/ltr_subl_addr/card_gt0.
      move: eq_ => <- /has_predT; rewrite has_filter predTI => /hasP [g] [_] /= eq_.
      by exists g; apply/isgeneratorP; move: eq_; rewrite /eq_order.
    qed.
  end FZMod.
end FiniteZModule.

(* -------------------------------------------------------------------- *)
abstract theory FiniteComRing.
  clone include ComRingStruct.

  clone include FiniteZModule with
    type t         <- t,
    theory RL      <- RL,
    theory ZModStr <- ZModStr
    rename [theory] "RL"  as "Gone"
                    "Str" as "Gone".

  theory FCR.
    import FT RL ZModStr CRStr FZMod.

    lemma card_gt1: 1 < FT.card.
    proof.
      rewrite /card ltzE /=; have <-: size [RL.zeror; RL.oner] = 2 by trivial.
      apply/uniq_leq_size => //=; [by rewrite eq_sym; apply/RL.oner_neq0|].
      by move => ? _; apply/enumP.
    qed.

    lemma gt0_char :
      0 < char.
    proof. by rewrite /char; apply/gt0_order. qed.

    lemma gt1_char :
      1 < char.
    proof. by move/ltzE/ler_eqVlt: gt0_char; rewrite eq_sym /= neq1_char. qed.
  end FCR.
end FiniteComRing.

(* -------------------------------------------------------------------- *)
abstract theory FiniteIDomain.
  clone include IDomainStruct.

  clone include FiniteComRing with
    type t         <- t,
    theory RL      <- RL,
    theory ZModStr <- ZModStr,
    theory CRStr   <- CRStr
    rename [theory] "RL"  as "Gone"
                    "Str" as "Gone".

  theory FID.
    import FT RL ZModStr CRStr IDStr FZMod FCR.

    lemma prime_char :
      prime char.
    proof. by case: char_integral => // eq0; move: gt0_char; rewrite eq0. qed.
  
    lemma frobenius_surj :
      surjective frobenius.
    proof.
      move: (frobenius_inj prime_char) => inj_ x.
      move: (uniq_map_injective _ _ inj_ enum_uniq) => uniq_.
      move: (uniq_leq_size_perm_eq _ _ uniq_ enum_uniq _).
      + by move => ? _; apply/enumP.
      rewrite size_map /= => /perm_eq_mem /(_ x); rewrite enumP /=.
      by move => /mapP [y] [_ ->>]; exists y.
    qed.
  
    lemma frobenius_bij :
      bijective frobenius.
    proof.
      by apply/bij_inj_surj; split; [apply/frobenius_inj/prime_char|apply/frobenius_surj].
    qed.
  
    lemma frobenius_cr_auto :
      cr_auto frobenius.
    proof.
      by split; [apply/frobenius_surj|apply/frobenius_cr_mono_endo/prime_char].
    qed.
  
    lemma cr_auto_iter_frobenius n :
      cr_auto (iter n frobenius).
    proof. by apply/cr_auto_iter/frobenius_cr_auto. qed.
  end FID.
end FiniteIDomain.

(* -------------------------------------------------------------------- *)
abstract theory FiniteField.
  clone include FieldStruct.

  clone include FiniteIDomain with
    type t         <- t,
    theory RL      <- RL,
    theory ZModStr <- ZModStr,
    theory CRStr   <- CRStr,
    theory IDStr   <- IDStr
    rename [theory] "RL"      as "Gone"
                    "ZModStr" as "Gone"
                    "CRStr"   as "Gone"
                    "IDStr"   as "FiniteFieldFiniteIDomainIDStrGone"
                    "FStr"    as "FiniteFieldFiniteIDomainFStrGone".

  clone include UZMod_Field with
    type t         <- t,
    theory RL      <- RL,
    theory ZModStr <- ZModStr,
    theory CRStr   <- CRStr,
    theory IDStr   <- IDStr,
    theory FStr    <- FStr
    rename [theory] "RL"      as "Gone"
                    "ZModStr" as "Gone"
                    "CRStr"   as "Gone"
                    "IDStr"   as "FiniteFieldUZMod_FieldIDStrGone"
                    "FStr"    as "FiniteFieldUZMod_FieldFStrGone".

  clone include FiniteZModule with
    type t         <- uz,
    theory RL      <- UZL,
    theory ZModStr <- UStr,
    op FT.enum     <= map USt.insubd (filter (predC1 RL.zeror) FT.enum)
    rename [theory] "RL"      as "Gone"
                    "ZModStr" as "Gone"
                    "FT"      as "FUT"
                    "FZMod"   as "FUZMod"
  proof *.

  realize FUT.enum_spec.
  proof.
    move=> u; rewrite count_map count_filter.
    rewrite (eq_count _ (pred1 (USt.val u))).
    + move=> x; rewrite /predI /predC1 /pred1 /preim /=.
      rewrite RL.unitfE; split=> [[] <<- ux|->>].
      - by rewrite USt.val_insubd ux.
      by rewrite USt.valKd USt.valP.
    rewrite count_uniq_mem ?FT.enum_uniq //.
    by apply/b2i_eq1/FT.enumP.
  qed.

  theory FF.
    import FT RL ZModStr CRStr IDStr FStr FZMod FCR FID.
    import UZL UStr USt FUT FUZMod.
  
    lemma card_unit :
      FT.card = FUT.card + 1.
    proof.
      rewrite /card (perm_eq_size  _ _ (perm_to_rem _ _ (FT.enumP RL.zeror))) /=.
      rewrite addrC; congr; rewrite -(size_map USt.val); apply/perm_eq_size/uniq_perm_eq.
      + by apply/rem_uniq/FT.enum_uniq.
      + by apply/uniq_map_injective; [apply/USt.val_inj|apply/FUT.enum_uniq].
      move => x; case: (x = RL.zeror) => [->>|neqx0].
      + rewrite rem_filter ?FT.enum_uniq // mem_filter /predC1 /= mapP.
        rewrite negb_exists /= => u; rewrite FUT.enumP /= eq_sym.
        by apply/negP; move/(congr1 unit); rewrite valP unitr0.
      rewrite mem_rem_neq // 1?eq_sym // FT.enumP /=; apply/mapP.
      by exists (insubd x); rewrite FUT.enumP /= val_insubd unitfP.
    qed.
  
    lemma exists_generator :
      exists g, UStr.is_generator g.
    proof.
      apply/few_small_order_exists_generator => d.
      case/ler_eqVlt => [<<- /dvd0z|lt0d]; [by move => eq_; move: FUT.card_gt0; rewrite eq_|].
      move => dvdd_; move: (size_to_seq_eq_pow_1 _ lt0d); apply/ler_trans/lerr_eq.
      rewrite -(size_map USt.insubd); apply/perm_eq_size/uniq_perm_eq.
      + by apply/uniq_to_seq.
      + rewrite map_inj_in_uniq; [|by apply/uniq_to_seq].
        move => x y; rewrite !mem_to_seq ?FT.is_finite_pred //.
        move => eqx eqy /(congr1 USt.val); rewrite !USt.insubdK //.
        - by apply/(unitrX_neq0 _ d); [apply/gtr_eqF|rewrite eqx unitr1].
        by apply/(unitrX_neq0 _ d); [apply/gtr_eqF|rewrite eqy unitr1].
      move => x; rewrite mapP mem_to_seq ?FUT.is_finite_pred //=.
      rewrite /eq_pow_1; split => [eq_|[y] [+ ->>]].
      + exists (USt.val x); rewrite USt.valKd /= mem_to_seq ?FT.is_finite_pred //=.
        by rewrite -UZModCR.valX eq_ val_insubd unitr1.
      rewrite mem_to_seq ?FT.is_finite_pred //= => eq_.
      apply/USt.val_inj; rewrite UZModCR.valX UZModCR.val1 USt.insubdK //.
      by apply/(unitrX_neq0 _ d); [apply/gtr_eqF|rewrite eq_ unitr1].
    qed.
  end FF.
end FiniteField.

(* ==================================================================== *)
abstract theory SubFiniteZModule.
  type t.

  clone include SubZModule with
    type t <- t.

  clone include SubFinite with
    type t     <- t,
    type st    <- st,
    theory Sub <- Sub
    rename [theory] "Sub" as "Gone".

  clone include FiniteZModule with
    type t         <- t,
    theory RL      <- TRL,
    theory ZModStr <- ZModTStr,
    theory FT      <- TFT
    rename [theory] "FZMod" as "FZModT".

  clone include FiniteZModule with
    type t         <- st,
    theory RL      <- SRL,
    theory ZModStr <- ZModSStr,
    theory FT      <- SFT
    rename [theory] "FZMod" as "FZModS".
end SubFiniteZModule.

(* -------------------------------------------------------------------- *)
abstract theory SubFiniteComRing.
  type t.

  clone include SubComRingModule with
    type t <- t.

  clone include SubFiniteZModule with
    type t           <- t,
    type st          <- st,
    theory TRL       <- TRL,
    theory SRL       <- SRL,
    theory ZModTStr  <- ZModTStr,
    theory ZModSStr  <- ZModSStr,
    theory ZModMorph <- ZModMorph,
    theory SZMod     <- SZMod,
    theory Sub       <- Sub
    rename [theory] "TRL"   as "Gone"
                    "SRL"   as "Gone"
                    "Str"   as "Gone"
                    "Morph" as "Gone"
                    "SZMod" as "Gone"
                    "Sub"   as "Gone".

  clone include FiniteComRing with
    type t         <- t,
    theory RL      <- TRL,
    theory ZModStr <- ZModTStr,
    theory CRStr   <- CRTStr,
    theory FT      <- TFT,
    theory FZMod   <- FZModT
    rename [theory] "FZMod" as "Gone"
                    "FCR"   as "FCRT".

  clone include FiniteComRing with
    type t         <- st,
    theory RL      <- SRL,
    theory ZModStr <- ZModSStr,
    theory CRStr   <- CRSStr,
    theory FT      <- SFT,
    theory FZMod   <- FZModS
    rename [theory] "FZMod" as "Gone"
                    "FCR"   as "FCRS".

  theory SFCR.
    import TRL SRL ZModTStr ZModSStr CRTStr CRSStr ZModMorph CRMorph SZMod SCR Sub CRM.
    import TFT SFT.

    op enum_lin (vs : t list) =
      map
        (fun ss => lin ss vs)
        (foldr (allpairs (::)) [[]] (nseq (size vs) SFT.enum)).
  
    lemma enum_lin_nil :
      enum_lin [] = [TRL.zeror].
    proof. by rewrite /enum_lin /= nseq0 /= BigMod.big_nil. qed.
  
    lemma enum_lin_cons v vs :
      enum_lin (v :: vs) =
      allpairs TRL.( + ) (map (transpose CRM.( ** ) v) SFT.enum) (enum_lin vs).
    proof.
      rewrite /enum_lin /= addrC nseqS ?size_ge0 //=; pose el := foldr _ _ _.
      elim: SFT.enum el => [|x senum IHsenum] el /=; [by rewrite !allpairs0l|].
      rewrite !allpairs_consl map_cat IHsenum -!map_comp; congr => {IHsenum}.
      by apply/eq_map => xs; rewrite /(\o) /= BigMod.big_cons /predT /idfun.
    qed.
  
    lemma enum_linP vs v :
      (v \in enum_lin vs) <=> (gen (vf_oflist vs) v).
    proof.
      elim: vs v => [|v vs IHvs] w.
      + by rewrite enum_lin_nil gen_vf_oflist_nil.
      rewrite enum_lin_cons gen_vf_oflist_cons allpairsP; split.
      + case => -[v1 v2] /= |> /mapP [s] |> mem_s /IHvs gen_v2.
        by exists s SRL.oner v2; rewrite gen_v2 scale1r.
      case => [s1 s2 w2] /= |> /(gen_scale _ s2) /IHvs mem_w2.
      exists (s1 ** v, s2 ** w2)%CRM; rewrite mem_w2 /=.
      split; last by rewrite /CRM.( ** ).
      by apply/mapP; exists s1 => /=; apply/SFT.enumP.
    qed.
  
    lemma size_enum_lin vs :
      size (enum_lin vs) = SFT.card ^ (size vs).
    proof.
      elim: vs => [|v vs IHvs] /=.
      + by rewrite expr0 enum_lin_nil.
      rewrite addrC exprS ?size_ge0 // -IHvs => {IHvs}.
      rewrite /enum_lin !size_map /= addrC nseqS ?size_ge0 //=.
      by rewrite size_allpairs -/SFT.card.
    qed.
  
    lemma free_uniq_enum_lin vs :
      uniq vs =>
      free (vf_oflist vs) =>
      uniq (enum_lin vs).
    proof.
      elim: vs => [|v vs IHvs]; [by rewrite enum_lin_nil|].
      rewrite free_vf_oflist_cons enum_lin_cons /=.
      move => |> Nmem_v uniq_ imp_eq0 free_.
      rewrite allpairs_mapl; apply/allpairs_uniq.
      + by apply/SFT.enum_uniq.
      + by apply/IHvs.
      move => s1 s2 v1 v2 mem_s1 mem_s2 /enum_linP gen1 /enum_linP gen2 /=.
      rewrite addrC -eqr_sub -scaleNr -scaleDl => eq_.
      move/(_ (s2 + (-s1))%SRL _): imp_eq0.
      + by rewrite -eq_; apply/gen_add => //; apply/gen_opp.
      rewrite SRL.subr_eq0 => ->>; move: eq_.
      by rewrite /= SRL.subrr scale0r TRL.subr_eq0.
    qed.
  
    lemma gen_t_enum_lin vs :
      (gen_t (vf_oflist vs)) <=> (forall v , v \in enum_lin vs).
    proof. by rewrite /gen_t; apply/forall_eq => v /=; apply/eqboolP; rewrite enum_linP. qed.
  end SFCR.
end SubFiniteComRing.

(* -------------------------------------------------------------------- *)
abstract theory SubFiniteIDomain.
  type t.

  clone include SubIDomainModule with
    type t <- t.

  clone include SubFiniteComRing with
    type t           <- t,
    type st          <- st,
    theory TRL       <- TRL,
    theory SRL       <- SRL,
    theory ZModTStr  <- ZModTStr,
    theory ZModSStr  <- ZModSStr,
    theory CRTStr    <- CRTStr,
    theory CRSStr    <- CRSStr,
    theory ZModMorph <- ZModMorph,
    theory CRMorph   <- CRMorph,
    theory SZMod     <- SZMod,
    theory SCR       <- SCR,
    theory CRM       <- CRM,
    theory Sub       <- Sub
    rename [theory] "TRL"   as "Gone"
                    "SRL"   as "Gone"
                    "Str"   as "Gone"
                    "Morph" as "Gone"
                    "SZMod" as "Gone"
                    "SCR"   as "Gone"
                    "CRM"   as "Gone"
                    "Sub"   as "Gone".

  clone include FiniteIDomain with
    type t         <- t,
    theory RL      <- TRL,
    theory ZModStr <- ZModTStr,
    theory CRStr   <- CRTStr,
    theory IDStr   <- IDTStr,
    theory FT      <- TFT,
    theory FZMod   <- FZModT,
    theory FCR     <- FCRT
    rename [theory] "FZMod" as "Gone"
                    "FCR"   as "Gone"
                    "FID"   as "FIDT"
                    "IDStr" as "FiniteIDomainTIDStrGone".

  clone include FiniteIDomain with
    type t         <- st,
    theory RL      <- SRL,
    theory ZModStr <- ZModSStr,
    theory CRStr   <- CRSStr,
    theory IDStr   <- IDSStr,
    theory FT      <- SFT,
    theory FZMod   <- FZModS,
    theory FCR     <- FCRS
    rename [theory] "FZMod" as "Gone"
                    "FCR"   as "Gone"
                    "FID"   as "FIDS"
                    "IDStr" as "FiniteIDomainSIDStrGone".
end SubFiniteIDomain.

(* -------------------------------------------------------------------- *)
abstract theory SubFiniteField.
  type t.

  clone include SubVectorSpace with
    type t <- t.

  clone include SubFiniteIDomain with
    type t           <- t,
    type st          <- st,
    theory TRL       <- TRL,
    theory SRL       <- SRL,
    theory ZModTStr  <- ZModTStr,
    theory ZModSStr  <- ZModSStr,
    theory CRTStr    <- CRTStr,
    theory CRSStr    <- CRSStr,
    theory IDTStr    <- IDTStr,
    theory IDSStr    <- IDSStr,
    theory ZModMorph <- ZModMorph,
    theory CRMorph   <- CRMorph,
    theory IDMorph   <- IDMorph,
    theory SZMod     <- SZMod,
    theory SCR       <- SCR,
    theory SID       <- SID,
    theory CRM       <- CRM,
    theory Sub       <- Sub
    rename [theory] "TRL"       as "Gone"
                    "SRL"       as "Gone"
                    "ZModTStr"  as "Gone"
                    "ZModSStr"  as "Gone"
                    "CRTStr"    as "Gone"
                    "CRSStr"    as "Gone"
                    "IDTStr"    as "SubFiniteFieldIDTStrGone"
                    "IDSStr"    as "SubFiniteFieldIDSStrGone"
                    "IDStr1"    as "SubFiniteFieldIDStr1Gone"
                    "IDStr2"    as "SubFiniteFieldIDStr2Gone"
                    "ZModMorph" as "Gone"
                    "CRMorph"   as "Gone"
                    "IDMorph"   as "SubFiniteFieldIDMorphGone"
                    "SZMod"     as "Gone"
                    "SCR"       as "Gone"
                    "SID"       as "Gone"
                    "CRM"       as "Gone"
                    "Sub"       as "Gone".

  clone include FiniteField with
    type t         <- t,
    theory RL      <- TRL,
    theory ZModStr <- ZModTStr,
    theory CRStr   <- CRTStr,
    theory IDStr   <- IDTStr,
    theory FStr    <- FTStr,
    theory FT      <- TFT,
    theory FZMod   <- FZModT,
    theory FCR     <- FCRT,
    theory FID     <- FIDT
    rename [theory] "FZMod"   as "Gone"
                    "FCR"     as "Gone"
                    "FID"     as "Gone"
                    "FF"      as "FFT"
                    "IDStr"   as "FiniteFieldTIDStrGone"
                    "FStr"    as "FiniteFieldTFStrGone"
                    "UZL"     as "UZLT"
                    "UStr"    as "UTStr"
                    "UFZMod"  as "UFZModT"
                    "USt"    as "UStT"
                    "FUT"     as "FUTT"
                    "UZModCR" as "UZModCRT"
                    "FUZMod"  as "FUZModT"
           [type]   "uz"      as "uzt".

  clone include FiniteField with
    type t         <- st,
    theory RL      <- SRL,
    theory ZModStr <- ZModSStr,
    theory CRStr   <- CRSStr,
    theory IDStr   <- IDSStr,
    theory FStr    <- FSStr,
    theory FT      <- SFT,
    theory FZMod   <- FZModS,
    theory FCR     <- FCRS,
    theory FID     <- FIDS
    rename [theory] "FZMod"   as "Gone"
                    "FCR"     as "Gone"
                    "FID"     as "Gone"
                    "FF"      as "FFS"
                    "IDStr"   as "FiniteFieldSIDStrGone"
                    "FStr"    as "FiniteFieldSFStrGone"
                    "UZL"     as "UZLS"
                    "UStr"    as "USStr"
                    "USt"    as "UStS"
                    "FUT"     as "FUTS"
                    "UZModCR" as "UZModCRS"
                    "FUZMod"  as "FUZModS"
           [type]   "uz"      as "uzs".

  theory SFF.
    import TRL SRL ZModTStr ZModSStr CRTStr CRSStr IDTStr IDSStr FTStr FSStr.
    import ZModMorph CRMorph IDMorph FMorph SZMod SCR SID SFld Sub CRM.
    import TFT SFT SFCR SFin.

    lemma finite_basis_exists :
      exists vs , uniq vs /\ basis (vf_oflist vs).
    proof.
      have /(_ TFT.card):
        forall n , 0 <= n => n <= TFT.card =>
        exists vs , uniq vs /\ free (vf_oflist vs) /\ n <= size (enum_lin vs);
      last first.
      + rewrite size_ge0 /= => -[vs] |> uniq_ free_ lecn.
        exists vs; rewrite uniq_ /basis free_ /= gen_t_enum_lin => v.
        move: lecn; rewrite uniq_leq_size_perm_eq.
        - by apply/free_uniq_enum_lin.
        - by apply/TFT.enum_uniq.
        - by move => ? _; apply/TFT.enumP.
        by move => /perm_eq_mem ->; apply/TFT.enumP.
      elim => [_|n le0n IHn /ltzE ltnc].
      + by exists []; rewrite free_vf_oflist_nil size_ge0.
      case/(_ _): IHn => [|vs |> uniq_ free_]; [by apply/ltzW|].
      move => /ler_eqVlt [->>|ltnp]; [|by exists vs; rewrite -ltzE].
      move/ltzNge: ltnc; rewrite uniq_leq_size_perm_eq.
      + by apply/free_uniq_enum_lin.
      + by apply/TFT.enum_uniq.
      + by move => ? _; apply/TFT.enumP.
      move => Nperm_eq_; move: (uniq_perm_eq (enum_lin vs) TFT.enum _ _).
      + by apply/free_uniq_enum_lin.
      + by apply/TFT.enum_uniq.
      rewrite Nperm_eq_ /= negb_forall /= => -[v]; rewrite TFT.enumP /= => Nmemv.
      exists (v :: vs); rewrite /= free_vf_oflist_cons uniq_ free_ /=; do!split.
      + by move: Nmemv; apply/contra => memv; apply/enum_linP/gen_p.
      + right => s; case: (s = SRL.zeror) => [->> //=|neqs0].
        rewrite -gen_scale_unit -?enum_linP //; apply/unitfP.
        by move: neqs0; apply/contra => ->>; apply/Sub.val_inj; rewrite val0.
      rewrite !size_enum_lin /= -ltzE addrC exprSr ?size_ge0 //.
      rewrite -subr_gt0 -IntID.mulN1r mulrC -IntID.mulrDl; apply/mulr_gt0.
      + by rewrite subr_gt0; apply/FCRS.card_gt1.
      by apply/expr_gt0/SFT.card_gt0.
    qed.
  
    op n = ilog SFT.card TFT.card.
  
    lemma lt0n :
      0 < n.
    proof.
      rewrite /n ltzE /=; move: (ilog_mono SFT.card SFT.card TFT.card).
      rewrite ilog_b FCRS.card_gt1 SFT.card_gt0 /= => -> //.
      by rewrite eq_card size_filter count_size.
    qed.
  
    lemma eq_card_pow_n :
      TFT.card = SFT.card ^ n.
    proof.
      case: finite_basis_exists => vs [uniq_ basis_].
      case: (basis_) => free_ /gen_t_enum_lin mem_e.
      move: (free_uniq_enum_lin _ uniq_ free_) => uniq_e.
      move: (size_enum_lin vs); rewrite /n /SFT.card /TFT.card.
      rewrite (perm_eq_size _ TFT.enum).
      + apply/uniq_perm_eq => // [|x]; [by apply/TFT.enum_uniq|].
        by rewrite TFT.enumP mem_e.
      by move=> ->; rewrite ilog_powK // FCRS.card_gt1.
    qed.
  end SFF.
end SubFiniteField.

(* ==================================================================== *)
abstract theory ZModP_FiniteField.
  type t.

  clone import ZModField as ZModP with
    type zmod <= t.

  (*TODO: Pierre-Yves: issue in ZModP: should be a clone with theory ZModP.ZModpField.*)
  clone import Field as RL with
    type t          <= t,
    op zeror        <= ZModP.zero,
    op oner         <= ZModP.one,
    op (+)          <= ZModP.(+),
    op [-]          <= ZModP.([-]),
    op ( * )        <= ZModP.( * ),
    op invr         <= ZModP.inv,
    pred unit       <= ZModP.unit,
    lemma addrA     <= ZModP.ZModpField.addrA,
    lemma addrC     <= ZModP.ZModpField.addrC,
    lemma add0r     <= ZModP.ZModpField.add0r,
    lemma addNr     <= ZModP.ZModpField.addNr,
    lemma oner_neq0 <= ZModP.ZModpField.oner_neq0,
    lemma mulrA     <= ZModP.ZModpField.mulrA,
    lemma mulrC     <= ZModP.ZModpField.mulrC,
    lemma mul1r     <= ZModP.ZModpField.mul1r,
    lemma mulrDl    <= ZModP.ZModpField.mulrDl,
    lemma mulVr     <= ZModP.ZModpField.mulVr,
    lemma unitP     <= ZModP.ZModpField.unitP,
    lemma unitout   <= ZModP.ZModpField.unitout,
    lemma mulf_eq0  <= ZModP.ZModpField.mulf_eq0,
    lemma unitfP    <= ZModP.ZModpField.unitfP.

  clone include FiniteField with
    type t     <- t,
    theory RL  <- RL,
    op FT.enum <= (choiceb (fun e => forall x , count (pred1 x) e = 1) witness)
    rename [theory] "RL" as "Gone"
  proof FT.enum_spec.

  realize FT.enum_spec.
  proof.
    pose Q:= (fun e => forall x , count (pred1 x) e = 1).
    move: (choicebP Q witness _); last first.
    + (*TODO: Pierre-Yves: spooky, the following asserts false:*)
      (*rewrite /Q; move=> + x. move/(_ x).*)
      by move=> + x; move/(_ x).
    rewrite /Q => {Q}; exists (map inzmod (range 0 p)).
    move => x; rewrite count_uniq_mem ?b2i_eq1.
    + rewrite map_inj_in_uniq ?range_uniq // => m n range_m range_n /eq_inzmod.
      by rewrite !modz_small -?mem_range ?gtr0_norm ?gt0_prime ?prime_p.
    by apply/mapP; exists (asint x); rewrite asintK /=; apply/mem_range/rg_asint.
  qed.

  theory ZModFin.
    import RL ZModStr CRStr CRStr IDStr FStr FT FZMod FF.

    lemma eq_enum : perm_eq FT.enum (map inzmod (range 0 p)).
    proof.
      apply/uniq_perm_eq; [by apply/FT.enum_uniq| |].
      + apply/map_inj_in_uniq; [|by apply/range_uniq].
        move=> x y memx memy /(congr1 asint); rewrite !inzmodK.
        by rewrite !pmod_small // -mem_range.
      move=> x; rewrite FT.enumP /= mapP; exists (asint x).
      by rewrite asintK mem_range rg_asint.
    qed.

    lemma eq_card_p :
      FT.card = p.
    proof.
      rewrite /FT.card; move: (perm_eq_size _ _ eq_enum) => ->.
      by rewrite size_map size_range ler_maxr //=; apply/ltzW/gt0_prime/prime_p.
    qed.

    lemma eq_char_p : CRStr.char = p.
    proof.
      rewrite /CRStr.char -eq_card_p -isgeneratorP.
      move=> x; exists (asint x); move: (perm_eq_mem _ _ eq_enum x).
      rewrite FT.enumP mapP /= => -[y] [] memy ->>.
      rewrite inzmodK -ofint_inzmod modz_small //.
      by rewrite -mem_range gtr0_norm // ltzE ltzW gt1_prime prime_p.
    qed.

    lemma cr_auto_zmod f : cr_auto f <=> f == idfun.
    proof.
      split=> [cra_f x|/fun_ext ->>]; [|by apply/cr_auto_id].
      rewrite /idfun -(asintK x) -ofint_inzmod.
      by rewrite (cr_autoZ _ cra_f) /ofint /intmul.
    qed.
  end ZModFin.
end ZModP_FiniteField.

(* ==================================================================== *)
abstract theory SubFiniteField_ZMod.
  type t, st.

  clone include FiniteField with
    type t <- t
    rename [theory] "RL"      as "TRL"
                    "ZModStr" as "ZModTStr"
                    "CRStr"   as "CRTStr"
                    "IDStr"   as "IDTStr"
                    "FStr"    as "FTStr"
                    "FT"      as "TFT"
                    "FZMod"   as "FZModT"
                    "FCR"     as "FCRT"
                    "FID"     as "FIDT"
                    "FF"      as "FFT"
                    "UZL"     as "UZLT"
                    "UStr"    as "UTStr"
                    "USt"    as "UStT"
                    "FUT"     as "FUTT"
                    "UZModCR" as "UZModCRT"
                    "FUZMod"  as "FUZModT"
           [type]   "uz"      as "uzt".

  clone include ZModP_FiniteField with
    type t <- st,
    op ZModP.p <= CRTStr.char
    rename [theory] "RL"      as "SRL"
                    "ZModStr" as "ZModSStr"
                    "CRStr"   as "CRSStr"
                    "IDStr"   as "IDSStr"
                    "FStr"    as "FSStr"
                    "FT"      as "SFT"
                    "FZMod"   as "FZModS"
                    "FCR"     as "FCRS"
                    "FID"     as "FIDS"
                    "FF"      as "FFS"
                    "UZL"     as "UZLS"
                    "UStr"    as "USStr"
                    "USt"    as "UStS"
                    "FUT"     as "FUTS"
                    "UZModCR" as "UZModCRS"
                    "FUZMod"  as "FUZModS"
           [type]   "uz"      as "uzs"
  proof ZModP.prime_p.

  realize ZModP.prime_p.
  proof. by apply/FIDT.prime_char. qed.

  clone include SubFiniteField with
    type t          <- t,
    type st         <- st,
    type uzt        <- uzt,
    type uzs        <- uzs,
    theory TRL      <- TRL,
    theory ZModTStr <- ZModTStr,
    theory CRTStr   <- CRTStr,
    theory IDTStr   <- IDTStr,
    theory FTStr    <- FTStr,
    theory TFT      <- TFT,
    theory FZModT   <- FZModT,
    theory FCRT     <- FCRT,
    theory FIDT     <- FIDT,
    theory FFT      <- FFT,
    theory UZLT     <- UZLT,
    theory UTStr    <- UTStr,
    theory UStT     <- UStT,
    theory FUTT     <- FUTT,
    theory UZModCRT <- UZModCRT,
    theory FUZModT  <- FUZModT,
    theory SRL      <- SRL,
    theory ZModSStr <- ZModSStr,
    theory CRSStr   <- CRSStr,
    theory IDSStr   <- IDSStr,
    theory FSStr    <- FSStr,
    theory SFT      <- SFT,
    theory FZModS   <- FZModS,
    theory FCRS     <- FCRS,
    theory FIDS     <- FIDS,
    theory FFS      <- FFS,
    theory UZLS     <- UZLS,
    theory USStr    <- USStr,
    theory UStS     <- UStS,
    theory UZModCRS <- UZModCRS,
    theory FUZModS  <- FUZModS,
    theory FUTS     <- FUTS,
    pred Sub.P      <= (fun x => exists n , x = TRL.ofint n),
    op Sub.val      <= TRL.ofint \o ZModP.asint,
    op Sub.insub    <= (fun x => if exists n , x = TRL.ofint n
                                 then Some (ZModP.inzmod
                                             (choiceb (fun n => x = TRL.ofint n) witness))
                                 else None),
    op Sub.wsT      <= TRL.ofint (ZModP.asint witness)
    rename [theory] "TRL"      as "Gone"
                    "ZModTStr" as "Gone"
                    "CRTStr"   as "Gone"
                    "IDTStr"   as "IDTStrGone"
                    "FTStr"    as "FTStrGone"
                    "TFT"      as "Gone"
                    "FZModT"   as "Gone"
                    "FCRT"     as "Gone"
                    "FIDT"     as "Gone"
                    "FFT"      as "Gone"
                    "UZLT"     as "Gone"
                    "UTStr"    as "Gone"
                    "UStT"     as "Gone"
                    "FUTT"     as "Gone"
                    "UZModCRT" as "Gone"
                    "FUZModT"  as "Gone"
                    "SRL"      as "Gone"
                    "ZModSStr" as "Gone"
                    "CRSStr"   as "Gone"
                    "IDSStr"   as "IDSStrGone"
                    "FSStr"    as "FSStrGone"
                    "SFT"      as "Gone"
                    "FZModS"   as "Gone"
                    "FCRS"     as "Gone"
                    "FIDS"     as "Gone"
                    "FFS"      as "Gone"
                    "UZLS"     as "Gone"
                    "USStr"    as "Gone"
                    "UStS"     as "Gone"
                    "FUTS"     as "Gone"
                    "UZModCRS" as "Gone"
                    "FUZModS"  as "Gone"
  proof Sub.*, SZMod.*, SCR.*.

  realize Sub.insubN.
  proof. by move=> x ->. qed.

  realize Sub.insubT.
  proof.
    move => x in_x; rewrite in_x /=; case: in_x => n ->; rewrite /(\o) /=.
    pose P:= (fun x => _ _ = _ x);  move: (choicebP P witness _).
    + by exists n.
    pose m:= choiceb _ _; move: m => m; rewrite /P => {P} -> {n}.
    apply/eq_sym/CRTStr.dvd2_char; rewrite ZModP.inzmodK -divzE.
    by apply/dvdz_mull; rewrite /ZModP.p dvdzz.
  qed.

  realize Sub.valP.
  proof. by rewrite /(\o) /= => x; exists (ZModP.asint x). qed.

  realize Sub.valK.
  proof.
    rewrite /pcancel /insub => x.
    pose P:= (fun n => (\o) TRL.ofint ZModP.asint x = TRL.ofint n).
    have [n]: exists n , P n.
    + by rewrite /P /(\o) => {P}; exists (ZModP.asint x).
    move=> eq_; rewrite ifT; [by exists n; rewrite eq_|].
    move: (choicebP P witness _); [by exists n; rewrite eq_|].
    rewrite /P => {P eq_ n}; pose y:= choiceb _ _; move: y => y.
    rewrite /(\o) -CRTStr.dvd2_char -/ZModP.p eq_mod modz_small.
    + rewrite gtr0_norm; [by apply/ltzE/ltzW/gt1_prime/ZModP.prime_p|].
      by apply/ZModP.rg_asint.
    case: (ZModP.eq_inzmod y (y %% ZModP.p)) => + _.
    move=> ->; [|by move=> <-; rewrite ZModP.asintK].
    by rewrite modz_mod.
  qed.

  realize Sub.insubW.
  proof.
    rewrite ifT; [by exists (ZModP.asint witness)|congr].
    pose P:= (fun n => (\o) TRL.ofint ZModP.asint witness = TRL.ofint n).
    move: (choicebP P witness _); rewrite /P /(\o) /= => {P}.
    + by exists (ZModP.asint witness).
    pose c := choiceb _ _; move: c => c.
    rewrite -CRTStr.dvd2_char dvdzP; case=> q.
    rewrite subr_eq addrC -subr_eq => <<-.
    by rewrite -mulNr ZModP.inzmod_mod modzMDr -ZModP.inzmod_mod ZModP.asintK.
  qed.

  realize SZMod.val0.
  proof. by rewrite /morphism_0 /(\o) ZModP.zeroE TRL.ofint0. qed.

  realize SZMod.valD.
  proof.
    move=> x y; rewrite /(\o) ZModP.addE -TRL.addrz eq_sym -CRTStr.dvd2_char.
    by rewrite -divzE dvdz_mull dvdzz.
  qed.

  realize SCR.val1.
  proof. by rewrite /morphism_0 /(\o) ZModP.oneE TRL.ofint1. qed.

  realize SCR.valM.
  proof.
    move=> x y; rewrite /(\o) ZModP.mulE TRL.mulrz eq_sym -CRTStr.dvd2_char.
    by rewrite -divzE dvdz_mull dvdzz.
  qed.

  theory FinZMod.
    import TRL SRL ZModTStr ZModSStr CRTStr CRSStr IDTStr IDSStr FTStr FSStr.
    import ZModMorph CRMorph IDMorph FMorph SZMod SCR SID SFld Sub CRM.
    import TFT SFT SFCR SFin FFT.

    lemma iter_frobenius_fixed_n :
      IDTStr.iter_frobenius_fixed SFF.n = predT.
    proof.
      apply/fun_ext => x; rewrite /predT eqT iter_frobenius_fixedP.
      + by apply/ltzW/SFF.lt0n.
      case (x = TRL.zeror) => [->>|/unitfP ux].
      + by rewrite expr0z gtr_eqF // expr_gt0 FCRT.gt0_char.
      rewrite -ZModFin.eq_card_p -SFF.eq_card_pow_n card_unit.
      move: (UStT.val_insubd x); rewrite ux /= => <-.
      move: (UStT.insubd _) => {x ux} x; rewrite -UZModCRT.valX.
      rewrite UZLT.mulrSz UZModCRT.valM -{2}(TRL.mulr1 (UStT.val _)).
      congr; case: (FFT.exists_generator) => g is_g_g.
      case/(_ x): (is_g_g) => n ->>; rewrite -UZLT.mulrM.
      rewrite mulrC UZLT.mulrM; move/FUZModT.isgeneratorP: is_g_g => <-.
      by rewrite UTStr.intmul_order UZLT.mul0i UZModCRT.val1.
    qed.

    lemma cr_auto_exp f :
      CRTStr.cr_auto f =>
      (exists k , 0 < k /\ forall x , f x = exp x k).
    proof.
      case: exists_generator => g isg_g cra_f.
      move: (isg_g (UStT.insubd (f (UStT.val g)))).
      case => k eq_; exists (k %% FUTT.card + FUTT.card).
      apply/and_impr; split; [apply/ltzE/ler_add|].
      + by apply/modz_ge0/gtr_eqF/FUTT.card_gt0.
      + by apply/ltzS/ltr_subl_addr/FUTT.card_gt0.
      move => lt0_ x; case (TRL.unit x) => [unitx|]; last first.
      + rewrite -TRL.unitfE /= => ->>; rewrite cr_auto0 //.
        by rewrite expr0z gtr_eqF.
      move/(congr1 UStT.val): eq_; rewrite UStT.insubdK.
      + apply/TRL.unitrE; rewrite -cr_autoV // -cr_autoM //.
        by rewrite divrr; [apply/UStT.valP|rewrite cr_auto1].
      rewrite -UTStr.intmul_modz_order -modz_mod -modzDr UTStr.intmul_modz_order.
      move/FUZModT.isgeneratorP: (isg_g) => ->; rewrite UZModCRT.valX.
      case/(_ (UStT.insubd x)): isg_g => i /(congr1 UStT.val).
      rewrite UStT.insubdK // UZModCRT.valX => ->>.
      by rewrite cr_autoX // => ->; rewrite -!exprM mulrC.
    qed.

(*TODO: must be in PolyFiniteRing, comes after proving existence of irreducible polynomial for any SubField.*)
(*
    lemma cr_autoP f :
      CRTStr.cr_auto f <=>
      (exists k, k \in range 0 SFF.n /\ f == iter k IDTStr.frobenius).
    proof.
      split=> [|[k] [_ /fun_ext ->>]]; last first.
      + by apply/FIDT.cr_auto_iter_frobenius.
      move=> cra_f; case/cr_auto_exp: (cra_f) => k [] lt0k eqf_.
      have:
        exists k ,
          k \in range 0 SFF.n /\
          (forall x , f x = exp x (CRTStr.char ^ k));
      last first.
      + case=> {k lt0k eqf_} k [] mem_k eqf_; exists k; split=> // x.
        by rewrite eqf_ IDTStr.iter_frobenius //; move: mem_k; apply/mem_range_le.
      case/prime_divisors: (lt0k) => ps kps.
      move: (is_pdec_pow_count_Ndvd (CRTStr.char) _ _ ZModP.prime_p kps).
      move: (is_pdec_pow_count_dvd (CRTStr.char) _ _ ZModP.prime_p kps).
      case/dvdzP => q ->> {kps}; move: lt0k; rewrite pmulr_lgt0.
      + by apply/expr_gt0/FCRT.gt0_char.
      move=> lt0q; rewrite exprS ?count_ge0 // dvdz_mulIf.
      + by apply/gtr_eqF/expr_gt0/FCRT.gt0_char.
      move=> Ndvd_; move: (FIDT.cr_auto_iter_frobenius (count (pred1 CRTStr.char) ps)).
      move=> cra_; case/CRTStr.cr_auto_inv: cra_ => g [] can_g [] cang_ cra_g.
      move: (CRTStr.cr_auto_comp _ _ cra_f cra_g); pose h:= f \o g.
      move=> cra_h; have eqh_: forall x , h x = exp x q.
      + move=> x; rewrite /h /(\o) eqf_ mulrC exprM.
        by move/(_ x): cang_; rewrite iter_frobenius ?count_ge0 // => ->.
      have: cr_auto (insubd \o h \o val).
      + split; [|apply/SCR.cr_mono_endo_sub]; first last.
        - by move=> x; rewrite eqh_; apply/PX.
        - by apply/CRTStr.cr_auto_mono_endo.
        move=> x; rewrite /(\o); case: (Bachet_Bezout CRTStr.char q) => u v.
        case: (gcd_prime _ q FIDT.prime_char); last first.
        - by move: (dvdz_gcdr CRTStr.char q) => + eq_; rewrite eq_.
        move=> ->; rewrite addrC eq_sym -IntID.subr_eq eq_sym -mulNr addrC => eq_.
        exists (exp x v); rewrite /val SF.valX -/val eqh_ -exprM; move: eq_ => ->.
        move: h eqh_ cra_h => h eqh_ cra_h {g can_g cang_ cra_g}.
        case: (x = SRL.zeror) => [->>|/SRL.unitfP ux].
        - rewrite /val SZMod.val0 expr0z ifF; [|by rewrite SZMod.insubd0].
          apply/negP => /(congr1 (transpose (%%) CRTStr.char)) /=.
          by rewrite modzMDl modz_small //= ltr_normr FCRT.gt1_char.
        rewrite exprD ?valU // expr1 SCR.insubdM ?PX /val ?valP // -/val.
        rewrite valKd; case: FFS.exists_generator => g isg_g; move: (isg_g).
        case/(_ (UStS.insubd x)) => n /(congr1 UStS.val).
        rewrite UStS.val_insubd ux /= => ->>; rewrite USZModCR.valX.
        rewrite -SF.valX -exprM mulrA -!USZModCR.valX -ZModFin.eq_card_p.
        move/FUSZMod.isgeneratorP: isg_g.
        admit.
      admit.
    qed.
*)
  end FinZMod.
end SubFiniteField_ZMod.


(* ==================================================================== *)
abstract theory SubFiniteZModulePred.
  clone include SubZModulePred.

  clone include SubFiniteSub with
    type t  <- t,
    type st <- st,
    theory Sub <- Sub
    rename [theory] "Sub" as "Gone".

  clone include SubFiniteZModule with
    type t           <- t,
    type st          <- st,
    theory TRL       <- TRL,
    theory SRL       <- SRL,
    theory ZModTStr  <- ZModTStr,
    theory ZModSStr  <- ZModSStr,
    theory ZModMorph <- ZModMorph,
    theory SZMod     <- SZMod,
    theory TFT       <- TFT,
    theory SFT       <- SFT,
    theory Sub       <- Sub,
    theory SFin      <- SFin
    rename [theory] "TRL"       as "Gone"
                    "SRL"       as "Gone"
                    "ZModTStr"  as "Gone"
                    "ZModSStr"  as "Gone"
                    "ZModMorph" as "Gone"
                    "SZMod"     as "Gone"
                    "TFT"       as "Gone"
                    "SFT"       as "Gone"
                    "Sub"       as "Gone"
                    "SFin"      as "Gone".
end SubFiniteZModulePred.

(* -------------------------------------------------------------------- *)
abstract theory SubFiniteComRingPred.
  clone include SubComRingPred.

  clone include SubFiniteSub with
    type t  <- t,
    type st <- st,
    theory Sub <- Sub
    rename [theory] "Sub" as "Gone".

  clone include SubFiniteComRing with
    type t           <- t,
    type st          <- st,
    theory TRL       <- TRL,
    theory SRL       <- SRL,
    theory ZModTStr  <- ZModTStr,
    theory ZModSStr  <- ZModSStr,
    theory CRTStr    <- CRTStr,
    theory CRSStr    <- CRSStr,
    theory ZModMorph <- ZModMorph,
    theory CRMorph   <- CRMorph,
    theory SZMod     <- SZMod,
    theory SCR       <- SCR,
    theory TFT       <- TFT,
    theory SFT       <- SFT,
    theory Sub       <- Sub,
    theory SFin      <- SFin
    rename [theory] "TRL"       as "Gone"
                    "SRL"       as "Gone"
                    "ZModTStr"  as "Gone"
                    "ZModSStr"  as "Gone"
                    "CRTStr"    as "Gone"
                    "CRSStr"    as "Gone"
                    "ZModMorph" as "Gone"
                    "CRMorph"   as "Gone"
                    "SZMod"     as "Gone"
                    "SCR"       as "Gone"
                    "TFT"       as "Gone"
                    "SFT"       as "Gone"
                    "Sub"       as "Gone"
                    "SFin"      as "Gone".
end SubFiniteComRingPred.

(* -------------------------------------------------------------------- *)
abstract theory SubFiniteIDomainPred.
  clone include SubIDomainPred.

  clone include SubFiniteSub with
    type t  <- t,
    type st <- st,
    theory Sub <- Sub
    rename [theory] "Sub" as "Gone".

  clone include SubFiniteIDomain with
    type t           <- t,
    type st          <- st,
    theory TRL       <- TRL,
    theory SRL       <- SRL,
    theory ZModTStr  <- ZModTStr,
    theory ZModSStr  <- ZModSStr,
    theory CRTStr    <- CRTStr,
    theory CRSStr    <- CRSStr,
    theory IDTStr    <- IDTStr,
    theory IDSStr    <- IDSStr,
    theory ZModMorph <- ZModMorph,
    theory CRMorph   <- CRMorph,
    theory IDMorph   <- IDMorph,
    theory SZMod     <- SZMod,
    theory SCR       <- SCR,
    theory SID       <- SID,
    theory TFT       <- TFT,
    theory SFT       <- SFT,
    theory Sub       <- Sub,
    theory SFin      <- SFin
    rename [theory] "TRL"       as "Gone"
                    "SRL"       as "Gone"
                    "ZModTStr"  as "Gone"
                    "ZModSStr"  as "Gone"
                    "CRTStr"    as "Gone"
                    "CRSStr"    as "Gone"
                    "IDTStr"    as "SubFiniteFieldPredIDTStrGone"
                    "IDSStr"    as "SubFiniteFieldPredIDSStrGone"
                    "IDStr1"    as "SubFiniteFieldPredIDStr1Gone"
                    "IDStr2"    as "SubFiniteFieldPredIDStr2Gone"
                    "IDGone"    as "SubFiniteFieldPredIDGone"
                    "IDGone1"   as "SubFiniteFieldPredIDGone1"
                    "IDGone2"   as "SubFiniteFieldPredIDGone2"
                    "FTStr"     as "Gone"
                    "FSStr"     as "Gone"
                    "ZModMorph" as "Gone"
                    "CRMorph"   as "Gone"
                    "IDMorph"   as "SubFiniteFieldPredIDMorphGone"
                    "FMorph"    as "SubFiniteFieldPredFMorphGone"
                    "SZMod"     as "Gone"
                    "SCR"       as "Gone"
                    "SID"       as "Gone"
                    "SFld"      as "Gone"
                    "TFT"       as "Gone"
                    "SFT"       as "Gone"
                    "Sub"       as "Gone"
                    "SFin"      as "Gone".
end SubFiniteIDomainPred.

(* -------------------------------------------------------------------- *)
abstract theory SubFiniteFieldPred.
  clone include SubFieldPred.

  clone include SubFiniteSub with
    type t  <- t,
    type st <- st,
    theory Sub <- Sub
    rename [theory] "Sub" as "Gone".

  clone include SubFiniteField with
    type t           <- t,
    type st          <- st,
    theory TRL       <- TRL,
    theory SRL       <- SRL,
    theory ZModTStr  <- ZModTStr,
    theory ZModSStr  <- ZModSStr,
    theory CRTStr    <- CRTStr,
    theory CRSStr    <- CRSStr,
    theory IDTStr    <- IDTStr,
    theory IDSStr    <- IDSStr,
    theory FTStr     <- FTStr,
    theory FSStr     <- FSStr,
    theory ZModMorph <- ZModMorph,
    theory CRMorph   <- CRMorph,
    theory IDMorph   <- IDMorph,
    theory FMorph    <- FMorph,
    theory SZMod     <- SZMod,
    theory SCR       <- SCR,
    theory SID       <- SID,
    theory SFld      <- SFld,
    theory TFT       <- TFT,
    theory SFT       <- SFT,
    theory Sub       <- Sub,
    theory SFin      <- SFin
    rename [theory] "TRL"       as "Gone"
                    "SRL"       as "Gone"
                    "ZModTStr"  as "Gone"
                    "ZModSStr"  as "Gone"
                    "CRTStr"    as "Gone"
                    "CRSStr"    as "Gone"
                    "IDTStr"    as "SubFiniteFieldPredIDTStrGone"
                    "IDSStr"    as "SubFiniteFieldPredIDSStrGone"
                    "IDStr1"    as "SubFiniteFieldPredIDStr1Gone"
                    "IDStr2"    as "SubFiniteFieldPredIDStr2Gone"
                    "IDGone"    as "SubFiniteFieldPredIDGone"
                    "IDGone1"   as "SubFiniteFieldPredIDGone1"
                    "IDGone2"   as "SubFiniteFieldPredIDGone2"
                    "FTStr"     as "Gone"
                    "FSStr"     as "Gone"
                    "ZModMorph" as "Gone"
                    "CRMorph"   as "Gone"
                    "IDMorph"   as "SubFiniteFieldPredIDMorphGone"
                    "FMorph"    as "SubFiniteFieldPredFMorphGone"
                    "SZMod"     as "Gone"
                    "SCR"       as "Gone"
                    "SID"       as "Gone"
                    "SFld"      as "Gone"
                    "TFT"       as "Gone"
                    "SFT"       as "Gone"
                    "Sub"       as "Gone"
                    "SFin"      as "Gone".
end SubFiniteFieldPred.


(* ==================================================================== *)
theory SubFiniteIDomainFrobenius.
  type t, st.

  clone include FiniteIDomain with
    type t <- t
    rename [theory] "RL"      as "TRL"
                    "Str"     as "TStr"
                    "FT"      as "TFT"
                    "FZMod"   as "FZModT"
                    "FCR"     as "FCRT"
                    "FID"     as "FIDT".

  op n : int.

  clone include SubFiniteIDomainPred with
    type t          <- t,
    type st         <- st,
    theory TRL      <- TRL,
    theory ZModTStr <- ZModTStr,
    theory CRTStr   <- CRTStr,
    theory IDTStr   <- IDTStr,
    theory TFT      <- TFT,
    theory FZModT   <- FZModT,
    theory FCRT     <- FCRT,
    theory FIDT     <- FIDT,
    pred Sub.P      <- IDTStr.iter_frobenius_fixed n
    rename [theory] "TRL"      as "Gone"
                    "TStr"     as "Gone"
                    "TFT"      as "Gone"
                    "FZModT"   as "Gone"
                    "FCRT"     as "Gone"
                    "FIDT"     as "Gone"
  proof subcrP.

  realize subcrP.
  proof. by apply/IDTStr.subcr_iter_frobenius_fixed/FIDT.prime_char. qed.
end SubFiniteIDomainFrobenius.

(* -------------------------------------------------------------------- *)
theory SubFiniteFieldFrobenius.
  type t, st.

  clone include FiniteField with
    type t <- t
    rename [theory] "RL"      as "TRL"
                    "Str"     as "TStr"
                    "FT"      as "TFT"
                    "FZMod"   as "FZModT"
                    "FCR"     as "FCRT"
                    "FID"     as "FIDT"
                    "FF"      as "FFT"
                    "UZL"     as "UZLT"
                    "UStr"    as "UTStr"
                    "USt"     as "UStT"
                    "FUT"     as "FUTT"
                    "UZModCR" as "UZModCRT"
                    "FUZMod"  as "FUZModT"
           [type]   "uz"      as "uzt".

  op n : int.

  clone include SubFiniteFieldPred with
    type t          <- t,
    type st         <- st,
    type uzt        <- uzt,
    theory TRL      <- TRL,
    theory ZModTStr <- ZModTStr,
    theory CRTStr   <- CRTStr,
    theory IDTStr   <- IDTStr,
    theory FTStr    <- FTStr,
    theory TFT      <- TFT,
    theory FZModT   <- FZModT,
    theory FCRT     <- FCRT,
    theory FIDT     <- FIDT,
    theory FFT      <- FFT,
    theory UZLT     <- UZLT,
    theory UTStr    <- UTStr,
    theory UStT     <- UStT,
    theory FUTT     <- FUTT,
    theory UZModCRT <- UZModCRT,
    theory FUZModT  <- FUZModT,
    pred Sub.P      <- IDTStr.iter_frobenius_fixed n
    rename [theory] "TRL"      as "Gone"
                    "ZModTStr" as "Gone"
                    "CRTStr"   as "Gone"
                    "IDTStr"   as "SubFiniteFieldFrobeniusIDTStrGone"
                    "IDStr1"   as "SubFiniteFieldFrobeniusIDStr1Gone"
                    "IDStr2"   as "SubFiniteFieldFrobeniusIDStr2Gone"
                    "IDGone"   as "SubFiniteFieldFrobeniusIDGone"
                    "FTStr"    as "Gone"
                    "TFT"      as "Gone"
                    "FZModT"   as "Gone"
                    "FCRT"     as "Gone"
                    "FIDT"     as "Gone"
                    "FFT"      as "Gone"
                    "UZLT"     as "Gone"
                    "UTStr"    as "Gone"
                    "UStT"     as "Gone"
                    "FUTT"     as "Gone"
                    "UZModCRT" as "Gone"
                    "FUZModT"  as "Gone"
  proof subfP.

  realize subfP.
  proof. by apply/FTStr.subf_iter_frobenius_fixed/FIDT.prime_char. qed.
end SubFiniteFieldFrobenius.

