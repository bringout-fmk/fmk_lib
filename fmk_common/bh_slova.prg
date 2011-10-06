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

/*! \fn KonvZnWin(cTekst, cWinKonv)
 *  \brief Konverzija znakova u stringu
 *  \param cTekst - tekst
 *  \param cWinKonv - tip konverzije
 */
function KonvZnWin(cTekst, cWinKonv)
local aNiz:={}
local i
local j

AADD(aNiz, {"[","Ê",chr(138),"S","ä"})
AADD(aNiz, {"{","Á",chr(154),"s","Á"})
AADD(aNiz, {"}","Ü",chr(230),"c","Ü"})
AADD(aNiz, {"]","è", chr(198),"C","è"})
AADD(aNiz, {"^","¨", chr(200),"C","¨"})
AADD(aNiz, {"~","ü",chr(232),"c","ü"})
AADD(aNiz, {"`","ß",chr(158),"z","ß"})
AADD(aNiz, {"@","¶",chr(142),"Z","¶"})
AADD(aNiz, {"|","–", chr(240),"dj",""})
AADD(aNiz, {"\","—", chr(208),"DJ","—"})

if cWinKonv = NIL
	cWinKonv:=IzFmkIni("DelphiRb","Konverzija","5")
endif

i:=1
j:=1

if cWinKonv=="1"
	i:=1
	j:=2
elseif cWinKonv=="2"
        // 7->A
	i:=1
	j:=4  
elseif cWinKonv=="3"
        // 852->7
	i:=2
	j:=1   
elseif cWinKonv=="4"
        // 852->A
	i:=2
	j:=4 
elseif cWinKonv=="5"
        // 852->win1250
	i:=2
	j:=3  
elseif cWinKonv=="6"
        // 7->win1250
	i:=1
	j:=3 
elseif cWinKonv=="8"
	i:=3
	j:=5
endif

if i<>j
	AEVAL(aNiz,{|x| cTekst:=STRTRAN(cTekst,x[i],x[j])})
endif

return cTekst




/*! \fn StrKZN(cInput, cIz, cU)
 *  \brief Vrsi zamjenu cInputa
 */
 
function StrKZN(cInput, cIz, cU)

local a852:={"Ê","—","¨","è","¶","Á","–","ü","Ü","ß"}
local a437:={"[","\","^","]","@","{","|","~","}","`"}
local aEng:={"S","D","C","C","Z","s","d","c","c","z"}
local aEngB:={"SS","DJ","CH","CC","ZZ","ss","dj","ch","cc","zz"}
local aWin:= {"ä", "–", "∆", "»", "é", "ö", "", "Ê", "Ë", "û"}
local aUTF:= {"&#352;", "&#272;", "&#268;", "&#262;", "&#381;", "&#353;", ;
	"&#273;", "&#269;", "&#263;", "&#382;"}

local i:=0, aIz:={}, aU:={}


if cIz=="7"
	aIz:=a437
elseif cIz=="8"
	aIz:=a852
elseif (goModul:oDataBase:cName=="LD" .and. cIz=="B")
	aIz:=aEngB
elseif (cIz=="W")
	aIz:=aWin
else
	aIz:=aEng
endif

if cU=="7"
	aU:=a437
elseif cU=="8"
	aU:=a852
elseif cU=="U"
	aU:=aUTF
elseif goModul:oDataBase:cName=="LD" .and. cU=="B"
	aU:=aEngB
else
	aU:=aEng
endif

// Ove dvije linije zamjenio sa gornjim kodom
// aIz:=IF(cIz=="7", a437, IF(cIz=="8", a852, aEng))
// aU:=IF(cU=="7", a437, IF(cU=="8", a852, aEng))

cPocStanjeSif:=cInput

for i:=1 to 10
	if (goModul:oDataBase:cName=="LD" .and. i==5)
		if AT("D@", cInput)<>0
			cInput:=STRTRAN(cInput, "D@", "DZ")
		elseif AT("D|", cInput)<>0
			cInput:=STRTRAN(cInput, "D|", "DZ")
		endif
	endif
	if (goModul:oDataBase:cName=="LD" .and. i==10)
		if AT("dß", cInput)<>0
			cInput:=STRTRAN(cInput, "dß", "dz")
		elseif AT("d`", cInput)<>0
			cInput:=STRTRAN(cInput, "d`", "dz")
		endif
	endif

	cInput:=STRTRAN(cInput,aIz[i],aU[i])
next


if (cU=="B" .and. LEN(ALLTRIM(cInput)) > 6)
	// provjeri da li ovaj par postoji u nizu
	nPos:=ASCAN(aKonvZN, {|aVal| aVal[1] == cPocStanjeSif})
	if nPos > 0
		cRet:=aKonvZN[nPos, 2]
	else
		cNoviId:=SPACE(6)
		Box(,3,25)
		@ 1+m_x, 2+m_y SAY "Unesi novi ID za sifru: "
		@ 2+m_x, 2+m_y SAY "Stari ID: " + cPocStanjeSif
		@ 3+m_x, 2+m_y SAY "Novi ID: " GET cNoviID
		read
		BoxC()
		AADD(aKonvZN, {cPocStanjeSif, cNoviId})
		cRet:=cNoviID
	endif
else
	cRet:=cInput
endif

cKrajnjeStanjeSif:=cRet

return cRet



function KSto7(cStr)
  cStr:=strtran(cStr,"Á","{")
  cStr:=strtran(cStr,"–","|")
  cStr:=strtran(cStr,"ß","`")
  cStr:=strtran(cStr,"ü","~")
  cStr:=strtran(cStr,"Ü","}")
  cStr:=strtran(cStr,"è","[")
  cStr:=strtran(cStr,"—","\")
  cStr:=strtran(cStr,"¶","@")
  cStr:=strtran(cStr,"¨","^")
  cStr:=strtran(cStr,"è","]")
return cStr

function KonvTable(fGraf)

return nil


function bhsort(cInput)
 IF gKodnaS=="7"
   cInput:=STRTRAN(cInput,"[","S"+CHR(255))
   cInput:=STRTRAN(cInput,"\","D"+CHR(255))
   cInput:=STRTRAN(cInput,"^","C"+CHR(254))
   cInput:=STRTRAN(cInput,"]","C"+CHR(255))
   cInput:=STRTRAN(cInput,"@","Z"+CHR(255))
   cInput:=STRTRAN(cInput,"{","s"+CHR(255))
   cInput:=STRTRAN(cInput,"|","d"+CHR(255))
   cInput:=STRTRAN(cInput,"~","c"+CHR(254))
   cInput:=STRTRAN(cInput,"}","c"+CHR(255))
   cInput:=STRTRAN(cInput,"`","z"+CHR(255))
 ELSE  // "8"
   cInput:=STRTRAN(cInput,"Ê","S"+CHR(255))
   cInput:=STRTRAN(cInput,"—","D"+CHR(255))
   cInput:=STRTRAN(cInput,"¨","C"+CHR(254))
   cInput:=STRTRAN(cInput,"è","C"+CHR(255))
   cInput:=STRTRAN(cInput,"¶","Z"+CHR(255))
   cInput:=STRTRAN(cInput,"Á","s"+CHR(255))
   cInput:=STRTRAN(cInput,"–","d"+CHR(255))
   cInput:=STRTRAN(cInput,"ü","c"+CHR(254))
   cInput:=STRTRAN(cInput,"Ü","c"+CHR(255))
   cInput:=STRTRAN(cInput,"ß","z"+CHR(255))
 ENDIF
RETURN PADR(cInput, 100)


// ------------------------------------------
// ------------------------------------------
function BosTipke()

/*  
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
*/

RETURN


// -------------------------------------------
// -------------------------------------------
function USTipke()

/*
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
*/

// ------------------------------
// ------------------------------
function KSTo852(cStr)

/*
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
*/

return cStr


