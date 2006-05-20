VERZIJA=CDX
MODUL=sc1g_pr

include $(SC_BUILD_HOME_DIR)/sclib/Makefile_clipper


SRCDOSROOT=c:\\dev\\af\\cl-sclib\\sclib\\print\\1g\\


PRGS=print.prg ptxt.prg
CS=
ASMS=isprint.asm lptswap.asm

OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)

all:
	lib
	
clean:
	rm -f *~
	rm -f *.xref
	rm -f *.xrefs
	rm -f *.html
	rm -f *.OBJ *.obj *.o
	rm -f xref_files
	rm -f $(OBJS) *.bak *.BAK


