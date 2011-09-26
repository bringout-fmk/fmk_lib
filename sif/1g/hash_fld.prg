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

// HASH FIELD funkcije
//
// primjer:
// ---------
// aStdVal := {}
// setovanje standardnih dozvoljenih opcija...
// AADD(aStdVal, {1, "opcija 1"})
// AADD(aStdVal, {2, "opcija 2"})
// AADD(aStdVal, {3, "opcija 3"})
//
// lBiloPromjena := .f.
// aVal := {}
//
// aVal := get_hash_field( table->field, aStdVal, @lBiloPromjena )
// if lBiloPromjena == .t.
//     scatter()
//     set_hash_field( table->_field, aVal )
//     gather()
// endif


// ----------------------------------------------------
// setovanje polja xField na osnovu matrice aHStrings
// forma aValsArr {} = [ val (n), opis (c) ]
// primjer: [1, "opis 1"] [2, "opis 2"] itd...
//
// params:
// xField - hash polje iz tabele
// aValsArr - matrica sa podacima
// cSeparator - separator "#", ";", "," itd..
// lSilent - .t. tihi nacin update-a, bez pitanja...
// ----------------------------------------------------
function set_hash_field(xField, aValsArr, cSeparator, lSilent)
local i
local cPom
local cDefSeparator := "#"

if lSilent == nil
	lSilent := .f.
endif

if !lSilent .and. pitanje(,"Snimiti promjene (D/N) ?", "D") == "N"
	return
endif

// provjeri velicinu...
if LEN(aValsArr) == 0
	return
endif

if cSeparator == nil
	cSeparator := cDefSeparator
endif

cPom := ""
for i:=1 to LEN(aValsArr)
	cPom += ALLTRIM(STR(aValsArr[i, 1]))
	cPom += cSeparator
next

xField := ALLTRIM(cPom)

return


// ----------------------------------------------
// vraca matricu napunjenu sa odabranim stavkama 
// iz aStdArr
//
// params:
// xField - hash polje iz tabele
// aStdArr - matrica sa dopustenim vrijednostima
// lChange - bilo promjena na matrici
// ----------------------------------------------
function get_hash_field(xField, aStdArr, lChange)
local nSvX
local nSvY
local aValArr := {}
local aTmp := {}
local nSelection := -99
local aOrigVal := {}

if ( lChange == nil )
	lChange := .f.
endif

if EMPTY( xField )
	// ako je prazno polje napuni matricu 
	// inicijalnim vrijednostima
	AADD(aValArr, { 0 , "-" })
else
	// iz polja uzmi vrijednosti
	// te uzmi opise iz aStdVals
	
	xField := ALLTRIM(xField)
	
	// napuni pomocnu matricu iz hash polja
	aTmp := toktoniz(xField, "#")
	
	// napuni matricu aRet sa konkretnim opisima iz
	// aStdArr na osnovu matrice iz polja...
	aValArr := ga_stdarr(aTmp, aStdArr)
endif

// kopiraj matricu ...
aOrigVal := ACLONE( aValArr )

do while nSelection == -99
	
	// snimi poziciju koordinata
	nSvX := m_x
	nSvY := m_y
	
	// otvori meni sa vrijednostima
	nSelection := m_val_arr(@aValArr, aStdArr)
	
	// vrati poziciju koordinata
	m_x := nSvX
	m_y := nSvY
enddo

// provjeri integritet - da li je bilo promjena
lChange := arr_changed(aOrigVal, aValArr)

return aValArr



// -----------------------------------------------
// Uporedjivanje matrica
// params:
// aArrOrig - originalna matrica
// aArr - matrica na kojoj su bile promjene
// -----------------------------------------------
static function arr_changed(aArrOrig, aArr)
local i

altd()

// uporedi velicine matrica
if LEN(aArrOrig) <> LEN(aArr)
	return .t.
endif

// uporedi clanove matrica
for i:=1 to LEN(aArrOrig)
	if aArrOrig[i, 1] <> aArr[i, 1]
		return .t.
	endif
	if aArrOrig[i, 2] <> aArr[i, 2]
		return .t.
	endif
next

return .f.



// ----------------------------------------------------
// vraca matricu napunjenu vrijednostima iz aStdVals
// 
// params:
// aFHashArr - matrica dobivena iz hash polja
//             "1#2#6#" = [1] [2] [6] ...
// aStdArr - matrica sa standarnim dozvoljenim
//           vrijednostima
// ----------------------------------------------------
static function ga_stdarr(aFHashArr, aStdArr)
local aRet := {}
local nPom
local nFndVal
local i

for i:=1 to LEN(aFHashArr)
	
	nFndVal := VAL( aFHashArr[i] )
	nPom := ASCAN(aStdArr, {|xVal| xVal[1] == nFndVal })
	
	if nPom <> 0
		AADD(aRet, { aStdArr[nPom, 1], aStdArr[nPom, 2] })
	endif
next

if LEN(aRet) == 0
	AADD(aRet, { 0 , "-" })
endif

return aRet


