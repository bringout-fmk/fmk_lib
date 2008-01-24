#include "sc.ch"
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/sclib/base/1g/gvars.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.10 $
 * $Log: gvars.prg,v $
 * Revision 1.10  2003/01/29 06:00:36  ernad
 * citanje ini fajlova
 *
 * Revision 1.9  2003/01/21 16:18:22  ernad
 * planika gSQL=D bug tops
 *
 * Revision 1.8  2002/08/19 10:01:47  ernad
 *
 *
 * podesenja za CLIP
 *
 * Revision 1.7  2002/07/30 17:40:59  ernad
 * SqlLog funkcije - Fin modul
 *
 * Revision 1.6  2002/06/30 20:28:44  ernad
 *
 *
 *
 * pos meni za odabir firme /MNU_INI
 *
 * Revision 1.5  2002/06/24 17:04:15  ernad
 *
 *
 * omoguceno da se "restartuje" program .... nakon podesenja sistemskog sata -> oApp:run() ....
 *
 * Revision 1.4  2002/06/17 09:49:43  ernad
 * uveden TAppMod:gParams, dodana opcija install DB-a pri <s-F10>
 *
 *
 */
 
/****v SC_BASE/GW_STATUS ***

*AUTOR
 Ernad Husremovic ernad@sigma-com.net

*IME
 GW_STATUS

*OPIS
 "-"                Gateway je slobodan
 "K_NA_CEKI_SQL"    Vrsi se import SQL loga
 "GEN_SQL_LOG"          Trenutno generisem SQL Log
 
*PRIMJER

*BILJESKE

****/

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

#ifdef CLIP
	? "start SetScGVars"
#endif
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
gSifk:=IzFmkIni("Svi","Sifk","D")

PUBLIC gHostOS
gHostOS:="Win9X"

public cBteksta
public cBokvira
public cBnaslova
public cBshema:="B1"
public gCekaScreenSaver

gCekaScreenSaver:=VAL(IzFMKINI("SCREENSAVER","CekajMinuta","5"))

#ifdef CLIP
	? "end SetScGVars"
#endif


return
*}


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
public  gWord97:="N"
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

#ifdef CLIP
	? "IniGParam2"
#endif

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


if gModul $ "TOPS#HOPS"
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
