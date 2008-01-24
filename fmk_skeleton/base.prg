#include "sc.ch"
#include "achoice.ch"
#include "fileio.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/sclib/base/1g/base.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.32 $
 * $Log: base.prg,v $
 * Revision 1.32  2004/04/27 11:01:53  sasavranic
 * Rad sa sezonama - bugfix
 *
 * Revision 1.31  2004/01/13 19:07:28  sasavranic
 * appsrv konverzija
 *
 * Revision 1.30  2003/01/21 16:18:22  ernad
 * planika gSQL=D bug tops
 *
 * Revision 1.29  2002/12/21 10:50:34  mirsad
 * uveo parametar koji po defaultu iskljucuje koristenje PID-ova
 *
 * Revision 1.28  2002/11/22 10:30:59  mirsad
 * prebacivanje security iz modula u SCLIB
 *
 * Revision 1.27  2002/08/19 10:01:47  ernad
 *
 *
 * podesenja za CLIP
 *
 * Revision 1.26  2002/07/30 17:40:59  ernad
 * SqlLog funkcije - Fin modul
 *
 * Revision 1.25  2002/07/23 08:08:51  ernad
 *
 *
 * debug: Nakon dogadjaja "Nema in/out komande" ostane crni ekran - program zaglavi
 *
 * Revision 1.24  2002/07/09 08:46:02  ernad
 *
 *
 * evidencija prometa po vrstama placanja: debug, nadogradnja (sada pokaze poruku o ukupnom pologu nakon unosa)
 * bug je bio sto nije mogao unijeti promet danas za juce
 *
 * Revision 1.23  2002/07/01 10:46:40  ernad
 *
 *
 * oApp:lTerminate - kada je true, napusta se run metod oApp objekta
 *
 * Revision 1.22  2002/07/01 09:22:19  ernad
 *
 *
 * debug m_x, m_y
 *
 * Revision 1.21  2002/06/30 20:28:44  ernad
 *
 *
 *
 * pos meni za odabir firme /MNU_INI
 *
 * Revision 1.20  2002/06/30 11:08:53  ernad
 *
 *
 * razrada: kalk/specif/planika/rpt_ppp.prg; pos/prikaz privatnog direktorija na vrhu; doxy
 *
 * Revision 1.19  2002/06/26 00:15:45  ernad
 *
 *
 * Pos applikacioni server ...
 * poziv je: tops 11 11 /APPSRV /ISQLLOG /L=50
 *           tops 21 21 /APPSRV /ISQLLOG /L=51 itd.
 *
 * Revision 1.18  2002/06/25 12:17:57  ernad
 *
 *
 *
 * debug kreiraj(F_SECUR)
 *
 * Revision 1.17  2002/06/25 12:04:56  ernad
 *
 *
 * -
 *
 * Revision 1.16  2002/06/25 12:04:07  ernad
 *
 *
 * ubaceno kreiranje SECUR-a (posto je prebacen u kumpath)
 *
 * Revision 1.15  2002/06/24 17:04:15  ernad
 *
 *
 * omoguceno da se "restartuje" program .... nakon podesenja sistemskog sata -> oApp:run() ....
 *
 * Revision 1.14  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.13  2002/06/24 07:00:37  ernad
 *
 *
 * GwDiskFree, ciscenja gateway
 *
 * Revision 1.12  2002/06/23 11:57:23  ernad
 * ciscenja sql - planika
 *
 * Revision 1.11  2002/06/21 16:00:51  ernad
 *
 *
 *
 * debug TDB:cRadimUSezona = NIL
 *
 * Revision 1.10  2002/06/21 14:18:12  ernad
 *
 *
 * pos - planika, import sql
 *
 * Revision 1.9  2002/06/20 16:52:06  ernad
 *
 *
 * ciscenje planika, uvedeno fmk/svi/specif.prg
 *
 * Revision 1.8  2002/06/20 12:53:11  ernad
 *
 *
 * ciscenje rada sezonsko<->radno podrucje ... prebacivanje db/1g -> db/2g
 *
 * Revision 1.7  2002/06/16 14:05:43  ernad
 * trazenje bug-a - install DB
 *
 * Revision 1.6  2002/06/16 09:45:57  ernad
 * cKorisn, cSifra izbrisani, ipak ostaju u TAppMod
 *
 * Revision 1.5  2002/06/14 12:49:57  ernad
 * cKorisn, cSifra
 *
 *
 */

#ifdef CLIP
static nCnt:=0
#endif

/*! \defgroup params
 *  @{
 *  @}
 */

