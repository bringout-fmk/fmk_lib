#!/bin/bash

#echo "Parametri $@"

CMD=$@

echo "Parametri: $CMD"

/c/"Program Files"/"7-Zip"/7z a -sfx7z.sfx $CMD 
