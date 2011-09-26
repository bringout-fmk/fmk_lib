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


#include "SC.ch"

/****h SC_CLIB/SC_QL ***
* 
*AUTOR
  Ernad Husremovic, ernad@sigma-com.net

*IME 
 SIGMA-COM Query language (jezik za pretrazivanje  tabela) 

*OPIS
   Elementi query jezika:
         (  )                     //  zagrade 
         .I.   .ILI.  ;           // i izraz, ili izraz
         $  < >  >=  <=  #  --    // in, manje, vece, vece ili jednake, manje ili jednako
         .S.LM??3*;               // like izraz

*DATUM
  04.2002

****/



static aOperators:={"#",">=",">","<",">","<>","!=","$","--","*","?"}
static aTokens:={ ";"    , ".I."   , ".ILI."}
static aToken2:={ ".or." , ".and." , ".or." }

/*!
 @function   Parsiraj
 @abstract   Vraca filter
 @discussion -
 @param      cSifra  "12;13"
 @param      cImeSifre "Idroba"
*/

function Parsiraj(cSifra,cImeSifre,cTip,fR, nSifWA)
* fR - rekurzivni poziv
* cizraz vraca karakterni izraz za navedeno
* nSifWA: npr. F_ROBA
local cStartSifra,cOperator,nPoz1,nPos,nPoz1End, nsiflen

local cVeznik:="",cToken:="", cIddd

if fr=NIL; fR:=.f.; endif  // rekurzivni poziv

if upper(cImeSifre)="IDROBA"  .and. right(trim(cSifra),1)=="*" // ovo cemo sada ovako staviti

  PushWa()  // moram otici u sifrarnik robe
  select roba
  cSifra:=trim(cSifra)
  cSifra:=substr(cSifra,1,len(cSifra)-1)
  SetSifFilt(cSifra)  // postavi filter u sifrarniku
  set filter to
  PopWA()
  return ".t."   // samo markirana roba
endif

if !fr
 cStartSifra:=cSifra
endif

if  nSifWA<>NIL .and. right(trim(csifra),1)<>";" .and. !fr
 if !empty(cSifra) 
  nPos:=ATToken(cSifra,";")  //  12121;21212;1A -> 1A
  nsiflen:=len(cSifra)
  pushwa()
  select (nSifWA)
  if nPos<>0
    cIddd:=padr(substr(cSifra,nPos), len(id))
    cSifra:=left(cSifra,nPos-1)
  else
    cIddd:=padr(cSifra,len(id))
    cSifra:=""
  endif
  set order to tag "ID"
  private ImeKol:={ { "ID  ",  {|| id},    "id"    },;
                   { "Naziv:", {|| naz},  "naz"     } }
  private Kol:={1,2}
  PostojiSifra(nsifWA,1,10,77,"Odredi sifru:",@cIddd)
  cSifra:= cSifra + cIddd+";"
  csifra:=padr(cSifra,nSiflen)
  PopWa()
  return NIL
 else
  return NIL
 endif
endif

cIzraz:=""
if cTip==NIL;  cTip:="C";  endif
cSifra:=TRIM(cSifra)
nLen:=LEN(cSifra)

 do while nLen>0
    cProlaz:=""
    if left(cSifra,1)<>"#"  // ove izraze ne razbijaj
     Zagrade(@cSifra,@nPoz1,@nPoz1end)
    else
     nPoz1:=0
     nPoz1End:=0
    endif
    // (>10.I.<11);
    if nPoz1>0 .and. nPoz1End>nPoz1

      cLijevo:=substr(cSifra,1,nPoz1-1)
      cDesno:= Substr(cSifra,nPoz1+1,nPoz1end-nPoz1-1)
      cIza:=   substr(cSifra,nPoz1end+1)

      if !empty(clijevo)
         VeznikRight(@cLijevo,@cVeznik)
         cIzraz+=Parsiraj(cLijevo,cImeSifre,cTip,.t.) + cVeznik
      endif
      cIzraz+="("

      VeznikRight(@cDesno,@cVeznik)
      cIzraz+=Parsiraj(cDesno,cImeSifre,cTip,.t.)
      cIzraz+=")"

      if !empty(cIza)
       VeznikLeft(@cIza,@cVeznik)
       cIzraz+=cVeznik
       cIzraz+=Parsiraj(cIza,cImeSifre,cTip,.t.)
      endif

      cSifra:="" // sve je rijeseno
      cProlaz:="("
    endif

    if npoz1=-999
       cProlaz:="DE"
    endif

    cOperator:=PrviOperator(cSifra,@nPoz1)
    if cOperator=="#"
      if empty(cProlaz) .and. nPoz1>0
        nPoz1end:=Nexttoken(@cSifra,@cToken)
        cDesno:=Substr(cSifra,nPoz1+1,nPoz1end-nPoz1-1)
        cSifra:=substr(cSifra,nPoz1End+1)
        cIzraz+= cDesno
        cProlaz+="#"
      endif
    endif

    if cOperator $ "< > >= <= <> !=" .and. empty(cProlaz) .and. npoz1>0
      nPoz1end:=NextToken(@cSifra,@cToken)
      cDesno:=Substr(cSifra,nPoz1+1,nPoz1end-nPoz1-len(cOperator))
      do case
       case cTip=="C"
        cIzraz+=cImeSifre+cOperator+"'"+cDesno+"'"
       case cTip=="N"
        cIzraz+=cImeSifre+cOperator+cDesno
       case cTip=="D"
        cIzraz+=cImeSifre+cOperator+"CTOD('"+cDesno+"')"
