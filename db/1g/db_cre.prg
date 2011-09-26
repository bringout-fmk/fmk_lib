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

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */

function CreKorisn(nArea)
*{
local cImeDBF

if nArea==nil
	nArea:=-1
endif

if (nArea==-1 .or. nArea==F_KORISN)
	 cImeDBF:=ToUnix(".\korisn.dbf")
	 //? "File ",cImeDBF,"ima li ga ?", File(cImeDBF)
	 IF !FILE(cImeDBF)
	  aDbf:={}
	  AADD(aDbf,{"ime","C",10,0})
	  AADD(aDbf,{"sif","C",6,0})
	  AADD(aDbf,{"dat","D",8,0})
	  AADD(aDbf,{"time","C",8,0})
	  AADD(aDbf,{"prov","N",4,0})  // brojac neispravnih pokusaja ulaza
	  AADD(aDbf,{"nk","L",1,0})
	  AADD(aDbf,{"level","C",1,0})
	  AADD(aDbf,{"DirRad","C",40,0})
	  AADD(aDbf,{"DirSif","C",40,0})
	  AADD(aDbf,{"DirPriv","C",40,0})
	  DBCREATE2(cImeDBF,aDbf)
	  USE (cImeDBF)

	  APPEND BLANK
	  REPLACE ime WITH "SYSTEM"        ,  ;               && SYSTEM
		  sif WITH CryptSC("SYSTEM") ,  ;
		  dat WITH  Date()         ,  ;
		  time WITH Time()         ,  ;
		  prov WITH 0              ,  ;
		  level WITH "0"           ,  ;
		  nk WITH .F.              ,  ;
		  level with "0"           ,  ;
		  DirRad  with             '*'  ,;
		  DirSif  with             '*'  ,;
		  DirPriv with             '*'
	   USE
	 ENDIF
	 //? "Create_Index KORISN/IME"
	 
	 CREATE_INDEX("IME","ime",ToUnix(".\korisn.dbf"),.t.)
endif

return
*}

/*! \fn CreSystemDb()
 *  \brief Kreiraj sistemske tabele (gparams, params, adres, ...)
 */
function CreSystemDb(nArea)
*{
local lShowMsg

lShowMsg:=.f.

if (nArea==nil)
	nArea:=-1

	if goModul:oDatabase:lAdmin
		lShowMsg:=.t.
	endif

endif

if lShowMsg
	MsgO("Kreiram systemske tabele")
endif
CreGParam(nArea)
CreParams(nArea)
CreAdres(nArea)
if lShowMsg
	MsgC()
endif

return
*}

function CreParams(nArea)
*{
close all

if gReadOnly
	return
endif

if (nArea==nil)
	nArea:=-1
endif

aDbf:={}
AADD(aDbf, {"FH","C",1,0} )  // istorija
AADD(aDbf, {"FSec","C",1,0} )
AADD(aDbf, {"FVar","C",2,0} )
AADD(aDbf, {"Rbr","C",1,0} )
AADD(aDbf, {"Tip","C",1,0} ) // tip varijable
AADD(aDbf, {"Fv","C",15,0}  ) // sadrzaj

if (nArea==-1 .or. nArea==F_PARAMS)

	if !file(ToUnix(PRIVPATH+"params.dbf"))
		DBCREATE2(PRIVPATH+"params.dbf",aDbf)
	endif
	CREATE_INDEX("ID","fsec+fh+fvar+rbr",PRIVPATH+"params.dbf",.t.)
	
endif


#ifndef CLIP
//......... izbaciti ... ovoga odavno nema
//KonvParams(PRIVPATH+"gparams.dbf")
//KonvParams(PRIVPATH+"params.dbf")
//KonvParams(".\mparams.dbf")
//KonvParams(KUMPATH+"kparams.dbf")
#endif

if (nArea==-1 .or. nArea==F_GPARAMS)
	if !file(ToUnix(PRIVPATH+"gparams.dbf"))
	 DBCREATE2(PRIVPATH+"gparams.dbf",aDbf)
	endif
	CREATE_INDEX("ID","fsec+fh+fvar+rbr",PRIVPATH+"gparams.dbf",.t.)
endif

if (nArea==-1 .or. nArea==F_MPARAMS)
	if !file(ToUnix(".\mparams.dbf"))
	 DBCREATE2(TRUENAME(".\mparams.dbf"),aDbf)
	endif
	CREATE_INDEX("ID","fsec+fh+fvar+rbr",".\mparams",.t.)
endif

if (nArea==-1 .or. nArea==F_KPARAMS)
	if !file(ToUnix(KUMPATH+"KPARAMS.dbf"))
	 DBCREATE2(KUMPATH+"KPARAMS.dbf",aDbf)
	endif
	CREATE_INDEX("ID","fsec+fh+fvar+rbr",KUMPATH+"kparams.dbf",.t.)
endif


aDbf:={}
AADD(aDbf, {"FH","C",1,0} )  // istorija
AADD(aDbf, {"FSec","C",1,0} )
AADD(aDbf, {"FVar","C",15,0} )
AADD(aDbf, {"Rbr","C",1,0} )
AADD(aDbf, {"Tip","C",1,0} ) // tip varijable
AADD(aDbf, {"Fv","C",15,0}  ) // sadrzaj


if (nArea==-1 .or. nArea==F_SECUR)
	cImeDBf:=ToUnix(KUMPATH+"secur.dbf")
	if !file(cImeDBF)
	 DBCREATE2(cImeDBF,aDbf)
	endif
	CREATE_INDEX("ID","fsec+fh+fvar+rbr", cImeDBF, .t.)
endif

return NIL
*}


