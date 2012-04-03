#!/bin/bash

echo "                            Copyright bring.out"
echo "------------------------------------------------------"
echo "clipper cl-sc build sistem, ver 01.10, 03.2002-06.2008"
echo "                            autor: hernad@bring.out.ba"
echo ""
echo ""

ToLower()
{
#echo ToLower
lowercase *.OBJ
#read cDN
}
prgname=$1
shift
prgname2=$(echo $prgname | tr [/] [\\\\] )

#echo "Prg name: $prgname2"
clipper $prgname2 $@ > /tmp/clipcomp
#read cDn

echo -----------------------
ERROR=`cat /tmp/clipcomp | grep -c -e "No code generated" -e "include error" -e "Statement not recognized" -e "Syntax error" -e "syntax error" -e "t open" -e "Error"`

#cat /tmp/clipcomp
#echo "--------------------- origggggggggggggggggggggg ----------------"
#read cDN

echo --------------------------------------------------------------------
#echo moram "c:\dir\test.prg" pretvoriti u  "/dir/test.prg"
sed -e "s/\(.*\)(\(.*\))[ ]\(.*\)/\1:\2:\3/; s/h://g; s/H://g; s/\\\\/\//g; y/ABCDEFGHIJKLMNOPQRSTUVZXYW/abcdefghijklmnopqrstuvzxyw/" /tmp/clipcomp 
echo --------------------------------------------------------------------
if [ "$ERROR" == "" ]
then
	ERROR=0
fi
if [ "$ERRORH1" == "" ]
then
	ERRORH1=0
fi
if [ "$ERRORH2" == "" ]
then
	ERRORH2=0
fi
if [ "$ERRORH3" == "" ]
then
	ERRORH3=0
fi
if [ "$ERRORH4" == "" ]
then
	ERRORH4=0
fi
if [ "$ERRORH5" == "" ]
then
	ERRORH5=0
fi


if [ $ERROR -gt 0 ] || [ $ERRORH1 -gt 0 ] || [ $ERRORH2 -gt 0 ] || [ $ERRORH3 -gt 0 ] || [ $ERRORH4 -gt 0 ] || [ $ERRORH5 -gt 0 ]
then
	echo "!!!!!!!!!!!!greska!!!!!!!!!!!!!!!!!!!!!!"
	exit 1
else
	ToLower
	exit 0
fi

