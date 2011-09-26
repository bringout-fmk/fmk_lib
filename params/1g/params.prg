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


#include "sc.ch"

#define  CHR254   254


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/sclib/params/1g/params.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.7 $
 * $Log: params.prg,v $
 * Revision 1.7  2003/01/21 13:36:00  ernad
 * test problem ini
 *
 * Revision 1.6  2002/07/30 17:40:59  ernad
 * SqlLog funkcije - Fin modul
 *
 * Revision 1.5  2002/06/24 07:00:37  ernad
 *
 *
 * GwDiskFree, ciscenja gateway
 *
 * Revision 1.4  2002/06/23 11:57:24  ernad
 * ciscenja sql - planika
 *
 * Revision 1.3  2002/06/21 16:00:51  ernad
 *
 *
 *
 * debug TDB:cRadimUSezona = NIL
 *
 * Revision 1.2  2002/06/19 13:17:30  ernad
 * debug - ubaci sekciju kada je nema
 *
 *
 */
 
/****f* SC_PAR/RPar ***
 
*AUTOR
   ernad.h 

*IME
  RPar
  
*OPIS
   Citanje, pisanje parametara u DBF fajlove

*SYNOPSIS
   RPar(cImeVar, xArg)

*DATUM
   00.00.96

****/

function RPar(cImeVar,xArg)
*{
local cPom, clTip

SEEK cSection+cHistory+cImeVar+"1"

if found() 
  cPom:=""
  clTip:=tip

  do while !eof() .and. (cSection+cHistory+cImeVar==Fsec+cHistory+Fvar)
    cPom+=Fv
    skip
  enddo

  cPom:=left(cPom,AT(chr(CHR254),cPom)-1)
  if clTip="C"
     xArg:=cPom
  elseif clTip=="N"
     xArg:=val(cPom)
  elseif clTip=="D"
     xArg:=ctod(cPom)
  elseif clTip=="L"
     xArg:=iif(cPom=="0",.f.,.t.)
  endif

endif

if clTip=="C" .and. gKonvertPath=="D" .and. ( ":\" $ xArg ) 
    // konvertuj lokacije npr C:\SIGMA -> I:\VAR\DATA1\SIGMA
    KonvertPath(@xArg)
endif

RETURN NIL
*}

/****v SC_PAR/sekcija_KonvertPath ***

*AUTOR
 Ernad Husremovic ernad@sigma-com.net

*IME
 sekcija_KonvertPath

*OPIS
 Pravila promjene direktorija koji su definisu lokacije
 podataka
 
*PRIMJER
 [KonvertPath]
 kNum=3
 k1=C:\SIGMA\FAKT\1 C:\var\data1\SIGMA\FAKT\1
 k2=C:\SIGMA C:\var\data1\SIGMA
 k3=C:\SIGMA\FAKT\K I:\var\data1\SIGMA\K

*BILJESKE

****/


function KonvertPath(cPath)
*{
local cPom, nKNum, cPravilo


nKNum:=VAL(IzFmkIni("KonvertPath", "kNum", "0"))
? "poslije .. ", nKNum
inkey(10)

for i:=1 to nKNum
  cPravilo:=IzFmkIni("KonvertPath", "k"+alltrim(str(i)), "")
  cPIz:=Token(cPravilo, " ",1)
  cPU :=Token(cPravilo, " ",2)
  cPom=STRTRAN(cPom, cPIz, cPU)
  if cPom <> UPPER(cPath)
     // doslo je do promjene
     cPath:=cPom
     exit
  endif
next
return
*}

function WPar(cImeVar, xArg, fSQL, cAkcija)
*{
local cPom, nRec

if TYPE("gSql")<>"C"
	gSql:="N"
endif
if (goModul:lSqlDirektno==nil)
	goModul:lSqlDirektno:=.t.
endif

if gReadonly
	return .t.
endif

// ako gSQL nije D onda u svakom slucaju ne radi SQL azuriranja
if (gSQL=="N")
	fSQL:=.f.
endif
if (fSQL==nil)
	fSQL:=.f.
endif
if (cAkcija==nil)
	cAkcija:="A"
endif
if (gSql=="D") .and. (goModul:lSqlDirektno)
	cAkcija:="L"
endif	

seek cSection+cHistory+cImeVar

 if found()
  if flock()
    do while !eof() .and. cSection+cHistory+cImeVar==Fsec+Fh+Fvar
      skip
      nRec:=recno()
      skip -1
      dbdelete2()
      go nRec
    enddo
    if fSQL
      cSQL:="update "+ALIAS()+" SET BRISANO='1' where Fh="+sqlvalue(Fh)+" and FSec="+sqlvalue(FSec)+" and FVar="+sqlvalue(FVar)
	
	if (goModul:lSqlDirektno)
		GwDirektno(cSql)
	else
	      	if cAkcija=="A"
	       		Gw(cSQL, @GW_HANDLE,"A")
		elseif cAkcija=="P"
			Gw(cSQL, @GW_HANDLE,"P")
	      	elseif cAkcija=="D" .or. cAkcija=="Z"
	       		Gw(cSQL, @GW_HANDLE,"D")
	      	endif
	endif
	
      cSQL:="delete from "+ALIAS()+" where Fsec="+sqlvalue(cSection)+" and Fh="+sqlvalue(cHistory)+" and FVar="+sqlvalue(cImeVar)
     
     	NextAkcija(cAkcija)
	
        if (goModul:lSqlDirektno)
       		GwDirektno(cSql)
	else
		if cAkcija=="A"
	       		Gw(cSQL, @GW_HANDLE,"A")
	      	elseif cAkcija=="D" .or. cAkcija=="P"
	       		Gw(cSQL, @GW_HANDLE,"D")
	      	elseif cAkcija=="Z"
	       		Gw(cSQL, @GW_HANDLE,"D")
	      	endif
	endif	   

    endif
  else
    MsgBeep("FLOCK:parametri nedostupni!!")
  endif
  dbunlockall()
 endif


clTip:=valtype(xArg)
if clTip=="C"
  cPom:=xArg
elseif clTip=="N"
  cPom:=str(xArg)
elseif clTip=="D"
  cPom:=dtoc(xArg)
elseif clTip=="L"
  cPom:=iif(xArg,"1","0")
endif
cPom+=chr(CHR254)

cRbr:="0"
do while len(cPom)<>0
	append blank
	if fSQL
		
		if goModul:lSqlDirektno
			sql_append(@GW_HANDLE,"L")
		elseif cAkcija=="A"
	    		sql_append(@GW_HANDLE,"A")
	 	else
	    		sql_append(@GW_HANDLE,"D")
	 	endif
	endif

	Chadd(@cRbr,1)

	replace Fh with chistory,;
		Fsec with cSection,;
		Fvar with cImeVar,;
		tip with clTip,;
		rBr with cRbr,;
		Fv   with left(cPom,15)

	if fSql
	  	sql_azur(.t.)
		NextAkcija(@cAkcija)

		replsql TYPE cAkcija Fh with chistory,;
			Fsec with cSection,;
		  	Fvar with cImeVar,;
		  	tip with clTip,;
		  	rBr with cRbr,;
		  	Fv   with left(cPom,15)

	endif

	cPom:=substr(cPom,16)
enddo

return nil
*}

static function NextAkcija(cAkcija)
*{

if goModul:lSqlDirektno
	cAkcija:="L"
endif

if cAkcija=="A"
	cAkcija:="A"
elseif cAkcija=="P" .or. cAkcija=="D"
	cAkcija:="D"
elseif cAkcija=="Z"
	cAkcija:="Z"
endif

return
*}

function Params1()
*{
local ncx,ncy,nOldc

if cHistory=="*" 

  seek cSection
  do while !eof() .and. cSection==Fsec
    cH:=Fh
    do while !eof() .and. cSection==Fsec .and. ch==Fh
      skip
    enddo
    AADD(aHistory,{ch})
  enddo

  if len(aHistory)>0
   @ -1,70 SAY ""
   cHistory:=(ABrowse(aHistory,10,1,{|ch|  HistUser(ch)}))[1]
  else
   cHistory:=" "
  endif
endif

return NIL
*}

function Params2()
*{
local ncx,ncy,nOldC

tone(320,1)
tone(320,1)
return .t.

function HistUser(Ch)
*{
local nRec,cHi

do case
 case Ch==K_ENTER
  return DE_ABORT
 case Ch=K_CTRL_T
  if len(aHistory)>1
   cHi:=aHistory[aBrowRow(),1]
   ADEL(aHistory,aBrowRow())
   ASIZE(aHistory,len(aHistory)-1)
   seek cSection+cHi
   do while !eof() .and. cSection+cHi==Fsec+Fh
	skip
      	nRec:=recno()
	skip -1
      	delete
      	go nRec
   enddo
  else
    Beep(2)
  endif
  return DE_REFRESH
  // izbrisi tekuci element
 otherwise
  return DE_CONT
endcase

return nil
*}
