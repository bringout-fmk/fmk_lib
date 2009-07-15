#include "fmk.ch"

cKomLin += " "+PRIVPATH+"  barkod id"

run &cKomLin
return DE_CONT


// ------------------------------------------------------
// stampa rekapitulacije stara cijena -> nova cijena
// ------------------------------------------------------
function rpt_zanivel()
local nTArea := SELECT()
local cZagl
local cLine
local cRazmak := SPACE(1)
local nCnt

O_ROBA
select roba
set order to tag "ID"
go top

// ako ne postoji polje u robi, nista...
if roba->(fieldpos("zanivel")) == 0
	return
endif

cZagl := PADC("R.br", 6)
cZagl += cRazmak
cZagl += PADC("ID", 10)
cZagl += cRazmak
cZagl += PADC("Naziv", 20)
cZagl += cRazmak
cZagl += PADC("Stara cijena", 15)
cZagl += cRazmak
cZagl += PADC("Nova cijena", 15)

cLine := REPLICATE("-", LEN(cZagl))

START PRINT CRET

? "Pregled promjene cijena u sifrarniku robe"
?
? cLine
? cZagl
? cLine

nCnt := 0

do while !EOF()

	if field->zanivel == 0
		skip
		loop
	endif
	
	++ nCnt
	
	? PADL( STR( nCnt, 5) + ".", 6 ), PADR(field->id, 10), PADR(field->naz, 20), PADL( STR(field->mpc, 12, 2), 15 ), PADL( STR(field->zanivel, 12, 2), 15 )
	
	skip
	
enddo

FF
END PRINT

select (nTArea)

return