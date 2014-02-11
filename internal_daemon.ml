open Printf
open Default_controller
open Utils

let genarate_content_type uri =
    let types = [("html","text/html");("css","text/css");("js","text/javascript")] in
    let ext = Utils.getExt uri in
    try
        (snd (List.find (fun x -> (fst x) = ext) types))
    with
    | _ -> "text/plain"

let generate_status status_code =
    let types = [(200,"OK");(404,"Not Found")] in
    try
        List.find (fun x -> (fst x) = status_code) types
    with
    | _ -> (200, "OK")

let generate resp = 
    printf "Generating response\n"; flush stdout;

    let h = 
        new Netmime.basic_mime_header
            ["Content-type", "text/html"] in
    let data = 
                Default_controller.getResponse() in
    resp # send (`Resp_status_line (200, "OK"));
    resp # send (`Resp_header h);
    resp # send (`Resp_body (data, 0, String.length data));
    resp # send `Resp_end
;;

let generate_gen req resp =
    printf "Gererating general response\n"; flush stdout;
    let h = new Netmime.basic_mime_header ["Content-type", (genarate_content_type (snd req))] in
    let code,data = Default_controller.handleData req in
    resp # send (`Resp_status_line (generate_status code));
    resp # send (`Resp_header h);
    resp # send (`Resp_body (data, 0, String.length data));
    resp # send `Resp_end
;;


let generate_error resp =
    printf "Generating error response\n"; flush stdout;
    let h = new Netmime.basic_mime_header ["Content-type", "text/html"] in
    let data = "<html><head><title>Bad Request</title></head>\n" ^
               "    <body>\nBad Requeest</body>\n" ^
               "</html>" in
    resp # send (`Resp_status_line (400, "Bad Request"));
    resp # send (`Resp_header h);
    resp # send (`Resp_body (data, 0, String.length data));
    resp # send `Resp_end;
;;

let serve fd = 
    let config = Nethttpd_kernel.default_http_protocol_config in
    let proto = new Nethttpd_kernel.http_protocol config fd in

    let rec next_token () =
        printf "wait next token...\n"; flush stdout;
        if proto # recv_queue_len = 0 then (
            proto # cycle ~block:(0.1) ();
            proto # cycle ();
            next_token()
        )
        else
            proto # receive()
    in

    let cur_reqs = ref None in
    let cur_tok = ref (next_token()) in
    let cur_resp = ref None in
    while !cur_tok <> `Eof do
        printf "loop token...\n"; flush stdout;
        (match !cur_tok with
            | `Req_header (((meth, uri), v), hdr, resp) ->
                printf "request: method = %s, uri = %s\n" meth uri;
                flush stdout;
                cur_reqs := Some (meth, uri);
                cur_resp := Some resp
            | `Req_expect_100_continue ->
                (match !cur_resp with
                    | Some resp -> resp # send Nethttpd_kernel.resp_100_continue
                    | None -> assert false
                )
            | `Req_end ->
                printf "Pipeline length: %d\n" proto#pipeline_len;
                (match !cur_resp with
                    | Some resp -> 
                        (match !cur_reqs with
                        | Some reqs -> 
                            generate_gen reqs resp (* generate resp *)
                        | None -> assert false);
                    | None -> assert false
                );
                cur_resp := None
            | `Req_body data_chunk ->
                ()
            | `Fatal_error e ->
                let name = Nethttpd_kernel.string_of_fatal_error e in
                printf "Fatal_error: %s\n" name;
                flush stdout;
            | `Bad_request_error (e, resp) ->
                let name = Nethttpd_kernel.string_of_bad_request_error e in
                printf "Bad Request error: %s\n" name;
                flush stdout;
                generate_error resp
            | `Timeout ->
                printf "Timeout\n";
                flush stdout;
            | `Req_trailer t -> 
                printf "Recieve Req_trailer\n"; flush stdout;
            | `Eof ->
                printf "Eof\n"; flush stdout;
                ()
        );
        cur_tok := next_token()
    done;

    while proto # resp_queue_len > 0 do
        (* proto # cycle ~block:(-1.0) (); *)
        proto # cycle();
    done;

    proto # shutdown();

    if proto # need_linger then (
        printf "Lingering close!\n";
        flush stdout;
        let lc = new Nethttpd_kernel.lingering_close fd in
        while lc # lingering do
            lc # cycle ~block:true ()
        done
    )    
    else
        printf "closing socket...\n"; flush stdout;
        Unix.close fd
;;
        

let start() = 
    let master_sock = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
    Unix.setsockopt master_sock Unix.SO_REUSEADDR true;
    Unix.bind master_sock (Unix.ADDR_INET(Unix.inet_addr_any, 8765));
    Unix.listen master_sock 100;
    printf "Listening on port 8765\n";
    flush stdout;

    while true do
        printf "loop...\n"; flush stdout;
        try
            let conn_sock, _ = Unix.accept master_sock in
            Unix.set_nonblock conn_sock;
            serve conn_sock;
        with
            Unix.Unix_error(Unix.EINTR,_,_) -> ()
        done
    ;;

let conf_debug() = 
    let debug = try Sys.getenv "DEBUG" with Not_found -> "" in
    if debug = "All" then
        Netlog.Debug.enable_all()
    else if debug = "LIST" then (
        List.iter print_endline (Netlog.Debug.names());
        exit 0
    )
    else (
        let l = Netstring_str.split (Netstring_str.regexp "[\t\r\n]+") debug in
        List.iter (fun m -> Netlog.Debug.enable_module m) l
    );
    if (try ignore(Sys.getenv "DEBUG_WIN32"); true with Not_found -> false) then
        Netsys_win32.Debug.debug_c_wrapper true
;;

Netsys_signal.init();
conf_debug();
start();



Netsys_signal.init();
start();;
