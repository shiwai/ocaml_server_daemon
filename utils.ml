open Str
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
