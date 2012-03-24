rem cd %1

set PATH=%PATH%;C:\clipper\bin
set INCLUDE=C:\CLIPPER\INCLUDE;c:\git\fmk_lib\;c:\git\fmk_c\cdx;c:\clipper\comix;c:\clipper\csy\include
set LIB=c:\clipper\lib;c:\clipper\comix;c:\git\fmk_lib\lib;c:\clippper\csy\lib


c:\clipper\c5\bin\masm %1 %2 %3 %4 %5 %6 %7 %8 %9 ,,,,

exitemu
