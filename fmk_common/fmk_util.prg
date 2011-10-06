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

 
/*! \fn UBrojDok(nBroj,nNumDio,cOstatak)
 * \brief Pretvara Broj podbroj u string format "Broj dokumenta"
 * \code
 * UBrojDok ( 123,  5, "/99" )   =>   00123/99
 * \encode
 */
 
function UBrojDok(nBroj,nNumdio,cOstatak)

return padl( alltrim(str(nBroj)), nNumDio, "0")+cOstatak


/*! \fn Calc()
 *  \brief Kalkulator
 */
function Calc()

local GetList:={}
private cIzraz:=SPACE(40)

bKeyOld1:=SETKEY(K_ALT_K,{|| Konv()})
bKeyOld2:=SETKEY(K_ALT_V,{|| DefKonv()})

Box(,3,60)
	
	set cursor on
	
	do while .t.
  		
		@ m_x,m_y+42 SAY "<a-K> kursiranje"
  		@ m_x+4,m_y+30 SAY "<a-V> programiranje kursiranja"
  		@ m_x+1,m_y+2 SAY "KALKULATOR: unesite izraz, npr: '(1+33)*1.2' :"
  		@ m_x+2,m_y+2 GET cIzraz
  		
		read
  		
		// ako je ukucan "," zamjeni sa tackom "."
		cIzraz:=STRTRAN(cIzraz, ",",".")
		
		@ m_x+3,m_y+2 SAY space(20)
  		if type(cIzraz)<>"N"
    			
			if upper(left(cIzraz,1))<>"K"
     				@ m_x+3,m_y+2 SAY "ERR"
    			else
     				@ m_x+3,m_y+2 SAY kbroj(substr(cizraz,2))
    			endif
			
    			//cIzraz:=space(40)
  		else
    			@ m_x+3,m_y+2 SAY &cIzraz pict "99999999.9999"
    			cIzraz:=padr(alltrim(str(&cizraz,18,5)),40)
  		endif

  		if lastkey()==27
			exit
		endif
  		
		INKEY()
  		
	enddo
BoxC()

if type(cIzraz)<>"N"
	if upper(left(cIzraz,1))<>"K"
    		SETKEY(K_ALT_K,bKeyOld1); SETKEY(K_ALT_V,bKeyOld2)
    		return 0
  	else
    		private cVar:=readvar()
    		INKEY()
    		// inkey(0)
    		if type(cVar) == "C" .or. (type("fUmemu")=="L" .and. fUMemu)
      			Keyboard KBroj(substr(cIzraz,2))
    		endif
    		SETKEY(K_ALT_K,bKeyOld1)
		SETKEY(K_ALT_V,bKeyOld2)
    		return 0
  	endif
else
	private cVar:=ReadVar()
  	if type(cVar)=="N"
     		&cVar:=&cIzraz
  	endif
  	SETKEY(K_ALT_K,bKeyOld1)
	SETKEY(K_ALT_V,bKeyOld2)
  	return &cizraz
endif

return



// -----------------------------------
// auto valute convert
// -----------------------------------
function a_val_convert( )
private cVar := ReadVar()
private nIzraz := &cVar
private cIzraz

// samo ako je varijabla numericka....
if type( cVar ) == "N"
	
	//cIzraz := ALLTRIM( STR( nIzraz ) )
	
	nIzraz := ROUND(nIzraz * omjerval( ValDomaca(), ValPomocna(), DATE() ), 5)
	// konvertuj ali bez ENTER-a
	//konv( .f. )
	
	//nIzraz := VAL( cIzraz )
	
	&cVar := nIzraz
	
endif
   	
return


// ----------------------------------------
// ----------------------------------------
function kbroj(cSifra)

local i,cPom,nPom,nKontrola, nPom3

cSifra:=alltrim(cSifra)
cSifra:=strtran(cSifra,"/","-")
cPom:=""
for i:=1 to len(cSifra)
  if !isdigit(substr(cSifra,i,1))
      ++i
      do while .t.
       if val(substr(cSifra,i,1))=0 .and. i<len(cSifra)
         i++
       else
         cPom+=substr(cSifra,i,1)
         exit // izadji iz izbijanja
       endif
      enddo
  else
    cPom+=substr(cSifra,i,1)
  endif
