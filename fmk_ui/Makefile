ROOT = ../../harbour/

HB_INC_COMPILE += $(TOP)../../include

PRG_SOURCES= \
  cgrid.prg  cui.prg std_dlg.prg \
  event.prg scget.prg  fvidi.prg

LIBS=\
        vm \
        rtl \
        lang \
        rdd \
        rtl \
        vm \
        macro \
        pp \
        dbfntx \
        dbfcdx \
        dbffpt \
        common \
        gttrm \
        fmk_common
      
LIBNAME=fmk_ui

include $(TOP)$(ROOT)config/lib.cf

CFLAGS := -I/usr/lib/ruby/1.8/i486-linux/ -I/usr/include/harbour -L/usr/lib/harbour

HB_FLAGS = -n -ufmk_std.ch -kM -gc0 -I$(TOP) -I$(HB_INC_COMPILE) -I/usr/include/harbour
