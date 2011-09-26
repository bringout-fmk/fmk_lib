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
#include "error.ch"

/*
 * ----------------------------------------------------------------
 *                          Copyright Sigma-com software 1996-2006 
 * ----------------------------------------------------------------
 */

function PocSkSez()
*{
if OFSveuDir(PRIVPATH,@aFilesP) .and.;
   iif(SIFPATH<>PRIVPATH, OFSveuDir(SIFPATH,@aFilesS),.t.) .and.;
   iif(KUMPATH<>SIFPATH.and.KUMPATH<>PRIVPATH,OFSveuDir(KUMPATH, @aFilesK),.t.)
   //
else
   MsgBeep("Operacija onemogucena, neko vec koristi podatke")
   ZFSveuDir(@aFilesP)
   ZFSveuDir(@aFilesS)
   ZFSveuDir(@aFilesK)
   return .f.
endif
return .t.
*}

function KrajskSez(cOldSezona)
*{

ZFSveuDir(@aFilesP)
ZFSveuDir(@aFilesS)
ZFSveuDir(@aFilesK)

return nil
*}

function StSezona(cSezona)
*{

if cSezona==goModul:oDataBase:cSezona
  MsgBeep("Ne mozete odabrati tekucu sezonu")
  return .f.
endif
if val(cSezona)>year(date())
  MsgBeep(cSezona+" je stara sezona ???")
  return .t.
endif
return .t.
*}

/****f SC_ASEZ/Skloni ***

*AUTOR
 Ernad Husremovic ernad@sigma-com.net

*IME

*SYNOPSIS
 function Skloni(cPath,cime,cSezona,finverse,fda,fnuliraj)


*ULAZI

*OPIS
 1) formiraju se sezonski direktoriji
 2) finverse = .t. iz radnog u sezonsko
 3) fda = .t. - ne pitam nego kopirama
          .f. - pitam za overwrite (kopiranje preko postojeceg)
 finverse .f. - u sezonski direktorij kopiraj
          .t. - iz sezonskog u radni direktorij



*PRIMJER
 function Skloni(KUMPATH, ToUnix("SUBAN.DBF"), "1998" , .f. , .f. , .f. )

*BILJESKE

***/


function Skloni(cPath,cIme,cSezona,fInverse,fDa,fNuliraj)
*{

if Empty(cSezona)
	MsgBeep("Nepostojeca sezona!!!" + cSezona)
endif

DirMake(cPath+cSezona)

cPath:=Upper(cPath)
cIme:=Upper(cIme)

if fInverse
	cFull:=cPath+cIme
else
	cFull:=cPath+cSezona+SLASH+cIme
endif
//MsgBeep(cFull)

if fDa .or. !fInverse .and. (!File(cFull) .or. Pitanje(,cPath+cIme+" je vec pohranjen u "+cSezona+". Spremiti D/N ?"," ")="D") .or. fInverse .and. (!File(cFull) .or. Pitanje(,cPath+cIme+" iz RP prekriti sadrzajem iz "+cSezona+" ?"," ")="D")
	Otkljucaj(cPath+cIme)
   	if fInverse
		// preimenuj ciljni fajl radi sigurnosti
     		cBackup:=cPath+STRTRAN(Upper(cIme),"."+DBFEXT,"._BF")
     		cBackup:=STRTRAN(cBackup,"."+MEMOEXTENS,"._BT")
		FErase(cBackup)
     		if FRename(cPath+cIme,cBackup)=-1   // ne moze preimenovati
          		if File(cPath+cIme)   // a fajl postoji
              			MsgBeep("Neko je zauzeo datoteku "+cPath+cIme)
              			return .f.
          		endif
     		endif
     		nKopirano:=FileCopy(cPath+cSezona+SLASH+cIme,cPath+cIme)
     		// izbrisi kopiju
     		cKom:="copy "+cPath+cSezona+SLASH+cIme+" "+cPath+cIme
     		CopySve(STRTRAN(cIme,"."+DBFEXT,"*."+INDEXEXT),cPath+cSezona+SLASH,cPath)
   	else

     		// preimenuj ciljni fajl radi sigurnosti
     		cBackup:=cPath+cSezona+SLASH+STRTRAN(Upper(cIme),"."+DBFEXT,"._BF")
     		cBackup:=STRTRAN(cBackup,"."+MEMOEXTENS,"._BT")
		FErase(cBackup)
     		FRename(cPath+cSezona+DBFEXT+cIme,cBackup)

     		nKopirano:=FileCopy(cPath+cIme,cPath+cSezona+SLASH+cIme)
     		cKom:="copy "+cPath+cIme+" "+cPath+cSezona+SLASH+cIme
		CopySve(STRTRAN(cIme,".DBF","*."+INDEXEXT),cPath,cPath+cSezona+SLASH)
   	endif
   	
	if FileCOpen()
     		MsgBeep("Proces kopiranja nije dobro zavrsen !???##"+;
             		"PREKINUTI RAD - ZOVI SIGMA-COM SERVIS!"+cKom)
   	endif
   	? cKom, nKopirano
   	?
  	if (nKopirano<>0 .and. fNuliraj)
     		select 66
     		usex (cPath+cIme)
     		zap
     	use
	endif

	Zakljucaj(cPath+cIme)
	//run &cKom

	cKom:=STRTRAN(Upper(cKom),".DBF","*."+INDEXEXTENS)
	
	? cKom
	?

endif // fda

return
*}