next
nPom:=val(cPom)
nP3:=0
nKontrola:=0
for i:=1 to 9
   nPom3:= nPom % 10 // cifra pod rbr i
   nPom:=int(nPom/10)
   nKontrola+= nPom3* (i+1)
next
nKontrola:=nKontrola%11
nKontrola:=11-nKontrola
if round(nkontrola,2)>=10
   nKontrola:=0
endif
return cSifra+alltrim(str(nKontrola,0))



function round2(nizraz,niznos)

*
* pretpostavlja definisanu globalnu varijablu g50F
* za g50F="5" vr�i se zaokru�enje na 0.5
*        =" " odra�uje obi�ni round()

local npom,npom2,nznak
if g50f="5"

   npom:=abs(nizraz-int(nizraz))
   nznak=nizraz-int(nizraz)
   if nznak>0
     nznak:=1
   else
     nznak:=-1
   endif
   npom2:=int(nizraz)
   if npom<=0.25
     nizraz:=npom2
   elseif npom>0.25 .and. npom<=0.75
     nizraz:=npom2+0.5*nznak
   else
     nIzraz:=npom2+1*nznak
   endif
   return nizraz
else
   return round(nizraz,niznos)
endif
return



// --------------------------------------
// kovertuj valutu
// --------------------------------------
static function Konv( lEnter )
local nDuz:=LEN(cIzraz)
local lOtv:=.t.
local nK1:=0
local nK2:=0

if lEnter == nil
 	lEnter := .t.
endif
  
IF !FILE(ToUnix(SIFPATH+"VALUTE.DBF"))
	RETURN
ENDIF

PushWA()

SELECT VALUTE
PushWA()
SET ORDER TO TAG "ID"

go top
dbseek( gValIz , .f. )
nK1:=VALUTE->&("kurs"+gKurs)
go top
dbseek( gValU  , .f. )
nK2:=VALUTE->&("kurs"+gKurs)

IF nK1==0 .or. type(cIzraz)<>"N"
    IF !lOtv
      USE
    ELSE
      PopWA()
    ENDIF
    PopWA()
    RETURN
  ENDIF
  cIzraz:=&(cIzraz) * nK2 / nK1
  cIzraz:=PADR(cIzraz,nDuz)
  IF !lOtv
    USE
  ELSE
    PopWA()
  ENDIF
  PopWA()
  if lEnter == .t.
  	KEYBOARD CHR(K_ENTER)
  endif
RETURN



static function DefKonv()

 LOCAL GetList:={}, bKeyOld:=SETKEY(K_ALT_V,NIL)
 PushWA()
 select 99
 if used()
   fUsed:=.t.
 else
   fUsed:=.f.
   O_PARAMS
 endif

 private cSection:="1",cHistory:=" "; aHistory:={}
 RPAR("vi",@gValIz)
 RPAR("vu",@gValU)
 RPAR("vk",@gKurs)

 Box(,5,65)
   set cursor on
   @ m_x,m_y+19 SAY "PROGRAMIRANJE KURSIRANJA"
   @ m_x+2,m_y+2 SAY "Oznaka valute iz koje se vrsi konverzija:" GET gValIz
   @ m_x+3,m_y+2 SAY "Oznaka valute u koju se vrsi konverzija :" GET gValU
   @ m_x+4,m_y+2 SAY "Kurs po kome se vrsi konverzija (1/2/3) :" GET gKurs VALID gKurs$"123" PICT "9"
   read
   IF LASTKEY()<>K_ESC
     WPAR("vi",gValIz)
     WPAR("vu",gValU)
     WPAR("vk",gKurs)
   ENDIF
 BoxC()

 select params
 if !fUsed
   select params; use
 endif
 PopWA()
 SETKEY(K_ALT_V,bKeyOld)
RETURN



function Adresar()

PushWa()
select (F_ADRES)
if !used()
	O_ADRES
endif
SELECT(F_SIFK)
if !USED()
	O_SIFK
endif

SELECT(F_SIFV)
if !USED()
	O_SIFV
endif
 
P_Adres()
USE

PopWa()
return nil


// --------------------------------
// --------------------------------
function P_Adres(cId,dx,dy)

