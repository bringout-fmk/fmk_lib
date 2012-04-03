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


#include "SC.CH"

/*! \fn ArhSigma()
 *  \brief Arhiviranje podataka 
 */
function ArhSigma()
*{
local cPomD
local cDbfKontr
local cPomd2

if empty(gArhDir)
  return
  // ne koristim arhiviranje
endif


gArhdir:=trim(gArhDir)

cDbfKontr:=ToUnix(gArhDir+SLASH+OtkUredj(cDirRad)+"\_podar_.dbf")
cPomD:=ToUnix(gArhDir+SLASH+OtkUredj(cDirRad))

if !file(cDbfKontr)
    if !file(cPomD)
       if !DIRMAK2(cPomD)
          Beep(2); Msg("ne mogu kreirati dir "+cPomD)
          return
       endif
    endif
    adbf:={}
    AADD(aDbf,{ "DATUM", "D",  8, 0 })
    AADD(aDbf,{ "OPIS" , "C", 20, 0 })
    AADD(aDbf,{ "Tip"  , "C",  1, 0 })
    DBCREATE2(cDbfKontr,aDbf,RDDENGINE)
    select 120
    use (cDbfKontr) via RDDENGINE
    
    append blank
    return
endif


select 120
use (cDbfKontr) via RDDENGINE
go top  
dDatArh:=datum
use

if date()-dDatArh  > 3  // svaka tri dana

#ifndef CLIP
   if !greadonly .and. pitanje(,"Izvrsiti formiranje pomocne arhive podataka ?","D")=="D"
       cScr:=""
       save screen to cScr
       cls
       ZaSvakiSlucaj(gArhDir+SLASH+OtkUredj(cDirRad)+SLASH,.f.) // u arhdir - nemoj CDX uzeti
       restore screen from cScr

       select 120
       usex (cDbfKontr) via RDDENGINE
       replace datum with date()
       use
       // datum arhive
   endif  // pitanje
#endif

endif  // date
return
*}


/*! \fn OtkUredjaj
 *  \brief Otkljucava direktorij
 *
 * \code
 * OtkUredj("C:\SIGMA\SIF")  ->  "SIGMA\SIF"
 * \endcode
*/

function OtkUredj(cDIr)
*{
local nPos
nPos:=AT(":",cDir)
if nPos<>0
 cDir:=substr(cDir,npos+1)
endif
if left(cdir,1)==SLASH
  cdir:=substr(cDir,2)
endif
if left(cdir,1)==SLASH
  cdir:=substr(cDir,2)
endif
return  cDir
*}


/*! \fn DirMak2(cDir)
 *  \brief rekurzivno pravi direktorij
 *  \param  - cDir - direktorij
 *  \return - .t. - uspjesno
 *
 *
 * \code
 *
 * Dirmak2("C:\sigma\fakt\11") 
 *
 * - rekurzivno odradjuje, sto znaci ako imamo dir c:\sigma
 * - formira fakt, pa onda poddirektorij 11
 * \encdode
 */
 
function Dirmak2(cDir)
*{
local nPos, npom

nPom:=dirmake(cdir)
if npom<>0
   nPos:=rat(SLASH,cDir)
   if nPos<>0
      dirmak2(substr(cDir,1,npos-1))
      dirmake(cdir)
   endif
endif

if fileattr(cdir)==16
	return .t.
else
	return .f.
endif

*}

/*! \fn CopySve(cMask,cInPath,cOutPath)
*   \brief Kopiraj sve fajlove iz cInPath-a u cOutPath
*/

function CopySve(cMask,cInPath,cOutPath)
*{
local aFiles:={} , i
aFiles:=Directory(cInPath+cMask)
for i:=1 to  len(aFiles)
  filecopy(cInPath+aFiles[i,1],cOutPath+aFiles[i,1])
  ? "kopiram:", cInPath+aFiles[i,1] ,"->", cOutPath+aFiles[i,1]
next
?
? cMask, "- kopirano ",len(aFiles),"fajla"
?
return NIL
*}

/*! \fn DelSve(cMask,cInPath)
 *  \brief Brisi sve iz inPath-a
 *
 * \code
 * DelSve("*.DB?","c:\sigma")
 * \endcode
 *
 */

function DelSve(cMask,cInPath)
*{
local aFiles:={} , i, cPom

cPom:=cInPath+iif(right(cInPath,1)<>SLASH,SLASH,"")+cMask
aFiles:=Directory(cPom)
for i:=1 to  len(aFiles)
  cPom:=cInPath+iif(right(cInPath,1)<>SLASH,SLASH,"")+aFiles[i,1]
  ferase(cPom)
  ? "brisem:", cPom
next
?
? cInPath,"#",cMask," - brisano ",len(aFiles),"fajla"
?
return NIL
*}

