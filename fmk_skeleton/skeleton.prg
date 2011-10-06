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


#include "fmk.ch"
#include "achoice.ch"
#include "fileio.ch"
#include "hbgtinfo.ch"
#include "hbcompat.ch"

REQUEST DBFCDX

#ifdef __PLATFORM__WINDOWS
//REQUEST HB_GT_WIN
//REQUEST HB_GT_GTQTC_DEFAULT
#else
//REQUEST HB_GT_CRS
REQUEST HB_GT_XWC_DEFAULT
#endif

/*

    Inicijalizacija systema, bazne funkcije
    prebaciti u potpunosti na objektni model (ionako se koristi oApp)
*/

/* SC_START(oApp, lSezone)
 */


*string FmkIni_ExePath_FMK_ReadOnly;

/*! \var *string FmkIni_ExePath_FMK_ReadOnly
 *  \param D-baza ce se otvoriti u readonly rezimu, N-tekuca vrijednost
 *  \note postavlja vrijednost globalne var. gReadOnly
 *  \sa SC_START,gReadOnly
 */


/* SC_START(oApp, lSezone)
 * Inicijalizacija sclib sistema
 *
 */
 
function SC_START(oApp, lSezone)

local cImeDbf

public gAppSrv

  
? "setujem engine (sc_start)"

if !oApp:lStarted  

  ? "setujem default engine ..." + RDDENGINE
  RDDSETDEFAULT( RDDENGINE )

#ifdef __PLATFORM__LINUX
   
   REQUEST HB_CODEPAGE_SL852 
   REQUEST HB_CODEPAGE_SLISO

   hb_setCodePage( "SL852" )
   hb_setTermCP("SLISO")

#else

   //REQUEST HB_CODEPAGE_SL852
   //REQUEST HB_CODEPAGE_SLWIN

   //hb_setCodePage( "SL852" )
   //hb_setTermCP("SLWIN")

#endif

  ? "startujem oApp:db()"
  oApp:initdb()

endif

? "setujem globalne varijable"

SetgaSDbfs()
set_global_vars_0()

gModul:=oApp:cName
gVerzija:=oApp:cVerzija

gAppSrv:=.f.

if mpar37("/APPSRV", oApp)
  ? "Pokrecem App Serv ..."
  gAppSrv:=.t.
endif

SetNaslov(oApp)

SET DELETED ON


if mpar37("/INSTALL",oApp)
  oApp:oDatabase:lAdmin:=.t.
  CreGParam()
endif

set_global_vars_0_prije_prijave()

// inicijalizacija, prijava
InitE(oApp)

set_global_vars_0_nakon_prijave()
if oApp:lTerminate
  return
endif

oApp:oDatabase:setgaDbfs()

if mpar37("/INSTALL",oApp)
  oApp:oDatabase:install()
endif

//IniGparam2()

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



/*! \fn ISC_START(oApp, lSezone)
 *  \brief Aktiviranje "install" programskog modula"
 */

function ISC_START(oApp, lSezone)


RDDSETDEFAULT(RDDENGINE)

set exclusive on
oApp:oDatabase:lAdmin:=.t.
CreKorisn()
@ 10,30 SAY ""

SetDirs(oApp)
CreSystemDB()
    
set_global_vars_0_nakon_prijave(.f.)

//IniGparam2(.f.)

oApp:oDatabase:loadSezonaRadimUSezona()
oApp:oDatabase:radiUSezonskomPodrucju()
  
oApp:setGVars()
@ 10,20 SAY ""
if Pitanje(,"Izvrsiti instalaciju fajlova (D/N) ?","N")=="D"
    oApp:oDatabase:kreiraj()
endif

gPrinter:="R"
InigEpson()

O_GPARAMS
O_PARAMS
gMeniSif:=.f.
gValIz:="280 "
gValU:="000 "
gKurs:="1"
  
private cSection:="1"
private cHistory:=" "
private aHistory:={}
RPar("px",@gPrinter)
RPar("vi",@gValIz)
RPar("vu",@gValU)
RPar("vk",@gKurs)
select params
use

select gparams
private cSection:="P"
private cHistory:=gPrinter
private aHistory:={}
RPar_Printer()

gPTKONV:="0"
gPicSif:="V"
gcDirekt:="V"
gSKSif:="D"
//gArhDir:=ToUnix("C:"+SLASH+"SIGARH")
gPFont:="Arial"

private cSection:="1", cHistory:=" "; aHistory:={}
Rpar("pt",@gPTKonv)
Rpar("pS",@gPicSif)
Rpar("SK",@gSKSif)
Rpar("DO",@gcDirekt)
Rpar("Ad",@gArhDir)
Rpar("FO",@gPFont)

select gparams
use

Beep(1)

IBatchRun(oApp)

