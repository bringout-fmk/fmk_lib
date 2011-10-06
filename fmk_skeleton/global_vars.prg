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


function set_global_vars()

SetSpecifVars()
SetValuta()

public gFirma:="10"
public gTS:="Preduzece"

private cSection:="K",cHistory:=" "; aHistory:={}
public gNFirma:=space(20)  // naziv firme
public gZaokr:=2
public gTabela:=0
public gPDV:=""

if gModul=="FAKT" .or. gModul=="FIN"
	cSection:="1"
endif

select (F_PARAMS)
if !used()
	O_PARAMS
endif

RPar("za",@gZaokr)
Rpar("fn",@gNFirma)
Rpar("ts",@gTS)
Rpar("tt",@gTabela)

if gModul=="FAKT"
	Rpar("fi",@gFirma)
else
	Rpar("ff",@gFirma)
endif

if (gModul<>"POS" .and. gModul<>"TOPS" .and. gModul<>"HOPS")
	if empty(gNFirma)
	  Box(,1,50)
	    Beep(1)
	    @ m_x+1,m_y+2 SAY "Unesi naziv firme:" GET gNFirma pict "@!"
	    read
	  BoxC()
	  WPar("fn",gNFirma)
	endif
endif

// u sekciji 1 je pdv parametar
cSection := "1"

if gModul <> "TOPS" 
	RPar("PD",@gPDV)
	ParPDV()
	// odjavi gSql
	//lSql:=.f.
	//if gModul=="TOPS" .and. gSql=="D"
	//	lSql:=.t.
	//	gSql:="N"
	//endif
	WPar("PD",gPDV)
	//if lSql
	//	gSql:="D"
	//endif
endif

select (F_PARAMS)
use

public gPartnBlock
gPartnBlock:=NIL

public gSecurity
gSecurity:=IzFmkIni("Svi","Security","N",EXEPATH)

public gnDebug
gnDebug:=VAL(IzFmkIni("Svi","Debug","0",EXEPATH))

public gNoReg
if IzFmkIni("Svi","NoReg","N",EXEPATH)=="D"
	gNoReg:=.t.
elseif IzFmkIni("Svi","NoReg","N",EXEPATH)=="N"
	gNoReg:=.f.
else
	gNoReg:=.f.
endif

public gOpSist
gOpSist:=IzFmkIni("Svi","OS","-",EXEPATH)

public cZabrana:="Opcija nedostupna za ovaj nivo !!!"

public gNovine
gNovine:=IzFmkIni("STAMPA","Opresa","N",KUMPATH)

if gModul<>"TOPS"
	if goModul:oDataBase:cRadimUSezona == "RADP"
		SetPDVBoje()
	endif
endif

return


function SetPDVBoje()

if IsPDV()
	PDVBoje()
	goModul:oDesktop:showMainScreen()
	StandardBoje()
else
	StandardBoje()
	goModul:oDesktop:showMainScreen()
	StandardBoje()
endif
return



function SetValuta()

// ako se radi o planici Novi Sad onda je naziv valute DIN
public gOznVal
gOznVal:="KM"

return



/*! \fn ParPDV()
 *  \brief Provjeri parametar pdv
 */
function ParPDV()

if (gPDV == "") .or. (gPDV $ "ND" .and. gModul=="TOPS")
	// ako je tekuci datum >= 01.01.2006
	if DATE() >= CToD("01.01.2006")
		gPDV := "D"
	else
		gPDV := "N"
	endif
endif
return



/*! \fn IsPDV()
 *  \brief Da li je pdv rezim rada ili ne
 *  \ret .t. or .f.
 */
function IsPDV()

if gPDV=="D"
	return .t.
endif
return .f.

