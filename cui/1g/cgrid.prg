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


#include "SC.CH"
#include "dbstruct.ch"
#include "error.ch"
#include "setcurs.ch"

/*! \file cgrid.prg
 *
 *   Funkcije za prikaz i obradu tabelarnih podataka
 */



/*! \fn function ObjDBedit(cImeBoxa,  xw, yw, bUserF,  cMessTop, cMessBot, lInvert, aMessage, nFreeze, bPodvuci, nPrazno, nGPrazno, aPoredak, skipblock)
 * \brief Glavna funkcija tabelarnog prikaza podataka
 * \param cImeBoxa - ime box-a
 * \param xw - duzina
 * \param yw - sirina
 * \param bUserF - kodni blok, user funkcija
 * \param cMessTop - poruka na vrhu
 * \return NIL
 * \note grid - eng -> mreza
 *
 * Funkcija ObjDbedit koristi se za prikaz tabelarnih podataka. Koristi je sifarski sistem, tablela pripreme itd ...
*/

* array ImeKol;

/*! \var ImeKol
 \brief Privatna Varijabla koja se inicijalizira prije "ulaska" u ObjDBedit
 \param - [ 1] Zalavlje kolone 
 \param - [ 2] kodni blok za prikaz kolone {|| id}
 \param - [ 3] izraz koji se edituje (string), obradjuje sa & operatorom
 \param - [ 4] kodni blok When
 \param - [ 5] kodni blok Valid
 \param - [ 6] -
 \param - [ 7] picture
 \param - [ 8] - ima jos getova ????
 \param - [ 9] -
 \param - [10] NIL - prikazi u sljedecem redu,  15 - prikazi u koloni my+15  broj kolone pri editu sa <F2>

*/

* string gTBDir;

/*! \var gTBDir
 \brief Rezim direktnog TBrowse-a
 \param - [D] Rad u rezimu direktnog TBrowse-a
 \param - [N] "standardni" TBrowse


*/

