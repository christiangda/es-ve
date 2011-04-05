#!/bin/bash
#
# Genera los diccionarios

# Para hacer "debug" del script se debe descomentar esta linea
#set -x

#Variables de ubicación
ROOT_DIR=`pwd`
TMP_DIR="build"
SVN=0


# Obtener las variables de la configuración del archivo config.sh
if [ -f ./config.sh ]; then
	. ./config.sh
else
	echo "No se encontró el archivo 'config.sh'... Abortando." > /dev/stderr
	exit 1
fi

#Valido si estamos trabajando dentro de un repositorio local de Subversion o no
if [ -d ".svn" ]; then
	SVN=1
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
LANG=$LOCALIZACION.$ENCODING

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

mkdir $ROOT_DIR/$TMP_DIR

#Copio todos los archivos necesarios a esta nueva ruta y les remuevo los
#comentarios y las lineas en blanco
cat $AFFIXES_FILE | $ROOT_DIR/scripts/remove_useless.sh > $BUILD_DIR/${AFFIXES_FILE_NAME}
cat $HYPHNATION_FILE | $ROOT_DIR/scripts/remove_useless.sh > $BUILD_DIR/${HYPHNATION_FILE_NAME}
cat $THESAURUS_DAT_FILE | $ROOT_DIR/scripts/remove_useless.sh > $BUILD_DIR/${THESAURUS_DAT_FILE_NAME}
cat $THESAURUS_IDX_FILE | $ROOT_DIR/scripts/remove_useless.sh > $BUILD_DIR/${THESAURUS_IDX_FILE_NAME}

#Reusamos las mismas variables
DICTIONARY_FILE=$BUILD_DIR/${DICTIONARY_FILE_NAME}
AFFIXES_FILE=$BUILD_DIR/${AFFIXES_FILE_NAME}
HYPHNATION_FILE=$BUILD_DIR/${HYPHNATION_FILE_NAME}
THESAURUS_DAT_FILE=$BUILD_DIR/${THESAURUS_DAT_FILE_NAME}
THESAURUS_IDX_FILE=$BUILD_DIR/${THESAURUS_IDX_FILE_NAME}