function CreAdres(nArea)
*{

if (nArea==nil)
	nArea:=-1
endif

if (nArea==-1 .or. nArea==F_KPARAMS)
	if !file(ToUnix(SIFPATH+"ADRES.DBF"))
	  aDBF:={}
	  AADD(aDBf,{ 'ID'    , 'C' ,  50 ,   0 })
	  AADD(aDBf,{ 'RJ'    , 'C' ,  30 ,   0 })
	  AADD(aDBf,{ 'KONTAKT'    , 'C' ,  30 ,   0 })
	  AADD(aDBf,{ 'NAZ'        , 'C' ,  15 ,   0 })
	  AADD(aDBf,{ 'TEL2'       , 'C' ,  15 ,   0 })
	  AADD(aDBf,{ 'TEL3'       , 'C' ,  15 ,   0 })
	  AADD(aDBf,{ 'MJESTO'     , 'C' ,  15 ,   0 })
	  AADD(aDBf,{ 'PTT'        , 'C' ,  6 ,   0 })
	  AADD(aDBf,{ 'ADRESA'     , 'C' ,  50 ,   0 })
	  AADD(aDBf,{ 'DRZAVA'     , 'C' ,  22 ,   0 })
	  AADD(aDBf,{ 'ziror'     , 'C' ,  30 ,   0 })
	  AADD(aDBf,{ 'zirod'     , 'C' ,  30 ,   0 })
	  AADD(aDBf,{ 'K7'     , 'C' ,  1 ,   0 })
	  AADD(aDBf,{ 'K8'     , 'C' ,  2 ,   0 })
	  AADD(aDBf,{ 'K9'     , 'C' ,  3 ,   0 })
	  DBCREATE2(SIFPATH+"ADRES.DBF",aDBf)
	endif
	CREATE_INDEX("ID","id+naz",SIFPATH+"ADRES.DBF")
endif

return
*}


* kreiraj gparams u glavnom modulu
function CreGparam(nArea)
*{
local aDbf
if (nArea==nil)
	nArea:=-1
endif
close all

if gReadonly
	return
endif

aDbf:={}
AADD(aDbf, {"FH","C",1,0} )  // istorija
AADD(aDbf, {"FSec","C",1,0} )
AADD(aDbf, {"FVar","C",2,0} )
AADD(aDbf, {"Rbr","C",1,0} )
AADD(aDbf, {"Tip","C",1,0} ) // tip varijable
AADD(aDbf, {"Fv","C",15,0}  ) // sadrzaj

if (nArea==-1 .or. nArea==F_GPARAMS)
	cImeDBf:=ToUnix("\GPARAMS.DBF")
	if !file(cImeDbf)
		DBCREATE2(cImeDbf,aDbf)
	endif
	CREATE_INDEX("ID","fsec+fh+fvar+rbr", cImeDBF )
endif

return
*}


function KonvParams(cImeDBF)
*{
cImeDBF:=ToUnix(cImeDBF)
close  all
if file(cImeDBF) // ako postoji
use (cImeDbf)
if fieldpos("VAR")<>0  // stara varijanta parametara
       save screen to cScr
       cls
       Modstru(cImeDbf,"C H C 1 0  FH  C 1 0",.t.)
       Modstru(cImeDbf,"C SEC C 1 0  FSEC C 1 0",.t.)
       Modstru(cImeDbf,"C VAR C 2 0 FVAR C 2 0",.t.)
       Modstru(cImeDbf,"C  V C 15 0  FV C 15 0",.t.)
       Modstru(cImeDbf,"A BRISANO C 1 0",.t.)  // dodaj polje "BRISANO"
       inkey(2)
       restore screen from cScr
endif
endif
close all
return
*}

function DBCREATE2(cIme,aDbf,cDriver)
*{
local nPos
local cCDX

cIme:=ToUnix(cIme)
nPos:=ASCAN(aDbf,  {|x| x[1]=="BRISANO"} )
if nPos==0
	AADD(aDBf,{ 'BRISANO'      , 'C' ,  1 ,  0 })
endif

if right(cIme,4)<>"."+DBFEXT
   cIme:=cIme+"."+DBFEXT
endif

cCDX:=strtran(cIme,"."+DBFEXT,"."+INDEXEXT)
if right(cCDX,4)="."+INDEXEXT
  ferase(cCDX)
endif

DBCREATE(cIme,aDbf,cDriver)
return
*}

function AddOidFields(aDbf)
*{

AADD(aDbf,{"_OID_", "N", 12, 0})
AADD(aDbf,{"_SITE_", "N", 2, 0})
AADD(aDbf,{"_DATAZ_", "D", 8, 0})
AADD(aDbf,{"_TIMEAZ_", "C", 8, 0})
AADD(aDbf,{"_COMMIT_", "C", 1, 0})
AADD(aDbf,{"_USER_", "N", 3, 0})

return
*}
