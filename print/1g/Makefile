VERZIJA=CDX
MODUL=sc1g_pr

include /sclib/Makefile_clipper

SRCDOSROOT=c:\\dev\\af\\cl-sclib\\sclib\\print\\1g\\


PRGS=print.prg ptxt.prg
CS=
ifdef CLIP
	ASMS=
else
	ASMS=isprint.asm lptswap.asm
endif

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
	rm -f *.OBJ *.obj *.o
	rm -f xref_files
	rm -f $(OBJS) *.bak *.BAK