function BrisiSezonu()
*{

if !sigmasif("SIGMABS")
    return
endif
  Box(,20,77)
    DO WHILE .t.
      BoxCLS()
      @ m_x+2, m_y+2 SAY "KUMPATH ='" + KUMPATH  + "'"
      @ m_x+3, m_y+2 SAY "PRIVPATH='" + PRIVPATH + "'"
      @ m_x+4, m_y+2 SAY "SIFPATH ='" + SIFPATH  + "'"
      @ m_x+5, m_y+2 SAY "EXEPATH ='" + EXEPATH  + "'"
      @ m_x+6, m_y+2 SAY REPL("-",70)

      aSezone := aSezona(KUMPATH)

      @ m_x+7, m_y+2 SAY "Postojece sezone:"
      i:=0
      FOR j:=1 TO LEN(aSezone)
        IF (j-1)%5 == 0
          ++i
          @ m_x+7+i, m_y+2 SAY "'" + aSezone[j,1] + "'"
        ELSE
          @ m_x+7+i, col()+1 SAY ", '" + aSezone[j,1] + "'"
        ENDIF
      NEXT
      ++i
      IF LEN(aSezone)<1
        @ m_x+7+i, m_y+2 SAY "Ne postoji nijedna sezona!"
        DO WHILE NEXTKEY()==0; OL_YIELD(); ENDDO
        INKEY()
        // INKEY(0)
        EXIT
      ELSE
        cSezona:=SPACE(4)
        cKumDN := "D"
        cPriDN := "D"
        cSifDN := "N"
        @ m_x+ 7+i, m_y+2 SAY "Ukucajte oznaku sezone koju zelite izbrisati" GET cSezona PICT "@!" VALID ASCAN(aSezone,{|x| UPPER(x[1])==TRIM(cSezona)}) > 0
        @ m_x+ 8+i, m_y+2 SAY "Brisati kumulativni direktorij ? (D/N)" GET cKumDN PICT "@!" VALID cKumDN$"DN"
        @ m_x+ 9+i, m_y+2 SAY "Brisati privatni direktorij ?    (D/N)" GET cPriDN PICT "@!" VALID cPriDN$"DN"
        @ m_x+10+i, m_y+2 SAY "Brisati direktorij sifrarnika?   (D/N)" GET cSifDN PICT "@!" VALID cSifDN$"DN"
        READ
        IF LASTKEY() == K_ESC
          EXIT
        ELSEIF ASCAN(aSezone,{|x| UPPER(x[1])==TRIM(cSezona)}) > 0 .and.;
               ( cKumDN=="D" .or. cPriDN=="D" .or. cSifDN=="D" )

          // brisi KUM
          // ---------
          IF cKumDN=="D"
            cDir:=KUMPATH+cSezona
            SAVE SCREEN TO cS
             DelSve("*.*",cDir)
            RESTORE SCREEN FROM cS
            nErrKod := DIRREMOVE(cDir)
            IF nErrKod==0
              MsgBeep(cDir+" uspjesno izbrisan!")
            ELSE
              MsgBeep("Greska("+STR(nErrKod)+")! "+cDir+" se ne moze izbrisati!")
            ENDIF
          ENDIF

          // brisi PRIV
          // ---------
          IF cPriDN=="D"
            cDir:=PRIVPATH+cSezona
            SAVE SCREEN TO cS
             DelSve("*.*",cDir)
            RESTORE SCREEN FROM cS
            nErrKod := DIRREMOVE(cDir)
            IF nErrKod==0
              MsgBeep(cDir+" uspjesno izbrisan!")
            ELSE
              MsgBeep("Greska("+STR(nErrKod)+")! "+cDir+" se ne moze izbrisati!")
            ENDIF
          ENDIF

          // brisi SIF
          // ---------
          IF cSifDN=="D"
            cDir:=SIFPATH+cSezona
            SAVE SCREEN TO cS
             DelSve("*.*",cDir)
            RESTORE SCREEN FROM cS
            nErrKod := DIRREMOVE(cDir)
            IF nErrKod==0
              MsgBeep(cDir+" uspjesno izbrisan!")
            ELSE
              MsgBeep("Greska("+STR(nErrKod)+")! "+cDir+" se ne moze izbrisati!")
            ENDIF
          ENDIF
        ENDIF
      ENDIF
    ENDDO
  BoxC()
return
*}


