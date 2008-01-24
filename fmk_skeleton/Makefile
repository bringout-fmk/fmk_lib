ROOT = ../../harbour/

HB_INC_COMPILE += $(TOP)../../include

PRG_SOURCES= \
        app.prg  skeleton.prg  db.prg  err.prg  gvars.prg  gw.prg



LIBNAME=fmk_security

include $(TOP)$(ROOT)config/lib.cf

CFLAGS := -I/usr/lib/ruby/1.8/i486-linux/ -I/usr/include/harbour

HB_FLAGS = -n -ufmk_std.ch -kM -gc0 -I$(TOP) -I$(HB_INC_COMPILE) -I/usr/include/harbour