function ObjDBedit(cImeBoxa, xw, yw, bUserF, cMessTop, cMessBot, lInvert, aMessage, nFreeze, bPodvuci, nPrazno, nGPrazno, aPoredak, skipblock)
*{

local nBroji2
local cSmj,nRez,i,K,aUF, cPomDB, nTTrec
local cLoc:=space(40)
local cStVr, cNovVr, nRec, nOrder, nPored, xcpos, ycpos

IF "U" $ TYPE("gTBDir"); gTBDir:="N"; ENDIF


if ("U" $ TYPE("TBCanClose")) .or. gTBDir=="N"

  private  bGoreRed:=NIL
  private  bDoleRed:=NIL
  private  bDodajRed:=NIL
  private  fTBNoviRed:=.f. // trenutno smo u novom redu ?
  private  TBCanClose:=.t. // da li se moze zavrsiti unos podataka ?
  private  TBAppend:="N"
  private  bZaglavlje:=NIL
           // zaglavlje se edituje kada je kursor u prvoj koloni
           // prvog reda
  private  TBScatter:="N"  // uzmi samo tekuce polje
  private  nTBLine:=1      // tekuca linija-kod viselinijskog browsa
  private  nTBLastLine:=1  // broj linija kod viselinijskog browsa
  private  TBPomjerise:="" // ako je ">2" pomjeri se lijevo dva
                           // ovo se moze setovati u when/valid fjama

  private  TBSkipBlock:={|nSkip| SkipDB(nSkip, @nTBLine)}
endif

if gTBDir=="N"  // nije mod direktnog unosa
if skipblock<>NIL // ovo je zadavanje skip bloka kroz parametar
   TBSkipBlock:=skipblock
else
   TBSkipBlock:=NIL
endif
endif

private bTekCol
private Ch:=0

private azImeKol:=ImeKol
private azKol:=Kol

if nPrazno==NIL; nPrazno:=0; endif
if nGPrazno==NIL; nGPrazno:=0; endif
if aPoredak==NIL; aPoredak:={}; endif
if (nPored:=LEN(aPoredak))>1; AADD(aMessage,"<c+U> - Uredi"); endif

PRIVATE TB

if lInvert==NIL; lInvert:=.f.; endif

PRIVATE aParametri:={}
AADD(aParametri,cImeBoxa)            //  1
AADD(aParametri,xw)                  //  2
AADD(aParametri,yw)                  //  3
AADD(aParametri,lInvert)             //  4
AADD(aParametri,aMessage)            //  5
AADD(aParametri,nFreeze)             //  6
AADD(aParametri,cMessBot)            //  7
AADD(aParametri,cMessTop)            //  8
AADD(aParametri,nPrazno)             //  9
AADD(aParametri,nGPrazno)            // 10
AADD(aParametri,bPodvuci)            // 11

IF gTBDir=="D"
  DaTBDirektni(.t.)
ELSE
  NeTBDirektni(.t.)
ENDIF

DO WHILE .T.
   Ch:=0   
    if deleted()  // nalazim se na brisanom slogu
       skip
       if eof()
         Tb:Down()
       else
         Tb:Up()
       endif	 
       Tb:RefreshCurrent()
    endif

    nBroji2:=seconds()
    DO WHILE !TB:stable .AND. ((Ch:=Inkey())==0 )
         Tb:stabilize()
         CekaHandler(@nBroji2)
    ENDDO

   IF TB:stable .AND. Ch==0
         if bUserF<>NIL
           xcpos:=ROW(); ycpos:=COL(); Eval(bUserF); @ xcpos,ycpos SAY ""
         endif

         nBroji2:=seconds()
         DO WHILE NEXTKEY()==0
           OL_YIELD()
           CekaHandler(@nBroji2)
         ENDDO
         Ch := INKEY()
         
   END

   if bUserF<>NIL
     While !TB:stabilize(); End   // mora se izvrsiti potpuna stabilizacija
     nRez:=Eval(bUserF)
   else
     nRez:=DE_CONT
   endif

   DO CASE

     CASE Ch==K_UP
       if gTBDir="D" .and. bGoreRed<>NIL
          Eval(bGoreRed)
       endif
        TB:up()

     CASE Ch==K_DOWN
       if gTBDir="D"
          if bDoleRed=NIL .or. Eval(bDoleRed)
            fTBNoviRed:=.f.
          endif
       endif
       TB:down()

     CASE Ch==K_LEFT
       TB:left()
     CASE Ch==K_RIGHT
       TB:right()
     CASE Ch==K_PGUP
       TB:PageUp()
     CASE Ch==K_CTRL_PGUP
        Tb:GoTop()
     CASE Ch==K_CTRL_PGDN
        Tb:GoBottom()
     CASE Ch==K_PGDN
        TB:PageDown()
     otherwise
       StandTBKomande(TB,Ch, @nRez,nPored,aPoredak)

       if gTBDir=="D" .and. !StandTBTipke(Ch)
         if TB:Colpos==1 .or. reccount2()==0

          nTTRec:=recno()
          skip -1

          if bof() // prvi red
            go nTTrec
            if reccount2()=0; fTBNoviRed:=.t.; endif
            if bZaglavlje<>NIL
                if !EVAL(bZaglavlje)
                   fTBNoviRed:=.f.
                endif
            endif
          else
            go nTTrec
          endif
         endif
       endif

       //ERNAD
       if gTBDir=="D" .and. LEN(ImeKol[TB:colpos])>2 .and. ;
         !StandTBTipke(Ch) .and. ;
         !(reccount2()=0 .and. !fTBNoviRed)

         // Getuj polje ............
         if Ch<>K_ENTER  .and. (!eof() .or. bDodajRed<>NIL)
           KEYBOARD CHR(Ch)
         endif

         if eof()  .or. bof()
              if bDodajRed<>NIL; Eval(bDodajRed); endif
              if TBAppend=="D"
                  fTBNoviRed:=.t.
              else
                  fTBNoviRed:=.f.
              endif
         endif

         if !eof() .and. !bof()
            DoGet()
         endif

            if len(ImeKol[TB:Colpos])>=6
               TBPomjeranje(TB,ImeKol[TB:Colpos,6])
            endif
            if !empty(TBPomjerise)
              TBPomjeranje(TB,TBPomjerise)
              TBPomjeriSe:=""
            endif



         nRez:=DE_REFRESH
       else
         if gTBDir=="D" .and. Ch<>0 // pomjeri se desno
           TB:Right()
         endif
         goModul:Gproc(Ch)
       endif


   end case

   do case

     CASE nRez==DE_REFRESH
       TB:RefreshAll()
       @ m_x+1,m_y+yw-6 SAY STR(RecCount2(),5)

     CASE Ch==K_ESC
       if !TBCanClose
          MsgBeep("Morate zavrsiti unos reda !")
          loop
       endif
       if nPrazno==0;BoxC();endif
       exit
     CASE nRez==DE_ABORT .or. Ch==K_CTRL_END .or. Ch==K_ESC
       if nPrazno==0;BoxC();endif
       EXIT


   endcase

END DO

RETURN
*}