//        cIzraz+="DTOS("+cImeSifre+")"+cOperator+"DTOS(CTOD('"+cDesno+"'))"
      endcase
      cSifra:=substr(cSifra,nPoz1End+len(cOperator))
      cProlaz+=cOperator
    endif

    if cOperator=="--" .and. empty(cProlaz) .and. npoz1>0
      nPoz1end:=NextToken(@cSifra,@cToken)
      cLijevo:=LEFT(cSifra,nPoz1-1)
      cDesno:=Substr(cSifra,nPoz1+2,nPoz1end-nPoz1-2)
      do case
       case cTip=="C"
        cIzraz+="("+cImeSifre+">='"+cLijevo+"'.and."+cImeSifre+"<='"+cDesno+"')"
      case cTip=="N"
        cIzraz+="("+cImeSifre+">="+cLijevo+".and."+cImeSifre+"<="+cDesno+")"
       case cTip=="D"
        cIzraz+="("+cImeSifre+">=CTOD('"+cLijevo+"').and."+cImeSifre+"<=CTOD('"+cDesno+"'))"
//        cIzraz+="(DTOS("+cImeSifre+")>=DTOS(CTOD('"+cLijevo+"')).and.DTOS("+cImeSifre+")<=DTOS(CTOD('"+cDesno+"')))"
      endcase
//      cSifra:=substr(cSifra,nPoz1End+2)  // BUG otkl.6.7.99.
      cSifra:=substr(cSifra,nPoz1End+1)
      cProlaz+="O"
    endif

    if cOperator=="$" .and. empty(cProlaz) .and. npoz1>0
      nPoz1end:=NextToken(@cSifra,@cToken)
      cLijevo:=LEFT(cSifra,nPoz1-1)
      cDesno:=Substr(cSifra,nPoz1+1,nPoz1end-nPoz1-1)
      if cTip=="C"
        cIzraz+="'"+ cDesno+"'$"+cImeSifre
      else
        cProlaz:="DE"  // Data error
      endif
      cSifra:=substr(cSifra,nPoz1End+1)
      cProlaz+="$"
    endif

    if cOperator $ "*?" .and. empty(cProlaz) .and. npoz1>0
      nPoz1:=1
      nPoz1end:=NextToken(@cSifra,@cToken)
      cLijevo:=LEFT(cSifra,nPoz1End-1)
      if cTip=="C"
        cIzraz+="LIKE('"+cLijevo+"',"+cImeSifre+")"
      else
        cProlaz:="DE"  // Data error
      endif
      cSifra:=substr(cSifra,nPoz1End+1)
      cProlaz+="?"
    endif

    if cOperator=="" .and. cProlaz=="" // nista od gornjih operatora
     nPoz1:=NextToken(@cSifra,@cToken)
     if nPoz1>0
       cLijevo:=LEFT(cSifra,nPoz1-1)
       do case
        case cTip=="C"
         cIzraz+=cImeSifre+"='"+clijevo+"'"
        case cTip=="N"
         cIzraz+=cImeSifre+"=="+clijevo
        case cTip=="D"
         cIzraz+=cImeSifre+"==CTOD('"+clijevo+"')"
       endcase
       cSifra:=substr(cSifra,nPoz1+1)
       cProlaz:="V"
     endif
    endif

    if cProlaz=="" .or. left(cProlaz,2)="DE"
      MsgO("Greska u sintaksi !!!")
      Beep(4)
      DO WHILE NEXTKEY()==0; OL_YIELD(); ENDDO
      INKEY()
      // Inkey(0)
      MsgC()
      return NIL
    else
     if !empty(cSifra) // vezni izraz
         cIzraz+=cToken
     endif
     nLen:=LEN(cSifra)
    endif

 enddo

