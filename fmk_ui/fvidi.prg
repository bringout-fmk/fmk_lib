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


function VidiFajl(cImeF, aLinFiks, aKolFiks)

run "gedit" + cImeF



// --------------------------------
// --------------------------------
function SljedLin(cFajl,nPocetak)

local cPom,nPom
cPom:=FILESTR(cFajl,400,nPocetak)
nPom:=AT(NRED,cPom)
if nPom==0; nPom:=LEN(cPom)+1; endif
return {LEFT(cPom,nPom-1),nPocetak+nPom+1}    // {cLinija,nPocetakSljedece}


function PrethLin(cFajl,nKraj)
local nKor:=400,cPom,nPom

if nKraj-nKor-2 < 0 
	nKor:=nKraj-2
endif

cPom:=FILESTR(cFajl,nKor,nKraj-nKor-2)
 nPom:=RAT( NRED ,cPom)
return IF( nPom==0, { cPom, 0}, { SUBSTR(cPom,nPom+2), nKraj-nKor+nPom-1} )
                               // {cLinija,nNjenPocetak}

return


function BrLinFajla(cImeF)
 
 local nOfset:=0,nSlobMem:=0,cPom:="",nVrati:=0
 if FILESTR(cImeF,2,VelFajla(cImeF)-2)!= NRED ; nVrati:=1; endif
 do while LEN(cPom)>=nSlobMem
  nSlobMem:=MEMORY(1)*1024-100
  cPom:=FILESTR(cImeF,nSlobMem,nOfset)
  nOfset=nOfset+nSlobMem-1
  nVrati=nVrati+NUMAT( NRED ,cPom)
 enddo
return nVrati

// -------------------------------------
// -------------------------------------
function VelFajla(cImeF,cAttr)
local aPom:=DIRECTORY(cImeF,cAttr)

return if (!EMPTY(aPom),aPom[1,2],0)