function NeTBDirektni(lIzOBJDB)
*{
LOCAL i,j,k
IF lIzOBJDB==NIL; lIzOBJDB:=.f.; ENDIF

if aParametri[9]==0
 IF !lIzOBJDB; BoxC(); ENDIF
 Box(aParametri[1],aParametri[2],aParametri[3],aParametri[4],aParametri[5])
else
 @ m_x+aParametri[2]-aParametri[9],m_y+1 SAY replicate("Ä",aParametri[3])
endif

IF !lIzOBJDB
  ImeKol:=azImeKol
  Kol:=azKol
ENDIF

  @ m_x,m_y+2 SAY aParametri[8]+IF(!lIzOBJDB,REPL("Í",42),"")
  @ m_x+aParametri[2]+1,m_y+2 SAY aParametri[7] COLOR "GR+/B"
  @ m_x+aParametri[2]+1,col()+1 SAY IF(!lIzOBJDB,REPL("Í",42),"")
  @ m_x+1,m_y+aParametri[3]-6 SAY STR(RecCount2(),5)
  TB:=TBRowseDB(m_x+2+aParametri[10],m_y+1,m_x+aParametri[2]-aParametri[9]-iif(aParametri[9]<>0,1,0),m_y+aParametri[3])

  if TBSkipBlock<>NIL
   Tb:skipBlock     := TBSkipBlock
  endif

  // Dodavanje kolona  za stampanje
  FOR k:=1 TO Len(Kol)
    i:=ASCAN(Kol,k)
    IF i<>0  .and. (ImeKol[i,2]<>NIL)     // kodni blok <> 0
       TCol:=TBColumnNew(ImeKol[i,1],ImeKol[i,2])
       if aParametri[11]<>NIL
         TCol:colorBlock:={|| iif(EVAL(aParametri[11]),{5,2},{1,2}) }
       endif
       TB:addColumn(TCol)
    END IF
  NEXT
  TB:headSep := 'Ä'
  TB:colsep :="³"
  if aParametri[6]==NIL
     TB:Freeze:=1
  else
     Tb:Freeze:=aParametri[6]
  endif
RETURN
*}

function DaTBDirektni(lIzOBJDB)
*{ 
LOCAL i,j,k
 IF lIzOBJDB==NIL; lIzOBJDB:=.f.; ENDIF

 if aParametri[9]==0
  IF !lIzOBJDB; BoxC(); ENDIF
  Box(aParametri[1],aParametri[2],aParametri[3],aParametri[4],aParametri[5])
 else
  @ m_x+aParametri[2]-aParametri[9],m_y+1 SAY PADC("-",aParametri[3],"-")
 endif

 IF ! ( "U" $ TYPE("adImeKol") )
   ImeKol:=adImeKol
 ENDIF
 IF ! ( "U" $ TYPE("adKol") )
   Kol:=adKol
 ENDIF

   //@ m_x,m_y+2 SAY aParametri[8]+"ÍUPOZORENJE: Mod direktnog unosa u tabelu!"
   @ m_x,m_y+2 SAY aParametri[8]+IF(!lIzOBJDB,REPL("Í",42),"")
   //@ m_x+aParametri[2]+1,m_y+2 SAY aParametri[7]+"ÍUPOZORENJE: Mod direktnog unosa u tabelu!"
   @ m_x+aParametri[2]+1,m_y+2 SAY aParametri[7] COLOR "GR+/B"

   @ m_x+1,m_y+aParametri[3]-6 SAY STR(RecCount2(),5)
   TB:=TBRowseDB(m_x+2+aParametri[10],m_y+1,m_x+aParametri[2]-aParametri[9]-iif(aParametri[9]<>0,1,0),m_y+aParametri[3])
   Tb:skipBlock     := TBSkipBlock
   Tb:goTopBlock    := {|| GoTopDB(@nTbLine)}
   Tb:goBottomBlock := {|| GoBottomDB(@nTBLine)}

   // Dodavanje kolona  za stampanje
   FOR k:=1 TO Len(Kol)
     i:=ASCAN(Kol,k)
     IF i<>0
        TCol:=TBColumnNew(ImeKol[i,1],ImeKol[i,2])
        if aParametri[11]<>NIL
          TCol:colorBlock:={|| iif(EVAL(aParametri[11]),{5,2},{1,2}) }
        endif
        TB:addColumn(TCol)
     END IF
   NEXT
   TB:headSep := CHR(220)
   //TB:colsep :=CHR(219)
   TB:colsep :="³"
   if aParametri[6]==NIL
      TB:Freeze:=1
   else
      Tb:Freeze:=aParametri[6]
   endif
RETURN
*}



