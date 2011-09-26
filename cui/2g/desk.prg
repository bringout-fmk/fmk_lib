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
 *
 */
 
function TDesktopNew()
*{
local oObj

#ifdef CLIP

oObj:=map()
  
oObj:cColShema:=nil

oObj:cColTitle:=nil
oObj:cColBorder:=nil
oObj:cColFont:=nil
	

// tekuce koordinate
oObj:nRow:=nil
oObj:nCol:=nil
oObj:nRowLen:=nil
oObj:nColLen:=nil
  
oObj:getRow:=@getRow()
oObj:getCol:=@getCol()
oObj:showLine:=@showLine()
oObj:setColors:=@setColors()
oObj:showSezona:=@showSezona()
oObj:showMainScreen:=@showMainScreen()


#else
oObj:=TDesktop():new()
#endif

oObj:nRowLen:=MAXROWS()
oObj:nColLen:=MAXCOLS()

oObj:cColTitle := "GR+/N"
oObj:cColBorder:= "GR+/N"
oObj:cColFont := "W/N  ,R/BG ,,,B/W"
	
return oObj
*}


#ifdef CPP

class TDesktop {
  
  public:
  	string cColShema;
  	VAR cColTitle;
  	VAR cColBorder;
  	VAR cColFont;
	
  	// tekuce koordinate
  	VAR nRow;
  	VAR nCol;
  	VAR nRowLen;
  	VAR nColLen;
  
  	method getRow;
  	method getCol;
  	method showLine;
  	method setColors;
  	method showSezona;
  	method showMainScreen;
  
}
#endif

#ifndef CPP
#ifndef CLIP
#include "class(y).ch"

CREATE CLASS TDesktop
  
  EXPORTED:
  VAR cColShema

  VAR cColTitle
  VAR cColBorder 
  VAR cColFont
	

  // tekuce koordinate
  VAR nRow
  VAR nCol
  VAR nRowLen
  VAR nColLen
  
  method getRow
  method getCol
  method showLine
  method setColors
  method showSezona
  method showMainScreen
  
END CLASS
#endif
#endif

*void TDesktop::getRow()
*{
method getRow()
return ::nRow
*}

*void TDesktop::getCol()
*{
method getCol()
return ::nCol
*}


*void TDesktop::showLine(string cTekst, string cRow)
*{
method showLine(cTekst,cRow)
LOCAL nCol

if cTekst<>NIL
 if Len(cTekst)>80
   nCol:=0
 else
   nCol:=INT((80-LEN(cTekst))/2)
 endif
 @ nRow,0 SAY REPLICATE(Chr(32),80)
 @ nRow,nCol SAY cTekst
endif

RETURN
*}

*void TDesktop::SetColors(string cIzbor)
*{
method setColors(cIzbor)
 
IF ISCOLOR()
   DO CASE
     CASE cIzbor=="B1"
        ::cColTitle := "GR+/N"
        ::cColBorder  := "GR+/N"
        ::cColFont := "W/N  ,R/BG ,,,B/W"
	
     CASE cIzbor=="B2"
        ::cColTitle := "N/G"
        ::cColBorder := "N/G"
        ::cColFont := "W+/G ,R/BG ,,,B/W"
     
     CASE cIzbor=="B3"
        ::cColTitle := "R+/N"
        ::cColBorder:= "R+/N"
        ::cColFont  := "N/GR ,R/BG ,,,B/W"
     
     CASE cIzbor=="B4"
        ::cColTitle := "B/BG"
        ::cColBorder  := "B/W"
        ::cColFont  := "B/W  ,R/BG ,,,B/W"
     
     CASE cIzbor=="B5"
        ::cColTitle := "B/W"
        ::cColBorder  := "R/W"
        ::cColFont  := "GR+/N,R/BG ,,,B/W"
     
     CASE cIzbor=="B6"
        ::cColTitle := "B/W"
        ::cColBorder  := "R/W"
        ::cColFont  := "W/N,R/BG ,,,B/W"
     CASE cIzbor=="B7"
        ::cColTitle := "B/W"
        ::cColBorder  := "R/W"
        ::cColFont  := "N/G,R+/N ,,,B/W"
     OTHERWISE
   ENDCASE

ELSE
        ::cColTitle := "N/W"
        ::cColBorder  := "N/W"
        ::cColFont  := "W/N  ,N/W  ,,,N/W"
ENDIF
::cColShema:=cIzbor
 
return cIzbor
*}

method showSezona(cSezona)
@ 3,70 SAY "Sez: "+cSezona COLOR INVERT
return
*}

*void showMainScreen(bool lClear)
*{
method showMainScreen(lClear)

if lClear==NIL
	lClear:=.f.
endif

if lClear
	clear
endif

@ 0,2 SAY '<ESC> Izlaz' COLOR INVERT
@ 0,COL()+2 SAY DATE()  COLOR INVERT
@ 24,64  SAY ELIBVER()

DispBox(2,0,4,79,B_DOUBLE+' ',NORMAL)
if lClear
	DispBox(5,0,24,79,B_DOUBLE+"±",INVERT)
endif

@ 3,1 SAY PADC(gNaslov+' Ver.'+gVerzija,72) COLOR NORMAL

return
*}
