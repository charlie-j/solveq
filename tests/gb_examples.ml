(* Grobner basis computations for K[X]-module *)

#use "topfind";;
#require "num";;
#require "batteries";;
#require "menhirLib";;
#require "solveq";;  

open Solveq
open GroebnerBasis
open Types
open Core
open Interference

let var_pp = Var.pp;;
let mon_pp = X.pp;;
let b_pp = B.pp;;
let r_pp = R.pp;;
let p_pp = P.pp;;
let s_pp = S.pp;;
let sb_pp = SB.pp;;
#install_printer var_pp;;
#install_printer p_pp;;
#install_printer r_pp;;
#install_printer bi_pp;;
#install_printer sb_pp;;
#install_printer mon_pp;;
#install_printer s_pp;;
(* polynomials displayed from biggest to monom to smallest *)


(* ------------------------------------------------------------------------- *)
(* Examples for Groebner Basis.                                              *)
(* ------------------------------------------------------------------------- *)

module GB = GroebnerBasis.ProdGB(R)(S)(P)
module VarSet = Set.Make(Var)

let x = Var.of_string "x" and y = Var.of_string "y" and z =  Var.of_string "z";;

let priv = VarSet.of_list [x;y];;

let m1 = X.ofvar x ;; (* x *)
let m2 = X.ofvar y;; (* y *)
let m3 = X.ofvar z;; (* z *)
let m4 = X.( *@ ) m1 m2;; (* xy *)
let m5 = X.( *@ ) m2 m3;; (* yz *)
let m6 = X.( *@ ) m1 m1;; (* xx *)

S.form R.unit m2;;

let vp1 = Var.of_string "sp1" and vp2=Var.of_string "sp2";;

let p1 = S.( +! ) (S.form R.unit m4) (S.form R.unit m2) and sp1 = S.form R.unit (X.ofvar vp1);; (* xy+y *)
let p2 =  (S.form R.unit m4) and sp2 = S.form R.unit (X.ofvar vp2);; (* xy *)

let py = (S.form R.unit m2);;

let p4 = S.(+!) p1 (S.form R.unit m6);;
S.split p4;;

X.compare m2 m4;;  (*should be -1 *)
X.compare m6 m1;; (* should be 1 *)
X.compare m1 m2;; (* should be -1*)

S.split p1;;

Int.compare 3 4;;

let gb = GB.groebner priv ([(p1,sp1);(p2,sp2)]);; 

let t = P.i1 p1;;

GB.deduc priv [(p1,sp1)] (P.i1 p1);;
GB.deduc priv gb (P.i1 py);;


(* boolean examples *)


let bpy = SB.form B.unit m2;;

let null = SB.( +!) bpy bpy;;

let bp1 = SB.( +! ) (SB.form B.unit m4) (bpy) and bsp1 = SB.form B.unit (X.ofvar vp1);; (* xy+y *)

let bp2 =  (SB.form B.unit m4) and bsp2 = SB.form B.unit (X.ofvar vp2);; (* xy *)

let py = SB.( +!) bp1 bp2;; (* xy+y+xy = y *)

(* indep examples *)
let x = Var.make_det (Var.of_string "x") and y = Var.make_det (Var.of_string "y") and r = Var.make_rnd ( Var.of_string "r");;

x.priority;;
r.priority;;



let rnd = VarSet.of_list [r];;
let det = VarSet.of_list [x;y];;
let m1 = X.ofvar x ;; (* x *)
let m2 = X.ofvar y;; (* y *)
let m3 = X.ofvar r;; (* z *)

let p1 = S.( +! ) (S.form R.unit m1) (S.form R.unit m3);; (* x+r *)
let p2 = S.( +! ) (S.form R.unit m2) (S.form R.unit m3);; (* y+r *)
let p3 = (S.form R.unit m1);;
module Dep = Interference.Dependencies(R)(S)(P);;
module GB = GroebnerBasis.GB(R)(S);;
module C = Converter(R)(S);;
module VarSet = Set.Make(Var);;
module VatSetSet = Set.Make(VarSet);;
    module M = Map.Make(Var);;

let basis1 = (Dep.get_dependencies [p1;p2] det rnd);; (* (x+r,y+r) is dependent from both x and y *)


let basis2 =(Dep.get_dependencies [p2;p3] det rnd);; (* (y+r,x) is only dependent from x *)


module Unif = Uniform.Unif(R)(S)(P);;