static function DoGet()

/*! 
 *Izvrsi GET za tekucu kolonu u browse-u
 */

*{
LOCAL bIns, lScore, lExit
LOCAL col, get, nKey
LOCAL xOldKey, xNewKey


// Make sure screen is fully updated, dbf position is correct, etc.
ForceStable()

// Save the current record's key value (or NIL)
// (for an explanation, refer to the rambling note below)
xOldKey := IF( EMPTY(INDEXKEY()), NIL, &(INDEXKEY()) )

// Save global state
lScore := Set(_SET_SCOREBOARD, .F.)
lExit := Set(_SET_EXIT, .T.)
bIns := SetKey(K_INS)

// Set insert key to toggle insert mode and cursor shape
SetKey( K_INS, {|| InsToggle()} )

// edit polja
col := TB:getColumn(TB:colPos)

IF LEN(ImeKol[TB:colpos])>4 // ima validaciju
  EditPolja(ROW(),COL(),EVAL(col:block),ImeKol[TB:ColPos,3],ImeKol[TB:ColPos,4],ImeKol[TB:ColPos,5],TB:colorSpec)
ELSEIF LEN(ImeKol[TB:colpos])>2  // nema validaciju
  EditPolja(ROW(),COL(),EVAL(col:block),ImeKol[TB:ColPos,3],{|| .t.},{|| .t.},TB:colorSpec)
ENDIF

// Restore state
Set(_SET_SCOREBOARD, lScore)
Set(_SET_EXIT, lExit)
SetKey(K_INS, bIns)

// Get the record's key value (or NIL) after the GET
xNewKey := IF( EMPTY(INDEXKEY()), NIL, &(INDEXKEY()) )

// If the key has changed (or if this is a new record)
IF .NOT. (xNewKey == xOldKey)

    // Do a complete refresh
    TB:refreshAll()
    ForceStable()

    // Make sure we're still on the right record after stabilizing
    DO WHILE &(INDEXKEY()) > xNewKey .AND. .NOT. TB:hitTop()
        TB:up()
        ForceStable()
    ENDDO

ENDIF

// Check exit key from get
nKey := LASTKEY()
IF nKey == K_UP .OR. nKey == K_DOWN .OR. ;
    nKey == K_PGUP .OR. nKey == K_PGDN

    // Ugh
    KEYBOARD( CHR(nKey) )

ENDIF

RETURN
*}


static function ForceStable()
*{
DO WHILE .NOT. TB:stabilize()
    ENDDO
RETURN
*}

static function InsToggle()
*{
IF READINSERT()
        READINSERT(.F.)
        SETCURSOR(SC_NORMAL)
    ELSE
        READINSERT(.T.)
        SETCURSOR(SC_INSERT)
    ENDIF
RETURN
*}

