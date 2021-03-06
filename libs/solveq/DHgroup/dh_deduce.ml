open Core
open Types
open Monalg


module DeduceDH(R : Field)(S : Monalg.MonAlgebra with type ring = R.t and type mon = X.t)(P : Monalg.ProductAlgebra with type ringA = S.t and type ringB = S.t)  = struct
  module C = Converter(R)(S)

  module GB = GroebnerBasis.ProdGB(R)(S)(P)

  
  let rec normalize (g:dhgroup) : S.t =
  match g with
  | UnitG -> S.zero
  | GenG -> S.unit
  | InvG g -> S.(~!)  (normalize g)
  | ExpG (g,r) -> S.( *! )  (C.ring_to_monalg r) (normalize g)
  | MultG (g1,g2) -> S.( +! ) (normalize g1) (normalize g2)

  (* Consider polynomials  h1,...,hn,s1,...,sn built over set of vars X and Y.
     The following function solves the deduction problem X,g^h1,...,g^hn \- g^s1,...,g^sn.
     unknown_vars corresponds to Y, the variables unknown to the attacker, known_dh is the list of group elements known to the attacker g^h1,...,g^hn, and secrets is the list of secrets (in the ring), s1,...,sn. *)
  let deduce_tuple (unknown_vars : var list) (known_dh : dhgroup list) (secrets : ring list) =
    let counter = ref (0) in
   let freshvars = ref VarSet.empty in
    let known_pols = List.map normalize known_dh in
    let ps = List.fold_left (fun acc poly ->
        counter := !counter+1;
        let fvar = Var.make_fresh (Var.of_int (!counter)) in
        let fresh_var =  S.form R.unit (X.ofvar fvar )  in
        freshvars := VarSet.add fvar (!freshvars);
        (poly, fresh_var )::acc
      ) [(S.unit,S.unit)] known_pols in (* for partially knwon polynomials, we simply add them to the basis *)
    let pvars = VarSet.of_list unknown_vars in
    let basis =  GB.groebner pvars ps in

    let secrets = List.map C.ring_to_monalg secrets in
     let recipees = List.map  (
        fun e->  match (GB.deduc pvars basis e) with
          |None -> raise NoInv
          |Some(q) -> q
            
        ) (List.map (fun x-> (x,S.zero)) secrets)
    in
      recipees

end
