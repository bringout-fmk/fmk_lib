ROOT = ../../harbour/harbour/

HB_INC_COMPILE += -I$(TOP)../include

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
   fakt_doks_txt.prg \
   roba.prg tarifa.prg sifk.prg trfp.prg rpt_cjenovnik.prg \
   codes_util_2.prg \
   ugov.prg gen_ugov.prg \
   roba_db_admin.prg \
   konta_tipovi_cijena.prg \
   sastavnice.prg \
   rpt_sastavnice.prg

LIBNAME=fmk_codes

include $(TOP)$(ROOT)config/lib.cf


HB_FLAGS = -n -ufmk_std.ch -kM -gc0 -I$(TOP) -I$(HB_INC_COMPILE) 