static function EditPolja(nX,nY,xIni,cNazPolja,bWhen,bValid,cBoje)
*{  
  local i
  local cStaraVr:=gTBDir
  local cPict
  local bGetSet
  local nSirina

  //gTBDir:="N"
  if TBScatter="N"
   cPom77I:=cNazpolja
   cPom77U:="w"+cNazpolja
   &cPom77U:=xIni
  else
   Scatter()
   if fieldpos(cNazPolja)<>0 // field varijabla
    cPom77I:=cNazpolja
    cPom77U:="_"+cNazpolja
   else
    cPom77I:=cNazpolja
    cPom77U:=cNazPolja
   endif
   //&cPom77U:=xIni
  endif

  cpict:=NIL
  if len(ImeKol[TB:Colpos])>=7  // ima picture
    cPict:=ImeKol[TB:Colpos,7]
  endif


  // provjeriti kolika je sirina get-a!!

  aTBGets:={}
  get := GetNew(nX, nY, MEMVARBlock(cPom77U),;
               cPom77U, cPict, "W+/BG,W+/B")
  get:PreBlock:=bWhen
  get:PostBlock:=bValid
  AADD(aTBGets,Get)
  nSirina:=8
  if cPict<>NIL
     nSirina:=len(transform(&cPom77U,cPict))
  endif
  //@ nX, nY GET &cPom77U VALID EVAL(bValid) WHEN EVAL(bWhen) COLOR "W+/BG,W+/B" pict cPict
  if len(ImeKol[TB:Colpos])>=8  // ima joç getova
    aPom:=ImeKol[TB:Colpos,8]  // matrica
    for i:=1 to len(aPom)
      nY:=nY+nSirina+1
      get := GetNew(nX, nY, MEMVARBlock(aPom[i,1]),;
               aPom[i,1],aPom[i,4], "W+/BG,W+/B")
      nSirina:=len(transform(&(aPom[i,1]),aPom[i,4]))
      get:PreBlock:=aPom[i,2]
      get:PostBlock:=aPom[i,3]
      AADD(aTBGets,Get)
    next

    if nY+nsirina>78

       for i:=1 to len(aTBGets)
          aTBGets[i]:Col:= aTBGets[i]:Col   - (nY+nSirina-78)
          // smanji col koordinate
       next
    endif

  endif

  //READ
    readmodal(aTBGets)

    if TBScatter="N"
     // azuriraj samo ako nije zadan when blok !!!
     REPLACE &cPom77I WITH &cPom77U
     sql_azur(.t.)
     REPLSQL &cPom77I WITH &cPom77U
    else
     IF LASTKEY()!=K_ESC .and. cPom77I<>cPom77U  // field varijabla
       Gather()
       sql_azur(.t.)
       GathSQL()
     endif
    endif

  //gTBDir:=cStaraVr
RETURN
*}

function Eval2(bblock,p1,p2,p3,p4,p5)
*{
if bBlock<>NIL
  Eval(bBlock,p1,p2,p3,p4,p5)
endif
*}


static function GoBottomDB( nTBLine )
*{
// You are receiving a reference
   DBGOBOTTOM()
   nTBLine := nTBLastLine
   RETURN (NIL)
*}

static function GoTopDB( nTBLine )
*{
// You are receiving a reference
   DBGOTOP()
   // Since you are pointing to the first record
   // your current line should be 1
   nTBLine := 1
   RETURN (NIL)
*}

function SkipDB( nRequest, nTBLine )
*{
// nTBLine is a reference
   LOCAL nActually := 0

   IF nRequest == 0
      DBSKIP(0)

   ELSEIF nRequest > 0 .AND. !EOF()
      WHILE nActually < nRequest
         IF nTBLine < nTBLastLine
            // This will print up to nTBLastLine of text
            // Some of them (or even all) might be empty
            ++nTBLine

         ELSE
            // Go to the next record
            DBSKIP(+1)
            nTBLine := 1

         ENDIF
         IF EOF()
           if gTBDir=="D" .and. TBAppend=="D" // dodaj novi slog
            nActually++
           else
            DBSKIP(-1)
            nTBLine := nTBLastLine
            EXIT
           endif
         ENDIF
         nActually++

      END

   ELSEIF nRequest < 0
      WHILE nActually > nRequest
         // Go to previous line
         IF nTBLine > 1
            --nTBLine

         ELSE
            DBSKIP(-1)
            IF !BOF()
               nTBLine := nTBLastLine

            ELSE
               // You need this. Believe me!
               nTBLine := 1
               GOTO RECNO()
               EXIT

            ENDIF

         ENDIF
         nActually--

      END

   ENDIF
   RETURN (nActually)
*}


