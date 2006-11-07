#include "sc.ch"

// parametri
static par_1 
static par_2
static par_3
static par_4
static last_nX
static last_nY



// ------------------------------------------
// dodaje opciju u matricu opcija...
// ------------------------------------------
function add_gvim_options(aOpt, cOption)
AADD(aOpt, { '"' + cOption + '"' })
return

// -----------------------------------------
// pokrece gvim sa zadanim parametrima...
// -----------------------------------------
function gvim_cmd(cFile)
local aOpt := {}
local cPom

// setovanje opcija gvim gui-ja

// font + font size...
//cPom := 'set gfn=Lucida_Console:h7:cDEFAULT'
//add_gvim_options(@aOpt, cPom)

// text wrap
//cPom := 'set wrap!'
//add_gvim_options(@aOpt, cPom)

// add bottom scrollbar
//cPom := 'set guioptions+=b'
//add_gvim_options(@aOpt, cPom)

cFile := ALLTRIM(cFile)

// pokreni gvim sa opcijama
r_gvim_cmd(cFile, aOpt)

return

// -------------------------------------------------
// pokrece gvim iz cmd line-a
// -------------------------------------------------
static function r_gvim_cmd(cFilename, aOpt)
local cCmd := ""
local cSpace := SPACE(1)
local i

cCmd += 'start gvim'

// opcije....
if LEN(aOpt) > 0
	for i:=1 to LEN(aOpt)
		// maksimalni broj opcija je 10
		if i == 11
			exit
		endif
		
		cCmd += cSpace
		cCmd += '-c'
		cCmd += cSpace
		cCmd += ALLTRIM(aOpt[i, 1])
	next
endif

cCmd += cSpace
cCmd += cFileName

Run(cCmd)

return


// --------------------------
// start print u GVIM
// --------------------------
function gvim_print()

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

gPrinter := "G"
gPTKonv := "0 "
gKodnaS := "8"

private cSection:="P"
private cHistory:=gPrinter
private aHistory:={}

RPar_Printer()

START PRINT CRET

return



// -------------------------------------
// vrati standardne printer parametre
// -------------------------------------
function gvim_end()

?
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


