open Mongo
open Printf

let easy_json_converter tp =
    let name,value = tp in
    "{\"name\":\"" ^ name ^ "\",\"value\":\"" ^ value ^ "\"}";;

let json_arr_converter ls =
    match ls with 
    | [] -> "[]"
    | _ -> "[" ^ (List.fold_left 
        (fun x y -> match x with
                    | "" -> y
                    | _ -> x ^ "," ^ y) "" ls) ^ "]"
    
(* Open, Execute And Clode DB *)
let using_mongo fn =
    let db = (Mongo.create "127.0.0.1" 27017 "ocaml" "sample_data") in
    let result = (fn db) in
    Mongo.destory db;
    result;;

(* find data from MongoDB Using Connection *)
let find_data db = 
    let cursor = (Mongo.find db) in
    let docs = (MongoReply.get_document_list cursor) in
    List.map (fun x -> 
        let element_key = Bson.get_element "name" x in
        let element_val = Bson.get_element "value" x in
        let string_key = Bson.get_string element_key in
        let string_value = Bson.get_string element_val in
        (string_key, string_value)) docs;;

(* Example, Get Data from DB And Convert To Json Format *)
let getApiTodos() =
    let data = using_mongo (fun db -> find_data db) in
    let sts = List.map (fun x -> easy_json_converter x) data in
    json_arr_converter sts;;

(* Example, Insert Data to DB *)
let insertApiTodos(name, value) =
    printf "name=%s, value=%s\n" name value;
    let bsonBase = Bson.empty in
    let name_element = Bson.create_string name in
    let value_element = Bson.create_string value in
    let added_name = Bson.add_element "name" name_element bsonBase in
    let added_name_and_value = Bson.add_element "value" value_element added_name in
    try
        using_mongo (fun db -> Mongo.insert db [added_name_and_value]);
        (201, "Created")
    with
    | Mongo_failed error ->
        printf "%s\n" error;
        (400, "Bad Request")
    | _ -> (400, "Bad Request")