/*! \file sc1g/base/base.prg
    \brief Inicijalizacija systema, bazne funkcije
    \note prebaciti u potpunosti na objektni model (ionako se koristi oApp)
 */

/*! \fn SC_START(oApp, lSezone)
 *  \brief Aktiviranje "glavnog" programskog modula"
 */


*string FmkIni_ExePath_FMK_ReadOnly;

/*! \var *string FmkIni_ExePath_FMK_ReadOnly
 *  \param D-baza ce se otvoriti u readonly rezimu, N-tekuca vrijednost
 *  \note postavlja vrijednost globalne var. gReadOnly
 *  \sa SC_START,gReadOnly
 */


/*! \fn SC_START(oApp, lSezone)
 *  \brief Inicijalizacija sclib sistema
 *
 *  \todo Nakon verzije 1.5 ... kreiranje F_SECUR  treba ukinuti
 *
 */
 
function SC_START(oApp, lSezone)
*{
local cImeDbf

public gAppSrv

#ifdef CLIP
	? "setujem engine (sc_start)"
#endif

if !oApp:lStarted	
	
#ifdef CLIP
	? "setujem default engine ..."
#endif
	RDDSETDEFAULT(RDDENGINE)
#ifdef CLIP
	? "startujem oApp:db()"
#endif
	oApp:initdb()
endif

#ifdef CLIP
	? "setujem globalne varijable"
#endif

SetgaSDbfs()
SetScGVars()

gModul:=oApp:cName
gVerzija:=oApp:cVerzija

gAppSrv:=.f.
if mpar37("/APPSRV", oApp)
  ? "Pokrecem App Serv ..."
  gAppSrv:=.t.
endif

SetNaslov(oApp)

SET DELETED ON

#IFDEF CAX
  #define AX
  #define D_VERZIJA "AX"
#ELSE
  #define D_VERZIJA "CDX"
#ENDIF

if mpar37("/INSTALL",oApp)
	oApp:oDatabase:lAdmin:=.t.
	CreGParam()
endif

IniGparams()

// inicijalizacija, prijava
InitE(oApp)

SetScGVar2()
if oApp:lTerminate
	return
endif

oApp:oDatabase:setgaDbfs()

if mpar37("/INSTALL",oApp)
	oApp:oDatabase:install()
endif

IniGparam2()
BosTipke()
KonvTable()

if lSezone
	oApp:oDatabase:loadSezonaRadimUSezona()
        if gAppSrv
		? "Pokrecem App Serv ..."
		oApp:setGVars()
		gAppSrv:=.t.
		oApp:srv()
	endif
  	oApp:oDatabase:radiUSezonskomPodrucju(mpar37("/XN",oApp))
	if !mpar37("/XN",oApp)
	  ArhSigma() 
	endif
	gProcPrenos:="D"

else
        if gAppSrv
	        altd()
		cPars:=mparstring(oApp)
		cKom:="{|| RunAppSrv("+cPars+")}"
		? "Pokrecem App Serv ..."
		gAppSrv:=.t.
		oApp:SetGVars()
		Eval(&cKom)
	endif

endif 

// epoha je u stvari 1999, 2000 itd
SET EPOCH TO 1960  
IniPrinter()
JelReadOnly()

if (lSezone .and. mpar37("/XN",oApp))
        SetOznNoGod()
endif

gReadOnly:=(IzFmkIni("FMK","ReadOnly","N")=="D")

SET EXCLUSIVE OFF

//Setuj globalne varijable varijable modula 
oApp:setGVars()

// nakon verzije 1.5 ovo cemo ukinuti
cImeDbf:=KUMPATH+"SECUR.DBF"
if !FILE(cImeDbf)
	#ifdef CLIP
		? "prije oApp:oDatabase:kreiraj"
		inkey(0)
		inkey(0)
		inkey(0)
	#endif
	oApp:oDatabase:kreiraj(F_SECUR)
endif

oApp:oDataBase:setSigmaBD(IzFmkIni("Svi","SigmaBD","c:"+SLASH+"sigma",EXEPATH))

if (gSecurity=="D")
	AddSecgaSDBFs()
	LoginScreen()
	ShowUser()
	public nUser:=GetUserID()
endif

return
*}


/*! \fn ISC_START(oApp, lSezone)
 *  \brief Aktiviranje "install" programskog modula"
 */

