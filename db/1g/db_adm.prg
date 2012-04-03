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
#include "fileio.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 
*static string
static OID_ASK:="0"
*;

*static string
static nSlogova:=0
*;


function CREATE_INDEX(cImeInd, cKljuc, cImeDbf, fSilent)
*{
local bErr
local cFulDbf
local nH
local cImeCDXIz
local cImeCDX
local nOrder
local nPos

private cTag
private cKljuciz

close all
  
cImeDbf:=ToUnix(cImeDbf)
if fSilent==nil
    fSilent:=.f.
endif

if AT(SLASH,cImeDbf)==0  // onda se radi o kumulativnoj datoteci
     cImeCdx :=  alltrim(cDirRad)+SLASH+ImeDBFCDX(cImeDbf)
else
     cImeCdx := ImeDbfCdx(cImeDbf)
endif

  
nPom:=RAT(SLASH,cImeInd)
cTag:=""
cKljucIz:=cKljuc
if nPom<>0
   cTag:=substr(cImeInd,nPom+1)
else
   cTag:=cImeInd
endif

fPostoji:=.t.

#ifndef PROBA
bErr:=ERRORBLOCK({|o| MyErrH(o)})
BEGIN SEQUENCE
#endif
	
	select (F_TMP)
	USEX(cImeDbf)
	
	if USED()
		nPos:=FIELDPOS("BRISANO")
		//nPos == nil ako nije otvoren DBF
		
		if nPos==0
			AddFldBrisano(cImeDbf)
		endif

		nOrder:=ORDNUMBER("BRISAN")
		cOrdKey:=ORDKEY("BRISAN")
		if (nOrder==0)  .or. !(LEFT(cOrdKey,8)=="BRISANO")
			PRIVATE cPomKey:="BRISANO"
			PRIVATE cPomTag:="BRISAN"
			cImeCDX:=STRTRAN(cImeCDX,"."+INDEXEXT,"")
			INDEX ON &cPomKey  TAG (cPomTag) TO (cImeCDX)
		endif

		if (gSQL=="D")
			FillOid(cImeDbf, cImeCDX)
			if (fieldpos("_OID_")<>0)
				//tabela ima _OID_ polje
				nOrder:=ORDNUMBER("_OID_")
				if (nOrder==0)
					cPomKey:="_OID_"
					index on &cPomKey TAG "_OID_"  TO (cImeCDX)
				endif
			endif
		endif
		

		if (gSQL=="D")
			if fieldpos("_SITE_")<>0
				nOrder:=ORDNUMBER("_SITE_")
				cOrdKey:=ORDKEY("_SITE_")
				if norder=0  .or. !(left(cOrdKey,6)="_SITE_")
					index on _SITE_  TAG _SITE_
				endif
			endif
		endif

		nOrder:=ORDNUMBER(cTag)
		cOrdKey:=ordkey(cTag)
		select (F_TMP)
		use
	else
		MsgBeep("Nisam uspio otvoriti "+cImeDbf)
		fPostoji:=.f.
	endif
	
#ifndef PROBA
RECOVER
	fPostoji:=.f.
END SEQUENCE
bErr:=ERRORBLOCK(bErr)
#endif

if !fPostoji
	// nisam uspio otvoriti, znaci ne mogu ni kreirati indexs ..
	return
endif

if !FILE(cImeCdx)  .or. nOrder==0  .or. UPPER(cOrdKey)<>UPPER(cKljuc)


     cFulDbf:=cImeDbf
     if right(cFulDbf,4)<>"."+DBFEXT
       cFulDbf:=trim(cFulDbf)+"."+DBFEXT
       if at(SLASH,cFulDbf)==0  // onda se radi o kumulativnoj datoteci
          cFulDbf:=alltrim(cDirRad)+SLASH+cFulDbf
       endif
     endif
     
     if  !IsFreeForReading(cFulDBF,fSilent)
	 return .f.
     endif
    
#ifdef CLIP
	Usexi(cImeDbf)
#else
	DBUSEAREA (.f., nil, cImeDbf, nil, .t. )
#endif

   if !fSilent
    MsgO("Baza:"+cImeDbf+", Kreiram index-tag :"+cImeInd+"#"+ExFileName(cImeCdx))
   endif
    
    nPom:=RAT(SLASH,cImeInd)
    private cTag:=""
    private cKljuciz:=cKljuc
    if nPom<>0
     cTag:=substr(cImeInd,nPom)
    else
     cTag:=cImeInd
    endif


     if (LEFT(cTag,4)=="ID_J" .and. fieldpos("ID_J")==0) .or. (cTag=="_M1_" .and. FIELDPOS("_M1_")==0)
        // da ne bi ispao ovo stavljam !!
     else
	cImeCdx:=strtran(cImeCdx,"."+INDEXEXT,"")
	INDEX ON &cKljucIz  TAG (cTag)  TO (cImeCdx) 
	USE
     endif

   if !fSilent
    MsgC()
   endif
    use
  endif

return
*}