if !empty(cizraz)
 if !fr // nije rekurzivni poziv
   cIzraz:="("+cizraz+")"
   cSifra:=cStartSifra
   return cizraz
 endif
else
 return ".t."
endif


function PrviOperator(cSifra,nPoz1)

local i
local cRet:=""
nPoz1:=999
for i:=1 to len(aOperators)
 nPom:=at(aOperators[i],cSifra)
 if npom>0 .and. nPom<nPoz1
   nPoz1:=nPom
   cRet:=aOperators[i]
  endif
next
for i:=1 to len(aTokens) // veznici
 nPom:=at(aTokens[i],cSifra)
 if npom>0 .and. nPom<nPoz1
   nPoz1:=1  // ispred svih operatora nalazi se veznik .i. .ili ;
   cRet:=""
  endif
next
return cRet  // npr "$"




function  Zagrade(cSifra,nPoz1,nPoz1end)
*
*  cSifra = 930239(3332('3232323))

local i,nBracket
nPoz1:=AT("(",cSifra)
if nPoz1=0
  nPoz1End:=0
  return
endif
nBracket:=1
for i:=npoz1+1 to len(cSifra)
  if substr(cSifra,i,1)==")"
     nBracket--
  endif
  if nBracket==0
     nPoz1End:=i
     exit
  endif
  if substr(cSifra,i,1)=="("
     nBracket++
  endif
next
if nBracket<>0  //greska u sintaksi
  nPoz1   :=999
  nPoz1End:=999
endif
if substr(cSifra,nPoz1End+1)=";" 
   cSifra:=left(cSifra,npoz1End)+substr(cSifra,npoz1End+2)
endif
return NIL



function VeznikRight(cLijevo,cVeznik)
*  456.I. -> 456;  cVeznik:=".and."

if right(cLijevo,1)==";"
   cVeznik:=".or."
endif
if right(cLijevo,3)==".I."
   cVeznik:=".and."
   cLijevo:=left(cLijevo,len(clijevo)-3)+";"
endif
if right(cLijevo,5)==".ILI."
   cVeznik:=".or."
   cLijevo:=left(cLijevo,len(clijevo)-5)+";"
endif
if right(cLijevo,1)<>";" .and. right(cLijevo,1)<>")"
   cLijevo+=";"  // dodaj ; da izraz bude regularan
endif
if right(clijevo,2)==");"
  cLijevo:=left(clijevo,len(clijevo-1))
endif


function VeznikLeft(cIza,cVeznik)
*
*  .I.456;  ->  456;   cVeznik:=".and."

if left(cIza,1)==";"
   cVeznik:=".or."
   cIza:=substr(cIza,2)
endif
if left(cIza,3)==".I."
   cVeznik:=".and."
   cIza:=substr(cIza,4)
endif
if left(cIza,5)==".ILI."
   cVeznik:=".or."
   cIza:=substr(cIza,6)
endif
if right(cIza,1)<>";" .and. right(cIza,1)<>")"
   cIza+=";"  // dodaj ; da izraz bude regularan
endif
if right(ciza,2)==");"
  ciza:=left(ciza,len(ciza-1))
endif


function NextToken(cSif,cVeznik)
*
*

local i:=0, npoz:=9999, npom:=0, iTek

for i:=1 to len(aTokens)
 nPom:=AT(aTokens[i],upper(cSif))
 if nPom>0 .and. nPom<nPoz
  nPoz:=nPom
  cVeznik:=aToken2[i]
  itek:=i
 endif
next

if nPoz=9999;  nPoz:=0; endif

if nPoz<>0
 cSif:=left(cSif,nPoz-1)+";"+substr(cSif,nPoz+len(aTokens[itek]))
endif
return nPoz




function Tacno(cizraz)
*

private cPom
cPom:=cIzraz
return &cPom



function TacnoN(cIzraz,bIni,bWhile,bSkip,bEnd)
*
*

local i,fRez:=.f.

private cPom

if cizraz=".t."
  return .t.
endif

EVAL(bIni)

do while EVAL(bWhile)
 fRez:=&cIzraz
 EVAL(bSkip)
enddo

Eval(bEnd)
return fRez


function SkLoNMark(cSifDBF, cId)
*{
nArea:= select()
select (cSifDBF)
HSEEK cID
select (nArea)
if ((cSifDBF)->_M1_ <> "*")
  return .t.
endif
return .f.
*}