local fkontakt:=.f.

private ImeKol:={}
private Kol:={}

if fieldpos("Kontakt")<>0
  fKontakt:=.t.
endif

AADD(ImeKol, { "Naziv firme", {|| id     } , "id" } )
AADD(ImeKol, { "Telefon "  , {|| naz } , "naz" } )
AADD(ImeKol, { "Telefon 2"  , {|| tel2} , "tel2" })
AADD(ImeKol, { "FAX      "  , {|| tel3} , "tel3" })
if fkontakt
  AADD(ImeKol, { "RJ "  , {|| rj  } , "rj" } )
endif
AADD(ImeKol, { "Adresa"     , {|| adresa  } , "adresa"   } )
AADD(ImeKol, { "Mjesto"     , {|| mjesto  } , "mjesto"   } )
if fkontakt
  AADD(ImeKol, { "PTT", {|| PTT } , "PTT"  } )
  AADD(ImeKol, { "Drzava", {|| drzava     } , "drzava"  } )
endif
AADD(ImeKol, { "Dev.ziro-r.", {|| ziror   } , "ziror"   } )
AADD(ImeKol, { "Din.ziro-r.", {|| zirod  } ,  "zirod"   } )

if fkontakt
  AADD(ImeKol, { "Kontakt", {|| kontakt     } , "kontakt"  } )
  AADD(ImeKol, { "K7", {|| k7 } , "k7"  } )
  AADD(ImeKol, { "K8", {|| k8 } , "k8"  } )
  AADD(ImeKol, { "K9", {|| k9 } , "k9"  } )
endif

FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT


PushWa()


select sifk
set order to tag "ID"
seek "ADRES   "

do while !eof() .and. ID="ADRES   "

 AADD (ImeKol, {  IzSifKNaz("ADRES   ",SIFK->Oznaka) })
 // AADD (ImeKol[Len(ImeKol)], &( "{|| padr(ToStr(IzSifk('ADRES   ','" + sifk->oznaka + "')),10) }" ) )
 AADD (ImeKol[Len(ImeKol)], &( "{|| ToStr(IzSifk('ADRES   ','" + sifk->oznaka + "')) }" ) )
 AADD (ImeKol[Len(ImeKol)], "SIFK->"+SIFK->Oznaka )
 if sifk->edkolona > 0
   for ii:=4 to 9
    AADD( ImeKol[Len(ImeKol)], NIL  )
   next
   AADD( ImeKol[Len(ImeKol)], sifk->edkolona  )
 else
   for ii:=4 to 10
    AADD( ImeKol[Len(ImeKol)], NIL  )
   next
 endif

 // postavi picture za brojeve
 if sifk->Tip="N"
   if decimal > 0
     ImeKol [Len(ImeKol),7] := replicate("9", sifk->duzina-sifk->decimal-1 )+"."+replicate("9",sifk->decimal)
   else
     ImeKol [Len(ImeKol),7] := replicate("9", sifk->duzina )
   endif
 endif

 AADD  (Kol, iif( sifk->UBrowsu='1',++i, 0) )

 skip
enddo
PopWa()

return PostojiSifra(F_ADRES,1,15,77,"Adresar:",@cId,dx,dy, {|Ch| AdresBlok(Ch)} )


// ----------------------------------------------------
// ----------------------------------------------------
function Pkoverte()

if Pitanje(,"Stampati koverte ?","N")=="N"
   return DE_CONT
endif

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
DBCREATE2(PRIVPATH+"koverte.DBF",aDBf)

usex (PRIVPATH+"koverte") new
zap
index on  "id+naz"  TAG "ID"

SELECT adres
GO TOP
MsgO("Priprema koverte.dbf")

cIniName:=EXEPATH+'ProIzvj.ini'


cWinKonv:=IzFmkIni("DelphiRb","Konverzija","3")
DO WHILE !EOF()
  Scatter()
  SELECT koverte
  APPEND BLANK
  KonvZnWin(@_Id,cWinKonv)
  KonvZnWin(@_Adresa,cWinKonv)
  KonvZnWin(@_Naz,cWinKonv)
  KonvZnWin(@_RJ,cWinKonv)
  KonvZnWin(@_KONTAKT,cWinKonv)
  KonvZnWin(@_Mjesto,cWinKonv)
  Gather()
  select adres
  skip
