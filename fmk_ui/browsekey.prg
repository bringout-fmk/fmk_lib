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
#include "dbstruct.ch"
#include "error.ch"
#include "setcurs.ch"

// ------------------------------------------------------
// ------------------------------------------------------
function BrowseKey(y1,x1,y2,x2,;
                   ImeKol,bfunk,uslov,traz,brkol,;
                   dx,dy,bPodvuci)

static poziv:=0
local lk, REKORD,TCol
local nCurRec:=1,nRecCnt:=0

Private TB
private usl

usl='USL'+alltrim(str(POZIV,2))
POZIV++
&usl=uslov
TB:=tbrowsedb(y1,x1,y2,x2)
TB:headsep='ÑÍ'
TB:colsep ='³'
if eof(); skip -1; endif
seek traz           //
do while  &(&usl)
   nRecCnt ++
   skip
enddo
seek traz          
if !found()
   nCurRec:=0
endif

for i:=1 to len(ImeKol)
    TCol:=tbcolumnnew(ImeKol[i,1],Imekol[i,2])
    if bPodvuci<>NIL
        TCol:colorBlock:={|| iif(EVAL(bPodvuci),{5,2},{1,2}) }
    endif
    TB:addcolumn(TCol)
next
if !empty(brkol) .and. valtype(brkol)='N'
  TB:freeze :=brkol
endif
TB:skipblock:={|x| korisnik(x,traz,dx,dy,@nCurRec,@nRecCnt)}

EVAL(bfunk,0)

do while .t.
   if dx<>NIL .and. dy<>NIL
     @ m_x+dx,m_y+dy say STR(nRecCnt,4)
   endif

   while !Tb:stabilize() .and. NEXTKEY() == 0
     if dx<>NIL .and. dy<>NIL
        @ m_x+dx,m_y+dy say STR(nRecCnt,4)
     endif
   enddo
   lk:=LASTKEY()

   if lk==K_ESC
      POZIV--
   exit

   elseif lk=K_DOWN
          TB:down()
   elseif lk=K_UP
          TB:up()
   elseif lk=K_RIGHT
          TB:right()
   elseif lk=K_LEFT
          TB:left()
   elseif lk=K_END
          TB:end()
   elseif lk=K_HOME
          TB:home()
   elseif lk=K_PGDN
          TB:pagedown()
   elseif lk=K_PGUP
          TB:pageup()
   elseif lk=26
           TB:panleft()
   elseif lk=2
           TB:panright()
   else
      povrat:=EVAL(bFunk,lk)
      if povrat==0
         POZIV--
         exit
      elseif povrat==DE_ADD
         nRecCnt++
         TB:refreshall()
      elseif povrat==DE_DEL
         if nRecCnt>0; nRecCnt--; endif
         TB:refreshall()
      elseif povrat==DE_REFRESH
         TB:refreshall()
      endif
   endif

enddo
return (nil)


// ------------------------------------------------------------
// ------------------------------------------------------------
static function Korisnik(nRequest,traz,dx,dy,nCurRec,nRecCnt)

local nCount
nCount := 0
if LastRec() != 0
   if .not.&(&usl)
      seek traz
      if .not. &(&usl)
         go bottom
         skip 1
      endif
      nRequest=0
   endif
   if nRequest>0
      do while nCount<nRequest .and. &(&usl)
         skip 1
         nCurRec++
         if Eof() .or. ! &(&usl)
            skip -1
            nCurRec--
            exit
         endif
         nCount++
      enddo
   elseif nRequest<0
      do while nCount>nRequest .and. &(&usl)
         skip -1
         nCurRec--
         if ( Bof() )
            nCurRec++
            exit
         endif
         nCount--
      enddo
      if ! &(&usl)
         skip 1
         nCurRec++
         nCount++
      endif
   endif
endif
if dx<>NIL .and. dy<>NIL
  //  @ m_x+dx,m_y+dy say STR(nCurRec,4)+"/"+STR(nRecCnt,4)
  @ m_x+dx,m_y+dy say STR(nRecCnt,4)
endif
return (nCount)

