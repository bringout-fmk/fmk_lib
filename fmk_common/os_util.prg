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

#define D_STAROST_DANA   25

// ------------------------------------
// vraca putanju exe fajlova
// ------------------------------------
function GetExePath( cPath )
local cRet := ""
local i
local n := 0
local cTmp

for i:=1 to LEN(cPath)

	cTmp := SUBSTR( cPath, i, 1 )
	
	if cTmp == "\"
		n += 1
	endif

	cRet += cTmp

	if n = 2
		exit
	endif

next

return cRet



/*! \fn FilePath(cFile)
 *  \brief  Extract the full path name from a filename
 *  \return cFilePath
 */
 
function FilePath( cFile )
LOCAL nPos, cFilePath

nPos := RAT(SLASH, cFile)
if (nPos != 0)
	cFilePath := SUBSTR(cFile, 1, nPos)
else
	cFilePath := ""
endif
return cFilePath

function ExFileName( cFile )
LOCAL nPos, cFileName
IF (nPos := RAT(SLASH, cFile)) != 0
   cFileName:= SUBSTR(cFile, nPos + 1 )
ELSE
   cFileName := cFile 
ENDIF
return cFileName

function AddBS(cPath)
if right(cPath,1)<>SLASH     
     cPath:=cPath + SLASH
endif


function DiskPrazan(cDisk)

 if diskspace(asc(cDisk)-64)<15000
   Beep(4)
   Msg("Nema dovoljno prostora na ovom disku, stavite drugu disketu",6)
   return .f.
 endif
return .t.


*string FmkIni_ExePath_POS_PitanjeUgasiti;

/*! \ingroup ini
 *  \var *string FmkIni_ExePath_POS_PitanjeUgasiti
 *  \param "0" - ne pitaj (dobro za racunar koji se ne koristi SAMO kao PC Kasa
 *  \param "-" - pitaj 
 */

function UgasitiR()

local cPitanje

if (gSQL=="D")
	cPitanje:=IzFmkIni("POS","PitanjeUgasiti","-")
	if cPitanje=="-"
		cPitanje:=" "
	endif

	if (cPitanje=="0")
		goModul:quit()
	elseif Pitanje(,"Zelite li ugasiti racunar D/N ?", cPitanje)=="D"
		if Gw("OMSG SHUTDOWN")=="OK"
			goModul:quit()
		endif
	endif
endif

if gModul<>"TOPS"
	goModul:quit()
else
	// nemoj se vracati u RADP
	goModul:quit(.f.)
endif

return



/*! \file ChangeEXT(cImeF,cExt, cExtNew, fBezAdd)
 * \brief Promjeni ekstenziju
 *
 * \params cImeF   ime fajla
 * \params cExt    polazna extenzija (obavezno 3 slova) 
 * \params cExtNew nova extenzija
 * \params fBezAdd ako je .t. onda ce fajlu koji nema cExt dodati cExtNew
 * 
 * \code
 *
 * ChangeEXT("SUBAN", "DBF", "CDX", .t.)
 * suban     -> suban.CDX
 * 
 * ChangeEXT("SUBAN", "DBF", "CDX", .f.)
 * SUBAN     -> SUBAN
 * 
 *
 * ChangeEXT("SUBAN.DBF", "DBF", "CDX", .t.)
 * SUBAN.DBF  -> SUBAN.CDX
 *
 * \endcode 
 *
 */

function ChangeEXT(cImeF,cExt, cExtNew, fBezAdd)

local cTacka

if fBezAdd==NIL
  fBezAdd:=.t.
endif  
  
if EMPTY(cExtNew)
  cTacka:=""
else
  cTacka:="."
endif
cImeF:=ToUnix(cImeF)

cImeF:=trim(STRTRAN(cImeF,"."+cEXT,cTacka+cExtNew))
if !EMPTY(cTacka) .and.  RIGHT(cImeF,4)<>cTacka+cExtNew
  cImeF:=cImeF+cTacka+cExtNew
endif
return  cImeF


// ------------------------------------------
// ------------------------------------------
function IsDirectory(cDir1)

local cDirTek
local lExists

cDir1 := ToUnix(cDir1)

cDirTek:=DirName()

if DirChange(cDir1) <> 0
 lExists:=.f.
else
 lExists:=.t.
endif

DirChange(cDirTek)

return lExists


// --------------------------------
// legacy
// --------------------------------
function DirExists(cDir1)


local nH

cDir1:=trim(cDir1)

if !IsDirectory(cDir1)
 beep(2)
 Msg("Nepostojeci direktorij ili niste prisutni na mrezi !",0)
 if Pitanje(,"Zelite li kreirati direktorij:"+trim(cDir1)+" ?","N")=="D"
    if DirMak2(cDir1)
       return .t.
    else
       Msg("Ne mogu kreirati direktorij ?",0)
       return .f.
    endif
  endif
  return .f.
else
 return .t.
endif



/*! \fn BrisiSFajlove(cDir)
  * \brief Brisi fajlove starije od 45 dana
  *
  * \code
  *
  * npr:  cDir ->  c:\tops\prenos\ 
  *
  * brisi sve fajlove u direktoriju
  * starije od 45 dana
  *
  * \endcode
  */

function BrisiSFajlove(cDir, nDana)

local cFile

if nDana == nil
	nDana := D_STAROST_DANA
endif

cDir:=ToUnix(trim(cdir))
cFile:=fileseek(trim(cDir)+"*.*")
do while !empty(cFile)
    if date() - filedate() > nDana  
       filedelete(cdir+cfile)
    endif
    cfile:=fileseek()
enddo
return NIL


function ShowMem()

Box(,3,50)
           @ m_x+1,m_y+2 SAY "(0) :"
	   ?? memory()
           inkey(0)
BoxC()

RETURN



// ----------------------------------------------
// ----------------------------------------------
function ToUnix(cFileName)

local nPos

cFileName:= LOWER(cFileName)


if HB_OSPATHSEPARATOR() == "/"
  cFileName:=STRTRAN(cFileName, ".\","")
  cFileName:=STRTRAN(cFileName, ".korisn", "korisn")
  cFileName:=STRTRAN(cFileName, ".mparams", "mparams") 
  
  if (cFileName == "/gparams")
    cFileName := GetEnv("HOME") + "/gparams"
  endif

  cFileName:=STRTRAN(cFileName, ".secur", "secur")
  cFileName:=STRTRAN(cFileName, "c:", "/c")
  cFileName:=STRTRAN(cFileName, "d:", "/d")
  cFileName:=STRTRAN(cFileName, "k:", "/k")
  cFileName:=STRTRAN(cFileName, "i:", "/i")
  cFileName:=STRTRAN(cFileName, "t:", "/t")
  cFileName:=STRTRAN(cFileName, "q:", "/q")
  cFileName:=STRTRAN(cFileName, "\", "/")
  
  if (cFileName=="/params")
    cFileName:="params"
  endif
  
  if (cFileName=="/kparams")
    cFileName:="kparams"
  endif

endif

return cFileName



// -------------------------------------
// -------------------------------------
function ShowOsInfo(gsOsInfo)

@ 24, 2 SAY gsOsInfo

return

