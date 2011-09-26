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

/****h SC_CLIB/SC_RPT ***
* 
*AUTOR
  Ernad Husremovic, ernad@sigma-com.net

*IME 

*OPIS


*DATUM
  04.2002

****/

function IniRPT()
*
* Definisi matrice report sistema
*

Public aTijelo:={}
Public aTijeloP:={}
Public aDetP:={}
Public aDetUsl:={}
Public aDetInit:={}
Public aDetEnd:={}
Public aDetCalc:={}
Public aDetFor:={}
Public aGH:={}
Public aGF:={}
Public aInitG:={}
Public aGHP:={}
Public aGFP:={}
Public aUslG:={}
Public aCalcG:={}

return



function R2(cImeDef,cOutf,bFor,nDuzSif)
*

local fpg,ng
IF nDuzSif==NIL; nDuzSif:=0; ENDIF

NBRG:=len(aInitG)
ASIZE(aGF,NBRG)
ASIZE(aGH,NBRG)


ProcitajRep(cImeDef)

fpg:=.f.
do while !eof() .and.  eval(bFor)

 for ng:=NBRG  to  1 step -1
   if eval(aUslG[ng]) .and. fPG
      skip -1
      Ispisi(ng,@aGF,@aGFP)
      skip
   endif
 next

 for ng:=1  to NBRG
   fPG:=.t.
   if eval(aUslG[ng])
      eval(aInitG[ng])
      Ispisi(ng,@aGH,@aGHP)
   endif
   EVAL(aCalcG[ng])
 next

 // sada idemo na tijelo
 PRIVATE nTekPT:=1
 for nT:=1 to len(aTijelo)
   if aTijelo[nT,1]=="&"
     IspisiT(nt,nDuzSif)
   elseif aTijelo[nT,1] $ "123"
     nDet:=val(aTijelo[nT,1])
     eval(aDetInit[nDet])
     cTekRed:=aTijelo[nT,2]
     IspisiD(nDet)
     eval(aDetEnd[nDet])
   endif
 next

 SKIP
enddo

if fpg  // ako je izvr{en prolaz kroz grupu
 for i:=NBRG to 1  step -1 // footer
   skip -1
   Ispisi(i,@aGF,@aGFP)
   skip
 next
endif

RETURN NIL



function Ispisi(nRedBr,aLinije,aPolja)
*
*
* za grupa header,footer

local i,nTekP,cTekRed,cC,nPreskoci

  NTEKP:=1
  NPRESKOCI:=0

  cTekRed:=aLinije[nRedBr]

  FOR I:=1 TO LEN(cTekRed)  // cTekRed je gornja varijabla
   IF NPRESKOCI==0
     CC:=SUBSTR(CTEKRED,I,1)
     IF CC=="#"
      XPOLJE:=TOSTR(   EVAL( (aPolja[nRedBr])[NTEKP++] )    )
       QQOUT(XPOLJE)
       NPRESKOCI:=LEN(XPOLJE)-1
     ELSE
      if cC<>"\"
       QQOUT(CC)
      endif
     ENDIF
   ELSE
     NPRESKOCI--
   ENDIF
  NEXT

return nil


function IspisiT(nRedBr,nDuzSif)
*
*  Ispisi tijelo

local i,cC,nPreskoci,nMemoLin,nLinPredh,fUMemu,nMemoLen
  NPRESKOCI:=0
  cTekRed:=aTijelo[nRedBr,2]
  nLinPredh:=1
  nMemoLin:=0
  fUMemu:=.f.
  FOR I:=1 TO LEN(cTekRed)  // cTekRed je gornja varijabla
   IF NPRESKOCI==0
     CC:=SUBSTR(CTEKRED,I,1)
     if cC==Chr(10)
      if fUMemu
       QQOUT(CHR(10))
       i:=nLinPredh
       LOOP
      else
       nLinPredh:=i
      endif
     endif
     IF CC=="#" .and. valtype(aTijeloP[NTEKPT])=="A"
      fUMemu:=.t.
      if nMemoLin==0
        xMemo:=EVAL(aTijeloP[NTEKPT,1])
        nMemoLen:=aTijeloP[NTEKPT,2]
        nMemoCount:=MLCOUNT(xMemo,nMemoLen)
        if nmemocount==0
         fUMemu:=.f.
         QQOUT(" ")
         NTEKPT++
        endif
      endif
      if nMemoLin<nMemoCount
        QQOUT(LEFT(memoline(xMemo,nMemoLen,++nMemoLin),nMemoLen))
        nPreskoci:=nMemoLen-1+nDuzSif
       if nMemoLin==nMemoCount
         fUMemu:=.f.
         nMemoLin:=0
         NTEKPT++
       endif
      endif
     ELSEIF CC=="#"
      XPOLJE:=TOSTR(   EVAL( aTijeloP[NTEKPT++] )    )
      QQOUT(XPOLJE)
       NPRESKOCI:=LEN(XPOLJE)-1+nDuzSif
     ELSE
      if cC<>"\"
       QQOUT(CC)
      endif
     ENDIF
   ELSE
     NPRESKOCI--
   ENDIF
  NEXT
RETURN



function IspisiD(nRedBr)
* Ispisi detalj

local i,nTekP,nLinPoc,cC,nPreskoci,nMemoLin,nLinPredh,fUMemu,nMemoLen

