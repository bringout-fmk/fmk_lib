ROOT = ../../harbour/harbour/

HB_INC_COMPILE += -I$(TOP)../include 

PRG_SOURCES= \
        file_io.prg  os_util.prg \
        bh_slova.prg \
        ini.prg \
        params.prg \
        print.prg \
	print_epl2.prg \
	print_pdf.prg \
	print_ptxt.prg \
	print_gvim.prg \
        util.prg \
        dummy.prg \
        array_util.prg \
        string_util.prg \
        report_common.prg \
        report_common_2.prg \
        rtf.prg \
        report_fmk_proizvoljni.prg \
        time_util.prg \
        fmk_util.prg \
        log.prg


LIBNAME=fmk_common

include $(TOP)$(ROOT)config/lib.cf


HB_FLAGS := -n -ufmk_std.ch -kM -gc0  -I$(TOP) -I$(HB_INC_COMPILE)
