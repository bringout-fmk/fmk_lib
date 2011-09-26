/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */



/*! \file sclib/sql/1g/sql_ext.prg
 *  \brief Komande direktno upucene externoj SQL bazi
 *  \note Koristeno za CROBA, sada je neaktivno
 */

/*
 sqlResult("c:\sigma\sqlout.sql",{"C","C","D","N"})
*/
function sqlresult(cFile, aSQLType )
*{
local cLin,ctok
local i
local aResult, aSQLRow

nH:=FOPEN(cFile)
if nH<0 
  aResult:={"ERR"}
else
  cLin:="startxyz"
  aResult:={{"OK",0}}
  do while !empty(cLin)
       cLin:=FREADLN(nh,1,250)
       nTok := NUMTOKEN( cLin , chr(9), 1 )
       if aSQLType<>NIL .and. len(aSQLType)<>nTok
          // nema vise slogova
          exit
       endif

       aSQLRow:={}
       FOR i:= 1 TO nTok
         cTok := TOKEN( cLin , chr(9) , i , 1 )
         if aSQLType<>NIL // prosljedjeni su tipovi rezultata
            if aSQLType[i]="N"
               cTok:=Val(cTOK)
            elseif aSQLType[i]="D"
               //1234-67-9A
               cTOK:=CTOD( substr(cTOK,9,2)+"."+substr(cTok,6,2)+"."+substr(cTok,1,4) )
            endif      
         endif   
         AADD(aSQLRow,cTOK)
       next
       AADD(aResult,aSQLRow)
       // record count
       aResult[1,2]:=aResult[1,2] + 1      
  enddo
endif
fclose(nh)
return aResult
*}

/*
sqlselect("c:\sigma\sql", test, "select y,y from partn xxxx yyyy")
*/
function sqlselect(cFile, cDatabase, cSQL, aSQLType)
*{
//static SQLKom:="mysql -f -h localhost -B -N "
local  nH

private cKomLin:=""
nH:= fcreate(cFile)
if nH<=0
  return {"ERR"}
endif
fwrite(nH,cSQL)
fclose(nH)
// neka rezultat ide u sqlout
cKomLin:=gSQLKom+cDatabase+" < "+cFile+" > c:\sigma\sqlout"
run &cKomLin

// daj mi matricu rezultata
return sqlresult("c:\sigma\sqlout", aSQLType )
*}


/*
   ("c:\sigma\sql", test, "insert into partn xxxx yyyy")
*/

function sqlexec(nH, cFile, cDatabase, cSQL)
*{
local fOdmah:=.f.

private cKomLin:=""
if cFile=="#CONT"
  // fajl je vec otvoren
elseif Left(cFile,5)=="#END#"
  // fajl je vec otvoren
else 
    if (nH==-999)
       // kreiraj i odmah izvrsi
      fOdmah:=.t.
    endif
    nH:=Fcreate(cFile)
  
endif  

if (nH<=0)
  return "ERR"
endif

FWRITE(nH,cSQL+";"+NRED)

if LEFT(cFile,5)=="#END#"
	// kraj zavrsi
	fOdmah:=.t.
	cFile:=substr(cFile,6)
endif

if fOdmah
  // zavrsi posao ...........
  fclose(nH)
  save screen to cScr
   clear
   cKomLin:=gSQLKom+cDatabase+" < "+cFile
   run &cKomLin
   if IzFmkIni('CROBA','Stani','N',PRIVPATH)=="D"
    // moze dobro doci za debugiranje i podesavanje, da vidimo sta je
    // mysql client prijavio
    inkey(0)
   endif
  restore screen from cSCR
endif  

return "OK"
*}

