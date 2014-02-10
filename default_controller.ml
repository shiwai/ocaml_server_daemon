open Printf
(* generate list [1..n] *)
let generate_list n =
    let rec generate_list_imp n ans =
        match n with
        | 0 -> ans
        | _ -> generate_list_imp (n-1) (n::ans) in
    generate_list_imp n []    

let gen_from_file filename =
    let fin = open_in filename in
    let rec read_contents inbff answer =
        try 
            let str = input_line inbff in
            read_contents inbff (answer ^ "\n" ^ str)
        with 
            End_of_file -> answer in
    read_contents fin ""


(* Create Response Text. *)
let getResponse() =
    let str = gen_from_file "./static/html/index.html" in
    printf "%s\n" str;
    str
(*
    let source = generate_list 100 in
    let stringSource = List.map (fun x -> string_of_int x) source in
    let paragraphs = List.map (fun x -> "<p>" ^ x ^ " times" ^ "</p>") stringSource in
    List.fold_left (fun x y -> x ^ y) "start..." paragraphs
*)
