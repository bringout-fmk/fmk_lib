#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 
/*! \fn nToLongC(nN)
 *  \brief Pretvara broj u LONG (C-ovski prikaz long integera)
 *
 */
 
function nToLongC(nN)
*{
local cStr:="",i

for i:=1 to 4
nDig:=nN-INT(nN/256)*256
cStr+=CHR(nDig)
nN:=INT(nN/256)
next

return cStr
*}

function CLongToN(cLong)
*{

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
*}

function Bios()
*{

local cStr:="",i
for i:=1 to 8
  //cStr+=peekchar("F000",65524+i)
  cStr+=chr(peekbyte("F000",65524+i))
next
return cStr
*}


function BosTipke()
*{  
  SETKEY( ASC('{') , {|| __KEYBOARD('[') }  )
  SETKEY( ASC('|') , {|| __KEYBOARD('\') }  )
  SETKEY( ASC('`') , {|| __KEYBOARD('@') }  )
  SETKEY( ASC('~') , {|| __KEYBOARD('^') }  )
  SETKEY( ASC('}') , {|| __KEYBOARD(']') }  )
  SETKEY( ASC('Á') , {|| __KEYBOARD('Ê') }  )
  SETKEY( ASC('Ü') , {|| __KEYBOARD('è') }  )
  SETKEY( ASC('ü') , {|| __KEYBOARD('¨') }  )
  SETKEY( ASC('–') , {|| __KEYBOARD('—') }  )
  SETKEY( ASC('ß') , {|| __KEYBOARD('¶') }  )
RETURN
*}


function USTipke()
SET KEY ASC('{') TO
  SET KEY ASC('|') TO
  SET KEY ASC('`') TO
  SET KEY ASC('~') TO
  SET KEY ASC('}') TO
  SET KEY ASC('Á') TO
  SET KEY ASC('Ü') TO
  SET KEY ASC('ü') TO
  SET KEY ASC('–') TO
  SET KEY ASC('ß') TO
RETURN

// ------------------------------
// ------------------------------
function KSTo852(cStr)
  cStr:=strtran(cStr,"{","Á")
  cStr:=strtran(cStr,"|","–")
  cStr:=strtran(cStr,"`","ß")
  cStr:=strtran(cStr,"~","ü")
  cStr:=strtran(cStr,"}","Ü")
  cStr:=strtran(cStr,"[","è")
  cStr:=strtran(cStr,"\","—")
  cStr:=strtran(cStr,"@","¶")
  cStr:=strtran(cStr,"^","¨")
  cStr:=strtran(cStr,"]","è")
return cStr

function BH7u8()
SETKEY( ASC('}') , {|| __KEYBOARD('Á') }  )
  SETKEY( ASC('{') , {|| __KEYBOARD('Ü') }  )
  SETKEY( ASC('~') , {|| __KEYBOARD('ü') }  )
  SETKEY( ASC('|') , {|| __KEYBOARD('–') }  )
  SETKEY( ASC('`') , {|| __KEYBOARD('ß') }  )
  SETKEY( ASC(']') , {|| __KEYBOARD('Ê') }  )
  SETKEY( ASC('[') , {|| __KEYBOARD('è') }  )
  SETKEY( ASC('^') , {|| __KEYBOARD('¨') }  )
  SETKEY( ASC('\') , {|| __KEYBOARD('—') }  )
  SETKEY( ASC('@') , {|| __KEYBOARD('¶') }  )
RETURN

function Sleep(nSleep)
*{
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
*}

function ScLibVer()
return DBUILD

function TechInfo()
*{
local cPom

cPom:=""
aLst:=rddlist()
for i:=1 to len(aLst)
       cPom+=aLst[i]+" "
next
#ifdef CDX
     cPom+="cmx "+cmxVersion(2)+" "
#endif

cPom=cPom+"##Glavni modul:"+gVerzija
cPom=cPom+ "#       sclib:"+ElibVer()
cPom+="##"+str(BliMemAvl())

cPom=cPom+"##     FmkSvi:"+FmkSviVer()
cPom=cPom+ "#     FmkRoba:"+FmkRobaVer()
cPom=cPom+ "#    FmkEvent:"+FmkEvVer()
cPom=cPom+ "# FmkSecurity:"+FmkSecVer()
cPom=cPom+ "#       sclib:"+ScLibVer()

cPom=cPom+"##"
if (BLIMGRSTS(BliMachineMode) = BliModeReal) 
	cPom=cPom+"Running in real mode#" 
	cacheloc = BLIMGRSTS(BliCacheLoc) 
	do case 
		case cacheloc = BliCacheNone 
			cPom=cPom+"No cache available" 
		case cacheloc = BliCacheXMS 
			cPom=cPom+"Cache is in XMS" 
		case cacheloc = BliCacheEMS 
			cPom=cPom+"Cache is in EMS" 
	endcase 
else 
	cPom=cPom+"Running in protected mode#"
	hosttype = BLIMGRSTS(BliHostMode) 
	cPom=cPom+"DOS extender host is :#" 
	do case 
	case hosttype = BliHostDPMI 
		cPom=cPom+"DPMI" 
	case hosttype = BliHostVCPI 
		cPom=cPom+"VCPI" 
	case hosttype = BliHostXMS 
		cPom=cPom+"XMS" 
	endcase 
endif

MsgBeep(cPom)
return

function NotImp()
MsgBeep("Not implemented ?")
return


// upisi text u fajl
function write_2_file(nH, cText, lNoviRed)
local cNRed := CHR(13)+CHR(10)
if lNoviRed
	FWrite(nH, cText + cNRed)
else
	FWrite(nH, cText)
endif
return


// kreiranje fajla
function create_file(cFilePath, nH)
nH:=FCreate(cFilePath)
if nH == -1
	MsgBeep("Greska pri kreiranju fajla !!!")
	return
endif
return


// zatvaranje fajla
function close_file(nH)
FClose(nH)
return



