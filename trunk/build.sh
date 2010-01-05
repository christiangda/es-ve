#!/bin/bash

# Descomentar la linea de abajo si se quiere debugear
#set -x

#Variables globales
ROOT_DIR=`pwd`
TMP_DIR=build

# El archivo de configuración por defecto es config.sh
# Las variables establecidas en el archivo config.sh son:
APP_NAME=          # short-name, jar and xpi files name. Must be lowercase with no spaces
CHROME_PROVIDERS=  # which chrome providers we have (space-separated list)
CLEAN_UP=          # delete the jar / "files" when done?       (1/0)
ROOT_FILES=        # put these files in root of xpi (space separated list of leaf filenames)
ROOT_DIRS=         # ...and these directories       (space separated list)
VAR_FILES=         # files that need variable substitution (space separated list)
VERSION=           # version number (string)
PRUNE_DIRS=	       # exclude files with these directories in their paths (space separated list)
BEFORE_BUILD=      # run this before building       (bash command)
AFTER_BUILD=       # ...and this after the build    (bash command)

# Incluimos el archivo de configuración
. ./config.sh

# Validamos si existe la variable que define la aplicación
if [ -z $APP_NAME ]; then
  echo "Es necesario configurar el archivo config.sh primero!"
  exit;
fi

# Removemos versiones anteriores
rm -rf $APP_NAME.xpi
rm -rf $TMP_DIR

# Creamos el directorio de trabajo
mkdir -pv $TMP_DIR/


