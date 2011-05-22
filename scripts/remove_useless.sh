#!/bin/bash
#
# Elimina espacios en blanco, tabuladores y lineas que comienzen con el 
# caracter "#" (lo cual significa comentarios).  Adicionalmente elimina
# espacios y tabuladores al final de cada linea.
#
# USO:  cat fichero_entrada | remove_useless.sh > fichero_salida
#
#sed '/^\#/d;/./!d;s/^[ \t]*//;s/[ \t]*$//;/^$/d'
sed -n '/^\#.*/ { d; }; /^$/ { d; }; /^[^\#]*\#.*/! { p; };
        /^[^\#]*\ [\ ]*\#.*/ { s/\ [\ ]*\#.*//; p; };
        /^[^\#]*\t[\t]*\#.*/ { s/\t[\t]*\#.*//; p; }' | \
sed -n '/  /! { p; }; /  \( \)*/ { s// /g; p; }'
