ROOT = ../../harbour/

HB_INC_COMPILE += $(TOP)../../include

PRG_SOURCES= \
        skeleton.prg \
        err.prg  gvars.prg  gw.prg \
        install.prg \
        app.prg db.prg \
        arhiviraj.prg \
        specif_vars.prg \
        global_vars.prg \
        global_vars_roba.prg \
        desktop.prg


LIBNAME=fmk_skeleton

include $(TOP)$(ROOT)config/lib.cf

CFLAGS := -I/usr/lib/ruby/1.8/i486-linux/ -I/usr/include/harbour

HB_FLAGS = -n -b -ufmk_std.ch -kM -gc0 -I$(TOP) -I$(HB_INC_COMPILE) -I/usr/include/harbour
