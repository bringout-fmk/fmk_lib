#include "fmk.ch"

// -----------------------------
// -----------------------------
function KeyboardEvent(nZnak)

local nBroji2
  
nBroji2:=seconds()
DO WHILE ( NEXTKEY()==0 )
     SqlKeyboardHandler(@nBroji2)
ENDDO
nZnak:=INKEY()
return 


// -----------------------------------
// -----------------------------------
function SqlKeyboardHandler(nBroji2)

return  CekaHandler(@nBroji2)


// -----------------------------------
// -----------------------------------
function CekaHandler(nBroji2)

local cRez:=""
if gSQL=="N"
  return nil
endif

do while .t.
  cRez:=GwStaMai(@nBroji2)
  if !( GW_STATUS == "NA_CEKI_K_SQL" )
       exit
  endif
enddo
return cRez


