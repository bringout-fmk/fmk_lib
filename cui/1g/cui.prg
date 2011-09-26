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
#include "set.ch"

*array
static aBoxStack:={}
*;

*array
static aPrStek:={}
*;

*array
static aMenuStack:={}    
*;

*array
static aMsgStack:={}
*;

/*! \fn Menu(MenuId,Items,ItemNo,Inv)
 *
 *  \brief Prikazuje zadati meni, vraca odabranu opciju
 *
 *  \param MenuId  - identifikacija menija     C
 *  \param Items   - niz opcija za izbor       C[]
 *  \param ItemNo  - Broj pocetne pozicije     N
 *  \param Inv     - da li je meni invertovan  L
 *
 *  \result Broj izabrane opcije, 0 kraj
 *
 */

function Menu(MenuId, Items, ItemNo, Inv, cHelpT, nPovratak, aFixKoo, nMaxVR)
*{
local Length
local N
local OldC
local LocalC
local LocalIC
local ItemSav
local i
local aMenu:={}
local cPom:=SET(_SET_DEVICE)
local lFK:=.f.


SET DEVICE TO SCREEN

IF nPovratak==NIL
	nPovratak:=0
ENDIF
IF nMaxVR==NIL
	nMaxVR:=16
ENDIF
IF aFixKoo==NIL
	aFixKoo:={}
ENDIF
IF LEN(aFixKoo)==2
	lFK:=.t.
ENDIF

N:=IF(Len(Items)>nMaxVR,nMaxVR,LEN(Items))
Length:=Len(Items[1])+1

if Inv==NIL
	Inv:=.f.
endif
LocalC:=IF(Inv,Invert,Normal)
LocalIC:=IF(Inv,Normal,Invert)


OldC:=SetColor(LocalC)

//  Ako se meni zove prvi put, upisi ga na stek
IF Len(aMenuStack)==0 .or. (Len(aMenuStack)<>0 .and. MenuId<>(StackTop(aMenuStack))[1])  
  IF lFK
    m_x := aFixKoo[1]
    m_y := aFixKoo[2]
  ELSE
    Calc_xy(N,Length)                    && odredi koordinate menija
  ENDIF
  StackPush(aMenuStack,{MenuId,;
                        m_x,;
                        m_y,;
                        SaveScreen(m_x,m_y,m_x+N+2-IF(lFK,1,0),m_y+Length+4-IF(lFK,1,0)),;
                        ItemNo,;
                        cHelpT;
   })

//  Ako se meni ne zove prvi put, uzmi koordinate sa steka
ELSE
  aMenu:=StackTop(aMenuStack)
  m_x:=aMenu[2]
  m_y:=aMenu[3]
END IF

@ m_x,m_y CLEAR TO m_x+N+1,m_y+Length+3 
IF lFK
  @ m_x,m_y TO m_x+N+1,m_y+Length+3
ELSE
  @ m_x,m_y TO m_x+N+1,m_y+Length+3 DOUBLE 
  @ m_x+N+2,m_y+1 SAY REPLICATE(Chr(177),Length+4)
  FOR i:=1 TO N+1
    @ m_x+i,m_y+Length+4 SAY Chr(177)
  NEXT
ENDIF

SetColor(Invert)
IF ItemNo<>0
  // CentrTxt(h[ItemNo],24)
ELSE
  CentrTxt(h[1],24)
END IF
SetColor(LocalC)
IF LEN(Items)>nMaxVR
 ItemNo:=AChoice3(m_x+1, m_y+2, m_x+N+1, m_y+Length+1, Items, .t., "MenuFunc", RetItem(ItemNo), RetItem(ItemNo)-1)
ELSE
 ItemNo:=AChoice2(m_x+1, m_y+2, m_x+N+1, m_y+Length+1, Items, .t., "MenuFunc", RetItem(ItemNo), RetItem(ItemNo)-1)
ENDIF

nTItemNo := RetItem(ItemNo)

aMenu:=StackTop(aMenuStack)
m_x:=aMenu[2]
m_y:=aMenu[3]
aMenu[5]:=nTItemNo

@ m_x,m_y TO m_x+N+1,m_y+Length+3
//StackPop(aWhereStack)

//
//  Ako nije pritisnuto ESC, <-, ->, oznaci izabranu opciju
//
IF nTItemNo<>0
  SetColor(LocalIC)
  @ m_x+MIN(nTItemNo,nMaxVR),m_y+1 SAY " "+Items[nTItemNo]+" "
  @ m_x+MIN(nTItemNo,nMaxVR),m_y+2 SAY ""
END IF

Ch:=LastKey()

//  Ako je ESC meni treba odmah izbrisati (ItemNo=0),
//  skini meni sa steka

IF Ch==K_ESC .or. nTItemNo==0 .or. nTItemNo==nPovratak
  @ m_x,m_y CLEAR TO m_x+N+2-IF(lFK,1,0),m_y+Length+4-IF(lFK,1,0)
  aMenu:=StackPop(aMenuStack)
  RestScreen(m_x,m_y,m_x+N+2-IF(lFK,1,0),m_y+Length+4-IF(lFK,1,0),aMenu[4])
  //if aMenu[6]<>NIL; PopHT(); endif
  //AEVAL(h,{|e| e:=""})
END IF


SetColor(OldC)
SET(_SET_DEVICE,cPom)
return ItemNo
*}


function Calc_xy(N,Length)
*{
// OPIS  : Odredjuje poziciju za ispis sljedeceg menija na
//        osnovu pozicije kursora M-x i m_y

private x,y

x:=Row()
y:=Col()

//  Odredi x koordinatu
IF 23-x >= N+2
  m_x=x+1
  IF Length+y+3<= 76
    m_y=y+3
  ELSEIF y+5<78 .AND. y-Length>0
    m_y=y-Length+5
  ELSE
    m_y=Int((78-Length)/2)
  END IF
ELSE
  m_x=Int((22-N)/2+1)
  m_y=INT((80-Length-2)/2)
END IF
return
*}


// vrati pravu vrijednost itema...
function retitem(nItemNo)
local nRetItem 
local cAction 

cAction := what_action(nItemNo)

do case
	case cAction == "K_CTRL_N"
		nRetItem := nItemNo - 10000
	case cAction == "K_F2"
		nRetItem := nItemNo - 20000
	case cAction == "K_CTRL_T"
		nRetItem := nItemNo - 30000
	otherwise
		nRetItem := nItemNo
endcase

return nRetItem



function range(nVal, nMin, nMax)
local lRet
if (nVal <= nMax) .and. (nVal >= nMin)
	lRet := .t.
else
	lRet := .f.
endif
return lRet


function what_action(nItemNo)
local cAction

do case
	case RANGE(nItemNo, 10000, 10999)
		cAction := "K_CTRL_N"
	case RANGE(nItemNo, 20000, 20999)
		cAction := "K_F2"
	case RANGE(nItemNo, 30000, 30999)
		cAction := "K_CTRL_T"
	otherwise
		cAction := ""
endcase

return cAction


/*! \fn Msg(Text,Sec, xPos)
*   \brief Ispisuje tekst i ceka <Sec> sekundi
*   \param xPos je pozicija ukoliko se ne zeli centrirati poruka
*   \note Maksimalna duzina jednog reda je 72 slova
*/

