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

/*! \file sclib/base/2g/app.prg
 *  \brief Bazni aplikacijski objekat - TAppMod
 */

function TAppModNew(oParent, cVerzija, cPeriod, cKorisn, cSifra, p3,p4,p5,p6,p7)

local oObj

oObj:=TAppMod():new()

return oObj


#include "hbclass.ch"

CLASS TAppMod 
  DATA cName
  DATA oParent
  DATA oDatabase
  DATA oDesktop
  DATA cVerzija
  DATA cPeriod
  DATA cKorisn
  DATA cSifra
  DATA cP3
  DATA cP4
  DATA cP5
  DATA cP6
  DATA cP7
  DATA cSqlLogBase
  DATA lSqlDirektno
  DATA lStarted
  DATA lTerminate
  
  method new
        method hasParent
  method setParent
  method getParent
  method setName
  method run
  method quit
  method gProc
  method gParams
  method setTGVars
  
ENDCLASS



METHOD new(oParent, cModul, cVerzija, cPeriod, cKorisn, cSifra, p3,p4,p5,p6,p7) CLASS TAppMod

::lStarted:=nil

::cName:=cModul
::oParent:=oParent
::oDatabase:=nil
::cVerzija:=cVerzija
::cPeriod:=cPeriod
::cKorisn:=cKorisn
::cSifra:=cSifra
::cP3:=p3
::cP4:=p4
::cP5:=p5
::cP6:=p6
::cP7:=p7
::lTerminate:=.f.

return


/*! \fn *bool TAppMod::hasParent()
 *  \brief ima li objekat "roditelja"
 */
 
*bool TAppMod::hasParent()

method hasParent()

return !(::oParent==nil)



/*! \fn *TObject TAppMod::setParent(TObject oParent)
 *  \brief postavi roditelja ovog objekta
 *
 *  Roditelj je programski modul (objekat) koji je izvrsio kreiranje ovog objekta. To bi znacilo za oPos to parent oFMK - "master" aplikacijski modul koji poziva pojedinacne programske module (oFIN, oKALK, oFAKT)
 */
*TObject TAppMod::setParent(TObject oParent)

method setParent(oParent)

::parent:=oParent

return



/*! \fn *TObject TAppMod::getParent()
 *  \brief Daj mi roditelja ovog objekta
 */

*TObject TAppMod::getParent()

method getParent()
return ::oParent



*string TAppMod::setName(string cName)

method setName()
::cName:="SCAPP"
return


*void TAppMod::run()

method run()

if ::oDesktop==nil
  ::oDesktop:=TDesktopNew()
endif
if ::lStarted==nil
  ::lStarted:=.f.
endif

SC_START(self, .t.)
// da se zna da je objekat jednom vec startovan
::lStarted:=.t.

if ::lTerminate
   ::quit()
   return
endif
::MMenu()

return



*void TAppMod::gProc(char Ch)

method gProc(Ch)
local lPushWa
local i

do case

  case (Ch==K_SH_F12)
    InfoPodrucja()

  case (Ch==K_SH_F1  .or. Ch==K_CTRL_F1)
    Calc()
    
  case (Ch==K_SH_F2 .or. Ch==K_CTRL_F2)
    PPrint()
    
  case Ch==K_SH_F10
    ::gParams()
    
  case Ch==K_SH_F5
    ::oDatabase:vratiSez()
    
  case Ch==K_ALT_F6
    ProcPrenos()
    
  case Ch==K_SH_F6
    ::oDatabase:logAgain()
    
  case Ch==K_SH_F7
    KorLoz()
      
  case Ch==K_SH_F8
    TechInfo()
    
  case Ch==K_SH_F9
    Adresar()
    
  case Ch==K_CTRL_F10
    SetROnly()
  
  otherwise
    if !("U" $ TYPE("gaKeys"))
      for i:=1 to LEN(gaKeys)
        if (Ch==gaKeys[i,1])
          EVAL(gaKeys[i,2])
        endif
      next
    endif
