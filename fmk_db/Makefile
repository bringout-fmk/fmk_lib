ROOT = ../../harbour/

HB_INC_COMPILE += $(TOP)../../include

PRG_SOURCES= \
        db_adm.prg  db_cre.prg  db.prg  db_sez.prg  kompat.prg qry_lang.prg \
        sql.prg


LIBNAME=fmk_db

include $(TOP)$(ROOT)config/lib.cf

CFLAGS := -I/usr/lib/ruby/1.8/i486-linux/ -I/usr/include/harbour

HB_FLAGS = -n -ufmk_std.ch -kM -gc0 -I$(TOP) -I$(HB_INC_COMPILE) -I/usr/include/harbour