function Msg(text, sec, xPos)
*{
local l,msg_x1,msg_x2,msg_y1,msg_y2,cPom:=SET(_SET_DEVICE)
LOCAL nLen, nHashPos, aText := {}, nCnt, nBrRed := 0

if gAppSrv
	? text
	return
endif

SET DEVICE TO SCREEN

WHILE (nHashPos := AT ("#", Text)) > 0
   AADD (aText, LEFT (Text, nHashPos-1))
   Text := SUBSTR (Text, nHashPos + 1)
   nBrRed ++
END
IF ! EMPTY (Text)
   AADD (aText, Text)
   nBrRed ++
ENDIF
l := 0
FOR nCnt := 1 TO LEN (aText)
   IF LEN (aText [nCnt]) > l
      l := LEN (aText [nCnt])
   ENDIF
NEXT
// l:=Len(Text)
IF xPos == NIL
   msg_x1:=8 - INT (nBrRed / 2)
   msg_x2:=13 + nBrRed - INT (nBrRed / 2)             // nBrRed >= 1
ELSE
   msg_x1 := xPos
   msg_x2 := xPos + 5 + nBrRed
ENDIF
msg_y1:=(79-l-7)/2
msg_y2:=79 - msg_y1
StackPush(aMsgStack,{if(setcursor()==0,0,iif(readinsert(),2,1)),setcolor(Invert),l,;
          SaveScreen(msg_x1,msg_y1,msg_x2,msg_y2)})
@ msg_x1,msg_y1 CLEAR TO msg_x2,msg_y2
@ msg_x1+1,msg_y1+2 TO msg_x2-1,msg_y2-2 DOUBLE
FOR nCnt := 1 TO nBrRed
   @ msg_x1+2+nCnt,msg_y1+4 SAY PADC (aText [nCnt], l)
NEXT
Inkey(Sec)

MsgC(msg_x1,msg_y1,msg_x2,msg_y2)
SET(_SET_DEVICE,cPom)
return
*}



function MsgO(text,sec)
*{
local l
local msg_x1
local msg_x2
local msg_y1
local msg_y2
local cPom

cPom:=SET(_SET_DEVICE)
if gAppSrv
	? text
	return
endif

SET DEVICE TO SCREEN

l:=Len(Text)
msg_x1:=8
msg_x2:=14
msg_y1:=(79-l-7)/2
msg_y2:=79 - msg_y1
StackPush(aMsgStack,{if(setcursor()==0,0,iif(readinsert(),2,1)),setcolor(Invert),l,;
          SaveScreen(msg_x1,msg_y1,msg_x2,msg_y2) })
@ msg_x1,msg_y1 CLEAR TO msg_x2,msg_y2
@ msg_x1+1,msg_y1+2 TO msg_x2-1,msg_y2-2 DOUBLE
@ msg_x1+3,msg_y1+4 SAY Text
set cursor off
SET(_SET_DEVICE,cPom)
return
*}

function MsgC(msg_x1,msg_y1,msg_x2,msg_y2)
*{
local aMsgPar
local l

if gAppSrv; return; endif

if len(aMsgStack)>0
  aMsgPar:=StackPop(aMsgStack)
  IF msg_x1 == NIL
     l:=aMsgPar[3]
     RESTSCREEN(8,(79-l-7)/2,14,79-(79-l-7)/2,aMsgPar[4])
  ELSE
     RESTSCREEN (msg_x1,msg_y1,msg_x2,msg_y2, aMsgPar[4])
  ENDIF
  setcursor(iif(aMsgPar[1]==0,0,iif(readinsert(),2,1)))
  SetColor(aMsgPar[2])
endif

return
*}

/*! \fn Box(BoxId, N, Length, Inv, chMsg, cHelpT)
 *  \brief Otvara prozor BoxID dimenzija (N x Length), invertovan 
 *         (Inv=.T. ili ne)
 *
 *  \param chMsg - tip C -> prikaz poruke
 *  \param A -> ispisuje opcije pomocu fje OpcTipke
 *  \param boxid se ne koristi
 */

function Box( BoxId, N, Length, Inv, chMsg, cHelpT )
*{

Local x1,y1,x2,y2,LocalC, cPom, cNaslovBoxa

if gAppSrv; return; endif

cPom:=SET(_SET_DEVICE)
cNaslovBoxa:=""

IF BoxID<>NIL .and. LEFT(BoxID,1)=="#"
  cNaslovBoxa:=SUBSTR(BoxID,2)
ENDIF

SET DEVICE TO SCREEN

Calc_xy(N,Length)
IF VALTYPE(chMsg)=="A"
  BoxId:=OpcTipke(chMsg)
  IF m_x+N>23-BoxId
    m_x:=23-BoxId-N
    IF m_x<1
      N:=22-BoxId
      m_x:=1
    ENDIF
  ENDIF
ENDIF

if  chMsg==NIL; cHMsg:=""; endif

StackPush(aBoxStack, ;
{  m_x, ;
   m_y, ;
   N,   ;
   Length, ;
   SaveScreen(m_x,m_y,m_x+N+1,m_Y+Length+2), ;
   IF(VALTYPE(chMsg)!="A","",BoxId), ;
   Row(), ;
   Col(), ;
   if(setcursor()==0,0,iif(readinsert(),2,1)), ;
   SETCOLOR(), ;
   cHelpT;
})

if Inv==NIL; Inv:=.f.; endif

LocalC:=IF(Inv,Invert,Normal)
SetColor(LocalC)

SCROLL(m_x,m_y,m_x+N+1,m_Y+Length+2)
@ m_x,m_y TO m_x+N+1,m_y+Length+2 DOUBLE

IF !EMPTY(cNaslovBoxa)
  @ m_x,m_y+2 SAY cNaslovBoxa COLOR "GR+/B"
ENDIF

SET(_SET_DEVICE,cPom)

return
*}

function BoxC()
*{

local aBoxPar[11], cPom

if gAppSrv; return; endif

cPom:=SET(_SET_DEVICE)
SET DEVICE TO SCREEN

aBoxPar:=StackPop(aBoxStack)

m_x:=aBoxPar[1]
m_y:=aBoxPar[2]
N:=aBoxPar[3]
Length:=aBoxPar[4]


SCROLL(m_x,m_y,m_x+N+1,m_y+Length+2)
RestScreen(m_x,m_y,m_x+N+1,m_y+Length+2,aBoxPar[5])

@ AboxPar[7],aBoxPar[8] SAY ""

SETCURSOR(iif(aBoxPar[ 9]==0,0,iif(readinsert(),2,1)))
SETCOLOR(aBoxPar[10])

IF VALTYPE(aBoxPar[6])=="N"; Prozor0(); ENDIF

if !StackIsEmpty(aBoxStack)
  aBoxPar:=StackTop(aBoxStack)
  m_x:=aBoxPar[1]
  m_y:=aBoxPar[2]
  N:=aBoxPar[3]
  Length:=aBoxPar[4]
endif

SET(_SET_DEVICE,cPom)

return
*}

/*! \fn OpcTipke(aNiz)
 *  \brief prikaz opcija u Browse-u
 *
 * \code
 *  aNiz:={"<c-N> Novi","<a-A> Ispravka"} 
 * \endcode
 *
 */
 
function OpcTipke(aNiz)
*{
LOCAL i:=0,j:=0,k:=0,nOmax:=0,nBrKol,nOduz,nBrRed,xVrati:=""
IF VALTYPE(aNiz)=="A"
 AEVAL(aNiz,{|x| IF(LEN(x)>nOmax,nOmax:=LEN(x),)})
 nBrKol:=INT(80/(nOmax+1))
 nBrRed:=INT(LEN(aNiz)/nBrKol)+IF(MOD(LEN(aNiz),nBrKol)!=0,1,0)
 nOduz:=IF(nOmax<10,10,IF(nOmax<16,16,IF(nOmax<20,20,IF(nOmax<27,27,40))))
 Prozor1(24-nBrRed,0,24,80,,,SPACE(9),,"W/N")
 FOR i:=1 TO nBrRed*nBrKol
   IF( MOD(i-1,nBrKol)==0 , EVAL({|| ++j,k:=0})  , k+=nOduz )
   IF i>LEN(aNiz); AADD(aNiz,""); ENDIF
   IF aNiz[i]==NIL; aNiz[i]=""; ENDIF
   @ 24-nBrRed+j,k SAY PADR(aNiz[i],nOduz-1)+IF(MOD(i-1,nBrKol)==nBrKol-1,"","≥")
 NEXT
 FOR i:=1 TO nBrKol
   @ 24-nBrRed,(i-1)*nOduz SAY REPLICATE("Õ",nOduz-IF(i==nBrKol,0,1))+IF(i==nBrKol,"","—")
 NEXT
 xVrati:=nBrRed+1
ENDIF
return xVrati
*}

function BoxCLS()
*{
local aBoxPar[11]
aBoxPar:=aBoxStack[len(aBoxStack)]

@ aBoxPar[1]+1,aBoxPar[2]+1 clear to aBoxPar[1]+aBoxPar[3],aBoxPar[2]+aBoxPar[4]+1
return
*}

