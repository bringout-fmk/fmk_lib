VERZIJA=CDX
MODUL=sc1g_pr

OS_NAME=$(shell uname)
ifeq "$(OS_NAME)" "Linux"
  include $(SC_BUILD_HOME_DIR)/sclib/Makefile_clipper_linux
else
  include /sclib/Makefile_clipper
endif


SRCDOSROOT=c:\\dev\\af\\cl-sclib\\sclib\\print\\1g\\


PRGS=print.prg ptxt.prg
CS=
ASMS=isprint.asm lptswap.asm

OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)

all: $(OBJS)
	rm -f $(MODUL)$(LIBEXT) 
	$(LIBEXE) "$(MODUL)$(LIBEXT) $(LIBCMD) $(LIBSUFFIX)"
	cp $(MODUL)$(LIBEXT) $(LIB_DEST)

	
clean:
	rm -f *~
	rm -f *.xref
	rm -f *.xrefs
	rm -f *.html
	rm -f *.OBJ *.obj *.o
	rm -f xref_files
	rm -f $(OBJS) *.bak *.BAK


