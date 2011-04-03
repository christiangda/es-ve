#!/bin/bash
#

#

for f in `find ../. -path *.svn -prune -o -print`
do
	enc=`file -i ${f}| gawk -Fcharset= '{ print $2 }'`
	echo -n "archivo = ${f}, encoding = "
	echo $enc
	
	if [ "$enc" == "iso-8859-1" ]; then
		echo -n "archivo = ${f}, encoding = "
		echo $enc
		iconv -f iso-8859-1 -t utf-8 $f > $f.new
		mv $f.new $f
	fi  
done

