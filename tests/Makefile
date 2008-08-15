ROOT = ../../harbour/harbour/

HB_INC_COMPILE += -I$(TOP)../include


PRG_SOURCES=\
      test_all.prg \
      test_cp.prg \
      test_screen.prg \
      test_novasifra.prg

LIBS=\
        hbvm \
        hbrtl \
        hblang \
        hbrdd \
        hbrtl \
        hbmacro \
        hbpp \
	hbcpage \
        rddcdx \
        rddfpt \
        rddntx \
        hbcommon \
        hbct \
	hbmisc \
        fmk_skeleton \
        fmk_security \
        fmk_common \
        fmk_ui \
        fmk_db \
        fmk_codes \
        fmk_event \
	fmk_rules \
	fmk_ugov \
	fmk_exp_dbf \
	fmk_lokalizacija \
	fmk_rabat \
        hbdebug \
	$(HB_GT_LIB)
               

EXE_NAME=test_all.exe
PRG_MAIN=test_all.prg


include $(TOP)$(ROOT)config/bin.cf


HB_FLAGS = -n -b -ufmk_std.ch -kM -gc0 -I$(TOP) -I$(HB_INC_COMPILE)

test_all.o : test_all.c 
	$(CC) $(CPPFLAGS) $(CFLAGS) $(C_USR) $(CC_IN) test_all.c -otest_all.o

copy:
	cp -v w32/mingw32/test_all.exe /c/sigma/test_fmk_lib_all.exe


run:
	linux/gcc/test_all
