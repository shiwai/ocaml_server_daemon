#!/bin/sh
make clean
make server
ocamlrun -b server