let s1 = VarSet.of_list [y];;
let s2 = VarSet.of_list [x;z];;


let subsets = Unif.all_sub_sets [s1;s2];;

List.map (VarSet.to_list) (Unif.VarSetSet.to_list subsets);;

let x = Var.make_det (Var.of_string "x") and y = Var.make_det (Var.of_string "y") and r1 = Var.make_rnd ( Var.of_string "r1") and r2 = Var.make_rnd ( Var.of_string "r2") ;;

let rndvars = VarSet.of_list [r1;r2];;

let m1 = X.ofvar x ;; (* x *)
let m2 = X.ofvar y;; (* y *)
let m3 = X.ofvar r1;; (* z *)
let m4 = X.ofvar r2;;

let p1 = S.( +! ) (S.form R.unit m1) (S.form R.unit m3);; (* x+r1 *)
let p2 = S.( +! ) (S.form R.unit m2) (S.form R.unit m4);; (* y+r2 *)
let p3 = S.( +! ) (S.form R.unit m2) (S.form R.unit m3);; (* y+r1 *)
let p4 = (S.form R.unit m1);; (* x *)


Unif.naive_is_unif [p1] (rndvars);; (* true *)
Unif.naive_is_unif [p4] rndvars;; (* false *)
Unif.naive_is_unif [p1;p2] rndvars;; (* true *)
Unif.naive_is_unif [p1;p3] rndvars;; (* false *)


let x0 = "x0" and x1 = "x1" and y0 = "y0" and y1 = "y1" and r0 =  "zr0" and r1 = "zr1";;

let x0 = Var.make_det (Var.of_string "x0") and x1 = Var.make_det (Var.of_string "x1") and y0 = Var.make_det (Var.of_string "y0") and y1 = Var.make_det (Var.of_string "y1") and r0 = Var.make_rnd ( Var.of_string "r0") and r1 = Var.make_rnd ( Var.of_string "r1") ;;


let mx0 = S.form R.unit (X.ofvar x0) ;;
let mx1 = S.form R.unit (X.ofvar x1);;
let my0 = S.form R.unit (X.ofvar y0);;
let my1 = S.form R.unit (X.ofvar y1);;
let mr0 = S.form R.unit (X.ofvar r0);;
let mr1 = S.form R.unit (X.ofvar r1);;



let rndvars = VarSet.of_list [r0;r1];;
let detvars = VarSet.of_list [x0;x1;y0;y1];;

let p1 = S.( +! ) mr0 (S. ( *! ) mx0 my1 );; (* r0 + x0y1 *)
let p2 = S.( +! ) mr0 (S. ( *! ) mx1 my0 );; (* r0 + x1y0 *)

Dep.check_indep [mx0;my0;p1] detvars rndvars;; (* x0 and y0 are bound, x1 and y1 are independent *)


let p1 = S.( +! ) mr0 mx0;;
let p2 = S.( +! ) mr0 my0;;
let p3 = S.( +! ) mr0 (S.( +! ) mr1 mx0);;

Dep.check_indep [p1;p2] detvars rndvars;; (* x0 and y0 are bound, x1 and y1 are independent *)
Dep.check_indep [p1;p2;p3] detvars rndvars;; (* x0 and y0 are bound, x1 and y1 are independent *)

let p1 = mx0;;
let p2 = my0;;
let p3 = S.( +!) ( S.( *! ) mx0 my1 ) mr0;;

Dep.check_indep [p1;p2;p3] detvars rndvars;;

let basis1 = (Dep.get_dependencies [p1;p2] detvars rndvars);;



let x = Var.make_det (Var.of_string "x") and y = Var.make_det (Var.of_string "y") and r1 = Var.make_det ( Var.of_string "r1") and r0 = Var.make_det ( Var.of_string "r0") ;;

let rlist = [VarR(x0);VarR(y0); AddR(MultR(VarR(x0),VarR(y1)),VarR(r0)) ];;
let rndvars = VarSet.of_list [r0;r1];;
VarSet.exists (fun r -> Var.eq r0 r) rndvars;;
if VarSet.exists (fun r -> Var.eq r0 r) rndvars then Var.make_rnd r0 else r0;;

let pols =  List.map (C.ring_to_monalg ~rndvars:(rndvars)) rlist;;


let detvars = VarSet.of_list [x0;x1;y0;y1];;


Interference.check_indep_ring rlist detvars rndvars;;
Interference.check_indep_ringbool rlist detvars rndvars;;
