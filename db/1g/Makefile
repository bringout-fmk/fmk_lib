VERZIJA=CDX
MODUL=sc1g_db

OS_NAME=$(shell uname)

ifeq "$(OS_NAME)" "Linux"
  include $(SC_BUILD_HOME_DIR)/sclib/Makefile_clipper_linux
else
  include $(SC_BUILD_HOME_DIR)/sclib/Makefile_clipper
endif

SRCDOSROOT=c:\\dev\\af\\cl-sclib\\sclib\\db\\1g\\

PRGS=db.prg db_adm.prg db_cre.prg db_sez.prg qry_lang.prg kompat.prg
CS=
ASMS=

OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)


all: $(OBJS)
	echo $(SC_BUILD_HOME_DIR)
	rm -f $(MODUL).lib 
	$(LIBEXE) $(MODUL) $(LIBCMD) ,,
	cp $(MODUL).lib $(LIB_DEST)
	cp sc_db.ch $(CLIPPERROOT)/$(VERZIJA)/

clean:
	echo SC_BUILD_HOME_DIR=$(SC_BUILD_HOME_DIR)
	rm -f *~
	rm -f *.xref
	rm -f *.xrefs
	rm -f *.html
	rm -f *.OBJ *.obj
	rm -f xref_files
	rm -f $(OBJS) *.bak *.BAK