function Beep(Nputa)
*{
local i

#ifdef CLIP
	? "Beep ..."
	return
#endif
for i:=1 to Nputa
	Tone(300,1)
next

return
*}

function CentrTxt(tekst,lin)
*{
LOCAL kol

if tekst<>NIL
 if Len(tekst)>80
   kol:=0
 else
   kol:=INT((80-Len(tekst))/2)
 endif
 @ lin,0 SAY REPLICATE(Chr(32),80)
 @ lin,kol SAY tekst
endif

return
*}

// --------------------------------------------------------
// --------------------------------------------------------
function Achoice2(x1, y1, x2, y2, Items, f1, cFunc, nItemNo)

local i
local ii
local nWidth
local nLen
local fExit
local fFirst
local nOldCurs
local cOldColor
local nOldItemNo
local cSavC
local nCtrlKeyVal := 0

if nItemNo==0
	return nItemNo
endif

fExit:=.f.

nOldCurs:=if(setcursor()==0,0,iif(readinsert(),2,1))
cOldColor:=setcolor()
set cursor off

nWidth:=y2-y1
nLen:=LEN(Items)

@ x1,y1 CLEAR TO x2-1,y2

for i:=1 to nLen
	if i==nItemNo
   		if left(cOldColor,3)==left(Normal,3)
        		setcolor(Invert)
   		else
   			setcolor(Normal)
   		endif
 	else
   		setcolor(cOldColor)
 	endif
 	@ x1+i-1,y1 SAY PADR(Items[i],nWidth)
next

fFirst:=.t.

do while .t.
	SetColor(Invert)
	SetColor(cOldColor)
	if !fFirst
		setcolor(cOldColor)
		@ x1+nOldItemNo-1,y1 SAY PADR(Items[nOldItemNo],nWidth)
		if left(cOldColor,3)==left(Normal,3)
			setcolor(Invert)
		else
			setcolor(Normal)
		endif
		@ x1+nItemNo-1,y1 SAY PADR(Items[nItemNo],nWidth)
	endif
	fFirst:=.f.

	if fExit
   		exit
	endif

	nChar:=WaitScrSav()
	nOldItemNo:=nItemNo

	do case
      		case nChar==K_ESC
        		nItemNo:=0
        		exit
      		case nChar==K_HOME
        		nItemNo:=1
      		case nChar==K_END
        		nItemNo:=nLen
      		case nChar==K_DOWN
        		nItemNo++
      		case nChar==K_UP
        		nItemNo--
      		case nChar==K_ENTER
        		exit
      		case IsAlpha(Chr(nChar)) .or. IsDigit(Chr(nChar))
        		for ii:=1 to nLen
          			// cifra
          			if IsDigit(chr(nChar)) 
            				if Chr(nChar) $ left(Items[ii],3) 
						// provjera postojanja
             					nItemNo:=ii          
	     					// broja u stavki samo 
						// u prva 3 karaktera
             					fexit:=.t.
            				endif             
          			else 
					// veliko slovo se trazi 
					// po citavom stringu
            				if UPPER(Chr(nChar)) $ Items[ii]
              					nItemNo:=ii
              					fexit:=.t.
            				endif
          			endif
        		next
      		
		case nChar == K_CTRL_N
			nCtrlKeyVal := 10000
			exit
		case nChar == K_F2
			nCtrlKeyVal := 20000
			exit
		case nChar == K_CTRL_T
			nCtrlKeyVal := 30000
			exit
		otherwise
         		goModul:GProc(nChar)
   	endcase
   	
	if nItemNo > nLen
        	nItemNo--
   	endif
   	
	if nItemNo < 1
		nItemNo++
	endif
enddo

setcursor(iif(nOldCurs==0,0,iif(readinsert(),2,1)))
setcolor(cOldColor)

return nItemNo + nCtrlKeyVal

/*! \fn AChoice3(x1,y1,x2,y2,Items,f1,cFunc,nItemNo)
 *  \brief AChoice za broj stavki > 16
 *  \todo Ugasiti stari Achoice ??, ne trebaju nam dva
 */
 
function AChoice3(x1,y1,x2,y2,Items,f1,cFunc,nItemNo)
*{

local i,ii,nWidth,nLen,fExit,fFirst,nOldCurs,cOldColor,nOldItemNo,cSavC
local nGornja
local nVisina
local nCtrlKeyVal := 0

if nItemNo==0
   return nItemNo
endif

fExit:=.f.

nOldCurs:=if(setcursor()==0,0,iif(readinsert(),2,1))
cOldColor:=setcolor()
set cursor off

nWidth:=y2-y1
nLen:=LEN(Items)
nVisina:=x2-x1
nGornja:=IF(nItemNo>nVisina,nItemNo-nVisina+1,1)

@ x1,y1 CLEAR TO x2-1,y2

do while .t. // ovu liniju sam premjestio odozdo radi korektnog ispisa

IF nVisina<nLen
 @   x2,y1+INT((y2-y1)/2) SAY IF(nGornja==1,"  ",IF(nItemNo==nLen,"ÕÕÕ","  "))
 @ x1-1,y1+INT((y2-y1)/2) SAY IF(nGornja==1,"ÕÕÕ",IF(nItemNo==nLen,"  ","  "))
ENDIF
for i:=nGornja to nVisina+nGornja-1
 if i==nItemNo
   if left(cOldColor,3)==left(Normal,3);  setcolor(Invert); else; setcolor(Normal); endif
 else
   setcolor(cOldColor)
 endif
 @ x1+i-nGornja,y1 SAY PADR(Items[i],nWidth)
next


SetColor(Invert)
SetColor(cOldColor)

   if fExit; exit; endif

   nChar:=WaitScrSav()

   nOldItemNo:=nItemNo
   do case
      case nChar==K_ESC
        nItemNo:=0
        exit
      case nChar==K_HOME
        nItemNo:=1
      case nChar==K_END
        nItemNo:=nLen
      case nChar==K_DOWN
        nItemNo++
      case nChar==K_UP
        nItemNo--
      case nChar==K_ENTER
        exit
      case IsAlpha(Chr(nChar)) .or. IsDigit(Chr(nChar))
        for ii:=1 to nLen
          if IsDigit(chr(nChar)) // cifra
            if Chr(nChar) $ left(Items[ii],3) // provjera postojanja
             nItemNo:=ii          // broja u stavki samo u prva 3 karaktera
             fexit:=.t.
            endif             
          else // veliko slovo se trazi po citavom stringu - promijenjeno
	    if (Items[ii]<>NIL) .and. UPPER(Chr(nChar)) $ LEFT(Items[ii],3)  
              nItemNo:=ii                             
              fexit:=.t.                              
            endif
          endif
        next
       
       case nChar == K_CTRL_N
       	   nCtrlKeyVal := 10000
	   exit
       case nChar == K_F2
           nCtrlKeyVal := 20000
	   exit
       case nChar == K_CTRL_T
           nCtrlKeyVal := 30000
	   exit
      otherwise
        goModul:GProc(nChar)
   endcase
   if nItemNo>nLen; nItemNo--; endif
   if nItemNo<1; nItemNo++; endif
   nGornja:=IF(nItemNo>nVisina,nItemNo-nVisina+1,1)
enddo
setcursor(iif(nOldCurs==0,0,iif(readinsert(),2,1)))
setcolor(cOldColor)
return nItemNo + nCtrlKeyVal
*}

// ------------------------------------
// ------------------------------------
function Menu2(x1,y1,aNiz,nIzb)
LOCAL xM:=0,yM:=0
 xM:=LEN(aNiz); AEVAL(aNiz,{|x| IF(LEN(x)>yM,yM:=LEN(x),)})
 Prozor1(x1,y1,x1+xM+1,y1+yM+1,,,,,,0)
 nIzb:=ACHOICE2(x1+1, y1+1, x1+xM, y1+yM, aNiz,, "KorMenu2", nIzb)
 Prozor0()
return nIzb