endcase

return



/*! \fn *void TAppMod::quit(bool lVratiseURP)
 *  \brief izlazak iz aplikacijskog modula
 *  \param lVratiSeURP - default vrijednost .t.; kada je .t. vrati se u radno podrucje; .f. ne mjenjaj radno podrucje
 *
 *  \todo proceduru izlaska revidirati, izbaciti Rad.sys iz upotrebe, kao i korisn.dbf
 */
 
*void TAppMod::quit(bool lVratiSeURP)

method quit(lVratiseURP)

local cKontrDbf
close all

if (lVratiseURP==nil)
  lVratiseURP:=.t.
endif

O_KORISN
LOCATE FOR (ALLTRIM(ImeKorisn)==ALLTRIM(korisn->ime) .and. SifraKorisn==korisn->sif)

SETCOLOR(StaraBoja)

if lVratiseURP // zatvori korisnika
  if !empty(goModul:oDataBase:cSezonDir)
    // prebaci se u radno podrucje, ali nemoj to zapisati
    URadPodr(.f.)  
  endif
endif


::lTerminate:=.t.

CLEAR SCREEN

if !(::hasParent())
  if !gReadonly
    if FOUND()
      SELECT korisn
      if RLOCK()
           REPLACE field->nk WITH .f.
      endif
    else
      QUIT
    endif
    USE
    MsgO("Brisem RAD.SYS ...")
      ERASE Rad.sys
    MsgC()
  endif
  QUIT
endif

return



*void TAppMod::gParams()

method gParams()

local cFMKINI:="N"
local cPosebno:="N"
local cOldBoje:=SETCOLOR(INVERT)
local cInstall:="N"
local lPushWa := .f.
private GetList:={}

if used()
  lPushWa:=.t.
  PushWa()
else
  lPushWa:=.f.
endif

private cSection:="1"
private cHistory:=" "
private aHistory:={}

select (F_PARAMS)
USE
O_PARAMS

RPar("p?",@cPosebno)

gArhDir:=padr(gArhDir, 100)
gPFont:=padr(gPFont, 20)

