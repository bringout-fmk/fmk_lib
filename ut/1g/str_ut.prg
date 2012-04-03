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

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 *
 */
 
function ToStr(xVal)
*{

do case
  case VALTYPE(xVal)  == "C"
     return(xVal)
  case VALTYPE(xVal)  == "D"
     return(DTOC(xVal))
  case VALTYPE(xVal)  == "L"
     return(iif(xVal,".t.",".f."))
  case VALTYPE(xVal)  == "N"
     return(STR(xVal))
  otherwise
     return "_?_"
endcase

return
*}

// --------------------------------
// --------------------------------
function SjeciStr(cStr, nLen, aRez)
*{

if aRez == nil
	aRez:={}
else
	// prosljedjena je matrica da se dodaju elementi
	// sa SjeciStr(cStr, nLen, @aRez)
endif

cStr:=Trim(cStr)

do while  !empty(cStr)

  fProsao:=.f.
  if len(cStr)>nLen
   for i:=nLen to int(nLen/2) step -1
   
     if substr(cStr, i, 1) $ " ,/-:)"
        AADD(aRez,PADR(left(cStr,i), nLen))
        cStr:=substr(cStr, i+1)
        i:=1
        fProsao:=.t.
     endif
     
   next
   
  else
  
    AADD( aRez, PADR(cStr,nLen) )
    fProsao:=.t.
    cStr:=""
    
  endif
  
  if !fProsao
     AADD(aRez,padr(left(cStr,nLen-1)+iif(len(cStr)>nLen, "-", ""),nLen))
     cStr:=substr(cStr,nLen)
  endif
enddo
if len(aRez)==0
	AADD(aRez,space(nLen))
endif
return aRez
*}

function CryptSC(cStr)
*{
local nLen,cC,cPom,i

cPom:=""
nLen:=len(cStr)
for i=1 to int(nLen/2)
  cC:=substr(cStr,nLen+1-i,1)
  if cC<'€'
     cPom+=CHR(ASC(cC)+128)
  else
     cPom+=CHR(ASC(cC)-128)
  endif
next

if nLen%2<>0
   cC:=substr(cStr,int(nLen/2)+1,1)
  if cC<'€'
     cPom+=CHR(ASC(cC)+128)
  else
     cPom+=CHR(ASC(cC)-128)
  endif
endif
for i=int(nLen/2) to 1 step -1
   cC:=substr(cStr,i,1)
  if cC<'€'
     cPom+=CHR(ASC(cC)+128)
  else
     cPom+=CHR(ASC(cC)-128)
  endif
next

return cPom
*}

/*
function Crypt(cStr)
local nLen,cC,cPom,i

nLen:=len(cStr)
for i=1 to int(nLen/2)
  cC:=substr(cStr,nLen+1-i,1)
  if cC<'€'
     cPom+=CHR(ASC(cC)+128)
  else
     cPom+=CHR(ASC(cC)-128)
  endif
next

if nLen%2<>0
   cC:=substr(cStr,int(nLen/2)+1,1)
  if cC<'€'
     cPom+=CHR(ASC(cC)+128)
  else
     cPom+=CHR(ASC(cC)-128)
  endif
endif
for i=int(nLen/2) to 1 step -1
   cC:=substr(cStr,i,1)
  if cC<'€'
     cPom+=CHR(ASC(cC)+128)
  else
     cPom+=CHR(ASC(cC)-128)
  endif
next

return cPom
*/




function ChADD(cC,n)
*{

*
*
* poziv cC:="A"; ChADD(@cC,2) -> "C"

cC:=Chr(ASC(cC)+n)
RETURN NIL
*}


function ChSub(cC,cC2)
*{

* poziv ChSub("C","A") -> 2

return ASC(cC)-ASC(cC2)
*}

function Crypt2(cStr, cModul)
*{
*
*
local nLen,cC,cPom,i

if cModul=NIL
  cModul:=gModul
endif

cPom:=""
nLen:=len(cStr)
for i=1 to int(nLen/2)
  cC:=substr(cStr,nLen+1-i,1)
  if cC<'€'
     cPom+=CHR(ASC(cC)+ASC(substr(padr(cModul,8),i,1)))
  else
     cPom+=CHR(ASC(cC)-ASC(substr(padr(cModul,8),i,1)))
  endif

next
for i=int(nLen/2) to 1 step -1
   cC:=substr(cStr,i,1)
  if cC<'€'
     cPom+=CHR(ASC(cC)+ASC(substr(padr(cModul,8),nLen+1-i,1)))
  else
     cPom+=CHR(ASC(cC)-ASC(substr(padr(cModul,8),nLen+1-i,1)))
  endif
next
return cPom
*}