function Menu3(x1,y1,aNiz,nIzb,cNasl)
*{
LOCAL xM:=0,yM:=0
 xM:=LEN(aNiz); AEVAL(aNiz,{|x| x:=" "+x+" ",IF(LEN(x)>yM,yM:=LEN(x),)})
 h:=ARRAY(LEN(aNiz))
 AFILL(h,"")
 Prozor1(x1,y1,x1+xM+2,y1+yM+1,cNasl,,B_DOUBLE+" ",,,0)
 @ x1+1,y1 SAY "Ã"+REPLICATE("Õ",yM)+"π"
 IF LEN(aNiz)>16
  nIzb:=ACHOICE3(x1+2,y1+1,x1+xM+2,y1+yM,aNiz,,"KorMenu2",nIzb)
 ELSE
  nIzb:=ACHOICE2(x1+2,y1+1,x1+xM+2,y1+yM,aNiz,,"KorMenu2",nIzb)
 ENDIF
 Prozor0()
return nIzb
*}

function KorMenu2
*{ 
 LOCAL nVrati:=2,nTipka:=LASTKEY()
 DO CASE
   CASE nTipka==K_ESC
     nVrati:=0
   CASE nTipka==K_ENTER
     nVrati:=1
 ENDCASE
return nVrati
*}

function Prozor1(v1,h1,v2,h2,cNaslov,cBojaN,cOkvir,cBojaO,cBojaT,nKursor)
*{

LOCAL cPom:=SET(_SET_DEVICE)
 
SET DEVICE TO SCREEN
IF cBojaN==NIL
	cBojaN:="GR+/N"
ENDIF
IF cOkvir==NIL
	cOkvir:=B_SINGLE+" "
ENDIF
IF nKursor==NIL
	nKursor:=SETCURSOR()
ENDIF
StackPush( aPrStek , { row(),col(),v1, h1, v2, h2, SAVESCREEN(v1,h1,v2,h2),;
                        SETCOLOR(cBojaT), SETCURSOR(nKursor)     } )
DISPBox(v1,h1,v2,h2,cOkvir,cBojaO)
@ v1+1,h1+1 CLEAR TO v2-1,h2-1
IF cNaslov!=NIL
   @ v1,(h2+h1+-1-LEN(cNaslov))/2 SAY " "+cNaslov+" " COLOR cBojaN
ENDIF
SET(_SET_DEVICE,cPom)
return
*}

function Prozor0()
*{
local aSt:=StackPop(aPrStek)
local cPom:=SET(_SET_DEVICE)

SET DEVICE TO SCREEN
RESTSCREEN(aSt[3],aSt[4],aSt[5],aSt[6],aSt[7])
SETCOLOR(aSt[8])
SETCURSOR(aSt[9])
@ aSt[1],aSt[2] SAY ""
SET(_SET_DEVICE,cPom)
return
*}


/*! \fn Postotak(nIndik,nUkupno,cTekst,cBNasl,cBOkv,lZvuk)
*   \brief Prikaz procenta uradjenog posla
*
* Ova fja omogucava prikaz procenta uradjenog posla, sto je efektno
* kod stanja cekanja da program uradi neki posao. Pise se najmanje tri puta
* u dijelu programa gdje se rjesava taj dugotrajni posao, s tim da se prvi
* parametar stavlja da je 1 pri prvom pozivu, 2 pri drugom, a 0 pri okoncanju
* posla. Pri prvom pozivu ove procedure potrebno je jos navesti i cio broj
* koji oznacava kolicinu posla koji treba biti uradjen, kao i tekst koji
* opisuje sta se radi. Pri drugom pozivu koji se nalazi najcesce u nekoj
* petlji drugi parametar je cio broj koji govori o kolicini uradjenog posla.
* Zadnji poziv ima samo parametar 0 i oznacava kraj posla.
*
* \code
*
*  O_RADOVI
*  Postotak(1,RECCOUNT2(),"Formiranje cijena")
*  GO TOP
*  DBEVAL({|| NCijene(FIELDGET(3),FIELDGET(1)),Postotak(2,++nPosto)})
*  Postotak(0)
*
* \encode
*
*/

function Postotak(nIndik,nUkupno,cTekst,cBNasl,cBOkv,lZvuk)
*{
 STATIC nCilj,cKraj,cNas,cOkv
 LOCAL nKara:=0,cPom:=SET(_SET_DEVICE)
 IF lZvuk==NIL; lZvuk:=.t.; ENDIF
  SET DEVICE TO SCREEN
  DO CASE
    CASE nIndik==1
      cOkv:=IF(cBOkv==NIL,"W+/N",cBOkv)
      cNas:=IF(cBNasl==NIL,"GR+/N",cBNasl)
      nCilj:=nUkupno
      cKraj:=cTekst+" zavrseno."
      Prozor1(10,13,14,66,cTekst+" u toku...",cNas,,cOkv,"B/W",0)
      @ 12,15 SAY REPLICATE("∞",50) COLOR "B/W"
      IF lZvuk; TONE(1900,0); ENDIF
    CASE nIndik==2
      nKara=INT(50*nUkupno/nCilj)
      @ 12,15 SAY REPLICATE("≤",nKara) COLOR "B/BG"
      @ 13,37 SAY STR(2*nKara,3)+" %" COLOR "B/W"
    CASE nIndik<=0
      @ 10,(78-LEN(cKraj))/2 SAY " "+cKraj+" " COLOR cNas
      IF lZvuk; TONE(2000,0); ENDIF
      IF nIndik==0
       DO WHILE INKEY()==0
         OL_Yield()
         @ 14,28 SAY "<pritisnite neku tipku>" COLOR IF(INT(SECONDS()*1.5)%2==0,"W/","W+/")+RIGHT(cOkv,1)
       ENDDO
      ENDIF
      Prozor0()
      nCilj:=0; cKraj:=""
  ENDCASE
  SET(_SET_DEVICE,cPom)
return
*}


/*! \fn LomiGa(cTekst,nOrig,nLin,nDuz)
 * \brief Formatira tekst u varijabli 'cTekst'
 *
 * To se radi prema zeljenom ispisu u 'nLin'
 * redova duzine 'nDuz'. Pri tom uklanja znak "-" koji se javlja pri
 * lomljenju rijeci. 'nOrig' je broj redova proslog formata 'cTekst'-a.
 * Ako nLin nije zadano ili je 0, nLin se formira prema duzini teksta
 *
 */

function LomiGa(cTekst,nOrig,nLin,nDuz)
*{

  LOCAL nTek:=LEN(cTekst), aPom:={}, i:=0, nDO, cPom:="", cPom2:=""
  IF nLin==NIL; nLin:=0; ENDIF


  nDO:=INT(nTek/nOrig)
  FOR i:=1 TO nOrig
    AADD( aPom, SUBSTR( cTekst, (i-1)*nDO+1, nDO))
    cPom:=ALLTRIM(aPom[i])
    IF RIGHT(cPom,1)=="-".AND.!(SUBSTR(cPom,-2,1) $ " 1234567890")
      aPom[i]:=LEFT(cPom,LEN(cPom)-1)
    ELSEIF RIGHT(cPom,1)=="-".AND.EMPTY(SUBSTR(cPom,-2,1))
      aPom[i]:=cPom+" "
    ELSEIF RIGHT(cPom,1)!="-"
      aPom[i]:=cPom+" "
    ELSE
      aPom[i]:=cPom
    ENDIF
  NEXT
  cPom:=""; cTekst:=""; AEVAL(aPom,{|x| cPom+=x})
  cPom2:=RTRIM(cPom)
  IF nLin==0; nLin:=INT(LEN(cPom)/nDuz)+IF(MOD(LEN(cPom),nDuz)!=0,1,0); ENDIF
  cPom2:=PADR(cPom2,nLin*nDuz)

  i:=0
  DO WHILE .t.
    ++i
    cPom:=MEMOLINE(cPom2,nDuz,i)
    IF LEN(cPom)<1.or.EMPTY(cPom).and.i>nLin
      EXIT
    ELSE
      cTekst+=cPom
    ENDIF
  ENDDO

return cTekst
*}

/*! \fn KudaDalje(cTekst, aOpc, cPom)
 *  \brief Meni od maksimalno 15 opcija opisanih u nizu aOpc
 *
 * Naslov menija je
 * cTekst, a cPom je oznaka za "Help"
 * Vraca redni broj opcije koja je izabrana. Na pritisak <Esc> vraca se
 * broj zadnje opcije u nizu (kao da je ona izabrana).
 */

