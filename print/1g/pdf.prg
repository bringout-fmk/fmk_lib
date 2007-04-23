#include "sc.ch"


// ------------------------------
// poziv PDF-a
// ------------------------------
function PDFView( cImeF )
local nFH
local cKom

cKom := "start /MIN fmkpdf -f"
cKom += " "
cKom += cImeF

if gPDFPAuto == "D"
	cKom += " "
	cKom += "-p"
endif


Run( cKom )

return


