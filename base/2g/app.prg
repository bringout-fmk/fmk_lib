#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/sclib/base/2g/app.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.21 $
 * $Log: app.prg,v $
 * Revision 1.21  2004/04/27 11:01:53  sasavranic
 * Rad sa sezonama - bugfix
 *
 * Revision 1.20  2003/01/19 23:44:18  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.19  2003/01/07 15:13:08  mirsad
 * ispravke rada u sezonama
 *
 * Revision 1.18  2003/01/07 01:14:32  mirsad
 * ispravke za rad sa sezonama
 *
 * Revision 1.17  2002/10/02 17:23:04  mirsad
 * testiranje-sezone
 *
 * Revision 1.16  2002/08/19 10:01:47  ernad
 *
 *
 * podesenja za CLIP
 *
 * Revision 1.15  2002/07/30 17:40:59  ernad
 * SqlLog funkcije - Fin modul
 *
 * Revision 1.14  2002/07/03 07:31:12  ernad
 *
 *
 * planika, debug na terenu
 *
 * Revision 1.13  2002/07/01 10:46:40  ernad
 *
 *
 * oApp:lTerminate - kada je true, napusta se run metod oApp objekta
 *
 * Revision 1.12  2002/06/30 20:28:44  ernad
 *
 *
 *
 * pos meni za odabir firme /MNU_INI
 *
 * Revision 1.11  2002/06/24 17:04:15  ernad
 *
 *
 * omoguceno da se "restartuje" program .... nakon podesenja sistemskog sata -> oApp:run() ....
 *
 * Revision 1.10  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.9  2002/06/24 07:00:37  ernad
 *
 *
 * GwDiskFree, ciscenja gateway
 *
 * Revision 1.8  2002/06/20 16:52:06  ernad
 *
 *
 * ciscenje planika, uvedeno fmk/svi/specif.prg
 *
 * Revision 1.7  2002/06/20 12:53:11  ernad
 *
 *
 * ciscenje rada sezonsko<->radno podrucje ... prebacivanje db/1g -> db/2g
 *
 * Revision 1.6  2002/06/19 19:51:00  ernad
 *
 *
 * rad u sezonama, gateway
 *
 * Revision 1.5  2002/06/19 13:17:47  ernad
 * gateway funkcije
 *
 * Revision 1.4  2002/06/17 09:49:43  ernad
 * uveden TAppMod:gParams, dodana opcija install DB-a pri <s-F10>
 *
 *
 */
 
/*! \file sclib/base/2g/app.prg
 *  \brief Bazni aplikacijski objekat - TAppMod
 */


function TAppModNew(oParent, cVerzija, cPeriod, cKorisn, cSifra, p3,p4,p5,p6,p7)
*{

local oObj

#ifdef CLIP

oObj:=map()
oObj:cName:=nil
oObj:oParent:=nil
oObj:oDatabase:=nil
oObj:oDesktop:=nil
oObj:cVerzija:=nil
oObj:cPeriod:=nil
oObj:cKorisn:=nil
oObj:cSifra:=nil
oObj:nKLicenca:=nil
oObj:cP3:=nil
oObj:cP4:=nil
oObj:cP5:=nil
oObj:cP6:=nil
oObj:cP7:=nil
oObj:cSqlLogBase:=nil
oObj:lSqlDirektno:=nil
oObj:lStarted:=nil
oObj:lTerminate:=nil

oObj:hasParent:=@hasParent()
oObj:setParent:=@setParent()
oObj:getParent:=@getParent()
oObj:setName:=@setName()
oObj:run:=@run()
oObj:quit:=@quit()
oObj:gProc:=@gProc()
oObj:init:=@init()
oObj:gParams:=@gParams()
oObj:base_setTGVars:=@setTGVars()
oObj:setTGVars:=@setTGVars()
oObj:limitKLicenca:=@limitKLicenca()
#else
oObj:=TAppMod():new()
#endif

oObj:self:=oObj

return oObj
*}

#ifdef CPP

/*! \class TAppMod
 *  \brief Bazni Aplikacijski objekt
 */

class TAppMod
{
       public:
	string cName;
	string oParent;
	TDB oDatabase;
	TDesktop oDesktop;
	string cVerzija;
	
	//korisnicka licenca
	string nKLicenca;
	string cPeriod;
	string cKorisn;
	string cSifra;
	string cP3;
	string cP4;
	string cP5;
	string cP6;
	string cP7;
	string cSqlLogBase;
	bool lSqlDirektno;
	bool lStarted;
	bool lTerminate;
	TObject self;
	*bool hasParent();
	*TObject setParent(TObject oParent);
	*TObject getParent();
	*string setName(string cName);
	*void run();
	*void quit(bool lVratiseURP);
	*void gProc();
	*void init(TObject oParent,string cModul,string cVerzija,string cPeriod,string cKorisn,string cSifra,string p3,string p4,string p5,string p6,string p7);
	*void gParams();
	*void setTGVars();
	*void limitKLicenca(int nLevel);
}
#endif

