open Str
open Printf

(* get extention from file path. *)
let getExt path =
    let lists = Str.split (regexp "\\.") path in
    let rec getExtImp lst ans:string =
        match lst with 
        | [] -> ans
        | (h::t) -> getExtImp t h in
    getExtImp lists "";;

(* check api call or not *)
let isApiCall uri = 
    Str.string_match (regexp "^/api/") uri 0;;

(* parse query to todo api format.
   If format is invalid, this function will raise Exception. *)
let parseString origin =
    let decode = Netencoding.Url.decode origin in
    let params = Str.split (regexp "\&") decode in
    let getVal str = 
        let keyAndVal = Str.split (regexp "=") str in
        (List.nth keyAndVal 1) in
    (getVal (List.nth params 0), getVal (List.nth params 1))

    
