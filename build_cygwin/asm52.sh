#!/bin/sh

$BASEDIR/fmk/fmk_lib/asm52.bat $1 $2 $3 $4 $5 $6 $7 $8 $9 

lowercase *.OBJ
rm *.CRF
rm *.LST