function IsFreeForReading(cFulDBF, fSilent)
*{
local nH

nH:=FOPEN(cFulDbf,2)  // za citanje i pisanje
if FERROR()<>0
      Beep(2)
      if !fSilent
       Msg("Ne mogu otvoriti "+cFulDBF+" - vjerovatno ga neko koristi#"+;
              "na mrezi. Ponovite operaciju kada ovo rijesite !")
       return .f.
      else
        cls
        ? "Ne mogu otvoriti",cFulDbf
        DO WHILE NEXTKEY()==0; OL_YIELD(); ENDDO
        INKEY()
      endif
      FCLOSE(nH)
      return .t.
endif
FCLOSE(nH)
return .t.
*}

function AddFldBrisano(cImeDbf)
*{
use
save screen to cScr
CLS
       Modstru(cImeDbf,"C H C 1 0  FH  C 1 0",.t.)
       Modstru(cImeDbf,"C SEC C 1 0  FSEC C 1 0",.t.)
       Modstru(cImeDbf,"C VAR C 2 0 FVAR C 2 0",.t.)
       Modstru(cImeDbf,"C VAR C 15 0 FVAR C 15 0",.t.)
       Modstru(cImeDbf,"C  V C 15 0  FV C 15 0",.t.)
       Modstru(cImeDbf,"A BRISANO C 1 0",.t.)  // dodaj polje "BRISANO"
inkey(3)
restore screen from cScr

select (F_TMP)
usex (cImeDbf)
return
*}

