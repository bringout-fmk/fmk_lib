#include "sc.ch"

// -----------------------------------------------------------------------
* F-ja vraca novu sifru koju odredjuje uvecavanjem postojece po sljedecem
* principu: Provjeravaju se znakovi pocevsi od posljednjeg i dok god je
* znak cifra "9" uzima se sljedeci znak, a "9" se mijenja sa "0". Ukoliko
* provjeravani znak nije "9", zamjenjuje se sa znakom ciji je kod veci za 1
* i zavrsava se sa pravljenjem sifre tj. neprovjeravani znakovi ostaju isti.
// -----------------------------------------------------------------------
function NovaSifra(cSifra)

local i:=0
local cPom, cPom2

if EMPTY(cSifra)
   cSifra := STRTRAN(cSifra, " ", "0")
endif

//altd()
for i := LEN(cSifra) TO 1 STEP -1

   if (cPom := substr(cSifra, i, 1)) < "9"
     //if i==1
     //  cSifra:=STUFF(cSifra, i, 1, novi_znak_extended(cPom))
     //endif
       cSifra:=STUFF(cSifra, i, 1, CHR(ASC(cPom) + 1))
     //endif
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

