open Str
let getExt path =
    let lists = Str.split (regexp "\\.") path in
    let rec getExtImp lst ans:string =
        match lst with 
        | [] -> ans
        | (h::t) -> getExtImp t h in
    getExtImp lists "";;