function KZNbaza(aPriv,aKum,aSif,cIz,cU, cSamoId)
*{

// cSamoId  "1"- konvertuj samo polja koja pocinju sa id
//          "2"- konvertuj samo polja koja ne pocinju sa id
//          "3" ili nil - konvertuj sva polja
//	    "B" - konvertuj samo IDRADN polja iz LD-a	

 LOCAL i:=0, j:=0, k:=0, aPom:={}, xVar:="", anPolja:={}
 CLOSE ALL
 SET EXCLUSIVE ON
 IF aPriv==nil; aPriv:={}; ENDIF
 IF aKum==nil ; aKum:={} ; ENDIF
 IF aSif==nil ; aSif:={} ; ENDIF
 if cSamoid==nil; cSamoid:="3"; endif
private cPocStanjeSif
private cKrajnjeStanjeSif
 if !gAppSrv
 	Box("xx",1,50,.f.,"Vrsi se konverzija znakova u bazama podataka")
 	@ m_x+1,m_y+1 say "Konvertujem:"
 else
 	? "Vrsi se konverzija znakova u tabelama"
 endif
 FOR j:=1 TO 3
   DO CASE
     CASE j==1
       aPom:=aPriv
     CASE j==2
       aPom:=aKum
     CASE j==3
       aPom:=aSif
   ENDCASE
   FOR i:=1 TO LEN(aPom)
     nDbf:=aPom[i]
     goModul:oDatabase:obaza(nDbf)
     DBSELECTArea (nDbf)
     if !gAppSrv
     	@ m_x+1,m_y+25 SAY SPACE(12)
     	@ m_x+1,m_y+25 SAY ALIAS(nDBF)
     else
        ? "Konvertujem: " + ALIAS(nDBF)
     endif
     if used()
       beep(1)
       ordsetfocus(0)
       GO TOP
       anPolja:={}
       FOR k:=1 TO FCOUNT()
        if (cSamoId=="3") .or. (cSamoId=="1" .and. upper(fieldname(k)) = "ID") .or. (cSamoId=="2"  .and. !(upper(fieldname(k)) = "ID")) .or. (cSamoId=="B" .and. ((UPPER(FieldName(k)) = "IDRADN") .or. ((UPPER(FieldName(k)) = "ID") .and. ALIAS(nDbf)=="RADN")))
         xVar:=FIELDGET(k)
         IF VALTYPE(xVar)$"CM"
           AADD(anPolja,k)
         ENDIF
        endif  // csamoid
       NEXT
       DO WHILE !EOF()
         FOR k:=1 TO LEN(anPolja)
           xVar:=FIELDGET(anPolja[k])
           FIELDPUT(anPolja[k],StrKZN(xVar,cIz,cU))
           // uzmi za radnika ime i prezime
	   if (cSamoId=="B") .and. UPPER(FIELDNAME(1)) = "ID" .and. ALIAS(nDbf)=="RADN"
		//AADD(aSifRev, {FIELDGET(4)+" "+FIELDGET(5), cPocStanjeSif, cKrajnjeStanjeSif})
	   endif
	 NEXT
         SKIP 1
       ENDDO
       use
     endif
   NEXT
 NEXT
 if !gAppSrv
 	BoxC()
 endif
 SET EXCLUSIVE OFF
 if !gAppSrv
 	BrisiPaK()
 else
     ? "Baze konvertovane!!!"
     BrisiPaK()
 endif
return
*}

function MyErrHt(o)
*{
BREAK o
return .t.
*}


function Reindex(ff)
*{

*  REINDEXiranje DBF-ova

local nDbf
local lZakljucana

IF (ff<>nil .and. ff==.t.) .or. if( !gAppSrv,  Pitanje("","Reindeksirati DB (D/N)","N")=="D", .t.)

if !gAppSrv
	Box("xx",1,56,.f.,"Vrsi se reindeksiranje DB-a ")
else
	? "Vrsi se reindex tabela..."
endif

// Provjeri da li je sezona zakljucana
lZakljucana := .f.

if gReadOnly
	lZakljucana := .t.
	// otkljucaj sezonu
	SetWOnly(.t.)
endif
//

close all

// CDX verzija
set exclusive on
for nDbf:=1 to 250
	if !gAppSrv
       		@ m_x+1,m_y+2 SAY SPACE(54)
   	endif
	#ifndef PROBA
		bErr:=ERRORBLOCK({|o| MyErrHt(o)})
		BEGIN SEQUENCE
		// sprijeciti ispadanje kad je neko vec otvorio bazu
		goModul:oDatabase:obaza(nDbf)
		RECOVER
		Beep(2)
		if !gAppSrv
			@ m_x+1,m_y+2 SAY "Ne mogu administrirati "+DbfName(nDbf)+" / "+alltrim(str(nDbf))
		else
			? "Ne mogu administrirati: " + DBFName(nDbf) + " / " + ALLTRIM(STR(nDBF))
		endif

		if !EMPTY(DBFName(nDbf))
			// ovaj modul "zna" za ovu tabelu, ali postoji problem
			inkey(3)
		endif
		END SEQUENCE
		bErr:=ERRORBLOCK(bErr)
	#else
		goModul:oDatabase:obaza(nDbf)
		if !gAppSrv
			@ m_x+1,m_y+2  SAY SPACE(40)
		endif
	#endif

	DBSELECTArea (nDbf)
	if !gAppSrv
		@ m_x+1,m_y+2 SAY "Reindeksiram: " + ALIAS(nDBF)
	else
		? "Reindexiram: " + ALIAS(nDBF)
	endif

	if used()
		beep(1)
		ordsetfocus(0)
		nSlogova:=0
		REINDEX
		//EVAL { || Every() } EVERY 150
		use
	endif

   next
   set exclusive off
   if !gAppSrv
   	BoxC()
   endif	
endif

if lZakljucana == .t.
	SetROnly(.t.)
endif

closeret
return nil
*}


