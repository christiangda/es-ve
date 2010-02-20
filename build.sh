#!/bin/bash
#
# Descomentar la linea de abajo si se quiere debugear
#set -x

#Variables globales
ROOT_DIR=`pwd`
TMP_DIR=build

# El archivo de configuración por defecto es config.sh
# Las variables establecidas en el archivo config.sh son:

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