Box(, 20, 70)
  set cursor on
   @ m_x+ 1,m_y+2 SAY "Parametre pohraniti posebno za korisnika "  GET cPosebno valid cPosebno $ "DN" pict "@!"
   read
   WPAr("p?",cPosebno)
   select params
  use
   if cPosebno=="D"
       if !file(PRIVPATH+"gparams.dbf")
      cScr:=""
            save screen to cscr
            CopySve("gpara*.*", SLASH, PRIVPATH)
            restore screen from cScr

       endif
   endif
   if cPosebno=="D"
       select (F_GPARAMSP)
       use
       O_GPARAMSP
   else
       select (F_GPARAMS)
       use
       O_GPARAMS
   endif

   gPtkonv := padr(gPtkonv, 2)
  gLokal := PADR(gLokal, 2)
   @ m_x+ 3,m_y+2 SAY "Konverzija znakova BEZ, 7-852, 7-A, 852-7, 852-A"
   @ m_x+ 4,m_y+2 SAY "                    0  / 1   /  2  / 3   /   4  "  GET gPTKonv pict "@!" valid subst(gPtkonv,2,1)$ " 1"
   @ m_x+ 6,m_y+2 SAY "Unos podataka u sifrarnike velika/mala slova/konv.u 852 (V/M/8)"  GET gPicSif valid gpicsif $ "VM8" pict "@!"
   @ m_x+ 7,m_y+2 SAY "Stroga kontrola ispravki/brisanja sifara     (D/N)"  GET gSKSif valid gSKSif $ "DN" pict "@!"
   @ m_x+ 8,m_y+2 SAY "Direktorij pomocne kopije podataka" GET gArhDir pict "@S20"
   @ m_x+ 9,m_y+2 SAY "Default odgovor na pitanje 'Izlaz direktno na printer?' (D/N/V/E)" GET gcDirekt valid gcDirekt $ "DNVER" pict "@!"
   @ m_x+10,m_y+2 SAY "Shema boja za prikaz na ekranu 'V' (B1/B2/.../B7):" GET gShemaVF
   @ m_x+11,m_y+2 SAY "Windows font:" GET gPFont
   @ m_x+12,m_y+2 SAY "Kodna strana:" GET gKodnaS valid gKodnaS $ "78" pict "9"
   @ m_x+12,col()+2 SAY "Word 97  D/N:" GET gWord97 valid gWord97 $ "DN" pict "@!"
   @ m_x+12,col()+2 SAY "Zaok 50f (5):" GET g50f    valid g50f    $ " 5" pict "9"
   @ m_x+13,m_y+2 SAY "Prenijeti podatke na lokalni disk (NDCX):" GET gKesiraj    valid gKesiraj $ "NDCX" pict "@!"
   @ m_x+14,m_y+2 SAY "Omoguciti kolor-prikaz? (D/N)" GET gFKolor valid gFKolor$"DN" pict "@!"
   @ m_x+15,col()+2 SAY "SQL log ? (D/N)" GET gSql pict "@!"
 
  @ m_x+16,m_y+2 SAY "PDV rezim rada? (D/N)" GET gPDV pict "@!" VALID gPDV$"DN"

   @ m_x+17, m_y+2 SAY "Lokalizacija 0/hr/ba/en/sr " GET gLokal ;
    VALID gLokal $ "0 #hr#ba#sr#en" ;
   
   @ m_x+18, m_y+2 SAY "PDF stampa (N/D/X)?" GET gPDFPrint VALID {|| gPDFPrint $ "DNX" .and. if(gPDFPrint $ "XD", pdf_box(), .t. ) } PICT "@!"
  
  @ m_x+20,m_y+2 SAY "Ispravka FMK.INI (D/S/P/K/M/N)" GET cFMKINI valid cFMKINI $ "DNSPKM" pict "@!"
   @ m_x+20,m_y+36 SAY "M - FMKMREZ"
    
   
  READ
BoxC()

if cFMKIni $ "DSPKM"
  private cKom:="q "
     if cFMKINI=="D"
         cKom+=EXEPATH
     elseif  cFMKINI=="K"
         cKom+=KUMPATH
     elseif  cFMKINI=="P"
         cKom+=PRIVPATH
     elseif  cFMKINI=="S"
         cKom+=SIFPATH
     endif
      //-- M je za ispravku FMKMREZ.BAT
      if cFMKINI=="M"
         cKom+=EXEPATH+"FMKMREZ.BAT"
      else
         cKom+="FMK.INI"
      endif

     Box(,25,80)
       run &ckom
     BoxC()
     IniRefresh() // izbrisi iz cache-a
endif


if lastkey()<>K_ESC
  Wpar("pt", gPTKonv)
    Wpar("pS", gPicSif)
    Wpar("SK", gSKSif)
    Wpar("DO", gcDirekt)
    Wpar("FK", gFKolor)
    Wpar("S9", gSQL)
    UzmiIzIni(KUMPATH+"fmk.ini","Svi","SqlLog",gSql,"WRITE")
    Wpar("SB", gShemaVF)
    Wpar("Ad", trim(gArhDir))
    Wpar("FO", trim(gPFont))
    Wpar("KS", gKodnaS)
    Wpar("W7", gWord97)
    Wpar("5f", g50f)
  Wpar("pR", gPDFPrint)
   if gKesiraj $ "CD"
       if sigmaSif("SKESH")
          Wpar("kE",gKesiraj)
       else
          MsgBeep("Neispravna sifra!")
       endif
   else
        Wpar("kE",gKesiraj)
   endif
  WPar("L8", ALLTRIM(gLokal) )
endif

KonvTable()

select gparams
use

SETCOLOR(cOldBoje)