/*! \fn Zakljucaj(cIme)
* \brief Zakljucava fajlove u direktoriju
*
* \return - .t. ako je uspio zakljucatio fajlove
*
* Otvara sve fajlove u matrici (time zakljucava za ostale korisnike)
*
* \note koristi private varijablu aFilesK (matrica fajlova)
*
* \todo ugasiti, funkcija je poglupa
*/


function Zakljucaj(cIme)
*{
local fRet:=.t., nHandle
local nPos
nPos:=ASCAN(aFilesK,{|x| x[1]==upper(cIme)})
if nPos<>0
  nHandle:=fopen(aFilesK[nPos,1])
  aFilesK[nPos,2]:=nHandle
  if nhandle<0; fRet:=.f.; endif
endif
nPos:=ASCAN(aFilesS,{|x| x[1]==upper(cIme)})
if nPos<>0
  nHandle:=fopen(aFilesS[nPos,1])
  aFilesS[nPos,2]:=nHandle
  if nhandle<0; fRet:=.f.; endif
endif
nPos:=ASCAN(aFilesP,{|x| x[1]==upper(cIme)})
if nPos<>0
  nHandle:=fopen(aFilesP[nPos,1])
  aFilesP[nPos,2]:=nHandle
  if nhandle<0; fRet:=.f.; endif
endif
*}


function Otkljucaj(cIme)
*{
local nPos
nPos:=ASCAN(aFilesK,{|x| x[1]==upper(cIme)})
if nPos<>0; fclose(aFilesK[nPos,2]); endif

nPos:=ASCAN(aFilesS,{|x| x[1]==upper(cIme)})
if nPos<>0; fclose(aFilesS[nPos,2]); endif

nPos:=ASCAN(aFilesP,{|x| x[1]==upper(cIme)})
if nPos<>0; fclose(aFilesP[nPos,2]); endif

*
* aFajlovi := {  PRIVPATH+"roba.dbf"  ,;
*                PRIVPATH+"robai1*.*"    }
*
*
* cImeArh:= "AFAKT"

return
*}



function Zipuj( aFiles, cImeArh, cDest, cTip )
local cAbc := "A"
local fRet := .t.
local nH
local cFileName
local l7zip := .f.

if cTip == nil
	cTip := "arj"
endif

if IzFmkIni("Svi","Arh7zip","N", EXEPATH)=="D"
	l7zip := .t.
endif

if cDest == NIL 
	// zadaj destinaciju
	Box(,1,50)
 	@ m_x+1,m_y+2 SAY "Arhivirati na disk A/B/C/D/E/F/G ?" get cabc pict "@!" valid cabc $ "ABCDEFG"
 	read
	ESC_BCR
	BoxC()
	cDest := cAbc + ":\"
endif

if cImearh == NIL
  	cImeArh:="ARHSIG"
endif

if !l7zip
	cKom:="ARJ A " + cDest + cImeArh + " -jf  -x*.bak !list.cmd"
else
	cKom:="7z a -tzip " + cDest + cImeArh + " @" + PRIVPATH + "arhlist.txt"
	// napravi fajl arhlist
	save screen to cScr
	cls
	?
	? "7Zip arhiviranje u toku:"
	?
	cFileName := PRIVPATH + "arhlist.txt"
	if (nH:=fcreate(cFileName))==-1
   		Beep(4)
   		Msg("Greska pri kreiranju fajla: "+cFileName+" !",6)
   		return
	endif
	fclose(nH)

	set printer to (cFileName)
	set printer off
	set printer on
	
	for i:=1 to len(aFiles)
  		? aFiles[i] + " "
	next
	
	set printer to
	set printer off
	set printer on
	
	run &cKom
	
	restore screen from cScr
	return
endif

save screen to cScr
cls
?
? "Izvrsavam komandu arhviranja:"
? cKom
?
?
? "list.cmd:"
for i:=1 to len(aFiles)
  ? aFiles[i]
next
cPom:=""
for i:=1 to len(aFiles)
  cPom+=trim(aFiles[i])+chr(13)+chr(10)
next
if strfile(cPom,"list.cmd")=0
  fret:=.f.
endif

?
if !swpruncmd(cKom,0,"","")
  fret:=.f.
endif
if swperrlev()<>0
 fRet:=.f.