function Pakuj(ff)
*{
local nDbfff,cDN

IF (ff<>nil .and. ff==.t.) .or. (cDN:=Pitanje("pp","Prepakovati bazu (D/N/L)","N")) $ "DL"


 Box("xx",1,50,.f.,"Fizicko brisanje zapisa iz baze koji su markirani za brisanje")
   @ m_x+1,m_y+1 say "Pakuje se DB:"


close all

set exclusive on
for nDbfff:=1 to 250
   goModul:oDatabase:obaza(nDbfff)
   if used()
    @ m_x+1,m_y+30 SAY SPACE(12)
    @ m_x+1,m_y+30 SAY ALIAS()
    set deleted off
    nOrder:=ORDNUMBER("BRISAN")
    
    // bezuslovno trazi deleted()
    if cDN=="L"  
     locate for deleted()
    else
     if norder<>0
      set order to TAG "BRISAN"
      
      // nadji izbrisan zapis
      seek "1"   
     endif
    endif
    if nOrder=0 .or. found()   //.or. (alias() $ "GPARAMS")
      BEEP(1)
      ordsetfocus(0)
      @ m_x+1,m_y+36 SAY reccount() pict "999999"
      __DBPACK()
      @ m_x+1,m_y+42 SAY "+"
      @ m_x+1,m_y+44 SAY reccount() pict "99999"
      set deleted on
    else
      @ m_x+1,m_y+36 SAY space(4)
      @ m_x+1,m_y+42 SAY "-"
      @ m_x+1,m_y+44 SAY space(4)
    endif
    inkey(0.4)


    set deleted on
    use
   endif //used
next
BoxC()

endif

closeret
return
*}


function BrisiPAk(fSilent)
*{
if fSilent==nil
  fSilent:=.f.
endif

#ifdef proba
if !gAppSrv
  Msgbeep("Brisipak procedura...")
endif
#endif

if fSilent .or. if(!gAppSrv, Pitanje(,"Izbrisati "+INDEXEXT+" fajlove pa ih nanovo kreirati","N")=="D", .t.)
   close all
   cMask:="*."+INDEXEXT
   if !gAppSrv
   	cScr:=""
   	save screen to cScr
   	cls
	if fSilent .or. pitanje(,"Indeksi iz privatnog direktorija ?","D")=="D"
     		DelSve(cMask,trim(cDirPriv))
     		inkey(1)
   	endif
   	if fSilent .or.  pitanje(,"Indeksi iz direktorija kumulativa ?","N")=="D"
     		DelSve(cMask,trim(cDirRad))
     		inkey(1)
   	endif
   	if fSilent .or.  pitanje(,"Indeksi iz direktorija sifrarnika ?","N")=="D"
    		DelSve(cMask,trim(cDirSif))
     		inkey(1)
   	endif
   	if fSilent .or.  pitanje(,"Indeksi iz tekuceg direktorija?","N")=="D"
     		DelSve(cMask,".")
     		inkey(1)
   	endif
   	if fSilent .or. pitanje(,"Indeksi iz korjenog direktorija?","N")=="D"
     		DelSve(cMask,SLASH)
     		inkey(1)
   	endif
   else
   	? "Brisem sve indexe..."
	? "Radni dir: " + TRIM(cDirRad)
	DelSve(cMask, TRIM(cDirRad))
	DelSve(cMask, TRIM(cDirSif))
	DelSve(cMask, TRIM(cDirPriv))
   endif	
   if !gAppSrv
   	restore screen from cScr
   endif
   CreParams()
   close all
   if gAppSrv
   	? "Kreiram sve indexe ...."
	? "Radni dir: " + cDirRad
   endif
   goModul:oDatabase:kreiraj()
   if gAppSrv
   	? "Kreirao index-e...."
   endif
endif

return
*}


