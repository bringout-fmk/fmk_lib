#!/bin/bash

echo "---------------------------------------------------"
echo "== GZip ==========================================="
echo "++++++ Ulazni parametri: "
echo "                - modul   = $1"
echo "                - repos   = $2"
echo "                - exepath = $3" 
echo ""
echo "===> Pravim pomocni fajl"
cp $3/$1.EXE $3/P.EXE
echo "===> Vrsim gzip"
gzip -f $3/$1.EXE
echo "===> Vracam fajl u prvobitno stanje"
mv $3/P.EXE $3/$1.EXE
echo "===> Saljem fajl na repos destinaciju"
mv $3/$1.EXE.gz $2
echo "++++++++++++++++++++++"