#ifndef CPP
#ifndef CLIP
#include "class(y).ch"

CREATE CLASS TAppMod 
	EXPORTED:
	VAR cName
	VAR oParent
	VAR oDatabase
	VAR oDesktop
	VAR cVerzija
	VAR cPeriod
	VAR cKorisn
	VAR cSifra
	VAR nKLicenca
	VAR cP3
	VAR cP4
	VAR cP5
	VAR cP6
	VAR cP7
	VAR cSqlLogBase
	VAR lSqlDirektno
	VAR lStarted
	VAR lTerminate
	VAR self
	method hasParent
	method setParent
	method getParent
	method setName
	method run
	method quit
	method gProc
	method init
	method gParams
	method setTGVars
	method limitKLicenca
	
END CLASS

#endif
#endif

/*! \fn *void TAppMod::init(TObject oParent,string cModul,string cVerzija,string cPeriod,string cKorisn,string cSifra,string p3,string p4,string p5,string p6,string p7)
 *  \brief Incijalizacija AppMod objekta
 */

*void TAppMod::init(TObject oParent,string cModul,string cVerzija,string cPeriod,string cKorisn,string cSifra,string p3,string p4,string p5,string p6,string p7)
*{

method init(oParent, cModul, cVerzija, cPeriod, cKorisn, cSifra, p3,p4,p5,p6,p7)

#ifdef CLIP
	? "start init"
#endif

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

#ifdef CLIP
	? "end init"
#endif


return
*}

/*! \fn *bool TAppMod::hasParent()
 *  \brief ima li objekat "roditelja"
 */
 
*bool TAppMod::hasParent()
*{
method hasParent()

#ifdef CLIP
	? "start has parent"
#endif

return !(::oParent==nil)
*}


/*! \fn *TObject TAppMod::setParent(TObject oParent)
 *  \brief postavi roditelja ovog objekta
 *
 *  Roditelj je programski modul (objekat) koji je izvrsio kreiranje ovog objekta. To bi znacilo za oPos to parent oFMK - "master" aplikacijski modul koji poziva pojedinacne programske module (oFIN, oKALK, oFAKT)
 */
*TObject TAppMod::setParent(TObject oParent)
*{
method setParent(oParent)

::parent:=oParent

return
*}


/*! \fn *TObject TAppMod::getParent()
 *  \brief Daj mi roditelja ovog objekta
 */

*TObject TAppMod::getParent()
*{
method getParent()
return ::oParent
*}


*string TAppMod::setName(string cName)
*{
method setName()
::cName:="SCAPP"
return
*}



*void TAppMod::run()
*{
method run()

if ::oDesktop==nil
	::oDesktop:=TDesktopNew()
endif
if ::lStarted==nil
	::lStarted:=.f.
endif

SC_START(::self, .t.)
if !::lStarted
	PID("START")
endif
// da se zna da je objekat jednom vec startovan
::lStarted:=.t.

if ::lTerminate
	::quit()	
	return
endif
::MMenu()

return
*}


*void TAppMod::gProc(char Ch)
*{
method gProc(Ch)

local i

altd()

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
		
	case Ch==K_ALT_F11
		ShowMem()

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
*}


/*! \fn *void TAppMod::quit(bool lVratiseURP)
 *  \brief izlazak iz aplikacijskog modula
 *  \param lVratiSeURP - default vrijednost .t.; kada je .t. vrati se u radno podrucje; .f. ne mjenjaj radno podrucje
 *
 *  \todo proceduru izlaska revidirati, izbaciti Rad.sys iz upotrebe, kao i korisn.dbf
 */
 
*void TAppMod::quit(bool lVratiSeURP)
*{
method quit(lVratiseURP)

local cKontrDbf
close all
if (lVratiseURP==nil)
  lVratiseURP:=.t.
endif

#ifdef CLIP
	? "quit metod."
#endif

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

PID("STOP")
CLEAR SCREEN

if !(::hasParent())
	if !gReadonly
		if FOUND()
			REPLACE field->nk WITH .f.
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
*}


