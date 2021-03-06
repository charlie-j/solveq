(* -------------------------------------------------------------------- *)
open Core
open Location

(* -------------------------------------------------------------------- *)
type perror =
  | PE_LexicalError of string
  | PE_Unknown

exception ParseError of Location.t option * perror

exception LexError of Location.t option * perror
                      
(* -------------------------------------------------------------------- *)
type pident = string loced

(* -------------------------------------------------------------------- *)
type pbinop = [`Add | `Mul | `Pow]

type pfsymb = [`BinOp of pbinop loced | `Named of pident]

type pterm_r =
  | PVar of pident
  | PLit of pliteral
  | PApp of pfsymb * pterm list

and pliteral_r =
  | PL_Int       of Big_int.big_int
  | PL_BitString of bool * pterm

and pterm    = pterm_r loced
and pliteral = pliteral_r loced

(* -------------------------------------------------------------------- *)
type pvardecl = pident list
type pisunif   = pterm list
type pinvert   = pident list * pterm list

(* -------------------------------------------------------------------- *)
type pentry_r =
  | PVarDecl of pvardecl
  | PIsUnif   of pisunif
  | PInvert   of pinvert
      
and pentry = pentry_r loced

(* -------------------------------------------------------------------- *)
type pprogram = pentry list

(* -------------------------------------------------------------------- *)
let string_of_perror = function
  | PE_LexicalError x ->
      Printf.sprintf "lexical error: %s" x

  | PE_Unknown ->
      Printf.sprintf "invalid syntax"