function KudaDalje(cTekst,aOpc,cPom)
*{
LOCAL nVrati:=1,nTipka,i:=0,nOpc:=LEN(aOpc),nRedova:=1,p:=0
  LOCAL nXp:=0,aTxt:={},cPom1,cPom2
  //IF cPom!=NIL; PushHT(cPom); ENDIF
  FOR i:=1 TO nOpc
    cPom1:=PADC(ALLTRIM(MEMOLINE(aOpc[i],16,1)),16)
    cPom2:=PADC(ALLTRIM(MEMOLINE(aOpc[i],16,2)),16)
    AADD(aTxt,{cPom1,cPom2})
  NEXT
  nRedova:=INT((nOpc-1)/3+1)
  nXp:=INT((25-nRedova*4-2)/2)+2
  Prozor1(nXp-2,4,nXp+1+4*nRedova,75,,"N/W","≤ﬂ≤≤≤‹≤≤ ","N/W","W/W",0)
  @ nXp-1, 5 SAY PADC(cTekst,70) COLOR "N/W"
  DO WHILE .t.
    FOR j=1 TO nRedova
     FOR i=1 TO 3
       IF (p:=3*(j-1)+i)<=nOpc
        DISPBox(nXp+1+4*(j-1),22*i-13,nXp+4+4*(j-1),22*i+4,1,IF(p==nVrati,"W+/N","N/W"))
        @ nXp+2+4*(j-1),22*i-12 SAY aTxt[p,1] COLOR IF(p==nVrati,"W+/N","N/W")
        @ nXp+3+4*(j-1),22*i-12 SAY aTxt[p,2] COLOR IF(p==nVrati,"W+/N","N/W")
       ENDIF
     NEXT
    NEXT

    CLEAR TYPEAHEAD
    DO WHILE NEXTKEY()==0; OL_YIELD(); ENDDO
    nTipka:=INKEY()

    DO CASE
     CASE nTipka==K_UP
        nVrati-=3; IF(nVrati<1,nVrati+=3,)
     CASE nTipka==K_DOWN
        nVrati+=3; IF(nVrati>nOpc,nVrati-=3,)
     CASE nTipka==K_LEFT
        nVrati--; IF(nVrati<1,nVrati++,)
     CASE nTipka==K_RIGHT
        nVrati++; IF(nVrati>nOpc,nVrati--,)
     CASE nTipka==K_ENTER
        EXIT
     CASE nTipka==K_ESC
        nVrati:=nOpc
        EXIT
     CASE nTipka==K_F1.and.cPom!=NIL
        //Help()
     CASE nTipka==K_F12.and.cPom!=NIL
        //Help2()
    ENDCASE
  ENDDO
  Prozor0()
return nVrati
*}

function Ocitaj(nObl,xKljuc,nPbr,lInd)
*{

// vraca trazeno polje (nPbr+1) iz
// sifrarn.za zadanu vrijednost indeksa 'xKljuc'
// Primjer : xRez:=Ocitaj(F_VALUTE,"D","naz2")

 LOCAL xVrati
 IF lInd==NIL; lInd:=.f.; ENDIF
 private cPom:=""
 if valtype(nPbr)=="C"
   cPom:=nPbr  // za makro evaluaciju mora biti priv varijabla
 endif

 PushWA()
 SELECT (nObl)
 SEEK xKljuc
  xPom:=IF(VALTYPE(nPbr)=="C",&cPom,FIELDGET(1+nPbr))
  IF lInd
    xVrati:=IF(FOUND(),xPom,BLANK(xPom))
  ELSE
    xVrati:=IF(FOUND(),xPom,SPACE(LENx(xPom)))
  ENDIF
  PopWA()
return xVrati
*}

function LENx(xVrij)
*{
 LOCAL cTip:=VALTYPE(xVrij)
return IF(cTip=="D",8,IF(cTip=="N",LEN(STR(xVrij)),LEN(xVrij)))
*}


function SrediDat(d_ulazni)
*{

  LOCAL pomocni
  IF EMPTY(d_ulazni)==.F.
     pomocni:=STUFF(DTOC(d_ulazni),7,0,STR(INT(YEAR(d_ulazni)/100),2,0))+".godine"
  ELSE
     pomocni:=SPACE(17)
  ENDIF
return pomocni
*}

function AutoSifra(nObl,cSifra)
*{

IF cSifra!=NIL.and.LEN(ALLTRIM(cSifra))>1.and.gAutoSif=="D"
   PushWA()
   SELECT (nObl)
   SEEK cSifra
   IF !FOUND()
     KEYBOARD CHR(K_CTRL_N)+ALLTRIM(cSifra)
   ENDIF
   PopWA()
 ENDIF
return
*}


function CistiTipke()
*{

 KEYBOARD CHR(0)
 DO WHILE !INKEY()==0; ENDDO
return
*}

function AMFILL(aNiz,nElem)
*{

 LOCAL i:=0,rNiz:={},aPom:={}
 FOR i:=1 TO nElem
  AEVAL(aNiz,{|x| AADD(aPom,x)})
  AADD(rNiz,aPom)
  aPom:={}
 NEXT
return rNiz
*}