function ISC_START(oApp, lSezone)
*{

RDDSETDEFAULT(RDDENGINE)

set exclusive on
oApp:oDatabase:lAdmin:=.t.
altd()
CreKorisn()
@ 10,30 SAY ""

SetDirs(oApp)
CreSystemDB()
    
IniGparams(.f.)
IniGparam2(.f.)

oApp:oDatabase:loadSezonaRadimUSezona()
oApp:oDatabase:radiUSezonskomPodrucju()
  
oApp:setGVars()
@ 10,20 SAY ""
if Pitanje(,"Izvrsiti instalaciju fajlova (D/N) ?","N")=="D"
    oApp:oDatabase:kreiraj()
endif

gPrinter:="1"
InigEpson()

O_GPARAMS
O_PARAMS
gMeniSif:=.f.
gValIz:="280 "
gValU:="000 "
gKurs:="1"
  
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

gPTKONV:="0"
gPicSif:="V"
gcDirekt:="V"
gSKSif:="D"
gArhDir:=ToUnix("C:"+SLASH+"SIGARH")
gPFont:="Arial"

private cSection:="1",cHistory:=" "; aHistory:={}
Rpar("pt",@gPTKonv)
Rpar("pS",@gPicSif)
Rpar("SK",@gSKSif)
Rpar("DO",@gcDirekt)
Rpar("Ad",@gArhDir)
Rpar("FO",@gPFont)

select gparams
use

//if (gSql=="D")
//	O_Log()
//endif

Beep(1)

IBatchRun(oApp)

@ 10,30 SAY ""
oApp:oDatabase:mInstall()


return
*}


/*! \fn IBatchRun(oApp)
 *  \brief Batch funkcije za kreiranje baze podataka
 *  \todo Sve batch funkcije prebaciti u appsrv kompomentu 
 */

function IBatchRun(oApp)

*{
if mpar37("/XM",oApp)
      oApp:oDatabase:modstruAll()
endif

if mpar37("/APPSRV",oApp)
        cKom:="{|| RunAppSrv() }"
        ? "Pokrecem App Serv ..."
        Eval(&cKom)
endif

if mpar37("/B",oApp)
       BrisipaK(.t.)
       CreKorisn()
       CreSystemDb()
       oApp:oDatabase:kreiraj()
endif

if mpar37("/I",oApp)
       oApp:oDatabase:kreiraj()
endif

if mpar37("/R",oApp)
       Reindex(.t.)
endif

if mpar37("/P",oApp)
       Pakuj(.t.)
endif

if mpar37("/M",oApp)
       RunMods(.t.)
endif

return
*}


function SetNaslov(oApp)
*{

gNaslov:= oApp:cName+" EXT, "+oApp:cPeriod+" "+D_VERZIJA
#ifndef PROBA
	SETCANCEL(.f.)

	#ifndef TRIAL

	if !gInstall
	 IzvrsenIn(oApp:cP3)
	endif
	
	gNaslov+=", Reg: "+SUBSTR(EVar,7,20)
		#IFDEF  READONLY
			 gNaslov+="-RO"
		#ENDIF
	#else
 		if gNoReg
			gNaslov+=" , NO-REG VERSION"
		else
			gNaslov+=" , PROBNA VERZIJA"
		endif
	#endif

	PUBLIC bGlobalErrorHandler
	bGlobalErrorHandler:={|objError| GlobalErrorHandler(objError,.f.)}
	ErrorBlock(bGlobalErrorHandler)
#else
 	
	PUBLIC EVar:="#Erky#12345678901234567890#0000"
 	gNaslov+=" , Reg: "+SUBSTR(EVar,7,20)
 	EXTERNAL _CLD

#endif
return
*}

function InitE(oApp)
*{
if (oApp:cKorisn<>nil .and. oApp:cSifra==nil)

    ? "Koristenje:  ImePrograma "
    ? "             ImePrograma ImeKorisnika Sifra"
    ?
    quit

endif

AFILL(h,"")

nOldCursor:=IIF(readinsert(),2,1)

if !gAppSrv
	standardboje()
endif

SET KEY K_INS  TO ToggleINS()
SET MESSAGE TO 24 CENTER
SET DELETED ON   // most commands ignores deleted records
SET DATE GERMAN
SET SCOREBOARD OFF
SET CONFIRM ON
SET WRAP ON
SET ESCAPE ON
SET SOFTSEEK ON
// naslovna strana

if gAppSrv
	? gNaslov, oApp:cVerzija  
	Prijava(oApp, .f. )
	return
endif

NaslEkran(.t.)
ToggleIns()
ToggleIns()

@ 10,35 SAY ""
// prijava

if !oApp:lStarted
	if (oApp:cKorisn<>nil .and. oApp:cSifra<>nil)
	 if oApp:cP3<>nil 
	   Prijava(oApp,.f.)  // bez prijavnog Box-a
	 else
	   Prijava(oApp)
	   PokreniInstall(oApp)
	 endif
	else
	 Prijava(oApp)
	endif
endif

SayPrivDir(cDirPriv)
return nil
*}


