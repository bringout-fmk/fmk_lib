VERZIJA=CDX
MODUL=sc1g_cui

include /sclib/Makefile_clipper

SRCDOSROOT=h:\\dev\\af\\cl-sclib\\sclib\\cui\\1g\\


PRGS=cgrid.prg cui.prg std_dlg.prg
CS=
ASMS=

OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)


ifdef CLIP

all: $(OBJS)
	clip_makeslib $(MODUL)$(LIBEXT) $(LIBCMD)
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


