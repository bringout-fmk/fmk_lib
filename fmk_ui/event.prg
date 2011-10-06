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


