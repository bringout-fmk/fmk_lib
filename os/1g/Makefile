VERZIJA=CDX
MODUL=sc1g_os

include /sclib/Makefile_clipper

SRCDOSROOT=c:\\dev\\af\\cl-sclib\\sclib\\os\\1g\\


PRGS=os_ut.prg file_io.prg
CS=

ifdef CLIP
	ASMS=
else
	ASMS=mkdir.asm rmdir.asm setdate.asm settime.asm
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
	rm -f *.OBJ *.obj
	rm -f xref_files
	rm -f $(OBJS) *.bak *.BAK



#
# create xrefs file (file with the names of all .xref files).
#
SC_CLIB.xrefs : $(XREFS) $(SOURCES)
	/bin/ls *.xref > $@

%.xref: %  
	$(ROBODOC) $< $(@:.xref=.html) INTERNAL -g $@ -v


index.html : SC_CLIB.xrefs $(DOCS)
	$(ROBODOC) $< $@ INDEX HTML

%.html: %
	 $(ROBODOC) $< $@ HTML INTERNAL -x SC_CLIB.xrefs -v


#include makefile_doc

