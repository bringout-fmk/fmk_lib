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


#include "sc.ch"

// parametri funkcija
static par_1 
static par_2
static par_3
static par_4
static last_nX
static last_nY
static txt_in_name
static txt_out_name
static desktop_path



// ----------------------------------------------------
// dodaje opciju u matricu opcija...
// aOpt - matrica koja se proslijedjuje po referenci
// cOption - string opcije npr "set readonly"
// ----------------------------------------------------
function add_gvim_options(aOpt, cOption)
AADD(aOpt, { '"' + cOption + '"' })
return



// ----------------------------------------------------
// dodaje argument u matricu argumenata...
// aArgs - matrica koja se proslijedjuje po referenci
// cArg - string argumneta npr "-c"
// ----------------------------------------------------
function add_gvim_args(aArgs, cArg)
AADD(aArgs, { cArg })
return



// -----------------------------------------
// pokrece gvim sa zadanim parametrima...
// -----------------------------------------
function gvim_cmd()
local aOpts := {}
local aArgs := {}
local cPom

// setovanje argumenata gvim-a (aArgs)
// -----------------------------------
// -n (no swap file)
cPom := "-n"
add_gvim_args(@aArgs, cPom)

// -R (read only)
cPom := "-R"
add_gvim_args(@aArgs, cPom)


// setovanje opcija gvim gui-ja (aOpts)
// ------------------------------------
// readonly
//cPom := 'set readonly'
//add_gvim_options(@aOpts, cPom)

// pokreni gvim sa opcijama
r_gvim_cmd(aArgs, aOpts)

return


// -------------------------------------------------
// pokrece gvim iz cmd line-a
// aOpts - matrica sa opcijama
// aArgs - matrica sa argumnetima 
// -------------------------------------------------
static function r_gvim_cmd(aArgs, aOpts)
// gvim pokretacka komanda
local cGvimCmd := ""
local cSpace := SPACE(1)
local nOpts
local nArgs

// putanja i naziv bat fajla za pokretanje gvim-a
cRunGvim := PRIVPATH + "run_gvim.bat"

// putanja do desktopa
desktop_path := '%HOMEDRIVE%%HOMEPATH%\Desktop\'

cGvimCmd += 'gvim'

if LEN(aArgs) > 0
	for nArgs := 1 to LEN(aArgs)
		cGvimCmd += cSpace
		cGvimCmd += ALLTRIM(aArgs[nArgs, 1])
		// generise sljedeci string, npr: ' -n'
	next
endif

// prodji kroz matricu opcija i dodaj ih u gvimcmd ....
if LEN(aOpts) > 0
	for nOpts:=1 to LEN(aOpts)
		// maksimalni broj opcija je 10, preko toga ne idi...
		if nOpts == 11
			exit
		endif
		
		cGvimCmd += cSpace
		cGvimCmd += '-c'
		cGvimCmd += cSpace
		cGvimCmd += ALLTRIM(aOpts[nOpts, 1])
		// generise sljedeci string, npr: ' -c "set readonly"'
	next
endif

cGvimCmd += cSpace

if UPPER(RIGHT(txt_out_name, 4)) <> ".TXT"
	txt_out_name += ".TXT"
endif

cGvimCmd += '"' + desktop_path + txt_out_name + '"'

set printer to (cRunGvim)
set printer on
set console off

// definisi komande bat fajla...

// pobrisi swap fajl ako je ostao... ali prvo attribut promjeni
// posto je swp hidden...
? 'ATTRIB -H "' + desktop_path + '.' + txt_out_name + '.swp"'
? 'DEL "' + desktop_path + '.' + txt_out_name + '.swp"'

// komanda kopiranja fajla outf.txt na desktop
? 'COPY ' + PRIVPATH + txt_in_name + ' "' + desktop_path + txt_out_name + '"'

// komanda za pokretanje gvima
? cGvimCmd

set printer to
set printer off
set console on

Run( 'start ' + cRunGvim )

return


// ---------------------------------------
// start print u GVIM
// cOut_name - ime izlaznog txt fajla
// ---------------------------------------
function gvim_print(cOut_Name)

last_nX := 0
last_nY := 0

par_1 := gPrinter
par_2 := gcDirekt
par_3 := gPTKonv
par_4 := gKodnaS

txt_in_name := "OUTF.TXT"

if ( cOut_name == nil )
	txt_out_name := txt_in_name
else
	txt_out_name := cOut_name
endif

// uzmi parametre iz printera "G"
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


