ROOT = ../../harbour/harbour/

#DIR = `pwd` | sed -e "s/^\/c/c:/" | sed -e "s/\//\\\/g" 
#BDIR = $( `echo "c:/test" | sed -e "s/^\/c/c:/"` ) 

BDIR = $(shell pwd | sed -e "s/^\/c/c:/")

HB_INC_COMPILE += -I$(TOP)../include

PRG_SOURCES= \
        skeleton.prg \
        fmk_errors.prg gw.prg \
        install.prg \
        app.prg db.prg \
        arhiviraj.prg \
        global_vars_0.prg \
        global_vars.prg \
        global_vars_roba.prg \
        desktop.prg \
	specifificnosti_vars.prg

LIBS=\
        hbextern 


LIBNAME=fmk_skeleton

include $(TOP)$(ROOT)config/lib.cf


HB_FLAGS = -n -b -ufmk_std.ch -kM -gc0 -I$(TOP) -I$(HB_INC_COMPILE)
ifneq ($(FMK_DEBUG),)
HB_FLAGS += -dFMK_DEBUG=1 
endif

