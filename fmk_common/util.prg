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
 
// --------------------------------------------------------------
//* nToLongC(nN)
//* Pretvara broj u LONG (C-ovski prikaz long integera)
// --------------------------------------------------------------
function nToLongC(nN)

local cStr:="",i

for i:=1 to 4
nDig:=nN-INT(nN/256)*256
cStr+=CHR(nDig)
nN:=INT(nN/256)
next

return cStr


// --------------------------------------------------------------
// --------------------------------------------------------------
function CLongToN(cLong)

local i,nExp
nRez:=0
for i:=1 to 4
 nExp:=1
 for j:=1 to i-1
   nExp*=256
 next
 nRez+=ASC(SUBSTR(cLong,i,1))*nExp
next
return nRez


// ---------------------------------------
// ---------------------------------------
function Sleep(nSleep)

local nStart, nCh

nStart:=seconds()
do while .t.
 if nSleep < 0.0001
    Exit
 else
    nCh:=inkey(nSleep)

    //if nCh<>0
       //Keyboard chr(nCh)
    //endif
    if (seconds()-nStart) >= nSleep
        Exit
    else
        nSleep:= nSleep - ( seconds()-nStart )
    endif
 endif

enddo

return

// ----------------------------
// ----------------------------
function TechInfo()

local cPom

cPom:=""
aLst:=rddlist()
for i:=1 to len(aLst)
       cPom+=aLst[i]+" "
next

cPom=cPom+"##Glavni modul:" + gVerzija
cPom=cPom+ "#     fmk_lib:" + fmklibver()

cPom=cPom+ "#     FmkRoba:" + FmkRobaVer()
cPom=cPom+ "#    FmkEvent:" + FmkEvVer()
cPom=cPom+ "# FmkSecurity:" + FmkSecVer()

MsgBeep(cPom)

return

// ----------------------------------------
// ----------------------------------------
function NotImp()
MsgBeep("Not implemented ?")

return

// ----------------------------------------
// upisi text u fajl
// ----------------------------------------
function write_2_file(nH, cText, lNoviRed)

local cNRed := CHR(13)+CHR(10)
if lNoviRed
	FWrite(nH, cText + cNRed)
else
	FWrite(nH, cText)
endif

return

// ----------------------------------------------
// kreiranje fajla
// ----------------------------------------------
function create_file(cFilePath, nH)

nH:=FCreate(cFilePath)
if nH == -1
	MsgBeep("Greska pri kreiranju fajla !!!")
	return
endif

return

// -------------------------------------------------
// zatvaranje fajla
// --------------------------------------------------
function close_file(nH)
FClose(nH)

return


// -------------------------------------------------
// -------------------------------------------------
function Run(cmd)

return __Run(cmd)

