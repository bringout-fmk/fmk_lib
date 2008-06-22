export PATH=/usr/harbour/bin:$PATH

if [ ! -f $1.prg ]; then
      echo usage $0 prg_name_bez_ekstenzije
fi

SYS=`uname`

hbcmp -b $1.prg


if [ "$SYS" == "Linux" ]; then

gcc -DHB_OS_LINUX -Wall -W -o$1 $1.o -L${HB_LIB_COMPILE} -L/usr/X11R6/lib  -Wl,--start-group   -lhbvm  -lhbrtl  -lhblang  -lhbrdd  -lhbrtl  -lhbmacro  -lhbpp  -lrddcdx  -lrddfpt  -lrddntx  -lhbcommon  -lhbct  -lfmk_skeleton  -lfmk_security  -lfmk_common  -lfmk_ui  -lfmk_db  -lfmk_codes  -lfmk_event  -lfmk_rules  -lfmk_ugov  -lfmk_exp_dbf  -lfmk_lokalizacija  -lfmk_rabat  -lhbdebug  -lgttrm  -lrddntx  -lrddcdx  -lrddfpt  -lhbsix  -lhbhsx  -lhbusrrdd  -lgtcgi  -lgtpca  -lgtstd  -lgttrm  -lgtcrs  -lgtsln  -lgtxwc -lncurses -lslang -lX11 -lm -ldl -Wl,--end-group

echo $1 buildan ...


else


gcc -Wall -W -o$1.exe $1.o  -mno-cygwin   -L${HB_LIB_COMPILE} -Lc:/cygwin/usr/mysql/lib  -Wl,--start-group -lhbclipsm   -lhbvm  -lhbrtl  -lhblang  -lhbrdd  -lhbrtl  -lhbmacro  -lhbpp  -lrddcdx  -lrddfpt   -lhbcommon -lhbdebug  -lhbct  -lrddntx -lgtwin -lrddcdx  -lrddfpt -lhbsix -lhbhsx -lhbusrrdd -lhbmysql -Wl,--end-group -luser32 -lwinspool -lgdi32 -lcomctl32 -lcomdlg32 -lole32 -loleaut32 -luuid -lmpr -lwsock32 -lws2_32 -lmapi32 -lmysql

echo $1.exe buildan ...

fi