*void TAppMod::gParams()
*{
method gParams()

local cFMKINI:="N"
local cPosebno:="N"
local cOldBoje:=SETCOLOR(INVERT)
local cInstall:="N"
private GetList:={}

PushWa()

private cSection:="1",cHistory:=" "; aHistory:={}
select (F_PARAMS);USE
O_PARAMS
RPar("p?",@cPosebno)

gArhDir:=padr(gArhDir,20)
gPFont:=padr(gPFont,20)
Box(,19,70)
 set cursor on
 @ m_x+ 1,m_y+2 SAY "Parametre pohraniti posebno za korisnika "  GET cPosebno valid cPosebno $ "DN" pict "@!"
 read
 WPAr("p?",cPosebno)
 select params; use
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

 gPtkonv:=padr(gPtkonv,2)
 @ m_x+ 3,m_y+2 SAY "Konverzija znakova BEZ, 7-852, 7-A, 852-7, 852-A"
 @ m_x+ 4,m_y+2 SAY "                    0  / 1   /  2  / 3   /   4  "  GET gPTKonv pict "@!" valid subst(gPtkonv,2,1)$ " 1"
 @ m_x+ 6,m_y+2 SAY "Unos podataka u sifrarnike velika/mala slova/konv.u 852 (V/M/8)"  GET gPicSif valid gpicsif $ "VM8" pict "@!"
 @ m_x+ 7,m_y+2 SAY "Stroga kontrola ispravki/brisanja sifara     (D/N)"  GET gSKSif valid gSKSif $ "DN" pict "@!"
 @ m_x+ 8,m_y+2 SAY "Direktorij pomocne kopije podataka" GET gArhDir pict "@!"
 @ m_x+ 9,m_y+2 SAY "Default odgovor na pitanje 'Izlaz direktno na printer?' (D/N/V/E)" GET gcDirekt valid gcDirekt$"DNVER" pict "@!"
 @ m_x+10,m_y+2 SAY "Shema boja za prikaz na ekranu 'V' (B1/B2/.../B7):" GET gShemaVF
 @ m_x+11,m_y+2 SAY "Windows font:" GET gPFont
 @ m_x+12,m_y+2 SAY "Kodna strana:" GET gKodnaS valid gKodnaS $ "78" pict "9"
 @ m_x+13,m_y+2 SAY "Word 97  D/N:" GET gWord97 valid gWord97 $ "DN" pict "@!"
 @ m_x+14,m_y+2 SAY "Zaok 50f (5):" GET g50f    valid g50f    $ " 5" pict "9"
 @ m_x+15,m_y+2 SAY "Prenijeti podatke na lokalni disk (NDCX):" GET gKesiraj    valid gKesiraj $ "NDCX" pict "@!"
 @ m_x+16,m_y+2 SAY "Omoguciti kolor-prikaz? (D/N)" GET gFKolor valid gFKolor$"DN" pict "@!"
 @ m_x+16,col()+2 SAY "SQL log ? (D/N)" GET gSql pict "@!"

 @ m_x+18,m_y+2 SAY "Ispravka FMK.INI (D/S/P/K/M/N)" GET cFMKINI valid cFMKINI $ "DNSPKM" pict "@!"
 @ m_x+18,m_y+36 SAY "M - FMKMREZ"
 read
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
  Wpar("pt",gPTKonv)
  Wpar("pS",gPicSif)
  Wpar("SK",gSKSif)
  Wpar("DO",gcDirekt)
  Wpar("FK",gFKolor)
  Wpar("S9",gSQL)
  UzmiIzIni(KUMPATH+"fmk.ini","Svi","SqlLog",gSql,"WRITE")
  Wpar("SB",gShemaVF)
  Wpar("Ad",trim(gArhDir))
  Wpar("FO",trim(gPFont))
  Wpar("KS",gKodnaS)
  Wpar("W7",gWord97)
  Wpar("5f",g50f)
 if gKesiraj $ "CD"
   if sigmaSif("SKESH")
    Wpar("kE",gKesiraj)
   else
    MsgBeep("Neispravna sifra!")
   endif
 else
    Wpar("kE",gKesiraj)
 endif

endif
KonvTable()
select gparams; use
PopWa()
SETCOLOR(cOldBoje)

return
*}

/*! \fn TAppMod::setTGVars() 
 *  \brief Setuje globalne varijable, te setuje incijalne vrijednosti objekata koji pripadaju glavnom app objektu
 */

*void TAppMod::setTGVars()
*{
method setTGVars()

#ifdef CLIP
? "base setTGVars ..."
#endif


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
*}

/*! \fn TAppMod::limitKLicenca(nLevel)
 *  \brief Prikazuje poruku o ogranicenosti korisnicke licence
 *  \return  True ako je nLevel> oApp:nKLicenca return .t.
 */

*void TAppMod::limitKLicenca(nLevel)
*{
method limitKLicenca(nLevel)

if (::nKLicenca==nil)
	nKLicenca:=5
endif

if (nLevel>::nKLicenca)
	MsgBeep("Prekoracen limit korisnicke licence" )
	return .t.
endif
return .f.
*}
