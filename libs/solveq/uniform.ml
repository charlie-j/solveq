open Core
open Monalg
open Types
open Inverter

module Unif(R : Field)(S : Monalg.MonAlgebra with type ring = R.t and type mon = X.t)(P : Monalg.ProductAlgebra with type ringA = S.t and type ringB = S.t)
=
struct
  module C = Converter(R)(S)
  module I = Inverter.InvertMonalg(R)(S)
      
  module GB = GroebnerBasis.ProdGB(R)(S)(P)
  module VarSet = Set.Make(Var)
  module VarSetSet = Set.Make(VarSet)

  exception NoSubSet

  let rec all_sub_sets sets =
    (* given a list of sets s1,..,sk, computes a set of all the set S of size n such that S is a subset of the union of all si, and the intersection between and S and each si is exactly one. We must select a distinct element from each si. *)
    match sets with
    |[] -> VarSetSet.empty
    |[p] -> VarSet.fold (fun var acc -> VarSetSet.add (VarSet.singleton var) acc) p VarSetSet.empty
    |p::q ->
          let subsets = all_sub_sets q in
          (* we compute all the possible subsets for the remainder *)

          VarSet.fold (fun var acc -> 
              let acceptable_subsets = VarSetSet.filter (fun set -> not(VarSet.mem var set)) subsets in
              (* we can only build a set extended with var if var is not in the subset *)
              (* then, to each accpetable subset, we add the var to it, and then we add all those new sets to the acc *)
              VarSetSet.union acc (VarSetSet.map (fun set -> VarSet.add var set) acceptable_subsets)
          ) p VarSetSet.empty
    

  
  let naive_is_unif (pols : S.t list) (rndvars : Set.Make(Var).t) =
    (* given pols based on some randomvars (included in rndvars) and other vars, try to find a set of random variables which makes pols uniform *)
    (* is complete only if the number of pols is equal to the number of rndvars *)
    let var_pols = List.map (fun pol -> VarSet.inter rndvars (C.varset pol)) pols in
    let pols_length = List.length pols in
    (* here, we need to find a subset R built from the random variables appearing in pols so that its size is equal to the number of pols and the function R -> pols is bijective *)
    let subrndvars = all_sub_sets var_pols in
    let rec is_unif varsubsets =
      if VarSetSet.is_empty varsubsets then false
      else
        begin
          let p,q =VarSetSet.pop varsubsets in             
          try
            let inverters = I.inverter_tuple (VarSet.to_list p) pols in
            true
          with NoInv -> is_unif q
          end
    in
    is_unif subrndvars

 end
