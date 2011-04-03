#!/bin/bash
#
# Genera los diccionarios

# Para hacer "debug" del script se debe descomentar esta linea
#set -x

#Variables de ubicación
ROOT_DIR=`pwd`
TMP_DIR="build"


MKDIR=`which mkdir 2>/dev/null`
GREP=`which grep 2>/dev/null`
FIND=`which find 2>/dev/null`
ZIP=`which zip 2>/dev/null`

# Abandonar si no se encuentra alguna de las herramientas
if [ "$MKDIR" == "" ]; then
	echo "No se encontró el comando 'mktemp'... Abortando." > /dev/stderr
	exit 1
fi
if [ "$GREP" == "" ]; then
	echo "No se encontró el comando 'grep'... Abortando." > /dev/stderr
	exit 1
fi
if [ "$FIND" == "" ]; then
	echo "No se encontró el comando 'find'... Abortando." > /dev/stderr
	exit 1
fi
if [ "$ZIP" == "" ]; then
	echo "No se encontró el comando 'zip'... Abortando." > /dev/stderr
	exit 1
fi

# Obtener las variables de la configuración del archivo config.sh
if [ -f ./config.sh ]; then
	. ./config.sh
else
	echo "No se encontró el archivo 'config.sh'... Abortando." > /dev/stderr
	exit 1
fi

#Verificamos si se quieren crear los diccionarios
if [ "$PKG_MOZ_CREATE" == "0" -a "$PKG_oOo_CREATE" == "0" ]; then
	echo "No se ha colocado las variables necesarias en el archivo 'config-sh'"
	echo 'se debe editar este achivo y colocar los valores necesarios en las variables'
	echo 'que allí se encuentran'
	echo ''
	echo "Se debe colocar el valor '1' en las variables 'PKG_MOZ_CREATE' o 'PKG_oOo_CREATE'"
	echo "en el archivo 'config.sh'"
	exit 1
fi

# Hacemos una copia del valor de la variable LANG para poder restaurarla.
LANG_BAK=$LANG

LANG="$LOCALIZACION.ISO-8859-1"

# Obtener el archivo de afijos
if [ -f $ROOT_DIR/src/affixes/${AFFIXES_FILE_NAME} ]; then
	AFFIXES_FILE="$ROOT_DIR/src/affixes/${AFFIXES_FILE_NAME}"
else
	echo "No se encontró el archivo ${AFFIXES_FILE_NAME}... Abortando." > /dev/stderr
	exit 1
fi

# Obtener el archivo de separación silábica
if [ -f $ROOT_DIR/src/hyphenation/${HYPHNATION_FILE_NAME} ]; then
	HYPHNATION_FILE="$ROOT_DIR/src/hyphenation/${HYPHNATION_FILE_NAME}"
else
	echo "No se encontró el archivo ${HYPHNATION_FILE_NAME}... Abortando." > /dev/stderr
	exit 1
fi

# Obtener el archivo de tesauro
if [ -f $ROOT_DIR/src/thesaurus/${THESAURUS_DAT_FILE_NAME} ]; then
	THESAURUS_DAT_FILE="$ROOT_DIR/src/thesaurus/${THESAURUS_DAT_FILE_NAME}"
else
	echo "No se encontró el archivo ${THESAURUS_DAT_FILE_NAME}... Abortando." > /dev/stderr
	exit 1
fi

# Obtener el archivo de tesauro
if [ -f $ROOT_DIR/src/thesaurus/${THESAURUS_IDX_FILE_NAME} ]; then
	THESAURUS_IDX_FILE="$ROOT_DIR/src/thesaurus/${THESAURUS_IDX_FILE_NAME}"
else
	echo "No se encontró el archivo ${THESAURUS_IDX_FILE_NAME}... Abortando." > /dev/stderr
	exit 1
fi


# Crear un directorio temporal de trabajo
# Obtener el archivo de tesauro
BUILD_DIR=$ROOT_DIR/$TMP_DIR

if [ -d $BUILD_DIR ]; then
	rm -rf $BUILD_DIR
fi

$MKDIR $ROOT_DIR/$TMP_DIR


#Copiamos todos los archivos necesarios a esta nueva ruta y les removemos los
#comentarios y las lineas en blanco
cat $AFFIXES_FILE | $ROOT_DIR/scripts/remove_useless.sh > $BUILD_DIR/${AFFIXES_FILE_NAME}
cat $HYPHNATION_FILE | $ROOT_DIR/scripts/remove_useless.sh > $BUILD_DIR/${HYPHNATION_FILE_NAME}
cat $THESAURUS_DAT_FILE | $ROOT_DIR/scripts/remove_useless.sh > $BUILD_DIR/${THESAURUS_DAT_FILE_NAME}
cat $THESAURUS_IDX_FILE | $ROOT_DIR/scripts/remove_useless.sh > $BUILD_DIR/${THESAURUS_IDX_FILE_NAME}

#Reusamos las mismas variables
AFFIXES_FILE=$BUILD_DIR/${AFFIXES_FILE_NAME}
HYPHNATION_FILE=$BUILD_DIR/${HYPHNATION_FILE_NAME}
THESAURUS_DAT_FILE=$BUILD_DIR/${THESAURUS_DAT_FILE_NAME}
THESAURUS_IDX_FILE=$BUILD_DIR/${THESAURUS_IDX_FILE_NAME}

#Creamos el diccionario de los toponimos
cat $ROOT_DIR/src/words/toponyms/*.txt \
	| $ROOT_DIR/scripts/remove_useless.sh \
	| $ROOT_DIR/scripts/order_remove_duplicates.sh \
	> $BUILD_DIR/'TOPONYMS_'${DICTIONARY_FILE_NAME}'.txt'




exit 0
