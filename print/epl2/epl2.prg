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

// parametri
static par_1 
static par_2
static par_3
static par_4

static last_nX
static last_nY
#DEFINE EPL2_DOT 7.8



// --------------------------------------------------
// print string
// nRotate - 0 - bez rotiranja, 3 - 270 stepeni
// nInvert - 0 - ne invertuj background, 1 - invert
// nFontSize - 1 - najmanji, 5 - najveci
// --------------------------------------------------
function epl2_string( nX, nY, cString, lAbsolute, nFontSize, nRotate, nInvert)
local cStr
local cVelicina
// povecanje u procentima  proreda
local nRowDelta := 0

if nRotate == nil
	nRotate := 0
endif

if nInvert == nil
	nInvert := 0
endif

if lAbsolute == nil
	lAbsolute := .t.
endif

if nFontSize == nil
	nFontSize := 2
endif

// F+1Ernad Husremovic idev fontom vecim za 1 u odnosu na tekuci
if LEFT(cString, 2) == "F+"
	cVelicina := SUBSTR(cString, 3, 1)
	nFontSize += VAL(cVelicina)
	// prored mora biti 30% veci
	nRowDelta := 30
	cString := SUBSTR(cString, 4)
endif

// F-1Ernad Husremovic idev fontom manjim za 1 u odnosu na tekuci
if LEFT(cString, 2) == "F-"
	cVelicina := SUBSTR(cString, 3, 1)
	nFontSize -= VAL(cVelicina)
	// prored mora biti 30% manji
	nRowDelta := -30
	cString := SUBSTR(cString, 4)
endif

if !lAbsolute
	nX := last_nX + nX
	nY := ROUND(last_nY + nY * (100 + nRowDelta)/100, 0)
else
	// ako je apsolutno zadano onda ne mogu napraviti povecanje
endif

last_nX:=nX
last_nY:=nY

cStr := "A"+ALLTRIM(STR(nX,0)) + ","
cStr += ALLTRIM(STR(nY,0)) + ","
cStr += ALLTRIM(STR(nRotate,0)) + ","
cStr += ALLTRIM(STR(nFontSize,0)) + ","
// horizontal multiplexer
cStr += ALLTRIM(STR(1,0)) + ","
// vertical multiplexer
cStr += ALLTRIM(STR(1,0)) + ","
if nInvert == 0
	cStr += "N"
else
	cStr += "R"
endif
cStr += ","

// " => \"
cString:=STRTRAN(cString, '"', '\"')
cStr += '"' + cString + '"'

? cStr

// -----------------------------------
// label width
// -----------------------------------
function epl2_f_width(nMM)
? 'q'+ ALLTRIM(STR( mm2dot(nMM), 0))
return

// ---------------------------
// setuj gornju i lijevu marginu
// ---------------------------
function epl2_f_init(nX, nY)
last_nX := nX
last_nY := nY
return


// -----------------------------------
// start novu formu
// -----------------------------------
function epl2_f_start(nKolicina)
? 'N'
return

// -----------------------------------
// print formu
// -----------------------------------
function epl2_f_print(nKolicina)
if nKolicina == nil
	nKolicina:=1
endif
? 'P'+ ALLTRIM(STR( ROUND(nKolicina, 0), 0))
return


// --------------------------------
// --------------------------------
function dot2mm(nDots)
return ROUND(nDots / EPL2_DOT, 0)

// --------------------------------
// --------------------------------
function mm2dot(nMM)
return ROUND(nMM * EPL2_DOT, 0)


// --------------------------------
// --------------------------------
function epl2_cp852()
? 'I8,2,049'
return

// --------------------------
// start print na EPL2 
// --------------------------
function epl2_start()

last_nX := 0
last_nY := 0

par_1 := gPrinter
par_2 := gcDirekt
par_3 := gPTKonv
par_4 := gKodnaS

// uzmi parametre iz printera "L"
SELECT F_GPARAMS
if !used()
        O_GPARAMS
endif

//gcDirekt := "D"
gPrinter := "L"
gPTKonv := "0 "
gKodnaS := "8"

private cSection:="P"
private cHistory:=gPrinter
private aHistory:={}

RPar_Printer()

START PRINT CRET
return



// -------------------------------
// vrati standardne printer parametre
// -------------------------------
function epl2_end()

?
// zavrsi stampu
END PRINT

// vrati tekuce parametre
gPrinter := par_1
gcDirekt := par_2
gPTKonv := par_3
gKodnaS := par_4

SELECT F_GPARAMS
if !used()
        O_GPARAMS
endif

private cSection:="P"
private cHistory:=gPrinter
private aHistory:={}

RPar_Printer()

select gparams
use

return
