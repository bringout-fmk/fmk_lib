#include "fmk.ch"

function SifFmkSvi()
*{
private Opc:={}
private opcexe:={}

AADD(opc,"1. partneri                          ")
if (ImaPravoPristupa("FMK","SIF","PARTNOPEN"))
	AADD(opcexe, {|| P_Firma()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

if (goModul:oDataBase:cName <> "FIN")
	AADD(opc,"2. konta")
	if (ImaPravoPristupa("FMK","SIF","KONTOOPEN"))
		AADD(opcexe, {|| P_Konto() } )
	else
		AADD(opcexe, {|| MsgBeep(cZabrana)})
	endif
else
	AADD(opc, "2. ----------------- ")
	AADD(opcexe, {|| NotImp()})
endif

AADD(opc,"3. tipovi naloga")
if (ImaPravoPristupa("FMK","SIF","TIPNALOPEN"))
	AADD(opcexe, {|| P_VN() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"4. tipovi dokumenata")
if (ImaPravoPristupa("FMK","SIF","TIPDOKOPEN"))
	AADD(opcexe, {|| P_TipDok() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"5. valute")
if (ImaPravoPristupa("FMK","SIF","VALUTEOPEN"))
	AADD(opcexe, {|| P_Valuta() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"6. radne jedinice")
if (ImaPravoPristupa("FMK","SIF","RJOPEN"))
	AADD(opcexe, {|| P_RJ() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"7. opcine")
if (ImaPravoPristupa("FMK","SIF","OPCINEOPEN"))
	AADD(opcexe, {|| P_Ops() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"8. banke")
if (ImaPravoPristupa("FMK","SIF","BANKEOPEN"))
	AADD(opcexe, {|| P_Banke() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"9. sifk - karakteristike")  
if (ImaPravoPristupa("FMK","SIF","SIFKOPEN"))
	AADD(opcexe, {|| P_SifK() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

if (IsRamaGlas().or.gModul=="FAKT".and.glRadNal)
	AADD(opc,"10. radni nalozi")  
	AADD(opcexe, {|| P_RNal() } )
endif

CLOSE ALL
OFmkSvi()

private Izbor:=1
gMeniSif:=.t.
Menu_SC("ssvi")
gMeniSif:=.f.

CLOSERET
return
*}
