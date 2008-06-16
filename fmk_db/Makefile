ROOT = ../../harbour/harbour/

HB_INC_COMPILE += -I$(TOP)../include

PRG_SOURCES= \
        db_adm.prg  db_cre.prg db_cre_2.prg  db.prg  db_sez.prg  kompat.prg qry_lang.prg \
        sql.prg sql_db.prg db_cre_roba.prg \
        db_cre_proizvoljni_izvjestaji.prg \
	db_strings.prg \
        sql_util.prg


LIBNAME=fmk_db

include $(TOP)$(ROOT)config/lib.cf


HB_FLAGS = -n -ufmk_std.ch -kM -gc0 -I$(TOP) -I$(HB_INC_COMPILE)
