@echo off
rem autoexec.bat for DOSEMU + FreeDOS
path z:\bin;z:\gnu;z:\dosemu
set HELPPATH=z:\help
set TEMP=c:\tmp
rem blaster
prompt $P$G
unix -s DOSDRIVE_D
if "%DOSDRIVE_D%" == "" goto nodrived
lredir del d: > nul
lredir d: linux\fs%DOSDRIVE_D%
:nodrived
rem uncomment to load another bitmap font
rem loadhigh display con=(vga,852,1)
rem mode con codepage prepare=((852) z:\cpi\ega.cpx)
rem mode con codepage select 852
rem chcp 852
lredir e: linux\fs/media/cdrom c
unix -s DOSEMU_VERSION
echo "Welcome to dosemu %DOSEMU_VERSION%!"
unix -e
