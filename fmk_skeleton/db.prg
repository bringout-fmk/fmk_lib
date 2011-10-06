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

#include "hbclass.ch"

function TDBNew(oDesktop, cDirPriv, cDirKum, cDirSif)

local oObj

CLASS TDB
	DATA oDesktop
	DATA oApp
	DATA cName
	
	DATA cSezona
	DATA cRadimUSezona
	
	DATA cSezonDir
	DATA cBase
	DATA cDirPriv
	DATA cDirKum
	DATA cDirSif
	DATA cSigmaBD
	DATA cUser
	DATA nPassword
	DATA nGroup1
	DATA nGroup2
	DATA nGroup3
	DATA lAdmin

	METHOD New() 
	METHOD logAgain (cSezona, lSilent, lWriteKParam) 
	
        METHOD radiUSezonskomPodrucju (lForceRadno)
 
	method loadSezonaRadimUSezona
	method saveSezona
	method saveRadimUSezona
	method modstruAll
	method setDirPriv
	method setDirSif
	method setDirKum
	method setSigmaBD
	method setUser
	method setPassword
	method setGroup1
	method setGroup2
	method setGroup3
	method mInstall
	method vratiSez
	method setIfNil
	method scan
	
ENDCLASS


method New(oDesktop, cDirPriv, cDirKum, cDirSif)  CLASS TDB

::oDesktop:=oDesktop
::cDirPriv:=cDirPriv
::cDirKum:=cDirKum
::cDirSif:=cDirSif
::lAdmin:=.f.

return self



/*! \var TDB:lAdmin
 *  \brief True - admin rezim, False - normalni pristup podacima 
 */


/*! \fn *void TDB::logAgain(string cSezona, bool lSilent, bool lWriteKParam)
 *  \brief logiraj se ponovo, sa oznakom nove sezone
 *  \param cSezona
 *  \param lSilent
 */
 
METHOD logAgain(cSezona, lSilent, lWriteKParam) CLASS TDB

local cPom
local fURp:=.f.
// sezona koja je trenutno radno podrucje
local cDanasnjaSezona
private lURp:=.f.

//ako sam u administratorskom rezimu, za svaki slucaj kreiraj
//parametarske tabele
if ::lAdmin
	CreSystemDb()
endif

CLOSE ALL

::setIfNil()

if (lWriteKParam==nil)
	lWriteKParam:=.t.
endif


if ((cSezona!=nil) .and. (::cSezona != nil) .and. (lSilent!=nil))
	if ((cSezona==::cSezona) .and. (::cSezona==STR(Year(Date()),4)) .and. lSilent)
		fURP:=.t.
	endif
endif

if cSezona==nil
	cSezona:=STR(YEAR(DATE())-1,4)
endif

if lSilent==nil
	lsilent:=.f.
endif

cDanasnjaSezona:=STR(YEAR(DATE()),4)

IF ::cSezona==nil
	::cSezona:=cDanasnjaSezona
EndIF

if !lsilent
	Box(,1,60)
	set cursor on
  	@ m_x+1,m_y+2 SAY "Pristup podacima iz sezone " GET cSezona pict "@!"
  	read
  	ESC_BCR
	BoxC()

	// pristup sezonskim podacima tek godine
	if ( ::cSezona==cSezona  .or. cSezona=="RADP") 
   		if Pitanje(,"Pristup radnom podrucju ?","D")=="D"
       			fURP:=.t.
   		endif
	endif
endif // fsilent

// novi radni direktoriji
if !EMPTY(::cSezondir)
	::setDirKum(strtran(::cDirKum ,::cSezonDir,""))
	::setDirSif(strtran(::cDirSif ,::cSezonDir,""))
	::setDirPriv(strtran(::cDirPriv,::cSezonDir,""))
endif

// vrati u predhodno stanje

if !fURP .and. (::cSezona==cDanasnjaSezona)
	// nisam u radnom podrucju, ako se ovo pokrece sa radne stanice
  	// kreirajmo privatne datoteke
  	::skloniSezonu(cSezona,.f.,.t.,.f.,  .t.)
endif

if fUrP
  	cSezona:="RADP"
endif

if lWriteKParam
	private cSection:="1",cHistory:=" "; aHistory:={}
	O_KPARAMS
	::cRadimUSezona:=cSezona
	Wpar("rp",::cRadimUSezona)
	select kparams
endif

USE

if fURP
 	::cSezonDir:=""
 	::oDesktop:showSezona(::cRadimUSezona)
 	::oDesktop:showMainScreen()