/*! \fn AppModS(cCHSName)
 *  \brief Modifikacija struktura APPSRV rezim rada
 *  \param cCHSName - ime chs fajla (npr. FIN)
 */
function AppModS(cCHSName)
*{
local cCHSFile:=""

if !gAppSrv
	return
endif

// ako nije zadan parametar uzmi osnovnu modifikaciju
if cCHSName==NIL .or. EMPTY(cChsName)
	cCHSFile:=(EXEPATH + gModul + ".CHS")
else
	cCHSFile:=(EXEPATH + cCHSName + ".CHS")
endif

? "Modifikacija struktura " + cCHSFile
? "Pricekajte koji trenutak ..."

cEXT:=SLASH+"*."+INDEXEXT

? "Modifikacija u privatnom direktoriju ..."
Modstru(TRIM(cCHSFile),trim(goModul:oDataBase:cDirPriv))

? "Modifikacija u direktoriju sifrarnika ..."
Modstru(TRIM(cCHSFile),trim(goModul:oDataBase:cDirSif))

? "Modifikacija u direktoriju kumulativa ..."
Modstru(TRIM(cCHSFile),trim(goModul:oDataBase:cDirKum))


// kreiraj, reindex
close all
goModul:oDatabase:kreiraj()
Reindex(.t.)

return
*}



/*! \fn RunModS(fDa)
 *  \param fDa - True -> Batch obrada (neinteraktivno)
 */

function RunModS(fDa)
*{

if fda==nil
	fda:=.f.
endif

cImeCHS:=EXEPATH+gModul+".CHS"

if fda .or. PitMstru(@cImeCHS)
	cScr:=""
       	save screen to cScr
       	cEXT:=SLASH+"*."+INDEXEXT
       	cls
       	if fda .or. Pitanje(,"Modifikacija u Priv dir ?","D")=="D"
        	close all
         	Modstru(TRIM(cImeCHS),trim(goModul:oDataBase:cDirPriv))
       	endif

       	if fda .or. Pitanje(,"Modifikacija u SIF dir ?","N")=="D"
        	close all
        	Modstru(TRIM(cImeCHS),trim(goModul:oDataBase:cDirSif))
       	endif

       	if fda .or. Pitanje(,"Modifikacija u KUM dir ?","N")=="D"
        	close all
         	Modstru(TRIM(cImeCHS),trim(goModul:oDataBase:cDirKum))
       	endif

       	if fda .or. Pitanje(,"Modifikacija u tekucem dir ?","N")=="D"
        	close all
         	Modstru(TRIM(cImeCHS),".")
       	endif

       	Beep(1)
       	restore screen from cScr
       	close all
       	goModul:oDatabase:kreiraj()
       	Reindex(.t.)
endif

return
*}

static function PitMstru(cImeChs)
*{
local cDN:="N"

cImeChs:=padr(cImeChs,200)

Box(,3,50)
  @ m_x+1,m_y+2 SAY "Izvrsiti modifikaciju struktura D/N" GET cDN pict "@!" valid cdn $ "DN"
  read
  if cDN=="D"
    @ m_x+3,m_y+2 SAY "CHS Skript:" GET cImeCHS PICT "@S30"
    read
    cImeCHS:=trim(cImeChs)
  endif
BoxC()
if cdn=="D"
  return .t.
else
  return .f.
endif
*}


/*! \fn ModStru(cImeF, cPath, fString)
 *  \brief procedura modifikacija struktura
 */