// -----------------------------------------------------------
// vraca niz poddirektorija koji nemaju ekstenziju u nazivu
// a nalaze se u direktoriju cPath (npr. "c:\sigma\fin\kum1\")
// -----------------------------------------------------------
FUNCTION ASezona(cPath)
*{
LOCAL aSezone
  aSezone := DIRECTORY(cPath+"*.","DV")
FOR i:=LEN(aSezone) TO 1 STEP -1
    IF aSezone[i,1]=="." .or. aSezone[i,1]==".."
      ADEL(aSezone,i)
      ASIZE(aSezone,LEN(aSezone)-1)
    ENDIF
NEXT
RETURN aSezone
*}


function ProcPrenos(fSilent)
*{

if gProcPrenos="N"
	MsgBeep("Ovaj program nema procedure prenosa !")
   	return
endif

if fSilent==nil
	fSilent:=.f.
endif

if !Uglavnommeniju()
	return
endif

if (goModul:oDatabase:cRadimUSezona=="RADP")
	if VAL(goModul:oDatabase:cSezona)<>YEAR(DATE()) 
	// sezona razlicita od godine
      		MsgBeep("Prema satu racunara tekuca sezona je "+STR(YEAR(Date()))+"##"+"Ukoliko vam je nejasno sta ciniti odgovorite sa 'N'##"+"i kontaktirajte servisera SIGMA-COMa ! ##"+"Ukoliko zelite zapoceti rad u novoj sezoni,#"+"na sljedece pitanje odgovorite sa 'D' ##"+"<Enter> nastavak")
      		if Pitanje(,"Pohraniti stanje iz radnog podrucja u sezonsko podrucje - sezona " + goModul:oDataBase:cSezona + " ?","N")=="D"
         		ZaSvakiSlucaj()
         		private aFilesP:={}
         		private aFilesS:={}
         		private aFilesK:={}
         		close all
	 		if !PocSkSez()
          			goModul:quit()
         		endif
	 		goModul:oDatabase:skloniSezonu(goModul:oDataBase:cSezona,.f.,.f.,.t.)
	 		cOldSezona:=goModul:oDataBase:cSezona
         		goModul:oDatabase:cSezona:=STR(YEAR(DATE()),4)
         		Otkljucaj(KUMPATH+"KPARAMS.DBF")
	 		goModul:oDatabase:saveSezona(goModul:oDatabase:cSezona)
         		MsgBeep("save sezona OK")
	 		MsgBeep("Promet protekle sezone je izbrisan iz radnih podataka.#"+"Ovi podaci nalaze se pohranjeni u sezonskom podrucju.##"+"Nakon ove operacije indeksi nisu korektni !##"+"Pokrenuti odgovarajuci install modul / opcija reindex##"+"SA <SHIFT-F6> PRISTUPATE PODACIMA IZ PROTEKLE SEZONE",0)
         		KrajskSez(cOldSezona)
         		release cOldSezona
         		Errorlevel(55)
         		goModul:quit()
     		endif
 	else
   		if !fSilent
     			MsgBeep("Oznaka sezone u radnom podrucju je:"+goModul:oDatabase:cSezona)
   		endif
 	endif

endif
return
*}

/****f SC_ASEZ/SetOznNoGod ***

*AUTOR
 Ernad Husremovic ernad@sigma-com.net

*IME
 SetOznNoGod
 
*SYNOPSIS
 SetOznNoGod

*OPIS
 U sezonama u kojima se nije radilo postavlja oznaku nove godine
 kao oznaku tekuce sezone

*PRIMJER

*BILJESKE

****/

function SetOznNoGod()
*{
IF OzNoGod() <> goModul:oDataBase:cSezona .and.;
   VAL(OzNoGod()) > VAL(goModul:oDataBase:cSezona) .and. VAL(OzNoGod())>2000
	if JelSeRadilo()
		O_KPARAMS
		PUBLIC gSezona:="    "
		private cSection:="1",cHistory:=" "; aHistory:={}
		Rpar("se",@gSezona)
		gSezona := STR(VAL(OzNoGod())-1,4)  // !!
		Wpar("se",gSezona,gSQL=="D")
		goModul:oDataBase:cSezona:=gSezona
		select kparams; use
		// slijedi alt+F6
		ProcPrenos()
	else
		// MsgBeep("Nije se radilo!")
		O_KPARAMS
		PUBLIC gSezona:="    "
		private cSection:="1",cHistory:=" "; aHistory:={}
		Rpar("se",@gSezona)
		gSezona := OzNoGod()  // !!
		Wpar("se",gSezona,gSQL=="D")
		goModul:oDataBase:cSezona:=gSezona
		select kparams
		use
	endif
	goModul:quit()
ENDIF

return
*}

