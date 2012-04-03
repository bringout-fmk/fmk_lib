#!/bin/sh

dosemu -dumb -E "c:\\dev\\clp_bc\\asm52.bat $@"

$(SC_BUILD_HOME_DIR)/sclib/lowercase *.OBJ
rm *.CRF
rm *.LST
