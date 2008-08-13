
// -----------------------------------------------------------------------
* F-ja vraca novu sifru koju odredjuje uvecavanjem postojece po sljedecem
* principu: Provjeravaju se znakovi pocevsi od posljednjeg i dok god je
* znak cifra "9" uzima se sljedeci znak, a "9" se mijenja sa "0". Ukoliko
* provjeravani znak nije "9", zamjenjuje se sa znakom ciji je kod veci za 1
* i zavrsava se sa pravljenjem sifre tj. neprovjeravani znakovi ostaju isti.
// -----------------------------------------------------------------------

function NovaSifra(cSifra)

local i:=0
local cPom
local cPom2

// "    " => "0000"
if empty(cSifra)
 cSifra:=STRTRAN(cSifra," ","0")
endif

? chr(138), chr(142), chr(198), chr(200), chr(208)
inkey(0)

FOR i:=len(cSifra) to 1 step -1


   // kod na prvoj poziciji
   if (i==1)
        if cPom == "A"
	   cPom2 := "9"
        elseif cPom == "Z"
	   cPom2 := CHR(138)
	elseif cPom == CHR(142)
	   cPom2 := CHR(142)
	elseif cPom == CHR(198)
	   cPom2 := CHR(198)
	elseif cPom == CHR(200)
	   cPom2 := CHR(208)
	elseif cPom == CHR(208)
	   // iscripio sam sva slova :(
	   cPom2 := "0"
	else
            cPom2 := CHR( ASC(cPom) + 1 )
        endif

        cSifra:=STUFF(cSifra, i, 1, cPom2)
        exit
   endif

   

   // ako sam pocetna sifra  ne pocinje sa "9"
   if (cPom:=SUBSTR(cSifra, i, 1)) <> "9"
     cSifra:=STUFF(cSifra, i, 1,  CHR(ASC(cPom)+1 ) )
     EXIT
   endif

   
NEXT

RETURN cSifra

