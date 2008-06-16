ROOT = ../../harbour/harbour/

HB_INC_COMPILE += -I$(TOP)../include 

PRG_SOURCES= \
        db.prg \
        main.prg \
        mnu_evn.prg \
	rpt_evn.prg



LIBNAME=fmk_event

include $(TOP)$(ROOT)config/lib.cf


HB_FLAGS = -n -ufmk_std.ch -kM -gc0 -I$(TOP) -I$(HB_INC_COMPILE) 
