open EcUtils

(* ==================================================================== *)
module type PrinterAPI = sig
  (* ------------------------------------------------------------------ *)
  open EcIdent
  open EcSymbols
  open EcPath
  open EcTypes
  open EcFol
  open EcDecl
  open EcModules
  open EcTheory

  (* ------------------------------------------------------------------ *)
  module PPEnv : sig
    type t

    val ofenv : EcEnv.env -> t
    val add_locals : ?force:bool -> t -> EcIdent.t list -> t
  end

  (* ------------------------------------------------------------------ *)
  type prpo_display = { prpo_pr : bool; prpo_po : bool; }

  (* ------------------------------------------------------------------ *)
  val string_of_cpos1 : EcParsetree.codepos1 -> string

  (* ------------------------------------------------------------------ *)
  val pp_pv      : PPEnv.t -> prog_var pp
  val pp_local   : ?fv:Sid.t -> PPEnv.t -> ident pp
  val pp_opname  : PPEnv.t -> path pp
  val pp_funname : PPEnv.t -> xpath pp
  val pp_topmod  : PPEnv.t -> mpath pp
  val pp_expr    : PPEnv.t -> expr pp
  val pp_form    : PPEnv.t -> form pp
  val pp_type    : PPEnv.t -> ty pp
  val pp_tyname  : PPEnv.t -> path pp
  val pp_axname  : PPEnv.t -> path pp
  val pp_scname  : PPEnv.t -> path pp
  val pp_tcname  : PPEnv.t -> path pp
  val pp_thname  : PPEnv.t -> path pp

  val pp_mem      : PPEnv.t -> EcIdent.t pp
  val pp_memtype  : PPEnv.t -> EcMemory.memtype pp
  val pp_tyvar    : PPEnv.t -> ident pp
  val pp_tyunivar : PPEnv.t -> EcUid.uid pp
  val pp_path     : path pp

  (* ------------------------------------------------------------------ *)
  val pp_typedecl    : PPEnv.t -> (path * tydecl                  ) pp
  val pp_opdecl      : ?long:bool -> PPEnv.t -> (path * operator  ) pp
  val pp_added_op    : PPEnv.t -> operator pp
  val pp_axiom       : ?long:bool -> PPEnv.t -> (path * axiom     ) pp
  val pp_schema      : ?long:bool -> PPEnv.t -> (path * ax_schema ) pp
  val pp_theory      : PPEnv.t -> (path * ctheory                 ) pp
  val pp_restr_s     :            (bool                           ) pp
  val pp_restr       : PPEnv.t -> (mod_restr                      ) pp
  val pp_modtype1    : PPEnv.t -> (module_type                    ) pp
  val pp_modtype     : PPEnv.t -> (module_type                    ) pp
  val pp_modexp      : PPEnv.t -> (mpath * module_expr            ) pp
  val pp_moditem     : PPEnv.t -> (mpath * module_item            ) pp
  val pp_modsig      : ?long:bool -> PPEnv.t -> (path * module_sig) pp
  val pp_modsig_smpl : PPEnv.t -> (path * module_smpl_sig         ) pp

  (* ------------------------------------------------------------------ *)
  val pp_hoareS   : PPEnv.t -> ?prpo:prpo_display -> sHoareS  pp
  val pp_choareS  : PPEnv.t -> ?prpo:prpo_display -> cHoareS  pp
  val pp_bdhoareS : PPEnv.t -> ?prpo:prpo_display -> bdHoareS pp
  val pp_equivS   : PPEnv.t -> ?prpo:prpo_display -> equivS  pp

  val pp_cost      : PPEnv.t -> cost pp
  val pp_proc_cost : PPEnv.t -> proc_cost pp

  val pp_stmt  : ?lineno:bool -> PPEnv.t -> stmt pp
  val pp_instr : PPEnv.t -> instr pp

  (* ------------------------------------------------------------------ *)
  type ppgoal = (EcBaseLogic.hyps * EcFol.form) * [
    | `One of int
    | `All of (EcBaseLogic.hyps * EcFol.form) list
  ]

  val pp_hyps : PPEnv.t -> EcEnv.LDecl.hyps pp
  val pp_goal : PPEnv.t -> prpo_display -> ppgoal pp

  (* ------------------------------------------------------------------ *)
  module ObjectInfo : sig
    type db = [`Rewrite of qsymbol | `Solve of symbol]

    val pr_ty  : Format.formatter -> EcEnv.env -> qsymbol -> unit
    val pr_op  : Format.formatter -> EcEnv.env -> qsymbol -> unit
    val pr_th  : Format.formatter -> EcEnv.env -> qsymbol -> unit
    val pr_ax  : Format.formatter -> EcEnv.env -> qsymbol -> unit
    val pr_sc  : Format.formatter -> EcEnv.env -> qsymbol -> unit
    val pr_mod : Format.formatter -> EcEnv.env -> qsymbol -> unit
    val pr_mty : Format.formatter -> EcEnv.env -> qsymbol -> unit
    val pr_rw  : Format.formatter -> EcEnv.env -> qsymbol -> unit
    val pr_at  : Format.formatter -> EcEnv.env -> symbol -> unit
    val pr_db  : Format.formatter -> EcEnv.env -> db -> unit
    val pr_any : Format.formatter -> EcEnv.env -> qsymbol -> unit
  end
end

(* ==================================================================== *)
module Registry : sig
  val register : (module PrinterAPI) -> unit
  val get : unit -> (module PrinterAPI)
end = struct
  let printer : (module PrinterAPI) option ref =
    ref None

  let register (m : (module PrinterAPI)) : unit =
    printer := Some m

  let get () : (module PrinterAPI) =
    EcUtils.oget !printer
end
