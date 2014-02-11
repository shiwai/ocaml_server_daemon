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
    let content = read_contents fin "" in
    close_in fin;
    content;;


(* Create Response Text. *)
let getResponse() =
    let str = gen_from_file "./static/html/index.html" in
    printf "%s\n" str;
    str

let handleData req = 
    let uri = snd req in
    try
        let str = gen_from_file ("./static" ^ uri) in
        (200, str)
    with
    | _ -> (404, "")
