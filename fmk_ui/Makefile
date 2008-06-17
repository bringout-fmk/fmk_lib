ROOT = ../../harbour/harbour/

HB_INC_COMPILE += -I$(TOP)../include

PRG_SOURCES= \
  cgrid.prg cui.prg std_dlg.prg \
  event.prg fvidi.prg get_extend.prg

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

HB_FLAGS = -n -ufmk_std.ch -kM -gc0 -I$(TOP) -I$(HB_INC_COMPILE)
