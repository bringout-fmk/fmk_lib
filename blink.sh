#!/bin/bash

#echo "Parametri $@"

CMD=$@
#echo "Parametri $CMD"

CMD2=$(echo $CMD | tr [/] [\\\\] )

blinker.com $CMD2 
