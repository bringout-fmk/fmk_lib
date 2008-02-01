ROOT = ../../harbour/

HB_INC_COMPILE += $(TOP)../../include

PRG_SOURCES= \
   browse.prg \
   print.prg \
   codes_common.prg \
   konta.prg \
   opstine.prg \
   partneri.prg \
   poredi_firme.prg \
   rnal.prg \
   valute.prg \
   vrste_naloga_dokumenata.prg \
   fakt_doks_txt.prg


LIBNAME=fmk_codes

include $(TOP)$(ROOT)config/lib.cf

CFLAGS := -I/usr/lib/ruby/1.8/i486-linux/ -I/usr/include/harbour

HB_FLAGS = -n -ufmk_std.ch -kM -gc0 -I$(TOP) -I$(HB_INC_COMPILE) -I/usr/include/harbour
