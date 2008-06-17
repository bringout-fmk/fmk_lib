DIRS = fmk_codes fmk_common fmk_event fmk_security fmk_skeleton fmk_db fmk_ui

all: compile install

compile:
	for d in $(DIRS); do \
	 make -C $$d; \
	done

install:
	scripts/cp_fmk_libs_to_hb_lib.sh

clean:
	for d in $(DIRS); do \
	 make -C $$d clean; \
	done
copy4debug:
	for d in $(DIRS); do \
	 cp -v $$d/*.prg /c/sigma; \
	done
