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

// ---------------------------------------------------------
// ---------------------------------------------------------
function DaTBDirektni(lIzOBJDB)
 
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






static function GoBottomDB( nTBLine )

// You are receiving a reference
   DBGOBOTTOM()
   nTBLine := nTBLastLine
   RETURN (NIL)


// -------------------------------------------
// -------------------------------------------
static function GoTopDB( nTBLine )

// You are receiving a reference
   DBGOTOP()
   // Since you are pointing to the first record
   // your current line should be 1
   nTBLine := 1
   RETURN (NIL)


// -----------------------------------------
// -----------------------------------------
function SkipDB( nRequest, nTBLine )

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



