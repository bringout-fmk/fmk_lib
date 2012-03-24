#!/bin/bash

ARG1=$1
shift

CMD=$@

CMD2=$(echo $CMD | tr [/] [\\\\] )

if [[ "$SC_BUILD_HOME_DIR" == "" ]]
then
  OUTFILE=~/.dosemu/drive_c/_bl_.lnk
else
  OUTFILE=${SC_BUILD_HOME_DIR}/clp_bc/tmp/_bl_.lnk
fi

if [ "$ARG1" = "add" ]; then
	echo $CMD2 >> $OUTFILE
else
	echo $CMD2 > $OUTFILE
fi
