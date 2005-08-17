#!/bin/bash

#echo "Parametri $@"

CMD=$@

echo "Parametri: $CMD"

/c/"Program Files"/Subversion/bin/svn commit -m $CMD 
