VERZIJA=CDX
MODUL=sc1g_ba

include /sclib/Makefile_clipper

SRCDOSROOT=c:\\dev\\af\\cl-sclib\\sclib\\base\\1g\\


PRGS=base.prg err.prg gvars.prg gw.prg

ifdef CLIP
	CS=
else
	CS=arg0.c
endif

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
	cp std.ch $(CLIPPERROOT)/$(VERZIJA)/
	cp /sclib/$(VERZIJA)/bl.lnk $(CLIPPERROOT)/$(VERZIJA)/
	cp  o_s_baze.ch no_cui.ch end_mprg.ch sc_std.ch  $(CLIPPERROOT)$(DEBUGDIR)/

endif
	
clean:
	rm -f *~
	rm -f *.xref
	rm -f *.xrefs
	rm -f *.html
	rm -f *.OBJ *.obj
	rm -f xref_files
	rm -f $(OBJS) *.bak *.BAK