endif
inkey(10)
restore screen from cScr
if !fret
  MsgBeep("Arhiviranje nije uspjesno zavrseno !")
endif

inkey(5)
restore screen from cscr

//#endif
closeret

return
*}


function UnZipuj(cImeArh,cLokacija,cDest)
*{

*
* unzipuj
* cDest = A:\

local cabc:="A",n123:=1, fRet:=.t.

if IzFmkIni("Svi","Arh7zip","N", EXEPATH)=="D"
	l7zip := .t.
else
	l7zip := .f.
endif

if cDest==NIL
	Box(,1,50)
 	@ m_x+1,m_y+2 SAY "Arhiva je na disku A/B/C/D/E/F/G ?" get cabc pict "@!" valid cabc $ "ABCDEFG"
 	read
	ESC_BCR
	BoxC()
	cDest:=cAbc+":\"
endif

if cImeArh==NIL
	cImeArh:="ARHSIG"
endif
if cLokacija==NIL
  	cLokacija:=PRIVPATH
endif

save screen to cScr
cls
if !l7zip
	cKom:="ARJ E "+cDest+cImeArh+" -jf -jyo "+cLokacija
else
	cKom:="7z e " + cDest + cImeArh + ".zip -o" + PRIVPATH + " -y"
	?
	? "7Zip dearhiviranje u toku:"
	?
	run &cKom
	restore screen from cScr
	return .t.
endif

?
? "Izvrsavam komandu DEARHIVIRANJA:"
? cKom
?
?
?
if !swpruncmd(cKom,0,"","")
  fret:=.f.
endif
if swperrlev()<>0
 fRet:=.f.
endif
if !fret
  MsgBeep("Dearhiviranje nije uspjesno zavrseno !")
endif
inkey(5)
restore screen from cScr

return fret
*}

function IscitajCRC(cFajl)
*{

LOCAL cPom
IF cFajl==NIL
	cFajl:="CRC.CRC"
ENDIF
cPom:=FILESTR(cFajl,22)
RETURN { VAL(LEFT(cPom,10)) , VAL(RIGHT(cPom,10)) }

*}

function NapraviCRC(cFajl,n1,n2)
*{ 
 LOCAL nH:=0
  IF cFajl==NIL; cFajl:="CRC.CRC"; ENDIF
  IF FILE( cFajl )
    FERASE( cFajl )
  ENDIF
  nH := FCREATE( cFajl , 0 )
  FWRITE( nH , STR(n1,10) )
  FWRITE( nH , CHR(13)+CHR(10) )
  FWRITE( nH , STR(n2,10) )
  FWRITE( nH , CHR(13)+CHR(10) )
  FCLOSE( nH )
RETURN
*}

function IntegDBF(cBaza)
*{
LOCAL berr, nRec:=RECNO(), nExpr:=0, nExpr2:=0, cStr:="", j:=0
   bErr:=ERRORBLOCK({|o| MyErrH(o)})
   BEGIN SEQUENCE
    cmxAutoOpen(.f.)
    IF cBaza!=NIL
      USE (cBaza) NEW
    ENDIF
    GO TOP
    DO WHILE !EOF()
      FOR j:=1 TO FCOUNT()
         IF VALTYPE(FIELDGET(j))=="C"
           cStr:=TRIM(FIELDGET(j))
           nExpr+=len(cStr)
           nExpr2+=NUMAT("A",cStr)
         ENDIF
      NEXT
      SKIP 1
    ENDDO
    IF cBaza!=NIL
      USE
    ELSE
      GO (nRec)
    ENDIF
   RECOVER
      bErr:=ERRORBLOCK(bErr)
      MsgBeep("Ponovite prenos, podaci su osteceni !")
      cmxAutoOpen(.t.)
      return { 0 , 0 }
   END SEQUENCE
   bErr:=ERRORBLOCK(bErr)
   cmxAutoOpen(.t.)
RETURN { nExpr , nExpr2 }
*}


