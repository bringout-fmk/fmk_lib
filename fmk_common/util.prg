#include "fmk.ch"
 
/*! \fn nToLongC(nN)
 *  \brief Pretvara broj u LONG (C-ovski prikaz long integera)
 *
 */
 
function nToLongC(nN)

local cStr:="",i

for i:=1 to 4
nDig:=nN-INT(nN/256)*256
cStr+=CHR(nDig)
nN:=INT(nN/256)
next

return cStr


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


function Bios()


local cStr:="",i
for i:=1 to 8
  //cStr+=peekchar("F000",65524+i)
  cStr+=chr(peekbyte("F000",65524+i))
next
return cStr



function BosTipke()
  
  SETKEY( ASC('{') , {|| __KEYBOARD('[') }  )
  SETKEY( ASC('|') , {|| __KEYBOARD('\') }  )
  SETKEY( ASC('`') , {|| __KEYBOARD('@') }  )
  SETKEY( ASC('~') , {|| __KEYBOARD('^') }  )
  SETKEY( ASC('}') , {|| __KEYBOARD(']') }  )
  SETKEY( ASC('�') , {|| __KEYBOARD('�') }  )
  SETKEY( ASC('�') , {|| __KEYBOARD('�') }  )
  SETKEY( ASC('�') , {|| __KEYBOARD('�') }  )
  SETKEY( ASC('�') , {|| __KEYBOARD('�') }  )
  SETKEY( ASC('�') , {|| __KEYBOARD('�') }  )
RETURN



function USTipke()
SET KEY ASC('{') TO
  SET KEY ASC('|') TO
  SET KEY ASC('`') TO
  SET KEY ASC('~') TO
  SET KEY ASC('}') TO
  SET KEY ASC('�') TO
  SET KEY ASC('�') TO
  SET KEY ASC('�') TO
  SET KEY ASC('�') TO
  SET KEY ASC('�') TO
RETURN

// ------------------------------
// ------------------------------
function KSTo852(cStr)
  cStr:=strtran(cStr,"{","�")
  cStr:=strtran(cStr,"|","�")
  cStr:=strtran(cStr,"`","�")
  cStr:=strtran(cStr,"~","�")
  cStr:=strtran(cStr,"}","�")
  cStr:=strtran(cStr,"[","�")
  cStr:=strtran(cStr,"\","�")
  cStr:=strtran(cStr,"@","�")
  cStr:=strtran(cStr,"^","�")
  cStr:=strtran(cStr,"]","�")
return cStr

function BH7u8()
SETKEY( ASC('}') , {|| __KEYBOARD('�') }  )
  SETKEY( ASC('{') , {|| __KEYBOARD('�') }  )
  SETKEY( ASC('~') , {|| __KEYBOARD('�') }  )
  SETKEY( ASC('|') , {|| __KEYBOARD('�') }  )
  SETKEY( ASC('`') , {|| __KEYBOARD('�') }  )
  SETKEY( ASC(']') , {|| __KEYBOARD('�') }  )
  SETKEY( ASC('[') , {|| __KEYBOARD('�') }  )
  SETKEY( ASC('^') , {|| __KEYBOARD('�') }  )
  SETKEY( ASC('\') , {|| __KEYBOARD('�') }  )
  SETKEY( ASC('@') , {|| __KEYBOARD('�') }  )
RETURN

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


function ScLibVer()
return DBUILD

function TechInfo()

local cPom

cPom:=""
aLst:=rddlist()
for i:=1 to len(aLst)
       cPom+=aLst[i]+" "
next
#ifdef CDX
     cPom+="cmx "+cmxVersion(2)+" "
#endif

cPom=cPom+"##Glavni modul:" + gVerzija
cPom=cPom+ "#       sclib:" + ElibVer()

cPom=cPom+"##     FmkSvi:"  + FmkSviVer()
cPom=cPom+ "#     FmkRoba:" + FmkRobaVer()
cPom=cPom+ "#    FmkEvent:" + FmkEvVer()
cPom=cPom+ "# FmkSecurity:" + FmkSecVer()
cPom=cPom+ "#       sclib:" + ScLibVer()

MsgBeep(cPom)

return

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