DO WHILE EVAL(aDetUsl[nRedBr])

if aDetFor[nRedBr]==NIL .or. eval(aDetFor[nRedBr])
  EVAL(aDetCalc[nRedBr])
  NTEKP:=1
  NPRESKOCI:=0
  nLinPredh:=1
  nMemoLin:=0
  fUMemu:=.f.
  FOR I:=1 TO LEN(cTekRed)  // cTekRed je gornja varijabla
   IF NPRESKOCI==0
     CC:=SUBSTR(CTEKRED,I,1)
     if cC==Chr(10)
      if fUMemu
       QQOUT(CHR(10))
       i:=nLinPredh
       LOOP
      else
       nLinPredh:=i
      endif
     endif

     IF CC=="#" .and. valtype(aDetP[nRedBr,NTEKP])=="A"
      fUMemu:=.t.
      if nMemoLin==0
        xMemo:=EVAL(aDetP[nRedBr,NTEKP,1])
        nMemoLen:=(aDetP[nRedBr,NTEKP])[2]
        nMemoCount:=MLCOUNT(xMemo,60)
        if nmemocount==0
         fUMemu:=.f.
         QQOUT(" ")
         NTEKP++
        endif
      endif
      if nMemoLin<nMemoCount
        QQOUT(memoline(xMemo,nMemoLen,++nMemoLin))
        nPreskoci:=nMemoLen-1
       if nMemoLin==nMemoCount
         nMemoLin:=0
         fUMemu:=.f.
         NTEKP++
       endif
      endif

     ELSEIF cC=="#"
      XPOLJE:=TOSTR(   EVAL( (aDetP[nRedBr])[NTEKP++] )    )
      QQOUT(XPOLJE)
        NPRESKOCI:=LEN(XPOLJE)-1
     ELSE
      if cC<>"\"
       QQOUT(CC)
      endif
     ENDIF

   ELSE
     NPRESKOCI--
   ENDIF
  NEXT
ENDIF // aDetFor

SKIP
ENDDO

return


FUNCTION ProcitajRep(cImef)
local nH:=FOPEN(cImeF)
local cBuf:=SPACE(512)
local nPreskoci:=0
local cTekRed:=""
local cTipL:="&",cTipL2
local cC:=""
do while .t.
   nB:=fread(nH,@cBuf,512)
   for i:=1 to nB
     if cC=="\"
      cC:="\"+substr(cBuf,i,1)
     else
      cC:=substr(cBuf,i,1)
     endif
     if len(cC)==2
      if cTipL<>cC
        if !empty(cTekRed)
         cTipL2:=Substr(cTipL,2,1)
         if ChSub(cTipL2,"a")>=0
           aGF[ChSub(cTipL2,"`")]:=cTekRed
         elseif ChSub(cTipL2,"A")>=0
           aGH[ChSub(cTipL2,"@")]:=cTekRed
         else
           AADD(aTijelo,{substr(cTipL,2,1),cTekRed})
         endif
        endif
        cTekRed:=""
        cTipL:=cC
      endif
     else
       if cC<>"\"
        cTekRed+=cC
       endif
     endif
   next
   if nB<512; exit; endif
enddo

if !empty(cTekRed)
 cTipL2:=Substr(cTipL,2,1)
 if ChSub(cTipL2,"a")>=0
   aGF[ChSub(cTipL2,"`")]:=cTekRed
 elseif ChSub(cTipL2,"A")>=0
   aGH[ChSub(cTipL2,"@")]:=cTekRed
 else
   AADD(aTijelo,{substr(cTipL,2,1),cTekRed})
 endif
endif
cTekRed:=""
cTipL:=cC
FCLOSE(nH)
RETURN


/*! \fn SetRptLineAndText(aLineArgs, nVariant)
 *  \brief vraca liniju po definisanoj matrici
 *  \param aLineArgs - matrica argumenata
 *  \param nVariant - varijanta, 0 - linija, 1 - prvi red izvjestaja, 2 - drugi red izvjestaja
 *  \example: aLineArgs := {2, 5, 5, 3}
 *            ret: -- ----- ----- --- 
 */
 
function SetRptLineAndText(aLineArgs, nVariant, cDelimiter)
*{

local cLine := ""

if nVariant == nil
	// po def. je linija	
	nVariant := 0
endif
if cDelimiter == nil
	cDelimiter := " "
endif

for i:=1 to LEN(aLineArgs)
	if nVariant == 0
		cLine += REPLICATE("-", aLineArgs[i, 1])
	elseif nVariant == 1
		nEmptyFill:=aLineArgs[i, 1] - LEN(aLineArgs[i, 2])
		cLine += aLineArgs[i, 2] + SPACE(nEmptyFill)	
	elseif nVariant == 2
		nEmptyFill:=aLineArgs[i, 1] - LEN(aLineArgs[i, 3])
		cLine += aLineArgs[i, 3] + SPACE(nEmptyFill)
	elseif nVariant == 3
		nEmptyFill:=aLineArgs[i, 1] - LEN(aLineArgs[i, 4])
		cLine += aLineArgs[i, 4] + SPACE(nEmptyFill)
	endif
		
	if i <> LEN(aLineArgs)
		if nVariant == 0
			cLine += " "
		else
			cLine += cDelimiter
		endif
	endif
next

return cLine
*}





