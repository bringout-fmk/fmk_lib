cd /usr/harbour/lib

if [ "$1" == "" ] ; then
	echo "usage $0 <symbol>"
fi

FILES=`ls *.a`
for f in $FILES; do echo $f && nm $f | grep  $1 ; done
