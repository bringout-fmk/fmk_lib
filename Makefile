
include /cl/sigma/Makefile_clipper

PREF2=/clip/
SVI1A=$(addprefix $(PREF2), $(FMKLIBS) )


LIB=libsclib.a
SLIB=libsclib.dll.a

all:
	rm -f cui/1g/cui.obj
	cp sc.ch /clipper
	cp sc.ch /clipper/debug
	make -C arh/1g
	make -C base/1g
	make -C base/2g
	make -C db/1g
	make -C db/2g
	make -C sif/1g
	make -C sql/1g
	make -C os/1g
	make -C ut/1g
	make -C print/1g
	make -C cui/1g
	make -C cui/2g
	make -C params/1g
	make -C ostalo/1g
	make -C rpt/1g
	make -C keyb/1g


clean:
	cp sc.ch /clipper
	cp sc.ch /clipper/debug
	cd arh/1g; make clean
	cd base/1g; make clean
	cd base/2g; make clean
	cd db/1g; make clean
	cd db/2g; make clean
	cd sif/1g; make clean
	cd sql/1g; make clean
	cd os/1g; make clean
	cd ut/1g; make clean
	cd print/1g; make clean
	cd cui/1g; make clean
	cd cui/2g; make clean
	cd params/1g; make clean
	cd ostalo/1g; make clean
	cd rpt/1g; make clean
	cd keyb/1g; make clean
	rm -f *.obj

lib:	
	rm -f *.o
	./arlibs
	clip_makeslib $(SLIB) *.o

