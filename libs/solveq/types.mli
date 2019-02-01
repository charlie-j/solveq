open Monalg
open Core

(* Abstract types for abelian group or ring *)
type var = int

type group = 
  | Zero
  | Opp of group
  | Add of group*group
  | Var of var

type ring =
  | ZeroR
  | UnitR
  | OppR of ring
  | AddR of ring*ring
  | MultR of ring*ring
  | InvR of ring
  | VarR of var

exception NoInv

(* Types for polynoms in normal form over IntField *)

module R = IntField   (* module for fields elements *)

type pvar = String.t

val pvar_of_var : ?pref:string -> var -> pvar

val var_of_pvar : pvar -> var

module V : (Monalg.Var with type t = pvar)   (* module for variables *)

module X : sig  (* module for monomials *)
  type t = Monalg.Multinom(V).t
  val unit : t
  val ( *@ ) : t -> t -> t
  val eq : t Core.Ord.eq
  val compare : t Core.Ord.comp
  val getpow : t -> V.t -> int
  val ofvar : V.t -> t
  val ofmap : int Core.Map.Make(V).t -> t
  val tomap : t -> int Core.Map.Make(V).t
  val varset : t -> Set.Make(V).t
  exception DivFailure
  val ( */ ) : Core.Set.Make(V).t -> t -> t -> t
  val lcm : t -> t -> t
  val pp : V.t Core.Format.pp -> t Core.Format.pp
end
    
module S : sig (* module for polynomials *)
  type t = Monalg.MonAlg(X)(R).t
  val zero : t
  val unit : t
  val ( +! ) : t -> t -> t
  val ( -! ) : t -> t -> t
  val ( ~! ) : t -> t
  val ( *! ) : t -> t -> t
  val eq : t Core.Ord.eq
  val compare : t Core.Ord.comp
  val form : R.t -> X.t -> t
  val tomap : t -> R.t Map.Make(X).t
  val split : t -> ((X.t * R.t) * t) option
  val pp : X.t Core.Format.pp -> R.t Core.Format.pp -> t Core.Format.pp
end

(* conversion functions *)
module C : sig
  val ring_to_monalg : ring -> S.t

  val monalg_to_ring : S.t -> ring
end
