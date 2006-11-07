#include "sc.ch"

// parametri
static par_1 
static par_2
static par_3
static par_4

static last_nX
static last_nY



// pokrece gvim sa zadanim parametrom...
function gvim_cmd(cFile)
local cCmd
local cSpace := SPACE(1)

cCmd := 'gvim'
cCmd += cSpace
cCmd += '-c'
cCmd += cSpace
cCmd += '"set gfn=Lucida_Console:h7:cDEFAULT"'
cCmd += cSpace
cCmd += cFile

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

//gcDirekt := "D"
gPrinter := "V"
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