function ModStru
*{
parameters cImeF,cPath, fString


? SPACE(40),"SIGMA-COM, 10.99, ver 02.33 CDX"
? SPACE(40),"-------------------------------"
?
set deleted on  // ne kopiraj izbrisane zapise !!!
close all

cmxAutoOpen(.f.)  // ne otvaraj CDX-ove

if pcount()==0
	?
  	? "Sintaksa:   MODSTRU  <ImeKomandnog_fajla>  <direktorij_sa_DBF_fajlovima>"
  	? "     npr:   MODSTRU  ver0155.chs    C:\EM\FIN\1"
  	?
  	quit
endif

if fstring=nil
	fString=.f.
endif

if cPath==nil
	cPath:=""
endif

if !fString
	if RIGHT(cPath,1)<>SLASH
   		cPath:=cPath+SLASH
 	endif
 	nH:=FOPEN(ToUnix(cImeF))
 	if nH==-1
   		nH:=FOPEN(".."+SLASH+cImeF)
 	endif
else
	if right(cImeF,4)<>"."+DBFEXT
     		cImeF:=cImeF+"."+DBFEXT
  	endif
  	cKomanda:=cPath
  	cPath:=""
endif

nLinija:=0
cDBF:=""

private fBrisiDBF:=.f.
private fRenameDBF:=.f.

fprom:=.f.
nProlaza:=0

do while fString .or. !FEOF(nH)
	++nLinija
	if fString
    	if nProlaza=0
       		cLin:="*"+cImeF
       		nProlaza++
    	elseif nprolaza=1
       		cLin:=cKomanda
       		nProlaza++
    	else
       		exit
    	endif
else
	cLin:=FReadLN(nH,1,200)
    	cLin:=left(cLin,len(cLin)-2)
endif

if empty(cLin) .or.  left(cLin,1)==";"
	loop
endif

if left(cLin,1)="*"
	kopi(fProm)
     	cLin:=substr(cLin,2,len(trim(clin))-1)
     	cDbf:=alltrim(cLin)
     	? cPath+cDbf
	cDbf:=UPPER(cDbf+iif(at(".",cDbf)<>0,"",".DBF"))
     	if file(cPath+cDbf)
       		select 1
       		usex (cPath+cDbf) alias olddbf
     	else
       		cDbf:="*"
       		?? "  Ne nalazi se u direktorijumu"
     	endif
     	fProm:=.f.   // flag za postojanje promjena u strukturi dbf-a
	aStru:=DBSTRUCT()
     	aNStru:=aclone(aStru)      // nova struktura
else  // funkcije za promjenu polja
	if empty(cDBF)
        	? "Nije zadat DBF fajl nad kojim se vrsi modifikacija strukture !"
        	quit
     	elseif cDbf=="*"
        	loop // preskoci
     	endif

     	cOp:=Rjec(@cLin)
	
	if alltrim(cOp)=="IZBRISIDBF"
        	fBrisiDbf:=.t.
	elseif alltrim(cOp)=="IMEDBF"
        	fRenameDBF:=.t.
		cImeP:=Rjec(@cLin)
	elseif alltrim(cOp)=="A"
        	cImeP:=Rjec(@cLin)
         	cTip:=Rjec(@cLin)
         	cLen:=Rjec(@cLin); nLen:=VAL(cLen)
         	cDec:=Rjec(@cLin); nDec:=VAL(cDec)
         	if !(nLen>0 .and. nLen>nDec) .or. (cTip="C" .and. nDec>0) .or. !(cTip $ "CNDM")
            		? "Greska: Dodavanje polja, linija:",nLinija
            		loop
         	endif
         	nPos=ascan(aStru,{|x| x[1]==cImep})
         	if npos<>0
            		? "Greska: Polje "+cImeP+" vec postoji u DBF-u, linija:",nlinija
            		loop
         	endif
         	? "Dodajem polje:",cImeP,cTip,nLen,nDec
         	AADD(aNStru,{cImeP,cTip,nLen,nDec})
         	fProm:=.t.

     	elseif alltrim(cOp)=="D"
        	cImeP:=upper(Rjec(@cLin))
         	nPos:=ASCAN(aNStru,{|x| x[1]==cImeP})
         	if nPos<>0
            		? "Brisem polje:",cImeP
            		ADEL(aNStru,nPos)
            		Prepakuj(@aNstru)  // prepakuj array
            		fProm:=.t.
         	else
            		? "Greska: Brisanje nepostojeceg polja, linija:",nLinija
         	endif

     	elseif alltrim(cOp)=="C"
        	cImeP1:=upper(Rjec(@cLin))
         	cTip1:=Rjec(@cLin)
         	cLen:=Rjec(@cLin); nLen1:=VAL(cLen)
         	cDec:=Rjec(@cLin); nDec1:=VAL(cDec)
         	nPos:=ASCAN(aStru,{|x| x[1]==cImeP1 .and. x[2]==cTip1 .and. x[3]==nLen1 .and. x[4]==nDec1})
         	if nPos==0
            		? "Greska: zadana je promjena nepostojeceg polja, linija:",nLinija
            		loop
         	endif
         	cImeP2:=upper(Rjec(@cLin))
         	cTip2:=Rjec(@cLin)
         	cLen:=Rjec(@cLin); nLen2:=VAL(cLen)
         	cDec:=Rjec(@cLin); nDec2:=VAL(cDec)

         	nPos2:=ASCAN(aStru,{|x| x[1]==cImep2})
         	if nPos2<>0 .and. cImeP1<>cImeP2
            		? "Greska: zadana je promjena u postojece polje, linija:",nLinija
            		loop
         	endif
         	fIspr:=.f.
         	if cTip1==cTip2
			fispr:=.t.
		endif
         	if (cTip1=="N" .and. cTip2=="C")   ;  fispr:=.t.; endif
         	if (cTip1=="C" .and. cTip2=="N")   ;  fispr:=.t.; endif
         	if (cTip1=="C" .and. cTip2=="D")   ;  fispr:=.t.; endif
         	if !fispr; ? "Greska: Neispravna konverzija, linija:",nLinija; loop; endif

		AADD(aStru[nPos],cImeP2)
         	AADD(aStru[nPos],cTip2)
         	AADD(aStru[nPos],nLen2)
         	AADD(aStru[nPos],nDec2)

         	nPos:=ASCAN(aNStru,{|x| x[1]==cImeP1 .and. x[2]==cTip1 .and. x[3]==nLen1 .and. x[4]==nDec1})
         	aNStru[nPos]:={ cImeP2, cTip2, nLen2, nDec2}

         	? "Vrsim promjenu:",cImep1,cTip1,nLen1,nDec1," -> ",cImep2,cTip2,nLen2,nDec2
         	// npr {"POLJE1", "C", 10, 0} =>
         	//     {"POLJE1", "C", 10, 0,"POLJE1NEW", "C", "15", 0}

         	fProm:=.t.
	else
        	? "Greska: Nepostojeca operacija, linija:",nLinija
     	endif
endif // fje za promjenu polja

enddo
kopi(fProm)

cmxAutoOpen(.t.)
return
*}