// ---------------------------
// ---------------------------
FUNCTION Razrijedi (cStr)
*{
LOCAL cRazrStr, nLenM1, nCnt
cStr := ALLTRIM (cStr)
nLenM1 := LEN (cStr) - 1
cRazrStr := ""
FOR nCnt := 1 TO nLenM1
  cRazrStr += SUBSTR (cStr, nCnt, 1) + " "
NEXT
cRazrStr += RIGHT (cStr, 1)
RETURN (cRazrStr)
*}

// f-je chr256() i asc256() rade sa tekstom duzine 2 znaka
// -------------------------------------------------------
FUNCTION CHR256(nKod)
*{
RETURN ( CHR(INT(nKod/256)) + CHR(nKod%256) )
*}

FUNCTION ASC256(cTxt)
*{
RETURN ( ASC(LEFT(cTxt,1)) * 256 + ASC(RIGHT(cTxt,1)) )
*}

FUNCTION KPAD(n,l)
*{
RETURN PADL(LTRIM(TRANS(ROUND(n,gZaokr),PicDEM)),l,".")
*}

function OdsjPLK(cTxt)
*{
local i
for i:=len(cTxt) to 1 step -1
  if !(substr(cTxt,i,1) $ Chr(13)+Chr(10)+" ")
       exit
  endif
next
return left(cTxt,i)
*}

function ParsMemo(cTxt)
*{

* Struktura cTxt-a je: Chr(16) txt1 Chr(17)  Chr(16) txt2 Chr(17) ...
local aMemo:={}
local i,cPom,fPoc

 fPoc:=.f.
 cPom:=""
 for i:=1 to len(cTxt)
   if  substr(cTxt,i,1)==Chr(16)
     fPoc:=.t.
   elseif  substr(cTxt,i,1)==Chr(17)
     fPoc:=.f.
     AADD(aMemo,cPom)
     cPom:=""
   elseif fPoc
      cPom:=cPom+substr(cTxt,i,1)
   endif
 next

return aMemo
*}

function StrLinija(cTxt2)
*{
local nTxt2

nLTxt2:=1
for i:=1 to len(cTxt2)
  if substr(cTxt2,i,1)=chr(13)
   ++nLTxt2
  endif
next

return nLTxt2
*}


/*! \fn TokToNiz(cTok, cSE)
 *  \brief Token pretvori u niz
 *  \param cTok - token
 *  \param cSE - separator niza
 */
function TokToNiz(cTok,cSE)
*{
local aNiz:={}
local nE:=0
local i:=0
local cE:=""

if cSE==NIL 
	cSE := "." 
endif

nE := NUMTOKEN(cTok,cSE)

for i:=1 to nE
	cE := TOKEN(cTok,cSE,i)
    	AADD(aNiz,cE)
next
return (aNiz)
*}



FUNCTION BrDecimala(cFormat)
*{
 LOCAL i:=0,cPom,nVrati:=0
 i:=AT(".",cFormat)
 IF i!=0
   cPom:=ALLTRIM(SUBSTR(cFormat,i+1))
   FOR i:=1 TO LEN(cPom)
     IF SUBSTR(cPom,i,1)=="9"
       nVrati+=1
     ELSE
       EXIT
     ENDIF
   NEXT
 ENDIF
RETURN nVrati
*}

/*! \fn StrKZN(cInput,cIz,cU)
 *  \brief Konverzija znakova u stringu
 *  \todo Prebaciti u /sclib ili ... (ovdje definitivno ne pripada)
 *  \param cInput
 *  \param cIz
 *  \param cU
 *  \return cInput
 */
 
