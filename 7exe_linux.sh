#!/bin/bash

echo "-------------------------------------------"
echo "== 7zip::ZIP 2 EXE ========================"
CMD=$@
echo "++++ Ulazni parametri: $CMD"
echo ""
7z a -sfx7z.sfx $CMD 
echo "+++++++++++++++++++++"

