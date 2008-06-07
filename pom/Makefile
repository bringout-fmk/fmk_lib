VERZIJA=CDX
MODUL=sc_clib

ifeq "${CLIP}" "1"
	include /sclib/makefile_clip
else
	include /sclib/makefile_clipper
endif

PRGS=sc_base.prg sc_cui.prg sc_db.prg sc_sqldb.prg sc_adb.prg sc_ausr.prg sc_asez.prg sc_cgrid.prg sc_bsif.prg sc_rpt.prg sc_fmkpi.prg sc_prn.prg sc_gprn.prg sc_fvidi.prg sc_event.prg sc_par.prg sc_sql.prg sc_ql.prg sc_err.prg sc_arh.prg os_ut.prg str_ut.prg sql_ut.prg sc_dlg.prg sc_kzn.prg fmk_ut.prg time_ut.prg num_ut.prg rtf_ut.prg gen_ut.prg sc_ini.prg sc_get.prg sc_arr.prg cre_db.prg gvars.prg table.prg 

CS=ARG0.C
ASMS=BSORT.ASM SETDATE.ASM SETTIME.ASM LPTSWAP.ASM MKDIR.ASM RMDIR.ASM

OBJPRGS=$(PRGS:.prg=.o)
OBJCS=$(CS:.c=.obj)
OBJASMS=$(ASMS:.c=.obj)

#LIBCMD=$(addprefix +, $(OBJPRGS) $(OBJASMS) $(OBJCS) )

#napravi dokumente

DOCS=$(PRGS:.PRG=.html)
XREFS=$(DOCS:.html=.xref)

OBJS=$(OBJPRGS)
#$(OBJCS) $(OBJASMS)

.SUFFIXES: .prg .c. .po

DLLSUFF=.dll.a
EXESUFF=.exe
DLLREALSUFF=.dll
LIB = libclip-$(MODUL).a
SLIB = libclip-$(MODUL)$(DLLSUFF)
SLIBREAL=libclip-$(MODUL)$(DLLREALSUFF)

TARGET=libclip-$(MODUL)$(DLLSUFF)
LIBS= $(LIB)

all: $(OBJS)
	echo $(OBJS)
	ar -r libclip-$(MODUL).a $(OBJS)
	$(CLIPROOT)/bin/clip_makeslib $(TARGET) $(LIBS)
	cp libclip-$(MODUL)* $(CLIPROOT)/lib
	#$(LIBEXE) SC_CLIB $(LIBCMD) ,,
	#cp SC_CLIB.lib $(CLIPPERROOT)$(DEBUGDIR)/$(VERZIJA)/
	#cp ./$(DEBUGDIR2)$(VERZIJA)/*.LNK $(CLIPPERROOT)$(DEBUGDIR)/$(VERZIJA)/
	#cp ./$(DEBUGDIR2)*.CH $(CLIPPERROOT)$(DEBUGDIR)

sregs: SREGS.OBJ FMK_UT.OBJ
	$(LINKEREXE) fi SREGS.OBJ fi FMK_UT.OBJ $(DEBUGLINK) @H:\\CLIPPER$(DEBUGDIR)\\$(VERZIJA)\\BL.LNK   output SREGS.exe
	cp SREGS.exe $(EXEDEST)/SREGS.EXE

	
clean:
	rm -f *~
	rm -f *.xref
	rm -f *.xrefs
	rm -f *.html
	rm -f xref_files
	rm -f $(OBJS) *.bak *.BAK
	rm -f SREG.OBJ


.prg.o:
	$(CLIPPERCOMP)  $(CLIPPERFLAGS) $< 
	
.asm.obj:
	$(ASMCOMP) $(ASMFLAGS) $< 

.c.o:
	$(CCOMP) $(CFLAGS) $<