else
	StandardBoje()
	::oDesktop:showSezona(::cRadimUSezona)
	SezonskeBoje()
	::oDesktop:showMainScreen()
	StandardBoje()

	::cSezonDir:=SLASH+::cRadimUSezona
	::setDirKum(trim(::cDirKum) + SLASH + ::cRadimUSezona)
	::setDirSif(trim(::cDirSif) + SLASH + ::cRadimUSezona)
	::setDirPriv(trim(::cDirPriv) + SLASH + ::cRadimUSezona)
 
	::oDesktop:showSezona(::cRadimUSezona) 

	StandardBoje()  // vrati standardne boje
endif


if !IsDirectory(::cDirKum) .and. Pitanje(,"Formirati sezonske direktorije","N")=="D"
	// kreiraj sezonske direktorije
	dirmake(::cDirKum)      
	dirmake(::cDirSif)
	dirmake(::cDirPriv)
endif

lURp:=fURp

::oApp:SetGVars()

JelReadOnly()
return



*void TDB::modstruAll()


METHOD modstruAll() CLASS TDB
local i
::lAdmin:=.t.

aSezone:=ASezona(::cDirKum)
RunMods(.t.)

FOR i:=1 TO LEN(aSezone)
	CreParams()
	::LogAgain(aSezone[i,1],.t.)   
	CreParams()
	RunMods(.t.)
NEXT

::cRadimUSezona:="RADP"
 
private cSection:="1"
private cHistory:=" "
private aHistory:={}

O_KPARAMS
Wpar("rp",::cRadimUSezona)
select kparams
use

::lAdmin:=.f.
return




*string TDB::setDirPriv(string cDir)

METHOD setDirPriv(cDir) CLASS TDB
local cPom

// dosadasnja vrijednost varijable
cPom:=::cDirPriv

cDir:=ALLTRIM(cDir)

if (gKonvertPath=="D")
	KonvertPath(@cDir)
endif

::cDirPriv:=ToUnix(cDir)

// setuj i globalnu varijablu dok ne eliminisemo sve pozive na tu varijablu
cDirPriv:=::cDirPriv

return cPom



*string TDB::setDirSif(string cDir)

METHOD setDirSif(cDir) CLASS TDB
local cPom

// dosadasnja vrijednost varijable
cPom:=::cDirSif

cDir:=alltrim(cDir)
if (gKonvertPath=="D")
	KonvertPath(@cDir)
endif
::cDirSif:=ToUnix(cDir)

// setuj i globalnu varijablu dok ne eliminisemo sve pozive na tu varijablu
cDirSif:=::cDirSif

return cPom



*string TDB::setDirKum(string cDir)

METHOD setDirKum(cDir) CLASS TDB
local cPom

// dosadasnja vrijednost varijable
cPom:=::cDirKum
cDir:=alltrim(cDir)
if (gKonvertPath=="D")
	KonvertPath(@cDir)
endif
::cDirKum:=ToUnix(cDir)

// setuj i globalnu varijablu dok ne eliminisemo sve pozive na tu varijablu

/*! \todo Eliminsati ovu nepotrebnu dvojnost cDirRad, cDirKum -> sve prebaciti na cDirKum !
 */

cDirKum:=::cDirKum
cDirRad:=::cDirKum

SET(_SET_DEFAULT,trim(cDir))

return cPom



*string TDB::setSigmaBD(string cDir)

METHOD setSigmaBD(cDir) CLASS TDB
local cPom
// dosadasnja vrijednost varijable
cPom:=::cSigmaBD
cDir:=alltrim(cDir)
if (gKonvertPath=="D")
	KonvertPath(@cDir)
endif
::cSigmaBD:=ToUnix(cDir)
return cPom



*string TDB::setUser(string cUser)

METHOD setUser(cUser) CLASS TDB
local cPom
// dosadasnja vrijednost varijable
cPom:=::cUser
::cUser:=cUser
return cPom



*string TDB::setPassword(integer nPassword)

METHOD setPassword(nPassword) CLASS TDB
local nPom
// dosadasnja vrijednost varijable
nPom:=::nPassword
::nPassword:=nPassword
return nPom



*string TDB::setGroup1(integer nGroup)

METHOD setGroup1(nGroup) CLASS TDB
local nPom
// dosadasnja vrijednost varijable
nPom:=::nGroup1
::nGroup1:=nGroup
return nPom



*string TDB::setGroup2(integer nGroup)

METHOD setGroup2(nGroup) CLASS TDB
local nPom
// dosadasnja vrijednost varijable
nPom:=::nGroup2
::nGroup2:=nGroup
return nPom



*string TDB::setGroup3(integer nGroup)

METHOD setGroup3(nGroup) CLASS TDB
local nPom
// dosadasnja vrijednost varijable
nPom:=::nGroup3
::nGroup3:=nGroup
return nPom





/*! \fn TDB::mInstall()
 *  \brief meni install database funkcija
 *  \note bivsa funkcija Sistem
 */
 
*void TDB::mInstall()

METHOD mInstall() CLASS TDB
local i, cPom, aLst
private nOldIzbor
private opc:={}
private opcexe:={}
private Izbor

