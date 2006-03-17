#include "sc.ch"

// -------------------------------
// -------------------------------
function PtxtSekvence()

gpIni:=  "#%INI__#"
gpCOND:= "#%KON17#"
gpCOND2:="#%KON20#"
gp10CPI:="#%10CPI#"
gP12CPI:="#%12CPI#"
gPB_ON :="#%BON__#"
gPB_OFF:="#%BOFF_#"
gPU_ON:="#%UON__#"
gPU_OFF:="#%UOFF_#"
gPI_ON:="#%ION__#"
gPI_OFF:="#%IOFF_#"
gPFF   :="#%NSTR_#"
gPO_Port:="#%PORTR#"
gPO_Land:="#%LANDS#"
// gRPL_Normal:="#%RPLNO#"        // u PTXT-u nije implementirano
gRPL_Normal:=""
// gRPL_Gusto:="#%RPLGU#"         // u PTXT-u nije implementirano
gRPL_Gusto:=""
return


// ------------------------------
// ------------------------------
function PTXT(cImeF)
*{
local cPtxtSw:=""
local nFH

local cKom

if gPtxtSw <> nil
	cPtxtSw := gPtxtSw
else
	cPTXTSw := R_IniRead ( 'DOS','PTXTSW',  "/P", EXEPATH+'FMK.INI' )
endif

cKom:=EXEPATH+"PTXT "+cImeF+" "



//if !file(EXEPATH+'FMK.INI')
//  nFH:=FCreate(EXEPATH+'FMK.INI')
//  FWrite(nFh,";------- Ini Fajl FMK-------")
//  Fclose(nFH)
//  cPTXTSW:=R_IniWrite ( 'DOS','PTXTSW',  "/P", EXEPATH+'FMK.INI')
//endif

// switchewi za ptxt

cKom += " "+ cPtxtSw


Run(cKom)


return
*}