function StrKZN(cInput,cIz,cU)
*{
LOCAL a852:={"æ","Ñ","¬","","¦","ç","Ð","Ÿ","†","§"}
 LOCAL a437:={"[","\","^","]","@","{","|","~","}","`"}
 LOCAL aEng:={"S","D","C","C","Z","s","d","c","c","z"}
 LOCAL i:=0, aIz:={}, aU:={}
 aIz := IF( cIz=="7" , a437 , IF( cIz=="8" , a852 , aEng ) )
 aU  := IF(  cU=="7" , a437 , IF(  cU=="8" , a852 , aEng ) )
 FOR i:=1 TO 10
   cInput:=STRTRAN(cInput,aIz[i],aU[i])
 NEXT
return cInput
*}


/*! \fn Slovima(nIzn,cDinDem)
 *  \brief Ispisuje iznos slovima
 *  \param nIzn       - iznos
 *  \param cDinDem    - 
 */
 
function Slovima(nIzn,cDinDem)
*{
local npom; cRez:=""
fI:=.f.

if nIzn<0
  nIzn:=-nIzn
  cRez:="negativno:"
endif

if (nPom:=int(nIzn/10**9))>=1
   if nPom==1
     cRez+="milijarda"
   else
     Stotice(nPom,@cRez,.f.,.t.,cDinDEM)
      if right(cRez,1) $ "eiou"
        cRez+="milijarde"
      else
        cRez+="milijardi"
     endif
   endif
   nIzn:=nIzn-nPom*10**9
   fi:=.t.
endif
if (nPom:=int(nIzn/10**6))>=1
   //if fi; cRez+="i"; endif
   if fi; cRez+=""; endif
   fi:=.t.
   if nPom==1
     cRez+="milion"
   else
     Stotice(nPom,@cRez,.f.,.f.,cDINDEM)
     cRez+="miliona"
   endif
   nIzn:=nIzn-nPom*10**6
   f6:=.t.
endif
if (nPom:=int(nIzn/10**3))>=1
   //if fi; cRez+="i"; endif
   if fi; cRez+=""; endif
   fi:=.t.
   if nPom==1
     cRez+="hiljadu"
   else
     Stotice(nPom,@cRez,.f.,.t.,cDINDEM)
     if right(cRez,1) $ "eiou"
       cRez+="hiljade"
     else
       cRez+="hiljada"
     endif
   endif
   nIzn:=nIzn-nPom*10**3
endif
//if fi .and. nIzn>=1; cRez+="i"; endif
if fi .and. nIzn>=1
	cRez+=""
endif
Stotice(nIzn,@cRez,.t.,.t.,cDINDEM)

return
*}


/*! \fn Stotice(nIzn, cRez, fDecimale, fMnozina, cDinDem)
 *  \brief Formatira tekst ako iznos prelazi 100
 *  \param nIzn       - iznos
 *  \param cRez
 *  \param fdecimale
 *  \param fMnozina
 *  \param cDinDem
 *  \return cRez
 */
 
static function Stotice(nIzn, cRez, fDecimale, fMnozina, cDinDem)
*{
local fDec,fSto:=.f.,i

   if (nPom:=int(nIzn/100))>=1
      aSl:={ "stotinu", "dvijestotine", "tristotine", "~etiristotine",;
             "petstotina","{eststotina","sedamstotina","osamstotina","devetstotina"}
      if gKodnaS=="8"
        for i:=1 to len(aSL)
          aSL[i]:=KSTo852(aSl[i])
        next
      endif
      cRez+=aSl[nPom]
      nIzn:=nIzn-nPom*100
      fSto:=.t.
   endif

   fDec:=.f.
   do while .t.
     if fdec
        cRez+=alltrim(str(nizn,2))
     else
      if int(nIzn)>10 .and. int(nIzn)<20
        aSl:={ "jedanaest", "dvanaest", "trinaest", "~etrnaest",;
               "petnaest","{esnaest","sedamnaest","osamnaest","devetnaest"}

        if gKodnaS=="8"
          for i:=1 to len(aSL)
            aSL[i]:=KSTo852(aSl[i])
          next
        endif
        cRez+=aSl[int(nIzn)-10]
        nIzn:=nIzn-int(nIzn)
      endif
      if (nPom:=int(nIzn/10))>=1
        aSl:={ "deset", "dvadeset", "trideset", "~etrdeset",;
               "pedeset","{ezdeset","sedamdeset","osamdeset","devedeset"}
        if gKodnaS=="8"
          for i:=1 to len(aSL)
            aSL[i]:=KSTo852(aSl[i])
          next
        endif
        cRez+=aSl[nPom]
        nIzn:=nIzn-nPom*10
      endif
      if (nPom:=int(nIzn))>=1
         aSl:={ "jedan", "dva", "tri", "~etiri",;
                "pet","{est","sedam","osam","devet"}
         if gKodnaS=="8"
          for i:=1 to len(aSL)
            aSL[i]:=KSTo852(aSl[i])
          next
         endif
        if fmnozina
             aSl[1]:="jedna"
             aSl[2]:="dvije"
        endif
        cRez+=aSl[nPom]
        nIzn:=nIzn-nPom
      endif
      if !fDecimale; exit; endif

     endif // fdec
     if fdec; cRez+="/100 "+cDINDEM; exit; endif
     fDec:=.t.
     fMnozina:=.f.
     nizn:=round(nIzn*100,0)
     if nizn>0
       if !empty(cRez)
           cRez+=" i "
       endif
     else
       if empty(cRez)
          cRez:="nula " + cDINDEM
       else
          cRez+=" "+cDINDEM
       endif
       exit
     endif
   enddo


return cRez
*}



/*! \fn CreateHashString(aColl)
 *  \brief Kreira hash string na osnovu podataka iz matrice aColl
 *  \brief primjer: aColl[1] = "podatak1"
 	            aColl[2] = "podatak2"
		    CreateHashString(aColl) => "podatak1#podatak2"
 *  \param aColl - matrica sa podacima
 *  \return cHStr - hash string
 */
function CreateHashString(aColl)
*{
cHStr:=""

// Ako je duzina matrice 0 izadji
if LEN(aColl)==0
	return cHStr
endif

for i:=1 to LEN(aColl)
	cHStr += aColl[i]
	if (i <> LEN(aColl))
		cHStr += "#"
	endif
next

return cHStr
*}

/*! \fn ReadHashString(cHashString)
 *  \brief Iscitava hash string u matricu
 *  \return aColl - matrica popunjena podacima iz stringa
 */
function ReadHashString(cHashString)
*{
if LEN(cHashString)==0
	cHashString:=""
endif

aColl:={}
aColl:=TokToNiz(cHashString, "#")

return aColl
*}


/*! \fn StrToArray(cStr, nLen)
 *  \brief Kreiraj array na osnovu stringa
 *  \param cStr - string
 *  \param nLen - na svakih nLen upisi novu stavku u array 
 */
function StrToArray(cStr, nLen)
*{
aColl:={}
cTmp:=""
cStr:=ALLTRIM(cStr)

if (LEN(cStr) < nLen)
	AADD(aColl, cStr)
	return aColl
endif

nCnt:=0

for i:=1 to LEN(cStr)
	nCnt++
	cTmp+=SUBSTR(cStr, i, 1)
	if (nCnt==nLen .or. ((nCnt<nLen) .and. i == LEN(cStr)))
		AADD(aColl, cTmp)
		nCnt:=0
		cTmp:=""
	endif
next

return aColl
*}


/*! \fn FlushMemo(aMemo)
 *  \brief Vraca vrijednost memo niza u string
 */
function FlushMemo(aMemo)
*{
local i, cPom
cPom:=""
cPom += Chr(16)
for i:=1 to LEN(aMemo)
	cPom += aMemo[i]
	cPom += Chr(17)
	cPom += Chr(16)
next 

return cPom
*}


// -------------------------------------
// -------------------------------------
function show_number(nNumber, cPicture, nExtra)
local nDec
local nLen
local nExp
local i

if nExtra <> NIL
	nLen := ABS(nExtra)

else
	nLen := LEN(cPicture)
endif


if cPicture == nil
	nDec = kolko_decimala( nNumber )
else
	// 99999.999"
	//     AT(".") = 6
	// LEN 9
	 
	nDec:=AT(".", cPicture)

	if nDec > 0
        	//  nDec =  9  - 6  = 3
		nDec := nLen - nDec 
	endif

endif

// max velicina koja se moze prikazati sa ovim picture
// 5  =  9 - 3 - 1  => 10 ^ 5
// 
nExp := nLen - nDec - 1

//     0  -> 3
for i:=0 to nDec
  // nNum 177 000  < 10**5 -1 = 100 000 - 1 = 99 999
  if nNumber/(10**i) < (10**(nExp)-1)
  	if i=0
		if cPicture == nil
			return STR(nNumber, nLen, nDec)
		else
			return TRANSFORM(nNumber, cPicture)
		endif
	else
		return STR(nNumber, nLen, nDec - i)
	endif
  endif
next

return REPLICATE("*", nLen)

// ---------------------------------
// ---------------------------------
static function kolko_decimala( nNumber)
local nDec
local i

// prepostavka da je maximalno 4
nDec := 4

// nadji broj potrebnih decimala
for i:=0 to 4
	if ROUND(nNumber, i) == ROUND(nNumber, nDec)
		return i
 	endif
next

return nDec

