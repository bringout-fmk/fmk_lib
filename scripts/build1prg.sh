export PATH=/usr/harbour/bin:$PATH

if [ ! -f $1.prg ]; then
      echo usage $0 prg_name_bez_ekstenzije
fi

SYS=`uname`

hbcmp $1.prg

if [ "$SYS" == "Linux" ] ; then


gcc  -o$1.exe $1.o  -L${HB_LIB_COMPILE}  -lhbclipsm   -lhbvm  -lhbrtl  -lhblang  -lhbrdd  -lhbrtl  -lhbmacro  -lhbpp  -lrddcdx  -lrddfpt   -lhbcommon  -lhbct  -lrddntx -lgttrm -lrddcdx  -lrddfpt -lhbsix -lhbhsx -lhbusrrdd 

else

gcc -Wall -W -o$1.exe $1.o  -mno-cygwin   -L${HB_LIB_COMPILE}  -Wl,--start-group -lhbclipsm   -lhbvm  -lhbrtl  -lhblang  -lhbrdd  -lhbrtl  -lhbmacro  -lhbpp  -lrddcdx  -lrddfpt   -lhbcommon  -lhbct  -lrddntx -lgtwin -lrddcdx  -lrddfpt -lhbsix -lhbhsx -lhbusrrdd  -Wl,--end-group -luser32 -lwinspool -lgdi32 -lcomctl32 -lcomdlg32 -lole32 -loleaut32 -luuid -lmpr -lwsock32 -lws2_32 -lmapi32

fi

echo $1.exe buildan ...