function StandTBKomande(TB, Ch, nRez, nPored, aPoredak)
*{
local cSmj,i,K,aUF
local cLoc:=space(40)
local cStVr, cNovVr, nRec, nOrder, xcpos, ycpos

DO CASE
  CASE Ch==K_CTRL_F
     bTekCol:=(TB:getColumn(TB:colPos)):Block
     if valtype(EVAL(bTekCol))=="C"
       Box("bFind",2,50,.f.)
        Private GetList:={}
        set cursor on
        cLoc:=PADR(cLoc,40)
        cSmj:="+"
        @ m_x+1,m_y+2 SAY "Trazi:" GET cLoc PICTURE "@!"
        @ m_x+2,m_y+2 SAY "Prema dolje (+), gore (-)" GET cSmj VALID cSmj $ "+-"
        read
       BoxC()
       if lastkey()<>K_ESC
        cLoc:=TRIM(cLoc)
        aUf:=nil
        if right(cLoc,1)==";"
          Beep(1)
          aUF:=parsiraj(cLoc,"EVAL(bTekCol)")
        endif
        Tb:hitTop:=TB:hitBottom:=.f.
        do while !(Tb:hitTop .or. TB:hitBottom)
         if aUF<>NIL
          if Tacno(aUF)
            exit
          endif
         else
          if UPPER(LEFT(EVAL(bTekCol),LEN(cLoc)))==cLoc
            exit
          endif
         endif
          if cSmj="+"
           Tb:down()
           Tb:Stabilize()
          else
           Tb:Up()
           Tb:Stabilize()
          endif

        enddo
        Tb:hitTop:=TB:hitBottom:=.f.
       endif
     endif

  CASE Ch==K_ALT_R
    IF (kLevel>"0" .or. gReadOnly .or. !ImaPravoPristupa(goModul:oDatabase:cName,"CUI","STANDTBKOMANDE-ALTR_ALTS"))
     Msg("Nemate pravo na koristenje ove opcije",15)
    ELSE
     private cKolona
     if len(Imekol[TB:colPos])>2
       if !empty(ImeKol[TB:colPos,3])
	  cKolona:=ImeKol[TB:ColPos,3]
          if valtype(&cKolona) $  "CD"

            Box(,2,60,.f.)
             Private GetList:={}
             set cursor on
             cStVr:=&cKolona
             cNovVr:=cStVr
             if  valtype(&cKolona)=="C"  .and. len(cStVr)>45
              @ m_x+1,m_y+2 SAY "Trazi:      " GET cStVr  pict "@S45"
              @ m_x+2,m_y+2 SAY "Zamijeni sa:" GET cNovVr pict "@S45"
             else
              @ m_x+1,m_y+2 SAY "Trazi:      " GET cStVr
              @ m_x+2,m_y+2 SAY "Zamijeni sa:" GET cNovVr
             endif
             read
            BoxC()
            if lastkey()<>K_ESC
             nRec:=recno()
             nOrder:=indexord()
             set order to 0
             go top
             do while !eof()
               if &cKolona==cStVr
                   replace &cKolona with cNovVr
                   replsql &cKolona with cNovVr
               endif

               if valtype(cStVr)=="C" // samo za karaktere
                cDio1:=left(cStVr,len(trim(cStVr))-2)
                cDio2:=left(cNovVr,len(trim(cNovVr))-2)
                if right(trim(cStVr),2)=="**" .and. cDio1 $ &cKolona
                   replace &cKolona with strtran(&cKolona,cDio1,cDio2)
                   replsql &cKolona with strtran(&cKolona,cDio1,cDio2)
                endif
               endif

               skip
             enddo
             dbsetorder(nOrder)
             go nRec
             TB:RefreshAll()
            endif
          endif
       endif
     endif
    ENDIF
  CASE Ch==K_ALT_S
    IF (kLevel>"0".or.gReadOnly .or. !ImaPravoPristupa(goModul:oDatabase:cName,"CUI","STANDTBKOMANDE-ALTR_ALTS"))
     Msg("Nemate pravo na koristenje ove opcije",15)
    ELSE
     private cKolona
     if len(Imekol[TB:colPos])>2
       if !empty(ImeKol[TB:colPos,3])
          cKolona:=ImeKol[TB:ColPos,3]
          if valtype(&cKolona)=="N"

            Box(,3,66,.f.)
             Private GetList:={}
             set cursor on
             private cVrijednost:=&cKolona
             private cUslov77:=SPACE(80)
             @ m_x+1,m_y+2 SAY "Postavi na:" GET cVrijednost
             @ m_x+2,m_y+2 SAY "Uslov za obuhvatanje stavki (prazno-sve):" GET cUslov77 PICT "@S20" VALID EMPTY(cUslov77) .or. EvEr(cUslov77,"Greska! Neispravno postavljen uslov!")
             read
            BoxC()
            if lastkey()<>K_ESC
             nRec:=recno()
             nOrder:=indexord()
             set order to 0
             if Pitanje(,"Promjena ce se izvrsiti u "+IF(EMPTY(cUslov77),"svim ","")+"stavkama"+IF(!EMPTY(cUslov77)," koje obuhvata uslov","")+". Zelite nastaviti ?","N")=="D"
               go top
               do while !eof()
                 IF EMPTY(cUslov77) .or. &cUslov77
                   replace &cKolona with cVrijednost
                   sql_azur(.t.)
                   replsql &cKolona with cVrijednost
                 ENDIF
                 skip
                enddo
             endif
             dbsetorder(nOrder)
             go nRec
             TB:RefreshAll()
            endif
          endif
       endif
     endif
    ENDIF
  CASE Ch==K_CTRL_U.and.nPored>1
     Private GetList:={}
     nRez:=INDEXORD()
     Prozor1(12,20,17+nPored,59,"UTVRDJIVANJE PORETKA",,,"GR+/N","W/N,B/W,,,B/W",2)
     FOR i:=1 TO nPored
      @ 13+i,23 SAY PADR("poredak po "+aPoredak[i],33,"ú")+STR(i,1)
     NEXT
     @ 18,27 SAY "UREDITI TABELU PO BROJU:" GET nRez VALID nRez>0 .AND. nRez<nPored+1 PICT "9"
     READ
     Prozor0()
     IF LASTKEY()!=K_ESC
       DBSETORDER(nRez+1)
       nRez:=DE_REFRESH
     ELSE
       nRez:=DE_CONT
     ENDIF

ENDCASE

return
*}


