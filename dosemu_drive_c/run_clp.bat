cd %1

SET PATH=z:\bin;z:\gnu;z:\dosemu;
set PATH=%PATH%;C:\clipper\bin;c:\clipper\c5\bin
set INCLUDE=C:\CLIPPER\INCLUDE;c:\git\fmk_lib\;c:\git\fmk_c\cdx;c:\clipper\comix;c:\clipper\csy\include
set LIB=c:\clipper\lib;c:\clipper\comix;c:\git\fmk_lib\lib;c:\clippper\csy\lib

clipper %2 %3 %4 %5 %6 %7 %8

exitemu