function PokreniInstall(oApp)
*{
local cFile
local lPitaj

lPitaj:=.f.

cFile:=oApp:oDatabase:cDirPriv

if (cFile==nil)
	return
endif

if !PostDir(cFile)
	lPitaj:=.t.
endif

cFile:=oApp:oDatabase:cDirSif
if !PostDir(cFile)
	lPitaj:=.t.
endif

cFile:=oApp:oDatabase:cDirKum
if !PostDir(cFile)
	lPitaj:=.t.
endif

if lPitaj
	if Pitanje(,"Pokrenuti instalacijsku proceduru ?","D")=="D"
		oApp:oDatabase:install()
	endif
endif

return
*}


function mpar37(x, oApp)
*{

// proslijedjeni su parametri
lp3:=oApp:cP3
lp4:=oApp:cP4
lp5:=oApp:cP5
lp6:=oApp:cP6
lp7:=oApp:cP7

return ( (lp3<>NIL .and. upper(lp3)==x) .or. (lp4<>NIL .and. upper(lp4)==x) .or. ;
         (lp5<>NIL .and. upper(lp5)==x) .or. (lp6<>NIL .and. upper(lp6)==x) .or. ;
         (lp7<>NIL .and. upper(lp7)==x) )

*}

function mpar37cnt(oApp)
*{
local nCnt:=0

if oApp:cP3<>nil
	++nCnt
endif
if oApp:cP4<>nil
	++nCnt
endif
if oApp:cP5<>nil
	++nCnt
endif
if oApp:cP6<>nil
	++nCnt
endif
if oApp:cP7<>nil
	++nCnt
endif

return nCnt
*}

function mparstring(oApp)
*{
local cPars
cPars:=""

if oApp:cP3<>NIL
	cPars+="'"+oApp:cP3+"'"
endif
if oApp:cP4<>NIL
	if !empty(cPars); cPars+=", ";endif
	cPars+="'"+oApp:cP4+"'"
endif
if oApp:cP5<>NIL
	if !empty(cPars); cPars+=", ";endif
	cPars+="'"+oApp:cP5+"'"
endif
if oApp:cP6<>NIL
	if !empty(cPars); cPars+=", ";endif
	cPars+="'"+oApp:cP6+"'"
endif
if oApp:cP7<>NIL
	if !empty(cPars); cPars+=", ";endif
	cPars+="'"+oApp:cP7+"'"
endif

return cPars
*}

/*! \fn PID(cStart)
 *  \brief funkcije za kreiranje/brisanje PID fajla
 *  \note PID (Program Idefntifcation)
 *
 *  \param cStart - "START" - na ulasku u aplikaciju napravi PID; "STOP"  - izbrisi pid fajl
 *
 * Primjer koda:
 * \code
 *
 * //pocetak aplikacije
 * PID("START")
 * ....
 * //u Quit proceduri (na kraju):
 * PID("STOP")
 * 
 * \endcode
 *
 *
 * Primjer FMK.INI
 * \code
 * 
 * Ime PID-a koji ce kreirati se cita iz EXEPATH/FMK.INI 
 * [PID]
 * <IME_MODULA>_<IME_KORISNIKA> = IME_PID_FAJLA
 * Default vrijednost je <BROJMODULA>
 *
 *
 * Tako je za modul TOPS, za korisnika sistem 
 * [PID]
 * TOPS_SYSTEM=8
 * 
 * Ako imamo vise poziva TOPS-a iz istog EXE direktorija moramo u fmk ini za
 * svakog korisnika definisati ime PID-fajla:
 * [PID]
 * ;korisnik SYSTEM 
 * TOPS_SYSTEM=8_KASA
 * ;za sve instal module isti je PID sto znaci da ga moze pokrenuti 
 * ;samo jedan korisnik istovremeno
 * I_TOPS_SYSTEM=I_8
 * ;korisnik NELA
 * TOPS_NELA=8_KNJIG
 * I_TOPS_NELA=I_8
 * ;korisnik MEVLIDA
 * TOPS_MEVLIDA=8_KNJIG2
 * I_TOPS_NELA=I_8
 *
 * \endcode
 *
 */