function JelSeRadilo()
*{
 LOCAL lVrati:=.t.
  IF "U" $ TYPE("gGlBaza") .or. EMPTY(gGlBaza)
    // bolje da se uzme da se radilo
    lVrati:=.t.
  ELSE
    select 0
    // MsgBeep("Otvaram '"+KUMPATH+gGlBaza+"'")
    USE (KUMPATH+gGlBaza); GO TOP
    IF RECCOUNT()>0
      lVrati:=.t.
    ELSE
      lVrati:=.f.
    ENDIF
    USE
  ENDIF
RETURN lVrati
*}

FUNCTION OzNoGod()
*{
RETURN PADR( IzFMKIni( "Svi" , "NovaGodina" , STR(YEAR(DATE()),4) ) ,4)
*}

function SezRad(cDir)
*{
local cPom
if !empty(goModul:oDatabase:cSezonDir) // u sezoni sam
  if  right(cDir,5)==goModul:oDatabase:cSezonDir
     return cDir
  else
    cPom:=cDir+right(goModul:oDatabase:cSezonDir,4) + "\"
    if PostDir(cPom)
     return cPom
    else
     return cDir
    endif
  endif
else
  return cdir // radno podrucje
endif

return
*}

function URadPodr(fset, oDatabase)
*{
*
* fset == .t. -> upisi u kparams

// vrati u predhodno stanje

if oDatabase==nil
	oDatabase:=goModul:oDatabase
endif

if fset==NIL
	fSet:=.t.
endif

oDatabase:logAgain(STR(YEAR(DATE()),4),.t.)

/*!
cDirRad:= strtran(cDirRad ,goModul:oDatabase:cSezonDir,"")
cDirSif:= strtran(cDirSif ,goModul:oDatabase:cSezonDir,"")
cDirPriv:=strtran(cDirPriv,goModul:oDatabase:cSezonDir,"")

// novi radni direktoriji
PUBLIC goModul:oDatabase:cSezonDir:=""

SET(_SET_DEFAULT,cDirRad)

StandardBoje()  // vrati standardne boje
NaslEkran(.f.)

@ 0,24 SAY PADR(trim(ImeKorisn)+":"+cDirPriv,25) COLOR INVERT
@ 3,70 SAY "Sez."+goModul:oDatabase:cSezona COLOR INVERT

private cSection:="1",cHistory:=" "; aHistory:={}

if fset  // upisi u kparams
O_KPARAMS
gRadnoPodr:="RADP"
Wpar("rp",gRadnoPodr)
select kparams; use
endif

goModul:SetGVars()
return
*/

*}

function PromOzSez(oDatabase)
*{
local cPom

if (oDatabase==nil)
	oDatabase:=goModul:oDatabase
endif

if !SigmaSif("SS      ")
  return
endif

if (gRadnoPodr<>"RADP")
   MsgBeep("Niste u radnom podrucju")
   return
endif

      
oDatabase:loadSezonaRadimUSezona()

Box(,2,60)
        @ m_x+1,m_y+2 SAY "Oznaka sezone za bazu podataka " GET oDatabase:cSezona pict "9999"
        read
	ESC_BCR
BoxC()
if LASTKEY()<>K_ESC
	oDatabase:saveSezona(oDatabase:cSezona)
        goModul:quit()
endif

return
*}


/*! \fn BrowseSezone
 *  \brief Prikazuje listu sezonskih podrucja (koja imaju sadrzaj)
 *  \return selektovanu sezonu (npr "0502") , ili "" ako nismo nista odabrali
 *
 *  Sezonsko podrucje je puno kada
 *  1. postoji direktorij KumPath + <SezPodr>
 *  2. postoji fajl pos.dbf u sezonskom podrucju i RECCOUNT()>0
 *
 *
 *  \todo Implementirati funkciju !
 */
 
function BrowseSezone()
*{

return "000"
*}

function InfoPodrucja()
*{
Box("#PODACI O TRENUTNOM PODRUCJU PODATAKA",20,77)
	@ m_x+2, m_y+2 SAY "goModul:oDataBase:cSezona      ='"+(goModul:oDataBase:cSezona)+"'"
	@ m_x+3, m_y+2 SAY "goModul:oDataBase:cSezonDir    ='"+(goModul:oDataBase:cSezonDir)+"'"
	@ m_x+4, m_y+2 SAY "goModul:oDataBase:cRadimUSezona='"+(goModul:oDataBase:cRadimUSezona)+"'"
	InkeySC(0)
BoxC()
return nil
*}
