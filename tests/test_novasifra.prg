
function test_novasifra()
local cSifra
local aSifre := {  "0000", "9999", "B000", "B999", "Z999",  chr(143) + "150", chr(143) + "999", chr(166) + "999", chr(172) + "999", chr(209)+"999", chr(230)+"999", "X999" }

? procname()
? "-------------------------------------------"
for i := 1 to LEN(aSifre)
 cSifra := aSifre[i]

 cNovaSifra := NovaSifra(cSifra)
 ? cSifra, "novasifra=", cNovasifra 
 ?? " asc stara" , ASC(LEFT(cSifra,1)), "asc nova=",  ASC(LEFT(cNovasifra,1)) 

next

