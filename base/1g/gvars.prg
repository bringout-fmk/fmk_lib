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
 

/****v SC_BASE/gVeryBusyInterval ***

*AUTOR
 Ernad Husremovic ernad@sigma-com.net

*IME
 gVeryBusyInterval 

*OPIS
 gVeryBusyInterval:=IzFmkINI('Gateway','VeryBusyInterval','70', EXEPATH )
 
 Broj sekundi nakon kojih ce se provjeravati da li je gateway
 zauzet.
 Preporuceno:
 70 - na kasama
 20 - u knjigovodstvu
 
****/

/****v SC_BASE/gKonvertPath ***

*AUTOR
 Ernad Husremovic ernad@sigma-com.net

*IME
 gKonvertPath

*OPIS
 IzFmkINI('FMK','KonvertPath','N', EXEPATH )
 D - konvertovati vrijednost varijabli koje predstavljaju lokacije
     podataka
 
****/

function SetScGVars()
*{

public ZGwPoruka:=""
public GW_STATUS:="-"

public GW_HANDLE:=0

public gModul:=""
public gVerzija:=""
public gAppSrv:=.f.
public gSQL:="N"
public gSQLLogBase:=ToUnix("c:"+SLASH+"sigma")
public ZGwPoruka:=""
public GW_STATUS:="-"
public GW_HANDLE:=0
public gReadOnly:=.f.
public gProcPrenos:="N"
public gInstall:=.f.
public gfKolor:="D"
public gPrinter:="1"
public gPtxtSw := nil
public gPDFSw := nil
public gMeniSif:=.f.
public gValIz:="280 "
public gValU:="000 "
public gKurs:="1"
public gPTKONV:="0 "
public gPicSif:="V"
public gcDirekt:="V"
public gSKSif:="D"
public gSezona:="    "

public gShemaVF:="B5"

//counter - za testiranje
public gCnt1:=0


PUBLIC m_x
PUBLIC m_y
PUBLIC h[20]
PUBLIC lInstal:=.f.

//  .t. - korisnik je SYSTEM
PUBLIC System   
PUBLIC aRel:={}

PUBLIC cDirRad
PUBLIC cDirSif
PUBLIC cDirPriv
PUBLIC gNaslov

public gSezonDir:=""
public gRadnoPodr:="RADP"

public ImeKorisn:="" 
public SifraKorisn:=""
public KLevel:="9"

public gArhDir
gArhDir:=ToUnix("C:"+SLASH+"SIGARH")

public gPFont
gPFont:="Arial"

public gKodnaS:="8"
public gWord97:="N"
public g50f:=" "

if !goModul:lStarted 
	public cDirPriv:=""
	public cDirRad:=""
	public cDirSif:=""
endif

PUBLIC StaraBoja
StarBoja:=SETCOLOR()

public System:=.f.
public gGlBaza:=""
public gSQL
public gSqlLogBase

PUBLIC  Invert:="N/W,R/N+,,,R/B+"
PUBLIC  Normal:="GR+/N,R/N+,,,N/W"
PUBLIC  Blink:="R****/W,W/B,,,W/RB"
PUBLIC  Nevid:="W/W,N/N"
PUBLIC gVeryBusyInterval

gVeryBusyInterval:=VAL(IzFmkIni('Gateway','VeryBusyInterval','70'))

PUBLIC gKonvertPath
gKonvertPath:=IzFmkIni('FMK','KonvertPath','N', EXEPATH )

PUBLIC gSifk
gSifk:=.t.

PUBLIC gHostOS
gHostOS:="Win9X"

public cBteksta
public cBokvira
public cBnaslova
public cBshema:="B1"
public gCekaScreenSaver

gCekaScreenSaver:=VAL(IzFMKINI("SCREENSAVER","CekajMinuta","5"))

// ne koristi lokale
public gLokal:="0"

// pdf stampa
public gPDFPrint := "N"
public gPDFPAuto := "D"
public gPDFViewer := SPACE(150)
public gDefPrinter := SPACE(150)

// windows parametri
public gOOPath := PADR("c:\Program Files\OpenOffice.org 3\program\", 200)
public gOOWriter := PADR("swriter.exe", 100)
public gOOSpread := PADR("scalc.exe", 100)
public gJavaPath := SPACE(200)
public gJavaStart := PADR("java -Xmx128m -jar",200)
public gJODRep := PADR("c:\bout\java\jodrep.jar", 200)
public gJODTemplate := PADR("c:\", 200)

return


/* \fn SetScGVar2(()
 * \fn postavljanje varijabli koje traze setovane *PATH varijable Db-a
 */
function SetScGVar2()
*{
gSql:=IzFmkIni("Svi", "SQLLog", "N", KUMPATH)
gSqlLogBase:=IzFmkIni("SQL","SQLLogBase","c:\sigma",EXEPATH)

*}


function IniGparams(fSve)
*{
local cImeDbf

if fsve==nil
  fSve:=.t.
endif

if fSve
public gSezonDir:=""
public gRadnoPodr:="RADP"
public ImeKorisn:="" 
public SifraKorisn:=""
public KLevel:="9"

public gPTKONV:="0 "
public gPicSif:="V", gcDirekt:="V", gShemaVF:="B5", gSKSif:="D"
public gArhDir:=padr(ToUnix("C:\SIGARH"),20)
public gPFont:="Arial CE"
public gKodnaS:="8"
public gWord97:="N"
public g50f:=" "

endif // fsve

public gKesiraj:="N" // ako je mrezni dir kesiraj na C,D
public gFKolor:="D"


O_GPARAMS
private cSection:="1",cHistory:=" "; aHistory:={}

if fsve
	Rpar("pt",@gPTKonv)
	Rpar("pS",@gPicSif)
	Rpar("SK",@gSKSif)
	Rpar("DO",@gcDirekt)
	Rpar("SB",@gShemaVF)
	Rpar("Ad",@gArhDir)
	Rpar("FO",@gPFont)
	Rpar("KS",@gKodnaS)
	Rpar("W7",@gWord97)
	Rpar("5f",@g50f)
	Rpar("L8",@gLokal)
	Rpar("pR",@gPDFPrint)
	Rpar("pV",@gPDFViewer)
	Rpar("pA",@gPDFPAuto)
	Rpar("dP",@gDefPrinter)
	Rpar("oP",@gOOPath)
	Rpar("oW",@gOOWriter)
	Rpar("oS",@gOOSpread)
	Rpar("oJ",@gJavaPath)
	Rpar("jS",@gJavaStart)
	Rpar("jR",@gJODRep)
	Rpar("jT",@gJODTemplate)
endif

Rpar("FK",@gFKolor)
Rpar("kE",@gKesiraj)

select (F_GPARAMS)
use

return nil
*}


/*! \fn IniGParam2(lSamoKesiraj)
 *  \brief Ucitava globalne parametre gPTKonv ... gKesiraj
 *  \param lSamoKesiraj - ucitaj samo gKesiraj
 *  Prvo ucitava "p?" koji je D ako zelimo ucitavati globalne parametre iz PRIVDIR
 *  Nakon toga ucitava iz GPARAMS ( gPTKonv, ... gKesiraj )
 *  \todo Ocigledno da je ovo funkcija za eliminaciju ...
 */
 
function IniGParam2(lSamoKesiraj)
*{

local cPosebno:="N"

if (lSamoKesiraj==nil)
	lSamoKesiraj:=.f.
endif

#ifdef CLIP
? "Privpath =", PRIVPATH, ";", goModul:oDatabase:cDirPriv, ";", cDirPriv
#endif

O_PARAMS
public gMeniSif:=.f.
private cSection:="1"
private cHistory:=" "
private aHistory:={}
RPar("p?",@cPosebno)

SELECT params
USE

if (cPosebno=="D")
	bErr:=ERRORBLOCK({|o| MyErrH(o)})
	O_GPARAMSP
	SEEK "1"
	bErr:=ERRORBLOCK(bErr)

	if !lSamoKesiraj
		Rpar("pt",@gPTKonv)
		Rpar("pS",@gPicSif)
		Rpar("SK",@gSKSif)
		Rpar("DO",@gcDirekt)
		Rpar("FK",@gFKolor)
		Rpar("S9",@gSQL)
		gSQL:=IzFmkIni("Svi","SQLLog","N",KUMPATH)
		Rpar("SB",@gShemaVF)
		Rpar("Ad",@gArhDir)
		Rpar("FO",@gPFont)
		Rpar("KS",@gKodnaS)
		Rpar("W7",@gWord97)
		Rpar("5f",@g50f)
		Rpar("L8",@gLokal)
		Rpar("pR",@gPDFPrint)
		Rpar("pV",@gPDFViewer)
		Rpar("pA",@gPDFPAuto)
		Rpar("dP",@gDefPrinter)
		Rpar("oP",@gOOPath)
		Rpar("oW",@gOOWriter)
		Rpar("oS",@gOOSpread)
		Rpar("oJ",@gJavaPath)
		Rpar("jS",@gJavaStart)
		Rpar("jR",@gJODRep)
	endif
	Rpar("kE",@gKesiraj)
	SELECT (F_GPARAMSP)
	USE
endif

return
*}


function IniPrinter()
*{

*
* procitaj gprinter, gpini, itd..
* postavi shift F2 kao hotkey


if gModul $ "EPDV"
	public gPrinter:="R"
elseif gModul $ "TOPS#HOPS"
 	public gPrinter:="0"
else
 	public gPrinter:="1"
endif

InigEpson()
public gMeniSif:=.f., gValIz:="280 ", gValU:="000 ", gKurs:="1"

if file(ToUnix("\GPARAMS.DBF"))

O_GPARAMS
O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}
RPar("px",@gPrinter)
RPar("vi",@gValIz)
RPar("vu",@gValU)
RPar("vk",@gKurs)
select params
use

select gparams
private cSection:="P",cHistory:=gPrinter; aHistory:={}

RPar_Printer()

/// EPSON STAMPACI
private cSection:="P",cHistory:="E"; aHistory:={}
gPINI:="xx"
cPom:="xx"
RPAR("01",@cPom)
if cPom=="xx"
    WPar_Printer()
endif

// HP STAMPACI  
private cSection:="P",cHistory:="H"; aHistory:={}
cPom:="xx"
RPAR("01",@cPom)
if cPom=="xx"
    InigHP()	 
    WPar_Printer()
endif

/// ZA POS, stampac tipa 0 !!!!  
private cSection:="P",cHistory:="0"; aHistory:={}
gPINI:="xx"
RPAR("01",@gPINI)
if gPINI=="xx"
    WPAR("01","")
    WPAR("02","")
    WPAR("03","")
    WPAR("04","")
    WPAR("05","")
    WPAR("06","")
    WPAR("07","")
    WPAR("08","")
    WPAR("09","")
    WPAR("10","")
    WPAR("11","")
    WPAR("12","")
    WPAR("13","")

    WPAR("14","")
    WPAR("15","")
    WPAR("16","")
    WPAR("17","")

    WPAR("PP","1")
endif


private cSection:="P",cHistory:=gPrinter; aHistory:={}
gPINI:=""
RPAR("01",@gPINI)


select gparams; use

endif // postoji gparams

IF !EMPTY(gPPTK)
  SetGParams("1"," ","pt","gPTKonv",gPPTK)
ENDIF

release cSection,cHistory,aHistory

IF gPicSif=="8"
  SETKEY(K_CTRL_F2,{|| PPrint()})
ELSE
  SETKEY(K_SH_F2,{|| PPrint()})
ENDIF

return
*}
