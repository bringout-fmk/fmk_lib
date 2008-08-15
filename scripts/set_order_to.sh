if [ "$1" == "" ] ; then
  echo "usage $0 <n>"
  exit 0
fi

FILES=`ls *.prg`

for f in $FILES 
do

  echo ${f}

  mv $f ${f}.orig
  sed  -e "s/set order to ${1}/set order to tag \"${1}\"/" $f.orig > $f
  mv $f ${f}.2.orig
  sed  -e "s/SET ORDER TO ${1}/set order to tag \"${1}\"/" ${f}.2.orig > $f

done

