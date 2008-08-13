
function test_novasifra()
local cSifra
local aSifre := { "0000", "B000", "Z999" }

for i := 1 to LEN(aSifre)
 cSifra := aSifre[i]

 ? cSifra, NovaSifra(cSifra)
next

