#!/bin/bash

echo "-----------------------------------------"
echo "== ZIP modul ============================"
CMD=$@
echo "++++ Ulazni parametri: $CMD" 
echo ""
/h/sigma/zip.exe $CMD
echo "+++++++++++++++++++++"