#Creo el diccionario de los toponimos, PersonasGrupos y otros
cat $ROOT_DIR/src/words/toponyms/*.txt \
	$ROOT_DIR/src/words/PersonasGrupos/*.txt \
	$ROOT_DIR/src/words/otros/*.txt \
	| $ROOT_DIR/scripts/remove_useless.sh \
	| $ROOT_DIR/scripts/order_remove_duplicates.sh \
	> $BUILD_DIR/'OTHERS_'${DICTIONARY_FILE_NAME}'.txt'

#Creo el archivo que contiene las palabras RAE y NoRAE
cat $ROOT_DIR/src/words/NoRAE/*.txt \
	$ROOT_DIR/src/words/RAE/*.txt \
	| $ROOT_DIR/scripts/remove_useless.sh \
	| $ROOT_DIR/scripts/order_remove_duplicates.sh \
	> $BUILD_DIR/'NoRAE_AND_RAE_'${DICTIONARY_FILE_NAME}'.txt'

#Creo el archivo del diccionario
touch $DICTIONARY_FILE

cat $BUILD_DIR/'OTHERS_'${DICTIONARY_FILE_NAME}'.txt' \
	$BUILD_DIR/'NoRAE_AND_RAE_'${DICTIONARY_FILE_NAME}'.txt' \
	| $ROOT_DIR/scripts/order_remove_duplicates.sh \
	| wc -l >> $DICTIONARY_FILE
	
cat $BUILD_DIR/'OTHERS_'${DICTIONARY_FILE_NAME}'.txt' \
	$BUILD_DIR/'NoRAE_AND_RAE_'${DICTIONARY_FILE_NAME}'.txt' \
	| $ROOT_DIR/scripts/order_remove_duplicates.sh \
	>> $DICTIONARY_FILE

#Si estoy dentro de un repositorio de Subversion, se deben exportar
#las carpetas de las aplicaciones
if [ "$SVN" == "1" ]; then
	svn export $ROOT_DIR/apps $BUILD_DIR/apps > /dev/null 2>&1
else
	cp -r -P $ROOT_DIR/apps $BUILD_DIR/
fi

#Reemplazo las Variables definidas en config.sh en los respectivos
#archivos dentro de las aplicaciones

#Diccionarios de Mozilla
if [ "$PKG_MOZ_CREATE" == "1" ]; then
	echo "Creando diccionario para Mozilla ..."

	for PKG_VAR in `grep -e '^PKG_MOZ_.*' config.sh | sed 's/\ /\@@/g' | sed 's/\"//g'`
	do
		KEY=`echo ${PKG_VAR} | gawk -F= '{ print $1 }'`
		VALUE=`echo ${PKG_VAR} | gawk -F= '{ print $2 }' | sed -e 's/\@@/\\\ /g'`

		for APPS_FILE in `grep -R $KEY $BUILD_DIR/apps/Mozilla/ | gawk -F: '{ print $1 }' | sort | uniq`
		do
			sed -i.bkup s/$KEY/"${VALUE}"/g $APPS_FILE
			rm -rf $APPS_FILE'.bkup'
		done
	done
	
	#Coloco los diccionarios y demás cosas donde deben ir
	cp $DICTIONARY_FILE $BUILD_DIR/apps/Mozilla/dictionaries/
	cp $AFFIXES_FILE $BUILD_DIR/apps/Mozilla/dictionaries/
	
	#Creo el archivo comprimido del diccionario
	cd $BUILD_DIR/apps/Mozilla/
	zip -r -q $PKG_MOZ_NAME_FILE *
	OUT_VER=`grep -e 'PKG_MOZ_VERSION' $ROOT_DIR/config.sh | gawk -F= '{ print $2 }' | sed -e 's/\"//g'`
	OUT_DIR=$ROOT_DIR'/dictionaries/Mozilla/v'$OUT_VER
	
	if [ ! -d $OUT_DIR ]; then
		mkdir $OUT_DIR
	else
		echo -n '¡Alerta! '
		echo "Será reemplazado el archivo $OUT_DIR/$PKG_MOZ_NAME_FILE"
	fi
	
	cp ./$PKG_MOZ_NAME_FILE $OUT_DIR/
	cd $ROOT_DIR
fi

#Diccionario de OpenOffice
if [ "$PKG_oOo_CREATE" == "1" ]; then
	echo "Creando diccionario para OpenOffice ..."

	for PKG_VAR in `grep -e '^PKG_oOo_.*' config.sh | sed 's/\ /\@@/g' | sed 's/\"//g'`
	do
		KEY=`echo ${PKG_VAR} | gawk -F= '{ print $1 }'`
		VALUE=`echo ${PKG_VAR} | gawk -F= '{ print $2 }' | sed -e 's/\@@/\\\ /g'`

		for APPS_FILE in `grep -R $KEY $BUILD_DIR/apps/OpenOffice/ | gawk -F: '{ print $1 }' | sort | uniq`
		do
			sed -i.bkup s/$KEY/"${VALUE}"/g $APPS_FILE
			rm -rf $APPS_FILE'.bkup'
		done
	done
	
	#Coloco los diccionarios y demás cosas donde deben ir
	cp $DICTIONARY_FILE $BUILD_DIR/apps/OpenOffice/dictionaries/
	cp $AFFIXES_FILE $BUILD_DIR/apps/OpenOffice/dictionaries/
	cp $HYPHNATION_FILE $BUILD_DIR/apps/OpenOffice/dictionaries/
	cp $THESAURUS_DAT_FILE $BUILD_DIR/apps/OpenOffice/dictionaries/
	cp $THESAURUS_IDX_FILE $BUILD_DIR/apps/OpenOffice/dictionaries/
	
	#Creo el archivo comprimido del diccionario
	cd $BUILD_DIR/apps/OpenOffice/
	zip -r -q $PKG_oOo_NAME_FILE *
	OUT_VER=`grep -e 'PKG_oOo_VERSION' $ROOT_DIR/config.sh | gawk -F= '{ print $2 }' | sed -e 's/\"//g'`
	OUT_DIR=$ROOT_DIR'/dictionaries/OpenOffice/v'$OUT_VER
	
	if [ ! -d $OUT_DIR ]; then
		mkdir $OUT_DIR
	else
		echo -n '¡Alerta! '
		echo "Será reemplazado el archivo $OUT_DIR/$PKG_oOo_NAME_FILE"
	fi
	
	cp ./$PKG_oOo_NAME_FILE $OUT_DIR/
	cd $ROOT_DIR
	
fi

#Eliminamos la carpeta temporal de construcción
rm -rf build/

LANG=$LANG_BAK

exit 0
