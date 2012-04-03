#!/bin/bash

dosemu -dumb -E "c:\\dev\\clp_bc\\c52.bat $@"


$(SC_BUILD_HOME_DIR)/sclib/lowercase *.OBJ
