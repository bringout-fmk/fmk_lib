#!/bin/bash

echo "-------------------------------------------"
echo "== 7zip::ZIP 2 EXE ========================"
CMD=$@
echo "++++ Ulazni parametri: $CMD"
echo ""
/c/"Program Files"/"7-Zip"/7z a -sfx7z.sfx $CMD 
echo "+++++++++++++++++++++"