// upisi i u params parametre za PDV / PRIVPATH+params.dbf
O_PARAMS
select params
WPar("PD", gPDV)
use

if lPushWa
  PopWa()
endif
return




// ------------------------------------------------------------
// prikaz dodatnog box-a za stimanje parametara PDF stampe
// ------------------------------------------------------------
static function pdf_box()
local nX := 1
private GetList:={}

if Pitanje(,"Podesiti parametre PDF stampe (D/N) ?", "D" ) == "N"
  return .t.
endif

Box(, 10, 75 )
  
  @ m_x + nX, m_y + 2 SAY "Podesavanje parametara PDF stampe *******"
  
  nX += 2
  
  @ m_x + nX, m_y + 2 SAY "PDF preglednik:" GET gPDFViewer VALID _g_pdf_viewer(@gPDFViewer) PICT "@S56"
  
   nX += 1
  
  @ m_x + nX, m_y + 2 SAY "Printanje PDF-a bez poziva preglednika (D/N)?" GET gPDFPAuto VALID gPDFPAuto $ "DN" PICT "@!"
  
  nX += 2
  
  @ m_x + nX, m_y + 2 SAY "Default printer:" GET gDefPrinter PICT "@S55"
  

  read
BoxC()

if LastKey() <> K_ESC

  // generisi yml fajl iz parametara
  wr_to_yml()

  // snimi parametre.....
  Wpar( "pV", gPDFViewer )
  Wpar( "dP", gDefPrinter )
  Wpar( "pA", gPDFPAuto )
  
endif

return .t.


// ---------------------------------------------
// upisi u yml fajl podesenja
// ---------------------------------------------
static function wr_to_yml( cFName )
local nH
local cParams := ""
local cNewRow := CHR(13) + CHR(10)

if cFName == nil
  cFName := "fmk_pdf.yml"
endif

// write params to yml
cParams += "pdf_viewer: " + ALLTRIM(gPDFviewer)
cParams += cNewRow
cParams += "print_to: " + ALLTRIM(gDefPrinter)

// kreiraj fajl
nH := FCREATE( EXEPATH + cFName )
// upisi u fajl
FWRITE( nH, cParams )
// zatvori fajl
FCLOSE( EXEPATH + cFName )

return



// -------------------------------------------
// vraca lokaciju pdf viewera
// -------------------------------------------
static function _g_pdf_viewer( cViewer )
local cViewName := "acrord32.exe"
local cViewPath := "c:\progra~1\adobe\"
local aPath := DIRECTORY(cViewPath + "*.*", "D")
local cPom

if !EMPTY(cViewer)
  return .t.
endif

ASORT(aPath, {|x,y| x[1] < y[1] })

nScan := ASCAN( aPath, {|xVal| UPPER(xVal[1]) = "ACRO" })

if nScan > 0
  cPom := ALLTRIM( aPath[nScan, 1] )

  cViewer := cViewPath + cPom
  cViewer += SLASH + "reader" + SLASH
  cViewer += cViewName
  
  cViewer := PADR( cViewer, 150 )
  
endif

if !EMPTY(cViewer) .and. !FILE( cViewer )
  msgbeep("Ne mogu naci Acrobat Reader!#Podesite rucno lokaciju preglednika...")
endif

return .t.


/*! \fn TAppMod::setTGVars() 
 *  \brief Setuje globalne varijable, te setuje incijalne vrijednosti objekata koji pripadaju glavnom app objektu
 */

*void TAppMod::setTGVars()

method setTGVars()

::cSqlLogBase:=IzFmkIni("Sql","SqlLogBase","c:"+SLASH+"sigma")
gSqlLogBase:=::cSqlLogBase

if IzFmkIni("Sql","SqlDirektno","D")=="D"
  ::lSqlDirektno:=.t.
else
  ::lSqlDirektno:=.f.
endif

if (::oDesktop!=nil)
  ::oDesktop:=nil
endif

::oDesktop:=TDesktopNew()
  
return