// -----------------------------------------
// crtanje menija sa hash vrijednostima
// -----------------------------------------
static function m_val_arr(aValArr, aStdArr)
local i
local cPom
// povratna vrijednost matrice
local nAReturn := 0
// povratna vrijednost funkcije
local nReturn := -99

private izbor := 1
private opc := {}
private opcexe := {}

for i:=1 to LEN(aValArr)
	
	if aValArr[i, 1] == 0
		// ako je stavka 0, onda treba dodavati stavke...
		cPom := PADC("c+N, nova stavka...", 30)
	else
		cPom := ALLTRIM(STR(aValArr[i, 1]))
		cPom += " - "
		cPom += PADR(aValArr[i, 2], 30)
	endif
	
	AADD(opc, cPom)
	AADD(opcexe, {|| val_key(@nAReturn, @aValArr, aStdArr, izbor), izbor := 0 })

next

Menu_SC("valarr")

if nAReturn == 0
	nReturn := 0
endif

return nReturn


// --------------------------------------
// obrada dogadjaja tipki na m_val_arr()
// --------------------------------------
static function val_key(nAReturn, aValArr, aStdArr, nIzbor)
// tekuci izbor
local nTIzbor := nIzbor
// akcija menija
local cAction

nIzbor := retitem(nTIzbor)
cAction := what_action(nTIzbor)

do case
	case cAction == "K_CTRL_N"
		// dodaj stavku u matricu
		add_val_item(@aValArr, aStdArr, nIzbor)
		nAReturn := -99
	case cAction == "K_CTRL_T"
		// brisi stavku iz matrice
		del_val_item(@aValArr, nIzbor)
		nAReturn := -99
	otherwise
		nAReturn := -99
endcase

return


// --------------------------------------------------- 
// Dodavanje stavke u matricu
// params:
// aValArr - matrica sa hash vrijednostima
// aStdArr - matrica sa mogucim dozvoljenim vrijednost
// nIzbor - tekuci odabir menija
// --------------------------------------------------- 
static function add_val_item(aValArr, aStdArr, nIzbor)
local nSelection := -99
local nFndVal
local nSvX
local nSvY

// snimi poziciju koordinata
nSvX := m_x
nSvY := m_y

// otvori menij standardnih vrijednosti
nSelection := m_std_arr(aStdArr)

// vrati poziciju koordinata nakon menija
m_x := nSvX
m_y := nSvY

if nSelection <> 0
	
	if ( LEN(aValArr) == 1 ) .and. ( aValArr[1, 1] == 0 )
		// reset matrice
		aValArr := {}
	endif
	
	// pretrazi da li vrijednost vec postoji u matrici
	nFndVal := ASCAN(aValArr, {|xVal| xVal[1] == nSelection })

	// ako ne postoji dodaj je
	if nFndVal == 0
		AADD(aValArr, { aStdArr[nSelection, 1], aStdArr[nSelection, 2] })
	else
		MsgBeep("Stavka vec postoji !!!")
	endif
endif

return


// --------------------------------------------------- 
// Brisanje stavke iz matrice
// params:
// aValArr - matrica hash vrijednosti
// nIzbor - tekuci izbor menija
// lSilent - tihi rezim rada, ne postavljaj pitanja
// --------------------------------------------------- 
static function del_val_item(aValArr, nIzbor, lSilent)
local aTmp := {}
local i

if ( lSilent == nil )
	lSilent := .f.
endif

if !lSilent .and. pitanje(,"Izbrisati stavku (D/N) ?", "D") == "D"
	
	// brisi stavku iz matrice
	ADEL( aValArr, nIzbor )
	
	// pobrisani zapisi su NIL
	// brisi nil zapise...
	
	for i:=1 to LEN(aValArr)
		// kopiraj u aTmp sve sto nije NIL
		if aValArr[i] <> nil
			AADD(aTmp, { aValArr[i, 1], aValArr[i, 2] })
		endif
		
	next
	
	// restore iz aTmp
	aValArr := aTmp
endif

return


// -------------------------------------------------------
// Crtanje menija sa standardnim dopustenim vrijednostima
// params:
// aStdArr - matrica sa dopustenim vrijednostima
//           [1, "val 1"] [2, "val 2"] ...
// -------------------------------------------------------
static function m_std_arr(aStdArr)
local i
local cPom
// povratna vrijenost matrice
local nAReturn := 0
// povratna vrijednost funkcije
local nReturn := -99

private izbor := 1
private opc := {}
private opcexe := {}

for i:=1 to LEN(aStdArr)
	
	// prvo numeric vrijednost
	cPom := ALLTRIM(STR(aStdArr[i, 1]))
	cPom += " - "
	cPom += PADR(aStdArr[i, 2], 30)
	
	AADD(opc, cPom)
	AADD(opcexe, {|| std_key(@nAReturn, izbor), izbor := 0 })

next

Menu_SC("stdarr")

if nAReturn > 0
	nReturn := aStdArr[nAReturn, 1]
endif

if nAReturn == 0
	nReturn := 0
endif

return nReturn


// ----------------------------------------------
// obrada dogadjaja tipke na meniju m_std_arr()
// ----------------------------------------------
static function std_key(nAReturn, nIzbor)
nAReturn := nIzbor		
return