function PID(cStart)
*{
local cPom, cDefault, cPidFile

#ifdef CLIP
	? "pid ", cStart
#endif

if ((cStart=="START") .and. (goModul:lStarted) .or. IzFmkIni("FMK","KoristiSePID","N",EXEPATH)=="N")
	// glavni aplikacijski objekat je vec startovan
	return
endif

if gModul="FIN"
  cDefault:="1"
elseif gModul="KALK"
  cDefault:="2"
elseif gModul="FAKT"
  cDefault:="3"
elseif gModul="OS"
  cDefault:="4"
elseif gModul="LD"
  cDefault:="5"
elseif gModul="VIRM"
  cDefault:="6"
elseif gModul="KAM"
  cDefault:="7"
elseif gModul="TOPS"
  cDefault:="8"
elseif gModul="HOPS"
  cDefault:="9"
elseif gModul="KADEV"
  cDefault:="10"
elseif gModul="TNAM"
  cDefault:="11"
endif

cPom:=gModul
if type("gInstall")="L"
   if gInstall
      cDefault:="I_"+cDefault
      cPom:="I_"+cPom
   else
   endif
endif

cPom:=cPom+"_"+UPPER(alltrim(ImeKorisn))

// koji PID pripada ovoj aplikaciji ?
// primjer TOPS_SYSTEM

cPid:= IzFmkIni("PID", cPom, cDefault, EXEPATH)

cPidFile:= ToUnix( EXEPATH + cPid+".pid" )

if cStart="STOP"
  // zatvori PID
  if type("gHndPid")<>"U"
   fclose(gHndPid)
  endif
  ferase(cPidFile)
else

  public gHndPid:=fcreate(cPidFile)
  fclose(gHndPid)
  gHndPid:=fopen(cPidFile,2+16) // exclusive
  if gHndPid<0
       // ne mogu izbrisati  pid
       MsgBeep(" PID:"+cDefault+" je vec aktiviran !")
       CLEAR SCREEN
       QUIT
  endif

endif

return
*}


/*! \fn Prijava(oApp,lScreen)
 *  \brief Prijava korisnika pri ulasku u aplikaciju
 *  \todo Prijava je primjer klasicne kobasica funkcije ! Razbiti je.
 *  \todo prijavu na osnovu scshell.ini izdvojiti kao posebnu funkciju
 */
 
function Prijava(oApp, lScreen)

