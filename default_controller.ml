open Utils
open Access_db
open Printf

(* generate list [1..n] *)
let generate_list n =
    let rec generate_list_imp n ans =
        match n with
        | 0 -> ans
        | _ -> generate_list_imp (n-1) (n::ans) in
    generate_list_imp n []    

(* Get Response From File *)
let gen_from_file filename =
    let fin = open_in filename in
    let rec read_contents inbff answer =
        try 
            let str = input_line inbff in
            read_contents inbff (answer ^ "\n" ^ str)
        with 
            End_of_file -> answer in
    let content = read_contents fin "" in
    close_in fin;
    content;;


(* Definition API Handles *)
let api_handler req content =
    printf "%s\n" content;
    let mtd,uri=req in
    match uri with
    | "/api/todos" -> 
        if mtd = "GET" then
            let response = Access_db.getApiTodos() in
            (200, response)
        else
            match content with
            | "" -> (400, "Bad Request")
            | _ ->
                try 
                    let key, value = Utils.parseString content in
                    Access_db.insertApiTodos(key, value)
                with
                | _ -> (400, "Bad Request")
    | _ -> (404, "Not Found")
   
(* Handle All Requests *)
let handleData req content = 
    let uri = snd req in
    if Utils.isApiCall uri then
        api_handler req content
    else
        try
            let str = gen_from_file ("./static" ^ uri) in
            (200, str)
        with
        | _ -> (404, "Not Found")
