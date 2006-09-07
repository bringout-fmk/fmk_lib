#include "sc.ch"

// parametri
static par_1 
static par_2

static last_nX
static last_nY
// --------------------------------------------------
// print string
// nRotate - 0 - bez rotiranja, 3 - 270 stepeni
// nInvert - 0 - ne invertuj background, 1 - invert
// nFontSize - 1 - najmanji, 5 - najveci
// --------------------------------------------------
function epl2_string(  nX, nY, cString, lAbsolute, nFontSize, nRotate, nInvert)
local cStr

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

if !lAbsolute 
	nX := last_nX + nX
	nY := last_nY + nY
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
cString:=STRTRAN(cStr, '"', '\"')
cStr += '"' + cString + '"'

? cStr

// --------------------------------
// --------------------------------
function epl2_cp852()
? 'I8,2,049'
return

// --------------------------
// start print na EPL2 
// --------------------------
function epl2_start()

par_1 := gPrinter
par_2 := gcDirekt

gcDirekt := "D"
gPrinter := "L"

// uzmi parametre iz printera "L"
SELECT F_GPARAMS
if !used()
        O_GPARAMS
	endif
	private cSection:="P"
	private cHistory:=gPrinter
	private aHistory:={}
	RPar_Printer()
return

return


// -------------------------------
// vrati standardne printer parametre
// -------------------------------
function epl2_end()

gPrinter := par_1
gcDirekt := par_2

RPar_Printer()
select gparams
use

return