*{
local i
local nRec
local cKontrDbf
local cCD

local cPom
local cPom2
local lRegularnoZavrsen

if lScreen==nil
	lScreen:=.t.
endif

if FILE(EXEPATH+'scshell.ini')
        ScShellIni()
endif

if goModul:oDatabase:lAdmin
	CreKorisn()
endif

O_KORISN   
do while .t.
	if oApp:cKorisn<>nil .and. oApp:cSifra<>nil
		 oApp:cKorisn:=ALLTRIM(upper(oApp:cKorisn))
		 oApp:cSifra:=CryptSC(upper(PADR(oApp:cSifra,6)) )
		 LOCATE FOR oApp:cSifra==korisn->sif
		 // Postoji korisnik, sifra
		 if FOUND()                 
		    exit
		 endif
	endif

	m_ime:=Space(10)
	m_sif:=Space(6)
	GetSifra(oApp, @m_ime, @m_sif)
	if oApp:lTerminate
		return
	endif
	SetColor(Normal)
	if m_sif="APPSRV"
		// aplikacijski server
		private cKom:="{|| RunAppSrv()}"
		EVAL (&cKom)
	endif
	if LEFT(m_sif,1)=="I"
		if (cKom==nil)
			cKom:=""
		endif
		PrijRunInstall(m_sif, @cKom)
	endif

	m_sif:=CryptSC(upper(m_sif))
	if (m_ime=="SIGMAX" .or. m_sif=="SIGMAX")
		Imekorisn:="SYSTEM"
		SifraKorisn:=m_sif
		KLevel:="0"
		exit
	endif
	
	oApp:cSifra:=m_sif
	LOCATE FOR oApp:cSifra==korisn->sif
	// Postoji korisnik, sifra
	if FOUND() 
		exit
	endif

enddo

LOCATE FOR oApp:cSifra==korisn->sif
CONTINUE

if FOUND()
	
	// postoji vise od jedne sifre
	if (oApp:cKorisn==NIL)
		oApp:cKorisn:=space(10)
	else
		oApp:cKorisn:=padr(oApp:cKorisn,10)
	endif
	
	LOCATE FOR oApp:cSifra==korisn->sif .and. korisn->ime==oApp:cKorisn
	if !FOUND()
		do while .t. // oznaka preduzeca
			Box(,2,30)
			@ m_x+1,m_y+2 SAY "Oznaka preduzeca:" GET oApp:cKorisn
			READ
			BoxC()
			if LASTKEY()==K_ESC
				CLEAR 
				oApp:quit()
			endif
			LOCATE FOR oApp:cSifra==korisn->sif .and. korisn->ime==oApp:cKorisn
			if found()
				exit
			endif
		enddo
	endif 
else  
	// samo jedna sifra
	LOCATE FOR oApp:cSifra==korisn->sif
	oApp:cKorisn:=korisn->ime
endif

@ 3,4 SAY ""
if (gfKolor=="D" .and. ISCOLOR())
	Normal:="GR+/B,R/N+,,,N/W"
else
	Normal:="W/N,N/W,,,N/W"
endif

if !oApp:lStarted
	if lScreen
		//korisn->nk napustiti
		//PozdravMsg(gNaslov, gVerzija, korisn->nk)
		//lGreska:=.f.
		PozdravMsg(gNaslov, gVerzija, .f.)
	endif
endif

if (gfKolor=="D" .and. ISCOLOR())
	Normal:="W/B,R/N+,,,N/W"
else
	Normal:="W/N,N/W,,,N/W"
endif

if (ImeKorisn=="SYSTEM")

#ifdef CLIP
	? "setujem dirkum, dirsif, dirpriv (oApp:oDatabase:setDirPriv ..)=tekuci dir"
#endif
	oApp:oDatabase:setDirKum(".")
	oApp:oDatabase:setDirSif(".")
	oApp:oDatabase:setDirPriv(".")
else
	SELECT korisn
	LOCATE FOR oApp:cSifra==field->sif .and. field->ime==oApp:cKorisn

	// eliminsati i ove globalne varijable
	ImeKorisn:=korisn->ime
	SifraKorisn:=korisn->sif

#ifdef CLIP
	? "setujem dirkum, dirsif, dirpriv (oApp:oDatabase:setDirPriv ..)"
#endif
	oApp:oDatabase:setDirKum(korisn->dirRad)
	oApp:oDatabase:setDirSif(korisn->dirSif)
	oApp:oDatabase:setDirPriv(korisn->dirPriv)

	// KLevel ... ubaciti u TAppMod klasu
	KLevel := level

	if !gReadonly
		REPLACE dat WITH DATE()
		REPLACE time WITH TIME()
		REPLACE nk WITH .t.
	endif

endif
// eliminisati System globalnu varijablu

System := (Trim(ImeKorisn)=="SYSTEM")
USE

// silent
SetDirs(oApp, .f.) 

CLOSERET
return nil
*}


function ScShellIni(oApp)
*{
local cPPSaMr
local cBazniDir
local cMrRs
local cBrojLok

cPPSaMr:=""
cPPSaMr:=R_IniRead ( 'TekucaLokacija','PrivPodSaMrezeU',  "",EXEPATH+'scshell.INI' )
// u ovu varijablu staviti direktorij npr C:\SIGMA
cBazniDir:=R_IniRead ( 'TekucaLokacija','BazniDir',  "",EXEPATH+'scshell.INI' )
cMrRS:=R_IniRead ( 'TekucaLokacija','RS',  "",EXEPATH+'scshell.INI' )
cBrojLok:=R_IniRead ( 'TekucaLokacija','Broj',  "",EXEPATH+'scshell.INI' )
// Mrezna radna stanica


if goModul:oDatabase:lAdmin
	CreKorisn()
endif

O_KORISN 
// napravi u korisn ovog korisnika
if !EMPTY(cPPSaMr) 
	LOCATE FOR field->ime==padr(oApp:cKorisn,6)
	if !FOUND()
		LOCATE FOR korisn->ime==PADR(LEFT(oApp:cKorisn,LEN(oApp:cKorisn)-1)+'1',6)
		// mora postojata korisnik 1 !!! na osnovu kojeg se formira novi korisnik
		// cKorisn = 501, cMRRs=5 -> 505
		if FOUND()
			cPom:=strtran(trim(DirPriv),LEFT(trim(DirPriv),len(cPPSaMr)),cPPSaMr)
			// K:\SIGMA\FIN\11  ->  C:\SIGMA\FIN\11
			cPom:=left(cPom,len(cPom)-1)+cMRRs
			// cMRS=8  =>  cPom:=C:\SIGMA\FIN\18
			// pravim direktorij, kopiram privatne fajlove za korisnika
			save screen to cScr
			cls
			? "Kopiram privatne fajlova za korisnika ..."
			?
			DirMak2(cPom)
			cPom2:=strtran(trim(DirPriv),LEFT(trim(DirPriv),len(cBazniDir)),cBazniDir)+SLASH
			?  cPom2
			CopySve("*."+DBFEXT, cPom2, cPom+SLASH)
			CopySve("*."+INDEXEXT, cPom2, cPom+SLASH)
			CopySve("*."+MEMOEXT, cPom2, cPom+SLASH)
			CopySve("*.TXT", cPom2, cPom+SLASH)
			restore screen from cScr

			oApp:oDatabase:setDirRad(STRTRAN(trim(DirRad), LEFT(trim(DirRad),len(cBazniDir)),cBazniDir))
			oApp:oDatabase:setDirSif(STRTRAN(trim(DirSif), LEFT(trim(DirSif),len(cBazniDir)),cBazniDir))

			ApndKorisn(cKorisn, cPom, oApp:cDirSif, oApp:cDirKum)
			oApp:oDatabase:setDirPriv("")
			oApp:oDatabase:setDirSif("")
			oApp:oDatabase:setDirKum("")

		else
			MsgBeep("Mora postojati korisnik :"+LEFT(cKorisn, LEN(cKorisn)-1)+'1')
			oApp:quit()
		endif
endif


endif


return
*}

