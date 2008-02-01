#include "fmk.ch"
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/sclib/sql/1g/sql_ut.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.5 $
 * $Log: sql_ut.prg,v $
 * Revision 1.5  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.4  2002/06/24 07:00:37  ernad
 *
 *
 * GwDiskFree, ciscenja gateway
 *
 * Revision 1.3  2002/06/23 11:57:24  ernad
 * ciscenja sql - planika
 *
 * Revision 1.2  2002/06/19 19:51:00  ernad
 *
 *
 * rad u sezonama, gateway
 *
 *
 */
 
function Log_Tabela(cTn)
*{
local cSQL
local i
local aStruct
local nSet
local fNoviCiklus
local cAkcija
private cImeP

GW_STATUS="GEN_SQL_LOG"


GW_HANDLE:=0

islog:=0
fNoviCiklus:=.t.
GW_HANDLE:=0
nCnt:=0

if goModul:lSqlDirektno
	cAkcija:="L"
else
	cAkcija:="P"
endif


GO TOP
do while !EOF()

   // dodaj ovaj slog
   nCnt++
   @ 24,60 SAY str(nCnt,4)

   sql_append(@GW_HANDLE, cAkcija)
   // procitaj vrijednosti
   scatter()
   //update komanda na osnovu procitanih vrijednosti

   if !goModul:lSqlDirektno  
	   if Len(GW_STRING())>6000 // 6 kb
	      islog:=0
	      cAkcija:="Z"
	   else
	      cAkcija:="D"
	   endif
   endif
	
   // "_" - ime varijable, .f. - ne dodaji slog

   Gathsql("_",.f., @GW_HANDLE, cAkcija)
   if !goModul:lSqlDirektno  
   	if cAkcija="Z"
      		cAkcija:="P"
   	endif
   endif


  skip
enddo

if !goModul:lSqlDirektno .and. cAkcija<>"Z"
 // zatvori zadnju komandu
 Gw("", @GW_HANDLE,"Z")
endif

return
*}
