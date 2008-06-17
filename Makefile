all: compile install

compile:
	make -C fmk_codes
	make -C fmk_common
	make -C fmk_event
	make -C fmk_security
	make -C fmk_skeleton
	make -C fmk_db
	make -C fmk_ui

install:
	scripts/cp_fmk_libs_to_hb_lib.sh

clean:
	make -C fmk_codes clean
	make -C fmk_common clean
	make -C fmk_event clean
	make -C fmk_security clean
	make -C fmk_skeleton clean
	make -C fmk_db clean
	make -C fmk_ui clean
