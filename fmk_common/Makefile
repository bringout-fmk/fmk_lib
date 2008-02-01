ROOT = ../../harbour/

HB_INC_COMPILE += $(TOP)../../include

PRG_SOURCES= \
        file_io.prg  os_util.prg \
        konvzn.prg \
        ini.prg \
        params.prg \
        print.prg \
        util.prg \
        dummy.prg


LIBNAME=fmk_common

include $(TOP)$(ROOT)config/lib.cf

CFLAGS := -I/usr/lib/ruby/1.8/i486-linux/ -I/usr/include/harbour

HB_FLAGS = -n -ufmk_std.ch -kM -gc0 -I$(TOP) -I$(HB_INC_COMPILE) -I/usr/include/harbour
