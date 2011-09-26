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


/*! \fn Test_StrUt()
 *  \brief TEST CASE string utility
 */
 
function Test_StrUt()
*{

// TC-STR-UT-1: kreiranje hash stringa
TestCreHashStr()
Inkey(0)
CLEAR SCREEN

// TC-STR-UT-2: citanja hash stringa
TestRdHashStr()
Inkey(0)
CLEAR SCREEN

// TC-STR-UT-3: kreiranje matrice iz stringa prema zadatoj duzini clana matrice
TestStr2Arr()
Inkey(0)
CLEAR SCREEN


return
*}


/*! \fn TestCreHashStrRW()
 *  \brief Test case kreiranja hash stringa
 */
function TestCreHashStr()
*{
? REPLICATE("-", 70)
? "TC-STR-UT-1: Create hash string"
? REPLICATE("-", 70)

aColl:={}
AADD(aColl, "JOVAN JOVANOVIC")
AADD(aColl, "IK BANKA")
AADD(aColl, "1032444233211")
AADD(aColl, "SUP BEOGRAD")

cRes:="JOVAN JOVANOVIC#IK BANKA#1032444233211#SUP BEOGRAD"

? 
? "Uporedjujem stringove...."
cHStr:=""
cHStr:=CreateHashString(aColl)

if (cHStr==cRes)
	?? "  [OK]"
else
	?? "  [FALSE]"
	? "Originalni hash string: " + cRes
	? "Generisani hash string: " + cHStr
endif

?
? "TEST CASE zavrsen...pritisni bilo koju tipku za nastavak..."


return
*}


/*! \fn TestRdHashStr()
 *  \brief Test case citanja hash stringa
 */
function TestRdHashStr()
*{

? REPLICATE("-", 70)
? "TC-STR-UT-2: Read hash string"
? REPLICATE("-", 70)

aResColl:={}
aGenColl:={}
AADD(aResColl, "JOVAN JOVANOVIC")
AADD(aResColl, "IK BANKA")
AADD(aResColl, "1032444233211")
AADD(aResColl, "SUP BEOGRAD")

cHStr:="JOVAN JOVANOVIC#IK BANKA#1032444233211#SUP BEOGRAD"
aGenColl:=ReadHashString(cHStr)

?
? "Uporedjujem duzine matrica: "

if LEN(aResColl) == LEN(aGenColl)
	?? " [OK]"
else
	?? " [FALSE]"
	? "Originalna matrica: " + STR(LEN(aResColl))
	? "Generisana matrica: " + STR(LEN(aGenColl))
endif

?
? "Uporedjujem elemente matrica: "

nCnt:=0
for i:=1 to LEN(aResColl)
	if aResColl[i] <> aGenColl[i]
	 	nCnt ++
		? "Razlika u elementu " + ALLTRIM(STR(i))
	endif
next

if nCnt == 0
	?? "  [OK]"
endif

?
? "TEST CASE zavrsen...pritisni bilo koju tipku za nastavak..."

return
*}


/*! \fn TestStr2Arr()
 *  \brief Test kreiranja niza iz stringa
 */
function TestStr2Arr()
*{

? REPLICATE("-", 70)
? "TC-STR-UT-3: String 2 Array"
? REPLICATE("-", 70)

cStr:="12345678901234567890" + REPLICATE("A", 20) + REPLICATE("B", 20) + REPLICATE("C", 10)
aTmp:={}
aTmp:=StrToArray(cStr, 20)
aRes:={}
AADD(aRes, "12345678901234567890")
AADD(aRes, "AAAAAAAAAAAAAAAAAAAA")
AADD(aRes, "BBBBBBBBBBBBBBBBBBBB")
AADD(aRes, "CCCCCCCCCC")

? 
? "Uporedjujem duzinu matrica ..."

if LEN(aRes) <> LEN(aTmp)
	? "Nije ista duzina matrica"
else
	?? "   [OK]"
endif

?
? "Uporedjujem elemente matrice ..."
for i:=1 to LEN(aRes)
	if aTmp[i] <> aRes[i]
		? "Generisano: " + aTmp[i]
		? "Originalno: " + aRes[i]
	else
		?? "  [OK]"
	endif
next

?
? "TEST CASE zavrsen...pritisni bilo koju tipku za nastavak..."

return
*}


