VERZIJA=CDX
MODUL=sc1g_par

include /sclib/Makefile_clipper

SRCDOSROOT=c:\\dev\\af\\cl-sclib\\sclib\\params\\1g\\


PRGS=params.prg ini.prg
CS=
ASMS=


SCLIB_LIBS=sc1g_arh.lib sc1g_ba.lib sc1g_cui.lib sc1g_db.lib sc1g_os.lib sc1g_ost.lib sc1g_pr.lib sc1g_sif.lib sc1g_sql.lib sc1g_ut.lib sc2g_app.lib sc2g_db.lib 
FMK_LIBS=
MODUL_LIBS=

PREF2=lib
FMKLIBCMD=$(addprefix $(PREF2) , $(SCLIB_LIBS) $(FMK_LIBS) $(MODUL_LIBS) )


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

test: 
	$(CLIPPERCOMP) $(SRCDOSROOT)ini.prg $(CLIPPERFLAGS) /DTEST 
	#/cl/sigma/form_blinker_lnk.sh $(LINKCMD)
	#/cl/sigma/form_blinker_lnk_2.sh $(FMKLIBCMD)
	$(LINKEREXE) fi ini $(DEBUGLINK) @P:\\CLIPPER\\$(VERZIJA)\\BL.LNK output e.exe
	
clean:
	rm -f *~
	rm -f *.xref
	rm -f *.xrefs
	rm -f *.html
	rm -f *.OBJ *.obj
	rm -f xref_files
	rm -f $(OBJS) *.bak *.BAK