function StandTBTipke()
*{
* ove tipke ne smiju aktivirati edit-mod


if Ch==K_ESC .or. Ch==K_CTRL_T .or. Ch=K_CTRL_P .or. Ch=K_CTRL_N .or. ;
   Ch==K_ALT_A .or. Ch==K_ALT_P .or. Ch=K_ALT_S .or. Ch=K_ALT_R .or. ;
   Ch==K_DEL .or. Ch=K_F2 .or. Ch=K_F4 .or. Ch=K_CTRL_F9 .or. Ch=0
   return .t.
endif
return .f.
*}


/*! \fn function TBPomjeranje(TB, cPomjeranje)
 *  \brief Opcije pomjeranja tbrowsea u direkt rezimu
 *  \param TB          -  TBrowseObjekt
 *  \param cPomjeranje - ">", ">2", "V0"
 */

function TBPomjeranje(TB, cPomjeranje)
*{
local cPomTB

if (cPomjeranje)=">"
   cPomTb:=substr(cPomjeranje,2,1)
   TB:Right()
   if !empty(cPomTB)
     for i:=1 to val(cPomTB)
         TB:Right()
     next
   endif

elseif (cPomjeranje)="V"
   TB:Down()
   cPomTb:=substr(cPomjeranje,2,1)
   if !empty(cPomTB)
     TB:PanHome()
     for i:=1 to val(cPomTB)
         TB:Right()
     next
   endif
   if bDoleRed=NIL .or. Eval(bDoleRed)
      fTBNoviRed:=.f.
   endif
elseif (cPomjeranje)="<"
   TB:left()
elseif (cPomjeranje)="0"
   TB:PanHome()
endif
*}


function EvEr(cExpr,cmes,cT)
*{ 
 LOCAL lVrati:=.t.
 IF cmes==nil; cmes:="Greska!"; ENDIF
 IF cT==nil; cT:="L"; ENDIF
 PRIVATE cPom:=cExpr
 IF !(TYPE(cPom)=cT)
   lVrati:=.f.
   msgbeep(cMes)
 ENDIF
RETURN lVrati
*}


function BrowseKey(y1,x1,y2,x2,;
                   ImeKol,bfunk,uslov,traz,brkol,;
                   dx,dy,bPodvuci)
*{
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
    // @ m_x+dx,m_y+dy say STR(nCurRec,4)+"/"+STR(nRecCnt,4)
     @ m_x+dx,m_y+dy say STR(nRecCnt,4)
   endif
   while !Tb:stabilize() .and. Inkey()==0
    if dx<>NIL .and. dy<>NIL
     // @ m_x+dx,m_y+dy say STr(nCurRec,4)+"/"+STR(nRecCnt,4)
      @ m_x+dx,m_y+dy say STR(nRecCnt,4)
    endif
   enddo

   DO WHILE NEXTKEY()==0; OL_YIELD(); ENDDO
   lk:=INKEY()
   // inkey(0)
   // lk:=lastkey()

   if lk==K_ESC; POZIV--; exit
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
*}

static function Korisnik(nRequest,traz,dx,dy,nCurRec,nRecCnt)
*{
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
*}
