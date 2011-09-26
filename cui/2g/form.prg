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

static aBoxStack:={}
static aPrStek:={}
// meniid,m_x,m_y,savescreen,ItemNo
static aMenuStack:={}    
static aMsgStack:={}


function TFormNew(oDesktop, nLength, nWidth, lInvert)
local oOb

#ifdef CLIP
#else
	oOb:=TForm():new()
#endif

oOb:oDesktop:=oDesktop
oOb:nLength:=nLength
oOb:nWidth:=nWidth
oOb:lInvert:=lInvert

oOb:nStartCursor:=setcursor()
oOb:nStartColor:=setcolor()
oOb:oDesktop:=oDesktop
oOb:cStartScreenArea:=;
   SaveScreen( oOb:oDesktop:getRow(), oOb:oDesktop:getCol(), oOb:oDesktop:getRow() + oOb:nLength + 1 , oOb:oDesktop:getCol() + oOb:nWidth + 2)

return oOb

#ifndef CPP
#ifndef CLIP
#include "class(y).ch"

CREATE CLASS TForm

  EXPORTED:
  // pocetne koordinate
  VAR    nStartCursor
  VAR    nStartColor

  VAR    nStartRow
  VAR    nStartCol
  VAR    cStartSreenArea
  
  VAR    oDesktop
  VAR    lInvert
  
  // duzina, sirina boxa
  VAR    nLength
  VAR	 nWidth
   
  VAR cNaslov
  VAR cMessage
  VAR aMessage
 
  method show
  method close
  method clear
  
END CLASS

#endif
#endif

static function show
local cPom
local nRedovaM
local cLocalC
if gAppSrv
	return
endif

cPom:=SET(_SET_DEVICE)

SET DEVICE TO SCREEN

::oDesktop:showLine(::cNaslov,::nLength)

IF ::aMessage<>NIL    
  nRedovaM:=OpcTipke(chMsg)
  IF ::oDesktop:nRow+ ::nLength > 23-nRedovaM
    ::oDesktop:nRow:=23-nRedovaM-::nLength
    IF ::oDesktop:nRow < 1
      ::nLength:=22-nRedovaM
      m_x:=1
    ENDIF
  ENDIF
ENDIF

if ::lInvert==NIL
 ::lInvert:=.f.
endif

cLocalC:=IF(::lInvert,Invert,Normal)

::oDesktop:setColor(cLocalC)

SCROLL(::nStartRow,::nStartCol,::nStartRow+::nLength+1,::nStartCol+::nWidth+2)
@ ::nStartRow,::nStartCol TO ::nStartRow+::nLength+1,::nStartCol+::nWidth+2 DOUBLE

IF ! ( ::cNaslov <> NIL ) .and.  !EMPTY(::cNaslov)
  @ ::oDesktop:getRow(),::oDesktop:getCol()+2 SAY ::cNaslov COLOR "GR+/B"
ENDIF

if ( ::cMessage<>NIL )
  ::oDesktop:setColor(Normal)
  ::oDesktop:showLine(::cMessage,24)
  ::oDesktop:setColor(cLocalC)
endif

SET(_SET_DEVICE,cPom)

return

static function close()
local cPom

if gAppSrv; return; endif

cPom:=SET(_SET_DEVICE)
SET DEVICE TO SCREEN

SCROLL(::oDesktop:getRow(), ::oDesktop:getCol(),;
       ::oDesktop:getRow() + ::nLength + 1 , ::oDesktop:getCol() + ::nWidth + 2)
       
RestScreen( ::oDesktop:getRow(), ::oDesktop:getCol(),;
       ::oDesktop:getRow() + ::nLength + 1 , ::oDesktop:getCol() + ::nWidth + 2,;
       ::cSaveScreenArea)

SETCURSOR(::nStartCursor==0,0,iif(readinsert(),2,1))
SETCOLOR(::nStartColor)

SET(_SET_DEVICE,cPom)

return

static function clear()
@ ::oDesktop:getRow(), ::oDesktop:getCol() CLEAR TO  ::oDesktop:getRow() + ::nLength  , ::oDesktop:getCol() + ::nWidth 
return


static function showOpcije()
LOCAL i:=0,j:=0,k:=0,nOmax:=0,nBrKol,nOduz,nBrRed,nVrati:=""
 
 aNiz:=::aMessage
 
 AEVAL(aNiz,{|x| IF(LEN(x)>nOmax,nOmax:=LEN(x),)})
 nBrKol:=INT(80/(nOmax+1))
 nBrRed:=INT(LEN(aNiz)/nBrKol)+IF(MOD(LEN(aNiz),nBrKol)!=0,1,0)
 nOduz:=IF(nOmax<10,10,IF(nOmax<16,16,IF(nOmax<20,20,IF(nOmax<27,27,40))))
 
 Prozor1(24-nBrRed,0,24,80,,,SPACE(9),,"W/N")
 FOR i:=1 TO nBrRed*nBrKol
   IF( MOD(i-1,nBrKol)==0 , EVAL({|| ++j,k:=0})  , k+=nOduz )
   IF i>LEN(aNiz); AADD(aNiz,""); ENDIF
   IF aNiz[i]==NIL; aNiz[i]=""; ENDIF
   @ 24-nBrRed+j,k SAY PADR(aNiz[i],nOduz-1)+IF(MOD(i-1,nBrKol)==nBrKol-1,"","³")
 NEXT
 
 FOR i:=1 TO nBrKol
   @ 24-nBrRed,(i-1)*nOduz SAY REPLICATE("Í",nOduz-IF(i==nBrKol,0,1))+IF(i==nBrKol,"","Ñ")
 NEXT
 
 nVrati:=nBrRed+1
 
return nVrati
