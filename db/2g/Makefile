VERZIJA=CDX
MODUL=sc2g_db

include /sclib/Makefile_clipper

SRCDOSROOT=h:\\dev\\af\\cl-sclib\\sclib\\db\\2g\\


PRGS=db.prg
CS=
ASMS=

OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)

ifdef CLIP
all: $(OBJS)
	clip_makeslib $(MODUL).dll.a $(LIBCMD)
	cp $(MODUL).dll* $(LIB_DEST)

else
all: $(OBJS)
	rm -f $(MODUL)$(LIBEXT) 
	$(LIBEXE) $(MODUL)$(LIBEXT) $(LIBCMD) $(LIBSUFFIX)
	cp $(MODUL)$(LIBEXT) $(LIB_DEST)
endif
	
clean:
	rm -f *~
	rm -f *.xref
	rm -f *.xrefs
	rm -f *.html
	rm -f *.OBJ *.obj
	rm -f xref_files
	rm -f $(OBJS) *.bak *.BAK