function Rjec(cLin)
*{
local cOp,nPos

nPos:=aT(" ",cLin)
if nPos==0 .and. !empty(cLin) // zadnje polje
	cOp:=alltrim(clin)
	cLin:=""
	return cOp
endif

cOp:=alltrim(left(cLin,nPos-1))
cLin:=right(cLin,len(cLin)-nPos)
cLin:=alltrim(cLin)
return cOp
*}


function Prepakuj(aNStru)
*{
local i,aPom
aPom:={}
for i:=1 to len(aNStru)
  if aNStru[i]<>nil
   aadd(aPom,aNStru[i])
  endif
next
aNStru:=aClone(aPom)
return nil
*}

/***
*  FGets( <nHandle>, [<nLines>], [<nLineLength>], [<cDelim>] ) --> cBuffer
*  Read one or more lines from a text file
*
*/

function FGets(nHandle, nLines, nLineLength, cDelim)
*{
return FReadLn(nHandle, nLines, nLineLength, cDelim)
*}


/*! \fn FileTop(nHandle) 
 *  \brief Position the file pointer to the first byte in a binary file and return the new file position (i.e., 0).
 *  \return nPos
 *
 */

function FileTop(nHandle)
*{      
return FSEEK(nHandle, 0)
*}

/*! \fn FileBottom(nHandle) 
 * \brief Position the file pointer to the last byte in a binary file and return the new file position
 * \param nHandle - handle fajla
 * \return nPos - lokacija 
 */