static function GetSifra(oApp, m_ime, m_sif)
*{

@ 10,20 SAY ""
m_ime:=Space(10)
m_sif:=Space(6)

Box("pas",3,30,.F.)

SET CURSOR ON
@ m_x+3,m_y+9 SAY "<ESC> Izlaz"
@ m_x+1,m_y+2 SAY "Sifra         "

m_sif:=upper(GETSECRET( m_sif ))

if (LASTKEY()==K_ESC)
	CLEAR 
	oApp:quit()
endif
SET CURSOR OFF

BoxC()

m_ime:=ALLTRIM(UPPER(m_ime))

return
*}

static function PrijRunInstall(m_sif, cKom)
*{

if m_sif=="I"
	cKom:=cKom:="I"+gModul+" "+ImeKorisn+" "+CryptSC(sifrakorisn)
endif
if m_sif=="IM"
	cKom+="  /M"
endif
if m_sif=="II"
	cKom+="  /I"
endif
if m_sif=="IR"
	cKom+="  /R"
endif
if m_sif=="IP"
	cKom+="  /P"
endif
if m_sif=="IB"
	cKom+="  /B"
endif
RunInstall(cKom)

return
*}


static function ApndKorisn(cKorisn, cDirPriv, cDirSif, cDirKum)
*{

APPEND BLANK
REPLACE ime WITH cKorisn
REPLACE sif WITH CRYPT(PADR(cKorisn,6))
REPLACE dat WITH DATE() 
REPLACE time WITH TIME() 
REPLACE prov WITH 0
REPLACE level WITH "0"
REPLACE nk WITH .F.
REPLACE level with "0"
REPLACE dirPriv with cDirPriv
REPLACE dirSif with cDirSif
REPLACE dirRad with cDirKum

return
*}


