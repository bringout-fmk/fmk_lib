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

// -----------------------------------------------------------------------
* F-ja vraca novu sifru koju odredjuje uvecavanjem postojece po sljedecem
* principu: Provjeravaju se znakovi pocevsi od posljednjeg i dok god je
* znak cifra "9" uzima se sljedeci znak, a "9" se mijenja sa "0". Ukoliko
* provjeravani znak nije "9", zamjenjuje se sa znakom ciji je kod veci za 1
* i zavrsava se sa pravljenjem sifre tj. neprovjeravani znakovi ostaju isti.
// -----------------------------------------------------------------------
function NovaSifra( cSifra )

local i:=0
local cPom, cPom2

if EMPTY(cSifra)
   cSifra := STRTRAN(cSifra, " ", "0")
endif

for i := LEN(cSifra) TO 1 STEP -1

   if (cPom := substr(cSifra, i, 1)) < "9"
       cSifra:=STUFF(cSifra, i, 1, CHR(ASC(cPom) + 1 ))
     exit
   endif

   if i==1
     cPom2 := novi_znak_extended(cPom) 
   else
     cPom2 := "0"
   endif

   cSifra := stuff(cSifra, i, 1, cPom2)
next

RETURN cSifra


// -------------------------------------
// -------------------------------------
static function novi_znak_extended( cChar)

if cChar == "9"
    return "A"

elseif cChar == "Z"
    return chr(143)

elseif cChar == CHR(143)
    return chr(166)

elseif cChar == CHR(166)
    return chr(172)

elseif cChar == CHR(172)
    return chr(209)

elseif cChar == CHR(209)
    return chr(230)

elseif cChar == chr(230)
    return "?"
else
    return CHR(ASC(cChar) + 1)
endif


