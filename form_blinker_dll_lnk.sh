#!/bin/bash

LIBRARY=$1
shift

EXPORT=$1
shift

#until [ -z "$1" ]
#do
#	echo -n "$1 "
#	shift
#done
echo $@ > _bl_dll_.lnk

echo "file bldclp52" >> _bl_dll_.lnk
echo "defbegin" >>  _bl_dll_.lnk
echo "  library $LIBRARY" >> _bl_dll_.lnk
echo "  exetype windows 3.1" >> _bl_dll_.lnk
echo " exports $EXPORT " >> _bl_dll_.lnk
echo "defend" >> _bl_dll_.lnk
echo "nodeflib" >> _bl_dll_.lnk