@ 10,30 SAY ""
oApp:oDatabase:mInstall()


return



/*! \fn IBatchRun(oApp)
 *  \brief Batch funkcije za kreiranje baze podataka
 *  \todo Sve batch funkcije prebaciti u appsrv kompomentu 
 */

function IBatchRun(oApp)


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


// --------------------------------------------------------
// --------------------------------------------------------
function SetNaslov(oApp)



gNaslov:= oApp:cName + " HB, " + oApp:cPeriod 

#ifndef FMK_DEBUG
SETCANCEL(.f.)
#endif

#IFDEF  READONLY
     gNaslov+="-RO"
#ENDIF

//PUBLIC bGlobalErrorHandler
//bGlobalErrorHandler:={|objError| GlobalErrorHandler(objError,.f.)}

return


function InitE(oApp)

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



function PokreniInstall(oApp)

local cFile
local lPitaj

lPitaj:=.f.

cFile:=oApp:oDatabase:cDirPriv

if (cFile==nil)
  return
endif

if !IsDirectory(cFile)
  lPitaj:=.t.
endif

cFile:=oApp:oDatabase:cDirSif
if !IsDirectory(cFile)
  lPitaj:=.t.
endif

cFile:=oApp:oDatabase:cDirKum
if !IsDirectory(cFile)
  lPitaj:=.t.
endif

if lPitaj
  if Pitanje(,"Pokrenuti instalacijsku proceduru ?","D")=="D"
    oApp:oDatabase:install()
  endif
endif

return



function mpar37(x, oApp)


// proslijedjeni su parametri
lp3:=oApp:cP3
lp4:=oApp:cP4
lp5:=oApp:cP5
lp6:=oApp:cP6
lp7:=oApp:cP7

return ( (lp3<>NIL .and. upper(lp3)==x) .or. (lp4<>NIL .and. upper(lp4)==x) .or. ;
         (lp5<>NIL .and. upper(lp5)==x) .or. (lp6<>NIL .and. upper(lp6)==x) .or. ;
         (lp7<>NIL .and. upper(lp7)==x) )



function mpar37cnt(oApp)

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


function mparstring(oApp)

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





/*! \fn Prijava(oApp,lScreen)
 *  \brief Prijava korisnika pri ulasku u aplikaciju
 *  \todo Prijava je primjer klasicne kobasica funkcije ! Razbiti je.
 *  \todo prijavu na osnovu scshell.ini izdvojiti kao posebnu funkciju
 */
 
function Prijava(oApp, lScreen)


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

  oApp:oDatabase:setDirKum(".")
  oApp:oDatabase:setDirSif(".")
  oApp:oDatabase:setDirPriv(".")
else
  SELECT korisn
  LOCATE FOR oApp:cSifra==field->sif .and. field->ime==oApp:cKorisn

  // eliminsati i ove globalne varijable
  ImeKorisn:=korisn->ime
  SifraKorisn:=korisn->sif

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



function ScShellIni(oApp)

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


static function GetSifra(oApp, m_ime, m_sif)


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


static function PrijRunInstall(m_sif, cKom)


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



static function ApndKorisn(cKorisn, cDirPriv, cDirSif, cDirKum)


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



function SetDirs(oApp, lScreen)

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
  @ m_x+1,m_y+2 SAY "Podesiti direktorije  "  GET cDN  picture "@!" valid cDN $ "DN"
  @ m_x+3,m_y+2 SAY "Radni direktorij      "  GET _DirRad ;
        VALID(DirExists(_DirRad)) when cDN=="D"

  @ m_x+4,m_y+2 SAY "Direktorij sifrarnika "  GET _DirSif ;
        VALID(DirExists(_DirSif)) when cDN=="D"

  @ m_x+5,m_y+2 SAY "Privatni direktorij   "  GET _DirPriv ;
        VALID(DirExists(_DirPriv))  when cDN=="D"
  READ

  ESC_BCR
  BoxC()
  
  if !gReadOnly
    Gather()
  endif

  @ 0,24 SAY PADR(trim(ImeKorisn)+":"+cDirPriv,25) COLOR INVERT
endif

USE

oApp:oDatabase:setDirPriv(_DirPriv)
oApp:oDatabase:setDirSif(_DirSif)
oApp:oDatabase:setDirKum(_DirRad)

if gReadOnly .and. (IzFmkIni('Svi','CitatiCD','N',EXEPATH) == "D")
  cCD:=""
    if file(EXEPATH+'scshell.ini')
          cCD:=""
          cCD:=R_IniRead ( 'TekucaLokacija', 'CD', "",EXEPATH+'scshell.INI' )
    endif
  if empty(cCD) .and. Pitanje(,"Citati podatke sa CD-a ?","N")=="D"
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


function RunInstall(cKom)

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



