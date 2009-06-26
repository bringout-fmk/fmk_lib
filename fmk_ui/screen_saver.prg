#include "fmk.ch"

// -----------------------------
// -----------------------------
function ScreenSaver()


local nBroji3
local i, nRow, nCol, x:=0, y:=0, nSek, xs:=0, ys:=0, cTXT
local cOC:=SET(_SET_COLOR)

nRow:=row()
nCol:=col()

cScr:=SaveScreen()
SET COLOR TO "W/N"
set cursor off
nSek:=SECONDS()
cTXT:="bring.out Sarajevo"
nBroji3:=Seconds()
do while nextkey()==0
     	if GwStaMai(@nBroji3) $ "CB_KRAJ#CB_IDLE"
         	
		// callback funkcija trazi kraj
         	exit
	endif
     IF SECONDS()-nSek >= 1.2
       CLS
       nSek:=SECONDS()
       xs := x
       ys := y
       DO WHILE x=xs .or. y=ys
         x := RANDOM()%25
         y := RANDOM()%(80-LEN(cTXT))
       ENDDO
       VuciULin(xs,ys,x,y,cTXT)
     ENDIF
enddo
set cursor on
cls
SET(_SET_COLOR,cOC)
restore screen from cScr

// pozicioniraj kursor tamo gdje je i bio !
@ nRow, nCol SAY ""     
return


// ---------------------------------------
// ---------------------------------------
function VuciULin(xs, ys, x, y, cTXT)

local a,b,i,j,is:=99

if y==ys .or. x==xs
	return
endif
a:=(y-ys)/(x-xs)
b:=y-a*x
for j:=ys to y step IF(ys>y,-1,1)
   i := ROUND( (j-b) / a , 0 )
   if is==99 .or. is<>i
     @ i,j  SAY cTxt
     is:=i
   endif
next
return

// -------------------------------------------------------
// -------------------------------------------------------
function WaitScrSav(lKeyb)

local cTmp
LOCAL nBroji, nBroji2, nChar, nCekaj

return inkey(0)

IF lKeyb==NIL
	lKeyb:=.f.
ENDIF

nBroji:=SECONDS()
nBroji2:=SECONDS()

nCekaj:=gCekaScreenSaver

while (nChar := inkey()) == 0
   cTmp:=CekaHandler(@nBroji2)

   if (SECONDS()-nBroji)/60 >= nCekaj
     screensaver()
     nBroji:=SECONDS()
     if !lKeyb
       CistiTipke()
     endif
   endif
enddo

IF lKeyb
  Keyboard Chr(nChar)
ENDIF

RETURN nChar

