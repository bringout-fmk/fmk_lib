#include "sc.ch"


// ------------------------------
// poziv PDF-a
// ------------------------------
function PDFView( cImeF )
local nFH
local cKom

cKom := "c:\ruby\bin\ruby.exe "
cKom += EXEPATH
cKom += "fmk_pdf.rb " 
cKom += " "
cKom += cImeF

if gPDFPAuto == "D"
	cKom += " "
	cKom += "-p"
endif


Run( cKom )

return


