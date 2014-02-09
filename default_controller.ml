(* generate list [1..n] *)
let generate_list n =
    let rec generate_list_imp n ans =
        match n with
        | 0 -> ans
        | _ -> generate_list_imp (n-1) (n::ans) in
    generate_list_imp n []    

(* Create Response Text. *)
let getResponse =
    let source = generate_list 100 in
    let stringSource = List.map (fun x -> string_of_int x) source in
    let paragraphs = List.map (fun x -> "<p>" ^ x ^ " times" ^ "</p>") stringSource in
    List.fold_left (fun x y -> x ^ y) "start..." paragraphs