function KonvZnakova(cTekst)
*{

 // jedan par: { 7-bit znak, 852 znak }
 LOCAL aNiz:={  {"[","Ê"}, {"{","Á"}, {"}","Ü"}, {"]","è"}, {"^","¨"},;
                {"~","ü"}, {"`","ß"}, {"@","¶"}, {"|","–"}, {"\","—"}  }
 LOCAL i,j
 IF "U" $ TYPE("g852"); g852:="D"; ENDIF
 IF g852=="D"
   i:=1; j:=2
 ELSE
   i:=2; j:=1
 ENDIF
 AEVAL(aNiz,{|x| cTekst:=STRTRAN(cTekst,x[i],x[j])})
return cTekst
*}

function Zvuk(nTip)
*{

 IF nTip==NIL; nTip:=0; ENDIF
 DO CASE
   CASE nTip==1
     Tone(400,2)
   CASE nTip==2
     Tone(500,2)
   CASE nTip==3
     Tone(600,2)
   CASE nTip==4
     Tone(700,2)
 ENDCASE
return
*}


function ShemaBoja(cIzbor)
*{
 LOCAL cVrati:=cbshema
 IF ISCOLOR()
   DO CASE
     CASE cIzbor=="B1"
        cbnaslova := "GR+/N"
        cbokvira  := "GR+/N"
        cbteksta  := "W/N  ,R/BG ,,,B/W"
     CASE cIzbor=="B2"
        cbnaslova := "N/G"
        cbokvira  := "N/G"
        cbteksta  := "W+/G ,R/BG ,,,B/W"
     CASE cIzbor=="B3"
        cbnaslova := "R+/N"
        cbokvira  := "R+/N"
        cbteksta  := "N/GR ,R/BG ,,,B/W"
     CASE cIzbor=="B4"
        cbnaslova := "B/BG"
        cbokvira  := "B/W"
        cbteksta  := "B/W  ,R/BG ,,,B/W"
     CASE cIzbor=="B5"
        cbnaslova := "B/W"
        cbokvira  := "R/W"
        cbteksta  := "GR+/N,R/BG ,,,B/W"
     CASE cIzbor=="B6"
        cbnaslova := "B/W"
        cbokvira  := "R/W"
        cbteksta  := "W/N,R/BG ,,,B/W"
     CASE cIzbor=="B7"
        cbnaslova := "B/W"
        cbokvira  := "R/W"
        cbteksta  := "N/G,R+/N ,,,B/W"
     OTHERWISE
   ENDCASE
 ELSE
        cbnaslova := "N/W"
        cbokvira  := "N/W"
        cbteksta  := "W/N  ,N/W  ,,,N/W"
 ENDIF
 cbshema:=cIzbor
return cVrati
*}


function NForma1(cPic)
*{

 LOCAL nPoz:=0,i:=0
 cPic:=ALLTRIM(cPic)
 nPoz:=AT(".",cPic)
 IF nPoz==0.and.!EMPTY(cPic); nPoz:=LEN(cPic)+1; ENDIF
 FOR i:=1 TO INT((nPoz-2)/3)
   cPic:=STUFF(cPic,nPoz-i*3,0," ")
 NEXT
return cPic
*}

function NForma2(cPic)
*{
return ( cPic := STRTRAN(NForma1(cPic)," ",",") )
*}

function FormPicL(cPic,nDuz)
*{

 LOCAL nDec,cVrati,i,lZarez:=.f.,lPrazno:=.f.
 cPic:=ALLTRIM(cPic)
 nDec:=RAT("9",cPic)-AT(".",cPic)
 IF nDec>=LEN(cPic).or.nDec<0; nDec:=0; ENDIF
 cVrati:=SPACE(nDuz)
 IF AT(",",cPic)!=0
   lZarez:=.t.
 ELSEIF AT(" ",cPic)!=0
   lPrazno:=.t.
 ENDIF
 FOR i:=1 TO nDuz
   IF i==nDec+1.and.nDec!=0
     cVrati:=STUFF(cVrati,nDuz-i+1,1,".")
   ELSEIF i>nDec+2.and.MOD(i-IF(nDec==0,0,nDec+1),4)==0.and.lZarez.and.i!=nDuz
     cVrati:=STUFF(cVrati,nDuz-i+1,1,",")
   ELSEIF i>nDec+2.and.MOD(i-IF(nDec==0,0,nDec+1),4)==0.and.lPrazno
     cVrati:=STUFF(cVrati,nDuz-i+1,1," ")
   ELSE
     cVrati:=STUFF(cVrati,nDuz-i+1,1,"9")
   ENDIF
 NEXT
return cVrati

*}

function VarEdit(aNiz,x1,y1,x2,y2,cNaslov,cBoje)
*{
LOCAL GetList:={},cbsstara:=ShemaBoja(cBoje),pom1,pom3,pom4,pom5,nP:=0
LOCAL cPomUI:=SET(_SET_DEVICE)

SET DEVICE TO SCREEN
  Prozor1(x1,y1,x2,y2,cNaslov,cbnaslova,,cbokvira,cbteksta,2)
   FOR i:=1 TO LEN(aNiz)
    cPom:=aNiz[i,2]
    IF aNiz[i,3]==NIL .or. LEN(aNiz[i,3])==0; aNiz[i,3]:=".t."; ENDIF
    IF aNiz[i,4]==NIL .or. LEN(aNiz[i,4])==0; aNiz[i,4]:=""; ENDIF
    IF aNiz[i,5]==NIL .or. LEN(aNiz[i,5])==0; aNiz[i,5]:=".t."; ENDIF
    IF "##" $ aNiz[i,3]
      nP:=AT("##",aNiz[i,3])
      pom3:="ValGeta(" + LEFT(aNiz[i,3],nP-1) + ",'" + SUBSTR(aNiz[i,3],nP+2) + "')"
    ELSE
      pom3:=aNiz[i,3]
    ENDIF
    pom1:=aNiz[i,1]; pom4:=aNiz[i,4]; pom5:=aNiz[i,5]
    @ x1+1+i,y1+2 SAY PADR(pom1,y2-y1-4-IF("S" $ pom4,DuzMaske(pom4), IF(EMPTY(pom4),LENx(&(cPom)),LEN(TRANSFORM(&cPom,pom4)))),".") GET &cPom WHEN &pom5 VALID &pom3 PICT pom4
   NEXT
   PRIVATE MGetList:=GetList
   READ
  Prozor0()
  ShemaBoja(cbsstara)
  SET(_SET_DEVICE,cPomUI)
return IF(LASTKEY()!=K_ESC,.t.,.f.)
*}

function ValGeta(lUslov,cPoruka)
*{
IF !lUslov; Msg(cPoruka,3); ENDIF
return lUslov
*}


function DuzMaske(cPicture)
*{
LOCAL nPozS:=AT("S",cPicture)
return VAL(SUBSTR(cPicture,nPozS+1))
*}


function MsgBeep(cxx)
if !gAppSrv
	Beep(2) 
endif
Msg(cxx,20)

return



function UGlavnomMeniju()
*{

local i
local fRet:=.t.

if goModul:oDataBase:cName=="LD"
	return fRet
endif

PushWa()
for i:=1 to 100
  select (i)
  if used()
    MsgBeep("Ova opcija je raspoloziva samo iz osnovnog menija")
    fRet:=.f.
    exit
  endif
next
PopWa()
return fret
*}

function KorLoz()
*{
if !system
  cSecur:=SecurR(kLevel,"PromSif")
  if ImaSlovo("X",cSecur)
     MsgBeep("Opcija nedostupna!")
     return
  endif
endif

O_KORISN

m_kor=SPACE(10)
m_sif=SPACE(6)
m_sif2=SPACE(6)

Box("pl",2,31,.F.,"Izmjena vase sifre")
SET CURSOR ON
@ m_x+1,m_y+2 SAY "Stara sifra........"  GET m_sif PICTURE "@!"
@ m_x+2,m_y+2 SAY "Nova sifra........."  GET m_sif2 PICTURE "@!"
READ; ESC_BCR
BoxC()


locate for alltrim(ImeKorisn)==alltrim(ime) .and. SifraKorisn=sif
IF FOUND()
  IF !gReadonly .and. sif==CRYPT(m_sif)
    REPLACE sif WITH CRYPT(m_sif2)
    SifraKorisn:=CRYPT(m_sif2)
  ELSE

  Msg("Sifra nije ispravna!",5)

  END IF
END IF

closeret
return
*}

function ispisiSez()
*{
@ 3,70 SAY "Sez: "+goModul:oDataBase:cSezona COLOR INVERT
return
*}


/*! \fn SecurR(cLevel, cStavka)
 *
 * \return A - moze sve, administrator, C - citaj, P - pisi, B - brisi, N - nedostupno, T - tekuca aktivnost - nije specijalno definisano
 *
 * \note return vrijednost moze biti i kombinacija  CP - citaj i pisi, ali ne brisi
 */
 
function SecurR(cLevel,cStavka)
local cK1:="AT", fZatv:=.f., nSelect

nSelect:=select()

SELECT (F_SECUR)
if !used()
  O_SECUR
  fZatv:=.t.
endif
private cSection:=cLevel,cHistory:=" "; aHistory:={}
RPar(padr(UPPER(cStavka),15),@cK1)

if fzatv
  use
endif

select(nSelect)
return cK1

// ----------------------------
// ----------------------------
function ElibVer()
return SC_LIB_VER

function ZaSvakiSlucaj(cDir,fCdx,aDirs,fRecurse)
*{
local fRet:=.t.
local i
local cScr
local cIme
local aFiles
local cPom

if fCDX==NIL
 fCdx:=.t.
endif
if cdir==NIL
 cDir:="."+SLASH
endif
if frecurse=NIL
 fRecurse:=.t.
endif


aFiles:=DIRECTORY(cDir+"*.ART")
// izbrisi sve starije od 40 dana

ASORT(aFiles,,,{|x,y| x[3]<y[3]})

for i:=1 to len(aFiles)-4
   ferase(cDir+aFiles[i,1])
next

cIme:=cDir+right(dtos(date()),6)
for i:=1 to 99
 if !file(cIme+alltrim(str(i))+".ART")
     cIme:=cIme+alltrim(str(i))+".ART"
     exit
 endif
next

cKom:="ARJ A"+iif(fRecurse," -r","")+" -jf -x*.ar? -x*.exe -x*.bak -x*.ntx "
if !fCdx; cKom+=" -x*.CDX "; endif
ckom+=cIme+" !list.cmd"

save screen to cScr

cls
?
? "Izvrsavam komandu arhviranja:"
? cKom
?
? "Budite strpljivi ..... ovo su VASI PODACI !"
?
? "list.cmd:"
if aDirs==NIL
  aDirs:={}
  AADD(aDirs,cDirRad)
  AADD(aDirs,cDirSif)
  AADD(aDirs,cDirPriv)
endif

for i:=1 to len(aDirs)
  ? adirs[i]
next

? "Pritisni <ENTER> za nastavak ...."

cSep:="*.*"+chr(13)+chr(10)

cPom:=""
for i:=1 to len(aDirs)
  cPom+=trim(aDirs[i])+iif(RIGHT(trim(aDirs[i]),1)=="\","","\")+cSep
next
if strfile(cPom,"list.cmd")=0
  fret:=.f.
endif

if len(aDirs)=0
  restore screen from cScr
  return .t.
endif

inkey(5)
?
if !swpruncmd(cKom,0,"","")
  fret:=.f.
endif
if swperrlev()<>0
 fRet:=.f.
endif
inkey(10)

restore screen from cScr
if !fret
  if pitanje(,"Zastita nije uspjela. Nastaviti ?","N")=="N"
   goModul:quit()
  endif
endif
return fret
*}

function NaslEkran(fBox)
*{
if fbox
	clear
endif

@ 0,2 SAY '<ESC> Izlaz' COLOR INVERT
@ 0,COL()+2 SAY DATE()  COLOR INVERT
@ 24,64  SAY ELIBVER()

DISPBox(2,0,4,79,B_DOUBLE+' ',NORMAL)

if fbox
	DISPBox(5,0,24,79,B_DOUBLE+"±",INVERT)
endif

@ 3,1 SAY PADC(gNaslov+' Ver.'+gVerzija,72) COLOR NORMAL
return
*}

function StandardBoje()
*{
public  Invert
public  Normal
public  Blink
public  Nevid

if TYPE("gFKolor")<>"C"
	gFKolor:="D"
endif

#ifdef CLIP
	Invert:="B/W,R/N+,,,R/B+"
	Normal:="W/B,R/N+,,,N/W"
	Blink:="R"+REPLICATE("*",4)+"/W,W/B,,,W/RB"
	Nevid:="W/W,N/N"
#else
if (gFKolor=="D" .and. ISCOLOR())

	Invert:="B/W,R/N+,,,R/B+"
	Normal:="W/B,R/N+,,,N/W"
	Blink:="R"+REPLICATE("*",4)+"/W,W/B,,,W/RB"
	Nevid:="W/W,N/N"
else

	Invert:="N/W,W/N,,,W/N"
	Normal:="W/N,N/W,,,N/W"
	Blink:="N"+REPLICATE("*",4)+"/W,W/N,,,W/N"
	Nevid:="W/W,N/N"
endif
#endif

return nil
*}

function PDVBoje()
*{
public  Invert
public  Normal
public  Blink
public  Nevid

if TYPE("gFKolor")<>"C"
	gFKolor:="D"
endif

#ifdef CLIP
	Invert:="B/W,R/N+,,,R/B+"
	Normal:="W/B,R/N+,,,N/W"
	Blink:="R"+REPLICATE("*",4)+"/W,W/B,,,W/RB"
	Nevid:="W/W,N/N"
#else
if (gFKolor=="D" .and. ISCOLOR())

	Invert:="B/W,R/N+,,,R/B+"
	Normal:="W/G,R/N+,,,N/W"
	Blink:="R"+REPLICATE("*",4)+"/W,W/B,,,W/RB"
	Nevid:="W/W,N/N"
else

	Invert:="N/W,W/N,,,W/N"
	Normal:="W/N,N/W,,,N/W"
	Blink:="N"+REPLICATE("*",4)+"/W,W/N,,,W/N"
	Nevid:="W/W,N/N"
endif
#endif

return nil
*}



function BtoEU(cInput) 
*{
local i,cpom, cChar, cChar2,nPos, fdupli
local cBTOETABLE
local cbMala
local cBVelika

IF gKodnaS=="7"
 cBTOETAble:="ABC^]D\˘EFGHIJKL˙MN˚OPRS[TUVZ@"
 // 249,250,251
 cBMala  :="~Ü–Áß"    // !!!!! ispraviti !!!
 cBVelika:="^è—Ê¶"

else
 cBTOETAble:="ABC¨èD—˘EFGHIJKL˙MN˚OPRSÊTUVZ¶"
 cBMala  :="üÜ–Áß"
 cBVelika:="¨è—Ê¶"
endif

cPom:=""

for i:=1 to len(cInput)
  cChar:=substr(cInput,i,1)
  cChar:=Upper(cChar)
  if (nPos:=AT(cChar,cBMALA))<>0
     cChar:=substr(cBVelika,npos,1)  // pretvori u velika
  endif

  fDupli:=.f.  // slova D¶, NJ, LJ
  if (cChar="D" .and. substr(cInput,i+1,1)="¶")
     nPos:=AT("˘",cBTOETABLE)+1   //LJ
     fDupli:=.t.
  elseif (cChar="L" .and. substr(cInput,i+1,1)="J")
     nPos:=AT("˙",cBTOETABLE)+1   //LJ
     fDupli:=.t.
  elseif (cChar="N" .and. substr(cInput,i+1,1)="J")
     nPos:=AT("˚",cBTOETABLE)
     fDupli:=.t.
  else
     nPos:=AT(cChar,cBTOETAble)
  endif
  if nPos<>0
    cPom+=chr(nPos+64)
    if fdupli; ++i; cPom+=" ";endif
  else
    cPom+=cChar
  endif
next

return cPom
*}

/*! \fn TokUNiz(cTok,cSN,cSE)
 *  \brief Token pretvori u matricu
 *  \param cTok - string tokena
 *  \param cSN - separator nizova
 *  \param cSE - separator elemenata
 */

function TokUNiz(cTok,cSN,cSE)
*{
LOCAL aNiz:={}, nN:=0, nE:=0, aPom:={}, i:=0, j:=0, cTE:="", cE:=""
  IF cSN==NIL ; cSN := ";" ; ENDIF
  IF cSE==NIL ; cSE := "." ; ENDIF
  nN := NUMTOKEN(cTok,cSN)
  FOR i:=1 TO nN
    cTE := TOKEN(cTok,cSN,i)
    nE  := NUMTOKEN(cTE,cSE)
    aPom:={}
    FOR j:=1 TO nE
      cE := TOKEN(cTE,cSE,j)
      AADD(aPom,cE)
    NEXT
    AADD(aNiz,aPom)
  NEXT
return (aNiz)
*}

/*! \fn TxtUNiz(cTxt,nKol)
 *  \brief Pretvara TXT u niz
 *  \param cTxt   - tekst
 *  \param nKol   - broj kolona
 */
 
function TxtUNiz(cTxt,nKol)
*{
LOCAL aVrati:={}, nPoz:=0, lNastavi:=.t., cPom:="", aPom:={}, i:=0
  cTxt:=TRIM(cTxt)
  DO WHILE lNastavi
    nPoz := AT( CHR(13)+CHR(10) , cTxt )
    IF nPoz>0
      cPom:=LEFT(cTxt,nPoz-1)
      IF nPoz-1>nKol
        cPom:=TRIM( LomiGa(cPom,1,5,nKol) )
        FOR  i:=1  TO  INT( (LEN(cPom)-1)/nKol ) + 1
          AADD( aVrati , SUBSTR( cPom , (i-1)*nKol+1 , nKol ) )
        NEXT
      ELSE
        AADD( aVrati , cPom )
      ENDIF
      cTxt := SUBSTR( cTxt , nPoz+2 )
    ELSEIF !EMPTY(cTxt)
      cPom:=TRIM(cTxt)
      IF LEN(cPom)>nKol
        cPom:=TRIM( LomiGa(cPom,1,5,nKol) )
        FOR  i:=1  TO  INT( (LEN(cPom)-1)/nKol ) + 1
          AADD( aVrati , SUBSTR( cPom , (i-1)*nKol+1 , nKol ) )
        NEXT
      ELSE
        AADD( aVrati , cPom )
      ENDIF
      lNastavi := .f.
    ELSE
      lNastavi := .f.
    ENDIF
  ENDDO
RETURN aVrati
*}



function MsgBeep2(cTXT)
*{
@ 24,0 SAY PADL(cTXT,80) COLOR "R/W"
Tone(900,0.3)
return
*}

function Reci(x,y,cT,nP)
*{
LOCAL px:=ROW(),py:=COL()
 IF nP==40 .and. (x==11 .and. y==23 .or. x==12 .and. y==23 .or. x==12 .and. y==24 .or. x==12 .and. y==25)
   nP+=6
 ENDIF
 IF nP==NIL; nP:=0; ENDIF
 @ m_x+x,m_y+y SAY IF(nP>0,SPACE(nP),"")
 @ m_x+x,m_y+y SAY cT
 SETPOS(px,py)
return
*}

function ShowKorner(nS, nStep, nDelta)
*{
static i:=0
local cpom

//nS - tekuca vrijednost

if nS==0
  i:=0
elseif nS==1
  i++
else
  i:=nS
endif
if ndelta=NIL
  nDelta:=0
endif
if i%nstep=0
  cPom:=SET(_SET_DEVICE)
  SET DEVICE TO SCREEN
  @ 24,73-nDelta say  i pict "999999"
  SET(_SET_DEVICE,cPom)
endif
return .t.
*}



/*! \fn Menu_SC(cIzp, fMain, lBug)
 * 
 * \param opc    - indirektno priv.var, matrica naslova opcija
 * \param opcexe - indirektno priv.var, matrica funkcija (string ili kodni blok promjenljive)
 * 
 *  \code
 *  private Opc:={}
 *  private opcexe:={}
 *  AADD(Opc,"1. kartica                                ")
 *  AADD(opcexe, {|| Kart41_42()})
 *  AADD(Opc,"2. kartica v2 (uplata,obaveza,saldo)")
 *  AADD(opcexe, {|| Kart412v2()})
 *  AADD(Opc,"5. realizovani porez")
 *  AADD(opcexe, {|| RekRPor})
 *  private Izbor:=1
 *  Menu_SC("itar")
 * \endcode
 *
 */

function Menu_SC(cIzp, fMain, lBug)
*{

local cOdgovor
local nIzbor

if fMain==NIL
  fMain:=.f.
endif
if lBug==NIL
  lBug:=.f.
endif

if fMain
  @ 4,5 SAY ""
endif

do while .t.
   Izbor:=menu(cIzp, opc, Izbor, .f.)
   nIzbor := retitem(Izbor)
   do case
     case Izbor==0
       if fMain
         cOdgovor:=Pitanje("",'Zelite izaci iz programa ?','N')
         if cOdgovor=="D"
          EXIT
         elseif cOdgovor=="L"
          Prijava()
          Izbor:=1
          @ 4,5 SAY ""
          LOOP
         else
          Izbor:=1
          @ 4,5 SAY ""
          LOOP
         endif
       else
          EXIT
       endif
     case lBug
        LOOP
	
     otherwise
      	 if opcexe[nIzbor] <> nil
          private xPom:=opcexe[nIzbor]
	  if VALTYPE(xPom)="C"
	     xDummy:=&(xPom)
	  else
	     EVAL(xPom)
	  endif
	 endif  
     endcase
     
enddo
return
*}

function MAXROWS()
*{
return 25
*}

function MAXCOLS()
*{
return 80
*}

function ToggleINS()
*{
local nx
local ny

nx:=row()
ny:=col()
if ReadInsert(!ReadInsert())
   setcursor(1)
   @ 0,50 SAY  '< OVER >' COLOR Invert
else
   setcursor(2)
   @ 0,50 SAY  '< INS  >' COLOR Invert
endif
@ 0,69 SAY "bring.out" COLOR "GR+/B"
setpos(nx,ny)

return .t.
*}

/*! \fn SayPrivDir(cDirPriv)
 *  \brief Prikazi  ime korisnika + ":" + privatni direktorij na vrhu ekrana
 *
 */

function SayPrivDir(cDirPriv)
*{
@ 0,24 SAY PADR(trim(ImeKorisn)+":"+cDirPriv,25) COLOR INVERT
@ 4,4 SAY ""
return
*}


function IzreziPath(cPath,cTekst)
*{
local nPom
if LEFT(cTekst,1)<>SLASH
	cTekst:=SLASH+cTekst
endif
nPom:=AT(cTekst,cPath)
if nPom>0
	cPath:=LEFT(cPath,nPom-1)
endif
return cPath
*}


function SezonskeBoje()
*{
public  Invert
public  Normal
public  Blink
public  Nevid

if TYPE("gFKolor")<>"C"
	gFKolor:="D"
endif


if (gFKolor=="D" .and. ISCOLOR())
	Invert:="N/W,R/N+,,,R/B+"
	Normal:="GR+/N,R/N+,,,N/W"
	Blink:="R"+REPLICATE("*",4)+"/W,W/B,,,W/RB"
	Nevid:="W/W,N/N"
else
	Invert:="N/W,W/N,,,W/N"
	Normal:="W/N,N/W,,,N/W"
	Blink:="N"+REPLICATE("*",4)+"/W,W/N,,,W/N"
	Nevid:="W/W,N/N"
endif

return nil
*}

// -----------------------------------------------------------------
// browsanje forme
// -----------------------------------------------------------------
function FormBrowse(nT,nL,nB,nR,aImeKol,aKol,aHFCS,nFreeze,bIstakni)
local oBrowse     // browse object
local oColumn     // column object
local k
local i

oBrowse:=TBrowseDB(nT,nL,nB,nR)

for k:=1 to LEN(aKol)
	i:=ASCAN(aKol,k)
  	if i<>0
     		oColumn:=TBColumnNew(aImeKol[i,1], aImeKol[i,2])
		if bIstakni<>nil
        		oColumn:colorBlock := {|| IIF (EVAL (bIstakni), {5,2}, {1,2})}
     		endif
		if aHFCS[1]<>nil
        		oColumn:headSep := aHFCS [1]
     		endif
     		if aHFCS[2]<>nil
        		oColumn:footSep := aHFCS [2]
     		endif
     		if aHFCS[3]<>nil
        		oColumn:colSep := aHFCS [3]
     		endif
     		oBrowse:addColumn (oColumn)
  	endif
next

if nFreeze==nil
	oBrowse:Freeze := 1
else
   	oBrowse:Freeze := nFreeze
endif

return (oBrowse)

// ---------------------------------------------------------
// prikaz forme
// ---------------------------------------------------------
function ShowBrowse(oBrowse, aConds, aProcs)
local nCnt
local lFlag
local nArrLen
local nRez:=DE_CONT
private cCH

nArrLen := LEN (aConds)
DO WHILE nRez <> DE_ABORT

   if nRez==DE_REFRESH     // obnovi
      oBrowse:Refreshall()
   endif

   IF oBrowse:colPos <= oBrowse:freeze
      oBrowse:colPos := oBrowse:freeze + 1
   ENDIF

   cCH := 0
   DO WHILE ! oBrowse:stable .AND. (cCH = 0)
      oBrowse:Stabilize()
      cCH := INKEY ()
   ENDDO

   IF oBrowse:stable
      IF oBrowse:hitTop .OR. oBrowse:hitBottom
         Beep (1)
      ENDIF
      cCH := INKEY (0)
   ENDIF

   lFlag := .T.
   FOR nCnt := 1 TO nArrLen
       IF EVAL (aConds [nCnt], cCH)
          nRez := EVAL (aProcs [nCnt])
          lFlag := .F.
          EXIT
       ENDIF
   NEXT

   IF ! lFlag;  LOOP; ENDIF

   DO CASE
     CASE cCH = K_ESC
          EXIT
     CASE cCH == K_DOWN
          oBrowse:down()
     CASE cCH == K_PGDN
          oBrowse:pageDown()
     CASE cCH == K_CTRL_PGDN
          oBrowse:goBottom()
     CASE cCH == K_UP
          oBrowse:up()
     CASE cCH == K_PGUP
          oBrowse:pageUp()
     CASE cCH == K_CTRL_PGUP
          oBrowse:goTop()
     CASE cCH == K_RIGHT
          oBrowse:right()
     CASE cCH == K_LEFT
          oBrowse:left()
     CASE cCH == K_HOME
          oBrowse:home()
     CASE cCH == K_END
          oBrowse:end()
     CASE cCH == K_CTRL_LEFT
          oBrowse:panLeft()
     CASE cCH == K_CTRL_RIGHT
          oBrowse:panRight()
     CASE cCH == K_CTRL_HOME
          oBrowse:panHome()
     CASE cCH == K_CTRL_END
          oBrowse:panEnd()
   ENDCASE
ENDDO
return


// -----------------------------------
// dummy funkcija
// -----------------------------------
function dummy_func()
return

