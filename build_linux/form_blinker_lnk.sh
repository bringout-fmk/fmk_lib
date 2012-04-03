#!/bin/bash


CMD=$@
#echo "Parametri $CMD"

CMD2=$(echo $CMD | tr [/] [\\\\] )


echo $CMD2 > _bl_.lnk
