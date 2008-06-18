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




function WaitScrSav(lKeyb)
local cTmp
LOCAL nBroji, nBroji2, nChar, nCekaj

IF lKeyb==NIL
	lKeyb:=.f.
ENDIF

nBroji:=SECONDS()
nBroji2:=SECONDS()

nCekaj:=gCekaScreenSaver

while nextkey() == 0
   cTmp:=CekaHandler(@nBroji2)

   if (SECONDS()-nBroji)/60 >= nCekaj
     screensaver()
     nBroji:=SECONDS()
     if !lKeyb
       CistiTipke()
     endif
   endif
enddo
nChar:=Inkey()
IF lKeyb
  Keyboard Chr(nChar)
ENDIF

RETURN nChar





