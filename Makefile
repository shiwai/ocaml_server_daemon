all: server

server: internal_daemon.ml
	ocamlfind ocamlc -o server -package "netstring,unix,nethttpd,netcgi2" \
		default_controller.ml internal_daemon.ml -linkpkg -g

clean: 
	rm -f *.cmo *.cmi *.o
	rm -f server