function UzmiIzArj(fBrisi,cEXT, cSwitch)
*{

* fBrisi
* cSwitch - extra switchevi

local cS

local cFileArt

local OPCF:={}
local H

if fbrisi==NIL
 fbrisi:=.f.
endif
if cExT==NIL
 cEXT:="ART"
endif

if cSwitch==NIL
 cSwitch:="-jf "  // otpakuj upravo tamo gdje je i zapakovano
endif

if !SigmaSif("ART     ")
   MSgBeep("Klonite se corava posla...")
   return
else
  MsgBeep("Nadam se da znate sta radite !")
endif

aFiles:=DIRECTORY("*."+cEXT)

ASORT(aFiles,,,{|x,y| x[3]>y[3] })      // datum

AEVAL(aFiles,  {|elem| AADD(opcF,PADR(elem[1],15))} ,1,20)   // samo 20 najnovijih
h:=ARRAY(LEN(OPCF))
for i:=1 to len(h)
  h[i]:=""
next

if len(opcf)==0
   msgbeep("Nema arhive ...")
   return
endif
// CITANJE
Izb3:=1
fPrenesi:=.f.
@ 10,20 SAY  ""
do while .t.
 Izb3:=Menu("iza",opcF,Izb3,.f.)

 if Izb3==0
   exit
 else
   cFileArt:=trim(opcf[izb3])
   save screen to cS
   cls
   cKom:="ARJ v -jp "+cFileArt
   swpruncmd(cKom,0,"","")
   cls
   ? "Pritisni nesto za nastavak .."
   DO WHILE NEXTKEY()==0; OL_YIELD(); ENDDO
   INKEY()
   // inkey(0)
   if Pitanje(,iif(fBrisi,"Brisati","Otpakovati")+" "+cFileArt," ")=="D"
        cKom:="ARJ x "+cSwitch+cFileArt
        swpruncmd(cKom,0,"","")
   endif
   restore screen from cS
 endif
enddo

return
*}


function StaviUArj(aDirs)
*{

local fRet:=.t.
local fCDX:=.f.
local i
local cScr
local cIme
local aFiles
local cPom

cCDX:="D"
cIme:=padr("A:\"+gmodul,30)
Box(,5,60)
  @ m_x+1,m_y+2 SAY "Ime arhive           :" GET cIme
  @ m_x+3,m_y+2 SAY "Pohraniti CDX fajlove:" GET cCDX pict "@!" valid cCDX $ "DN"
  read
BoxC()

if cCDX=="D"
 fCDX:=.t.
endif

fRecurse:=.f.

cKom:="ARJ A"+iif(fRecurse," -r","")+" -x*.ar? -x*.exe -x*.bak -x*.ntx "
if !fCdx; cKom+=" -x*.CDX "; endif
ckom+=trim(cIme)+" !list.cmd"



save screen to cScr

cls
?
? "Izvrsavam komandu arhviranja:"
? cKom
?
? "Budite strpljivi ..... "
?
? "list.cmd:"
if aDirs==NIL
  aDirs:={}
  AADD(aDirs,cDirRad)
  AADD(aDirs,cDirSif)
  AADD(aDirs,cDirPriv)
endif

for i:=1 to len(aDirs)
  ? adirs[i]
next

? "Pritisni <ENTER> za nastavak ...."

cSep:="*.*"+chr(13)+chr(10)

cPom:=""
for i:=1 to len(aDirs)
  cPom+=trim(aDirs[i])+iif(RIGHT(trim(aDirs[i]),1)==SLASH,"",SLASH)+cSep
next
if strfile(cPom,"list.cmd")=0
  fret:=.f.
endif

if len(aDirs)=0
  return .t.
endif


inkey(2)
?
if !swpruncmd(cKom,0,"","")
  fret:=.f.
endif
if swperrlev()<>0
 fRet:=.f.
endif
inkey(10)
restore screen from cScr
if !fret
  if pitanje(,"Zastita nije uspjela. Nastaviti ?","N")=="N"
   goModul:quit()
  endif
endif
return fret
*}


/*! \fn OFSveuDir(cPath, aFiles)
 * \brief Otvori Fajlove Sve u Direktoriju
 * \note proslijedi aFiles
 * \return - ako su svi otvoreni - okupirani, vrati .t.
 */

function OFSveuDir(cPath,aFiles)
*{
local nRet:=.t.
local i
aFiles:=Directory(trim(cPath)+"*.DBF")
for i:=1 to len(afiles)
  aFiles[i,1]:=upper(trim(cPath)+aFiles[i,1])
  afiles[i,2]:=fopen(aFiles[i,1],2)
  if afiles[i,2]==-1
     MsgBeep("Neko vec koristi "+aFiles[i,1])
     ShowFERROR()
     //fclose(afiles[i,2])
     nRet:=.f.
  endif
next
return nRet

*}

/*! \fn ZFSveUDir(aFiles)
 *  \brief kontra OFSveuDir
 *  \sa OfSveuDir
 */

function ZFSveuDir(aFiles)
*{
local i
for i:=1 to len(afiles)
 if aFiles[i,2]>0  // ako je -1 preskoci
  fclose(aFiles[i,2])
 endif
next
Asize(aFiles,0)
return .t.

*}