ENDDO

MsgC()

select koverte
use

if pitanje(,"Aktivirati Win Report ?","D")=="D"
 #ifdef PROBA
  private cKomLin:="c:\sigma\DelphiRB "+IzFmkIni("Adres","AdresRTM","adres", SIFPATH)+" "+PRIVPATH+"  koverte id"
 #else
  private cKomLin:="DelphiRB "+IzFmkIni("Adres","AdresRTM","adres", SIFPATH)+" "+PRIVPATH+"  koverte id"
 #endif
 run &cKomLin
endif

return DE_CONT


function AdresBlok(Ch)

if Ch==K_F8  // koverte
 PKoverte()
endif

RETURN DE_CONT



/****f FMK_UT/DiskSezona ***

*AUTOR
 Ernad Husremovic ernad@sigma-com.net

*IME
 DiskSezona

*SYNOPSIS
 DiskSezona()

*OPIS
  pregled slobodnog mjesta na disku i
  eventualno brisanje sezone

*PRIMJER
  Funkcija se poziva iz menija 
  
****/

PROCEDURE DiskSezona ()

LOCAL nSlobodno, pDirPriv, pDirRad, pDirSif, cSezBris

cSezBris:= SPACE (4)
nSlobodno := DISKSPACE () / (1024*1024)

* nSlobodno se daje u MB
MsgBeep ("Postoji jos "+STR (nSlobodno, 10, 2)+;
         " MB slobodnog prostora na disku!"+;
         IIF (nSlobodno<20, "#Preporucuje se brisanje najstarije sezone#"+;
                            "kako bi se oslobodio prostor i ubrzao rad!";
                          , ""))
IF Pitanje ("bss","Zelite li izbrisati staru sezonu?","N")=="D"
  Box(,2,60)
  @ m_x+1,m_y+1 SAY "Sezona koju zelite obrisati" GET cSezBris ;
                    Valid NijeRTS (cSezBris)
  READ
  BoxC()
  IF LastKey() == K_ESC
    RETURN
  EndIF
  pDirPriv := cDirPriv
  pDirRad  := cDirRad
  pDirSif  := cDirSif
  IF Empty (gSezonDir)
    pDirPriv := pDirPriv+"\"+AllTrim (cSezBris)
    pDirRad  := pDirRad+"\"+AllTrim (cSezBris)
    pDirSif  := pDirSif+"\"+AllTrim (cSezBris)
  Else
    pDirPriv := strtran (pDirPriv, gSezonDir, "\"+AllTrim (cSezBris))
    pDirRad  := strtran (pDirRad, gSezonDir, "\"+AllTrim (cSezBris))
    pDirSif  := strtran (pDirSif, gSezonDir, "\"+AllTrim (cSezBris))
  EndIF
  BrisiIzDir (pDirPriv)
  BrisiIzDir (pDirRad)
  BrisiIzDir (pDirSif)
  *
  * vidjeti za removing directories
  *
EndIF
RETURN

FUNCTION NijeRTS (cSez)

  IF gSezona==cSez
    MsgBeep ("Ne mozete obrisati tekucu sezonu!!!")
    RETURN .F.
  EndIF
  IF gRadnoPodr==cSez
    MsgBeep ("Ne mozete obrisati sezonu u kojoj radite!!!")
    RETURN .F.
  EndIF
RETURN .T.


function BrisiIzDir (cDir)

LOCAL aFiles, nCnt, nRes
  Beep (4)
  Box (,1,60)
  @ m_x,m_y+1 SAY "Direktorij "+AllTrim (cDir) COLOR Invert
  aFiles := Directory (cDir+SLASH+"*.*")
  For nCnt := 1 To LEN (aFiles)
    nRes := Ferase (cDir+SLASH+aFiles [nCnt][F_NAME])
    IF nRes==0
      @ m_x+1,m_y+1 SAY PADC ("Obrisana datoteka "+aFiles [nCnt][F_NAME], 60)
    Else
      @ m_x+1,m_y+1 SAY PADC ("NIJE OBRISANA "+aFiles [nCnt][F_NAME], 60)
    EndIF
  Next
  BoxC()

return

