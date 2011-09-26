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



/****h SC_CLIB/TIME_UT ***
* 
*AUTOR
  Ernad Husremovic, ernad@sigma-com.net

*IME 
  TIME_UT

*OPIS
  Fukcije za rad za operacije nad VRIJEME, DATUM varijabama


*DATUM
  04.2002

****/


function InRange(xVar,xPoc,xKraj)
if VALTYPE(xVar)=="D"
  xPoc=CTOD(xPoc);xKraj:=CTOD(xKraj)
endif
return (xVar >= xPoc  .and. xVar <= xKraj)


function DInRange(dDat,d1,d2)
return  ( dDat>=d1 .and. dDat<=d2 )



* opseg
function GMJD(nBrdana)
local ostatak, godina,mjeseci,dana
godina= (nBrDana/365.125)
ostatak=nBrDana % 365.125
mjeseci=(ostatak / 30.41)
ostatak=ostatak % 30.41
dana=round(ostatak,0)
godina:=int(godina)
mjeseci:=int(mjeseci)
if dana==30; dana:=0; mjeseci++; endif
if mjeseci==13; mjeseci:=0; godina++; endif
return {godina,mjeseci,dana}


* god,mj,dana ->

function GMJD2N(god,mj,dana)
return god*365.125+mj*30.41+dana


* datum1 - manji datum, datum2 - ve}i datum
function GMJD2(dDat1,dDat2)
return {year(dDat1)-year(dDat2), month(dDat1)-month(dDat2),  day(dDat1)-day(dDat2)}


function ADDGMJD(aRE,aRB)
local nPom
local aRU:={0,0,0}

nPom:=aRE[3]+aRB[3]
if nPom>30
  aRU[3]:=nPom%30 // dana
  aRU[2]+=int(nPom/30)
else
  aRU[3]:=nPom
endif

aRU[2]+=aRE[2]+aRB[2]

if aRU[2]>11
    aRU[1]+=INT(aRu[2]/12)
    aRU[2]:=aRU[2]%12
endif

aRU[1]+=aRE[1]+aRB[1]

return aRU
