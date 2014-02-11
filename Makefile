all: server

server: internal_daemon.ml
	ocamlfind ocamlc -o server -package "unix,mongo,netstring,nethttpd,netcgi2,str" \
		utils.ml access_db.ml default_controller.ml internal_daemon.ml -linkpkg -g
	rm -f *.cmo *.cmi

mongot: access_db.ml
	ocamlfind ocamlc -o mongo -package "unix,mongo" \
	access_db.ml -linkpkg -g
	rm -f *.cmo *.cmi

clean: 
	rm -f *.cmo *.cmi *.o
	rm -f mongo
	rm -f server
