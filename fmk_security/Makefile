ROOT = ../../harbour/

HB_INC_COMPILE += $(TOP)../../include 
#HB_FLAGS = -n -q0 -w2 -es2 -gc0 -kM -I$(TOP) -I$(HB_INC_COMPILE)

PRG_SOURCES= \
        db.prg \
        main.prg \
        mnu_sec.prg



LIBNAME=fmk_security

include $(TOP)$(ROOT)config/lib.cf

CFLAGS := -I/usr/lib/ruby/1.8/i486-linux/ -I/usr/include/harbour

HB_FLAGS = -n -ufmk_std.ch -kM -gc0 -I$(TOP) -I$(HB_INC_COMPILE) -I/usr/include/harbour
