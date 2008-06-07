function Main()
*{
goModul:=TAppModNew()
SetSCGVars()
nBroj:=99
set confirm on
@ 23,0 SAY "Unesi zeljenu opciju: " GET nBroj pict "999"  valid nBroj>0 .and. nBroj<255
read
errorlevel(nBroj)
quit
return
*}


function SetScGVars()
*{

#ifdef CLIP
	? "start SetScGVars"
#endif
public ZGwPoruka:=""
public GW_STATUS:="-"

public GW_HANDLE:=0

public gModul:=""
public gVerzija:=""
public gAppSrv:=.f.
public gSQL:="N"
public ZGwPoruka:=""
public GW_STATUS:="-"
public GW_HANDLE:=0
public gReadOnly:=.f.
public gProcPrenos:="N"
public gInstall:=.f.
public gfKolor:="D"
public gPrinter:="1"
public gMeniSif:=.f.
public gValIz:="280 "
public gValU:="000 "
public gKurs:="1"
public gPTKONV:="0 "
public gPicSif:="V"
public gcDirekt:="V"
public gSKSif:="D"
public gSezona:="    "

public gShemaVF:="B5"

//counter - za testiranje
public gCnt1:=0


PUBLIC m_x
PUBLIC m_y
PUBLIC h[20]
PUBLIC lInstal:=.f.

//  .t. - korisnik je SYSTEM
PUBLIC System   
PUBLIC aRel:={}

PUBLIC cDirRad
PUBLIC cDirSif
PUBLIC cDirPriv
PUBLIC gNaslov

public gSezonDir:=""
public gRadnoPodr:="RADP"

public ImeKorisn:="" 
public SifraKorisn:=""
public KLevel:="9"

public gArhDir

public gPFont
gPFont:="Arial"

public gKodnaS:="8"
public gWord97:="N"
public g50f:=" "

//if !goModul:lStarted 
	public cDirPriv:=""
	public cDirRad:=""
	public cDirSif:=""
//endif

PUBLIC StaraBoja
StarBoja:=SETCOLOR()

public System:=.f.
public gGlBaza:=""
public gSQL
public gSqlLogBase

PUBLIC  Invert:="N/W,R/N+,,,R/B+"
PUBLIC  Normal:="GR+/N,R/N+,,,N/W"
PUBLIC  Blink:="R****/W,W/B,,,W/RB"
PUBLIC  Nevid:="W/W,N/N"

PUBLIC gHostOS
gHostOS:="Win9X"

public cBteksta
public cBokvira
public cBnaslova
public cBshema:="B1"


#ifdef CLIP
	? "end SetScGVars"
#endif

return
*}