::lAdmin:=.t.

@ 4,5 SAY""
AADD(opc,"1. pregled korisnika modula - sifre, prioriteti  ")
AADD(opcexe,{|| KorPreg() })
AADD(opc,"2. promjena sifre")
AADD(opcexe, {|| KorLoz() })
AADD(opc,"3. reindex")
AADD(opcexe, {|| Reindex() })
AADD(opc,"4. pakovanje")
AADD(opcexe, {|| Pakuj() })
AADD(opc,"5. brisi pa ponovo kreiraj indekse")
AADD(opcexe, {|| BrisiPaK()})
AADD(opc,"6. modifikacija struktura")
AADD(opcexe, {|| RunMods()})
AADD(opc,"7. instalacija fajlova")
#ifdef CLIP
	AADD(opcexe, {|| CreParams(), self:kreiraj()  })
#else
	AADD(opcexe, {|| CreParams(), ::kreiraj()  })
#endif
AADD(opc,"9. promjena oznake sezone u radnom podrucju")
AADD(opcexe, {|| PromOzSez() })
AADD(opc,"A. otpakuj iz tmp arhive")
AADD(opcexe, {|| UzmiIzArj() })
AADD(opc,"-------------------")
AADD(opcexe, nil)
AADD(opc,"X. arhiviraj na diskete")
AADD(opcexe, {|| StaviUArj() })
AADD(opc,"Y. konverzija znakova u bazama")
AADD(opcexe, {|| ::konvZn() })
AADD(opc,"F. ostale funkcije")
AADD(opcexe, {|| ::ostalef() })
AADD(opc,"-------------------")
AADD(opcexe, nil)

AADD(opc,"T. tech info")
AADD(opcexe, {|| TechInfo() })
AADD(opc,"U. uklanjanje sezona")
AADD(opcexe, {|| BrisiSezonu() })

if System .or. (KLevel='0' .and. Right(trim(ImeKorisn),1)='1')
  AADD(opc,"S. sistem zastite")
  AADD(opcexe, {|| Secur() })
endif

Izbor:=1
Menu_SC("imod")

::lAdmin:=.f.
return



/*! \fn TDB::vratiSez()
 *  \brief vrati stanje podataka iz sezone u radno podrucje
 */
 
*void TDB::vratiSez()
METHOD vratiSez(oDatabase) CLASS TDB


if ::oApp:limitKLicence(AL_GOLD)
	return
endif

//if !UGlavnomMeniju()
//   return
//endif

::lAdmin:=.t.

if !empty(::cSezonDir) // sezonski podaci
  Msg("Opcija nedostupna pri radu u sezonskom podrucju")
  closeret
endif

close all
if !sigmasif("SIGMASEZ")
  return
endif

Box(,3,50)
  cDN:="N"
  set cursor on
  cSezona:=padr(goModul:oDataBase:cSezona,4)
  @ m_x+1, m_y+2 SAY "U radno podrucje vratiti stanje iz sezone" GET cSezona pict "9999" valid StSezona(cSezona)
  @ m_x+3, m_y+2 SAY "Zelite nastaviti operaciju D/N" GET cDN pict "@!" valid cdn $ "DN"
  read

BoxC()
if lastkey()==K_ESC  .or. cDN="N"
    return
endif


// privatni
fnul:=.f.

private aFilesP:={}
private aFilesS:={}
private aFilesK:={}
close all
if !PocSkSez()
  closeret
endif


cOldSezona:=goModul:oDataBase:cSezona

// ako je "0000" ne pravi backup backupa
if cSezona<>"0000"   
 ::skloniSezonu("0000",.f.,.t.)   // backup
 // jos jednom za svaki slucaj bezuvjetno
 // .t. - bez price
else
 cOldSezona:=cSezona
endif

if Pitanje(,"Prenos RADNO PODRUCJE -> SEZONA "+goModul:oDataBase:cSezona+" ?","D")=="D"
    	// .f. - iz radnog u sezonski
	::skloniSezonu(goModul:oDataBase:cSezona,.f.,.t.)
endif


if Pitanje(,"Prenos: SEZONA "+cSezona+" -> RADNO PODRUCJE ?","D")=="D"
    ::skloniSezonu(cSezona,.t.,.t.)
    // .t. - iz sezonskog u radni
    // bezuvjetno

     Otkljucaj(KUMPATH+"KPARAMS.DBF")
     O_KPARAMS
     private cSection:="1",cHistory:=" "; aHistory:={}
     if cSezona=="0000" 
     	// iz backupa vracam, pa cu ja odrediti sezonu
         gSezona:=goModul:oDataBase:cSezona
         Box(,4,60)
           set escape off
           set confirm on
           @ m_x+1,m_y+2 SAY "Podaci vraceni iz backup - 0000 sezone"
           @ m_x+2,m_y+2 SAY "Povrat je izvrsen u radno podrucje."
           @ m_x+4,m_y+2 SAY "Odredite sezonu podataka u radnom podrucju:" GET gSezona pict "9999" valid gSezona<>"0000"
           read
           set escape on
           set confirm off
         BoxC()
         goModul:oDataBase:cSezona:=gSezona
     else
      goModul:oDataBase:cSezona:=cSezona
     endif
     Wpar("se",goModul:oDataBase:cSezona,gSQL=="D")
     select kparams; use
     IspisiSez()
