VERZIJA=CDX
MODUL=sc1g_db

include /sclib/Makefile_clipper

SRCDOSROOT=c:\\dev\\af\\cl-sclib\\sclib\\db\\1g\\

PRGS=db.prg db_adm.prg db_cre.prg db_sez.prg qry_lang.prg kompat.prg
CS=
ASMS=


OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)



ifdef CLIP


all: $(OBJS)
	clip_makeslib $(MODUL)$(LIBEXT) $(LIBCMD)
	cp $(MODUL).dll* $(LIB_DEST)

else
all: $(OBJS)
	rm -f $(MODUL).lib 
	$(LIBEXE) $(MODUL) $(LIBCMD) ,,
	cp $(MODUL).lib $(LIB_DEST)
	cp sc_db.ch $(CLIPPERROOT)/$(VERZIJA)/
endif

clean:
	rm -f *~
	rm -f *.xref
	rm -f *.xrefs
	rm -f *.html
	rm -f *.OBJ *.obj
	rm -f xref_files
	rm -f $(OBJS) *.bak *.BAK