function FileBottom(nHandle)
*{      
return FSEEK(nHandle, 0, FS_END)
*}



function SetgaSDBFs
*{
PUBLIC gaSDBFs:={ ;
 {F_GPARAMS  , "GPARAMS",  P_ROOTPATH },; 
 {F_GPARAMSP , "GPARAMS",  P_PRIVPATH},;
 {F_PARAMS   , "PARAMS"  , P_PRIVPATH},;
 {F_KORISN   , "KORISN"  , P_TEKPATH },;
 {F_MPARAMS  , "MPARAMS" , P_TEKPATH },;
 {F_KPARAMS  , "KPARAMS" , P_KUMPATH },;
 {F_SECUR    , "SECUR"   , P_KUMPATH },;
 {F_ADRES    , "ADRES"   , P_SIFPATH },;
 {F_SIFK     , "SIFK"    , P_SIFPATH },;
 {F_SIFV     , "SIFV"    , P_SIFPATH  },;
 {F_TMP      , "TMP"     , P_PRIVPATH},;
 {F_SQLPAR   , "SQLPAR"  , P_KUMSQLPATH};
}
return
*}



function FillOid(cImeDbf, cImeCDX)
*{
private cPomKey

if FIELDPOS("_OID_")==0
  return 0
endif


cImeCDX:=STRTRAN(cImeCDX,"."+INDEXEXT,"")

nOrder:=ORDNUMBER("_OID_")
cOrdKey:=ORDKEY("_OID_")
if !( nOrder==0  .or. !(LEFT(cOrdKey,5)="_OID_") )
  return
endif

if (field->_OID_==0 .and. RecCount2()<>0)
    
   Msgbeep("OID "+ALIAS()+" nepopunjen ")

   if OID_ASK=="0"
            // OID nije inicijaliziran
            if SigmaSif("OIDFILL")
               OID_ASK:="D"
            endif
   endif

   if  (OID_ASK=="D") .and. Pitanje(,"Popuniti OID u tabeli "+ALIAS()+" ?"," ")=="D"
         MsgO("Popunjavam OID , tabela "+ALIAS())
	 cPomKey:="_OID_"
	 index on &cPomKey TAG "_OID_"  TO (cImeCDX) 
         go top
         if field->_OID_=0
           set order to 0
           go top
           do while !eof()
             replace _OID_ with New_Oid()
             skip
           enddo
         endif
         MsgC()
   endif
endif

return
*}

/*! \fn ImdDBFCDX(cIme)
 *  \brief Mjenja DBF u indeksnu extenziju
 *
 * \code 
 *  suban     -> suban.CDX
 *  suban.DBF -> suban.CDX
 * \endcode
 */
 
function ImeDBFCDX(cIme)
*{
cIme:=trim(strtran(ToUnix(cIme),"."+DBFEXT,"."+INDEXEXT))
if right(cIme,4)<>"."+INDEXEXT
	cIme:=cIme+"."+INDEXEXT
endif
return  cIme
*}

static function Every()
*{
//nSlogova=nSlogova+1
//@ 24, 10 SAY "Slogova: "+STR(nSlogova*100)
//OL_Yield()
//return
*}

