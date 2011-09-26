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

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/sclib/keyb/1g/event.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.9 $
 * $Log: event.prg,v $
 * Revision 1.9  2004/01/09 14:38:40  sasavranic
 * no message
 *
 * Revision 1.8  2003/01/29 06:00:36  ernad
 * citanje ini fajlova
 *
 * Revision 1.7  2003/01/18 18:26:49  ernad
 * speed testing exclusive
 *
 * Revision 1.6  2003/01/18 13:26:09  ernad
 * OL_Yield - dummy
 *
 * Revision 1.5  2002/10/01 13:17:32  mirsad
 * sitna korekcija (nRez->local nRez)
 *
 * Revision 1.4  2002/07/30 17:40:59  ernad
 * SqlLog funkcije - Fin modul
 *
 * Revision 1.3  2002/06/24 07:00:37  ernad
 *
 *
 * GwDiskFree, ciscenja gateway
 *
 * Revision 1.2  2002/06/21 02:28:36  ernad
 * interni sql parser - init, testiranje pos-sql
 *
 * Revision 1.1  2002/06/20 14:27:25  ernad
 *
 *
 * init keyb komponenta
 *
 * Revision 1.5  2002/06/19 13:17:47  ernad
 * gateway funkcije
 *
 * Revision 1.4  2002/06/19 10:18:58  ernad
 * ubacne gw.prg - operacije gateway-a
 *
 *
 */

function KeyboardEvent(nZnak)
*{
local nBroji2
  
nBroji2:=seconds()
DO WHILE ( NEXTKEY()==0 )
     OL_YIELD()
     SqlKeyboardHandler(@nBroji2)
ENDDO
nZnak:=INKEY()
return 
*}

function SqlKeyboardHandler(nBroji2)
*{
return  CekaHandler(@nBroji2)
*}

function CekaHandler(nBroji2)
*{
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
*}



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

function ScreenSaver()
*{

local nBroji3
local i, nRow, nCol, x:=0, y:=0, nSek, xs:=0, ys:=0, cTXT
local cOC:=SET(_SET_COLOR)

nRow:=row()
nCol:=col()

cScr:=SaveScreen()
SET COLOR TO "W/N"
set cursor off
nSek:=SECONDS()
cTXT:='"bring.out" d.o.o Sarajevo, podrska@bring.out.ba'
nBroji3:=Seconds()
do while nextkey()==0
     	OL_YIELD()
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
*}

function VuciULin(xs,ys,x,y,cTXT)
*{
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
*}


//function OL_Yield()
// dummy funkcija
//return

