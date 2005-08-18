#!/bin/bash

echo "---------------------------------------------------"
echo "== Commit 2 Repos ================================="
echo "++++++ Ulazni parametri: $1 $2"

#define VERSION const
VERSION=`cat /c/dev/fmk/$1/$1.ch | grep _VERZIJA | awk -F '"' '{ print $2}'`

echo "++++++ Trenutna verzija modula $1 : $VERSION"
echo ""
echo "++++++++++++++++++++++"

/c/"Program Files"/Subversion/bin/svn commit -m $VERSION $2 

echo "++++++++++++++++++++++"