endif
KrajskSez(cOldSezona)

::lAdmin:=.f.
return



*string KParams_se;
/*! \ingroup params
 *  \var KParams_se
 *  \brief Oznaka sezone za podatke u KUMPATH-u, tekucoj lokaciji podataka
 *  \note Ako stoji 2002, znaci da se u ovom direktoriju nalaze podaci iz 2002 godine
 */

*string KParams_rp;
/*! \ingroup params
 *  \var KParams_rp
 *  \brief Oznaka sezone sa kojom se trenutno radi
 *  \note Ako stoji 2001, znaci da se trenutno radi sa podacima iz 2001 godine
 */



/*! \fn TDB::loadSezonaRadimUSezona()
 *  \brief ucitaj ::cSezona, ::cRadimUSezona iz tabele parametara
 */
 
*void TDB::loadSezonaRadimUSezona()
METHOD loadSezonaRadimUSezona() CLASS TDB
local cPom


O_KPARAMS
public gSezona:="    "


private cSection:="1"
private cHistory:=" "
private aHistory:={}

cPom:=::cSezona
Rpar("se",@cPom)
::cSezona:=cPom
SELECT kparams
USE

// nije upisana sezona tekuce godine, ovo se desava samo pri inicijalizaciji baze
if EMPTY(::cSezona)
    	::cSezona:=STR(YEAR(DATE()),4)
	::cSezonDir:=""
	::saveSezona(::cSezona)
endif

O_KPARAMS
cPom:=::cRadimUSezona
Rpar("rp",@cPom)
SELECT kparams
USE

if cPom==nil
	cPom:="RADP"
	::saveRadimUSezona(cPom)
endif

::cRadimUSezona:=cPom

if (::cRadimUSezona==::cSezona .or. ::cRadimUSezona=="RADP")
	::cSezonDir:=""
else
	::cSezonDir:=SLASH+::cRadimUSezona
endif

return


*void TDB:saveSezona(string cValue)

METHOD saveSezona(cValue) CLASS TDB

#ifdef CLIP
	? "save sezona ..."
#endif
O_KPARAMS
private cSection:="1"
private cHistory:=" "
private aHistory:={}
Wpar("se", cValue, gSQL=="D")
select kparams
use
return


*void TDB:saveRadimUSezona(string cValue)

METHOD saveRadimUSezona(cValue) CLASS TDB
O_KPARAMS
private cSection:="1"
private cHistory:=" "
private aHistory:={}
if gSql != "D" 
	Wpar("rp", cValue, .f.)
else
	if TYPE("gSQLSite")=="N" .and. VALTYPE(goModul:cSqlLogBase)=="C"  
		Wpar("rp", cValue, .t.)
	endif
	//if gSQL=="D"
	//	MsgBeep("Nije definisan gSQLSite ?")
	//endif
endif
SELECT kparams
USE
return



/*! \fn *void TDB::radiUSezonskomPodrucju()
 *  \brief Na osnovu ::cRadimUSezona odredi database: Sezonsko ili Radno podrucje
 *  \note centralno pitanje je "Prosli put ste radili u sezonskom podrucju ... Nastaviti ?"
 */

*void TDB::radiUSezonskomPodrucju(bool lForceRadno)

METHOD radiUSezonskomPodrucju (lForceRadno) CLASS TDB

::setIfNil()
if (lForceRadno==nil)
	lForceRadno:=.f.
endif

if ::cRadimUSezona<>"RADP"
	if ( lForceRadno .or. Pitanje(,"Prosli put ste radili u sezonskom podrucju " +::cRadimUSezona+". Nastaviti ?","D")=="N")
		//ipak se prebaci na radno podrucje
		::cRadimUSezona:="RADP"
		::saveRadimUSezona(::cRadimUSezona)
		::cSezonDir:=""

	else
       		CreParams()
		::logAgain(::cRadimUSezona,.t.)
	endif
else
		::cRadimUSezona:="RADP"
		::saveRadimUSezona(::cRadimUSezona)
endif



*void TDB:setIfNil()

METHOD setIfNil() CLASS TDB
if (::oDesktop==nil)
	::oDesktop:=goModul:oDesktop
endif
if (::oApp==nil)
	::oApp:=goModul
endif
return


METHOD scan() CLASS TDB

return


