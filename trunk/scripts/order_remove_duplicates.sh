#!/bin/bash
#
# Ordena un archivo de forma alfabético ascendente y adicionalmente
# elimina las palabras repetidas
#
# USO:  cat fichero_entrada | order_remove_duplicates.sh > fichero_salida
#
sort | uniq