function SetDirs(oApp, lScreen)
*{
local cDN:="N"
local cPom

if lScreen==nil
 lScreen:=.t.
endif

select (F_KORISN)
use
O_KORISN

LOCATE FOR alltrim(ImeKorisn)==alltrim(korisn->ime) .and. SifraKorisn=korisn->sif
Scatter()

if lScreen
	Box("radD",5,65,.f.,"Lokacije podataka")
	SET CURSOR ON
	@ m_x+1,m_y+2 SAY "Podesiti direktorije  "  GET cDN PICTURE "@!" valid cDN$"DN"
	@ m_x+3,m_y+2 SAY "Radni direktorij      "  GET _DirRad PICTURE "@!";
			  VALID(DirExists(_DirRad)) when cDN=="D"
	@ m_x+4,m_y+2 SAY "Direktorij sifrarnika "  GET _DirSif PICTURE "@!";
			  VALID(DirExists(_DirSif)) when cDN=="D"
	@ m_x+5,m_y+2 SAY "Privatni direktorij   "  GET _DirPriv PICTURE "@!";
			  VALID(DirExists(_DirPriv))  when cDN=="D"
	READ
	ESC_BCR
	BoxC()

	Gather()
	@ 0,24 SAY PADR(trim(ImeKorisn)+":"+cDirPriv,25) COLOR INVERT
endif

USE

oApp:oDatabase:setDirPriv(_DirPriv)
oApp:oDatabase:setDirSif(_DirSif)
oApp:oDatabase:setDirKum(_DirRad)

if gReadOnly
  cCD:=""
  if file(EXEPATH+'scshell.ini')
        cCD:=""
        cCD:=R_IniRead ( 'TekucaLokacija', 'CD', "",EXEPATH+'scshell.INI' )
  endif

  if empty(cCD) .and. Pitanje(,"Citati podatke sa CD-a ?","D")=="D"
   cCd:="E"
   Box(,1,60)
     @ m_x+1,m_y+2 SAY "CD UREDJAJ:" GET cCD pict "@!"
     read
  BoxC()
  endif

  if !empty(cCD)
	cPom:=cCD+SUBSTR(oApp:oDatabase:cDirPriv,2)
	oApp:oDatabase:setDirPriv(cPom)
	
	cPom:=cCD+SUBSTR(oApp:oDatabase:cDirSif,2)
	oApp:oDatabase:setDirSif(cPom)

	cPom:=cCD+SUBSTR(oApp:oDatabase:cDirKum,2)
	oApp:oDatabase:setDirKum(cPom)
  endif

endif
*}

function RunInstall(cKom)
*{
local lIB

lIB:=.f.

if (cKom==nil)
	cKom:=""
endif

//MsgBeep("cKom="+cKom)
if (" /B" $ cKom)
	goModul:cP7:="/B"
	lIb:=.t.
endif
goModul:oDatabase:install()

if (lIB)
	goModul:cP7:=""
	lIB:=.f.
endif


*}

/*
function T_Start(nHPid, cPath, cModul, cUser )
*{
local hH, nCnt
local cFN
local cBuf

cBuf:=space(10)
cFN:=cPath+gmodul+'.pid'
do while .t.
  nHPid:=FCREATE(cFN)
  if nHPid < 0
     nH:=fopen(cFN)
     nCnt:=fread(nH,@cBuf)
     FClose(nH)
     @ 23,65 SAY "..azurira:"+left(cBuf,nCnt)
     inkey(1)
     @ 23,65 SAY space(10)
     if lastkey()=27
        exit
     endif
  else
     fwrite(nHPid,cUser)
     exit
  endif
enddo
return nHPid
*}

function T_Stop(nHPid, cPath, cModul, cUser )
*{
local cFN
cFN:=cPath+cmodul+'.pid'
fclose(nHPid)
ferase(cFN)
return
*}

*/

function IzvrsenIn(p3,fImodul, cModul, fsilent)
*{
local i,nCheck,fid,nHBios,cBuffer,nBytes

PUBLIC EVar:="#Erky#____SIGMA-COM_ZE____#0000"

if fimodul==NIL; fimodul:=.f.; endif
if cmodul==NIL; cModul:=gModul; endif
if fsilent==NIL; fSilent:=.f.; endif

if !fsilent
clear
?
endif

private cSbr:=SUBSTR(EVar,7,20)
if file(EXEPATH+"serbr.mem")
 restore from (EXEPATH+"serbr.mem") additive
endif

Evar:=substr(Evar,1,6)+padr(cSbr,20)+substr(Evar,27,5)

if !fsilent
? "Registrovano na:", cSbr
?
endif
nCheck:=0
for i:=1 to 20
 nCheck+=ASC(substr(cSbr,i,1))+i
next

#ifdef CLIP
 ? "Preskacem BIOS funkcije ..."

 return .t.
#endif
if !fimodul

  fid:=.f.
  cBuffer:=space(8)
  nHBios:=fopen(ToUnix(EXEPATH+"\bx.xv"))
  do while .t.
    nBytes:=FREAD(nHBios,@cBuffer,8)
    if cBuffer==Crypt2(Bios(),cModul)
       fid:=.t.   // ovaj broj postoji
       exit
    endif
    if nBytes<8
       exit
    endif

  enddo
  FCLOSE(nHBios)
  if !fid
    if !fsilent
     Evar:= substr(Evar,1,6)+padr("PROBNA VERZIJA",20)+substr(Evar,27,5)
     Evar+="0"
    else
       return .f. // vrati .f.
    endif
  endif
  ?

endif
return .t.
*}

#ifdef CLIP
function Arg0()
*{
return "/dev/fmk/pos/1g/e.exe"
*}
#endif

