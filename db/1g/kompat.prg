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

/* \fn DBT2FPT(cImeDBF)
 * \brief Konvertuje memo polja iz DBT u FTP format (Clipper NTX -> FOX CDX)
 *
 * \note Obavezno proslijediti c:\sigma\ROBA - BEZ EXTENZIJE
 *
 */

function DBT2FPT(cImeDBF)
*{

cImeDbf:=strtran(ToUnix(cImeDBF),"."+DBFEXT,"")
close all

#ifdef CAX
  ? "Konverziju vrsiti sa CDX verzijama"
  return
#endif

if file(cimedbf+".DBT") .and. Pitanje(,"Izvrsiti konverziju "+cImeDBF," ")=="D"
   if file(cimedbf+".FPT")
     MsgBeep("Ne smije postojati"+cImeDBF+".FPT ????#Prekidam operaciju !")
     return
   endif
   use (cImeDBF) via "DBFNTX" NEW
   MsgO("Konvertujem "+cImeDBF+" iz DBT u FPT")
     Beep(1)
     copy structure extended to struct
     USEX STRUCT NEW
     dbappend()
     replace field_name with "BRISANO" , field_type with "C", ;
        field_len with 1, field_dec with 0
     use

     close all
     COPY FILE (cImeDBF+".DBF") TO (PRIVPATH+"TEMP.DBF")
     COPY FILE (cImeDBF+".DBT") TO (PRIVPATH+"TEMP.DBT")
     ferase(cImeDBF+".DBT")
     ferase(cImeDBF+".DBF")
     ferase(cImeDBF+".CDX")
     ferase(cImeDBF+".FPT")
     create (cImeDBF) from struct  VIA RDDENGINE
     close all
     usexv (PRIVPATH+"TEMP") VIA "DBFNTX"   NEW
     set order to 0
     usexv (cImeDBF)  VIA  RDDENGINE NEW alias novi
     set order to 0
     select temp
     go top
     do while !eof()
       scatter()
       select novi
       append blank
       gather()
       select temp
       skip
     enddo

   MsgC()
endif

close all

return
*}


function kopi(fProm)
*{

if fBrisiDBF
     nPos:=at(".",cDbf)
     select olddbf; use
     ferase(cpath+left(cdbf,npos)+"DBF")
     ? "BRISEM :",cpath+left(cdbf,npos)+"DBF"
     ferase(cpath+left(cdbf,npos)+"FPT")
     ? "BRISEM :",cpath+left(cdbf,npos)+"FPT"
     fBrisiDBF:=.f.
     return
endif
if fRenameDBF
     nPos:=at(".",cDbf)
     nPos2:=at(".",cImeP)
     c1:=cpath+left(cdbf,npos)+"DBF"
     c2:=cpath+left(cImeP,npos2)+"DBF"
     select olddbf; use
     if frename(c1,c2) = 0
      ? "PREIMENOVAO :",c1," U ",c2
     endif
     c1:=cpath+left(cdbf,npos)+"FPT"
     c2:=cpath+left(cImeP,npos2)+"FPT"
     if frename(c1,c2) = 0
      ? "PREIMENOVAO :",c1," U ",c2
     endif
     fRenameDBF:=.f.
     return
endif

if fProm 
     nPos:=RAT(SLASH,cDbf)
     if nPos<>0
       cPath2:=substr(cDbf,1,nPos)
     else
       cPath2:=""
     endif
     cCDX:=strtran(cDBF,"."+DBFEXT,"."+INDEXEXT)
     if right(cCDX,4)="."+INDEXEXT // izbrisi cdx
       ferase(cPath+cCDX)
     endif

     ferase(cpath+cPath2+"tmp.fpt")
     ferase(cpath+cPath2+"tmp.tmp")
     ferase(cpath+cPath2+"tmp.cdx")
     dbcreate(cpath+cPath2+"tmp.tmp",aNStru)
     select 2
     usex (cpath+cPath2+"tmp.tmp") alias tmp
     select olddbf  //5.2
     ?
     nRow:=row()
     @ nrow,20 SAY "/"; ?? reccount()
     set order to 0;  go top
     do while !eof()
        @ nrow,1  SAY recno()
        select tmp
        //append blank
        dbappend()

        for i:=1 to Len(aStru)
         // prolaz kroz staru strukturu i preuzimanje podataka
         cImeP:=aStru[i,1]
         if len(aStru[i])>4
           cImePN:=aStru[i,5]
           if aStru[i,2]==aStru[i,6]
              replace &cImePN with olddbf->&cImeP
           elseif aStru[i,2]=="C" .and. aStru[i,6]=="N"
              replace &cImePN with val(olddbf->&cImeP)
           elseif aStru[i,2]=="N" .and. aStru[i,6]=="C"
              replace &cImePN with str(olddbf->&cImeP)
           elseif aStru[i,2]=="C" .and. aStru[i,6]=="D"
              replace &cImePN with ctod(olddbf->&cImeP)
           endif
         else
           nPos:=ascan(aNStru,{|x| cImeP==x[1]})
           if nPos<>0 // polje postoji u novoj bazi
             replace &cImeP with olddbf->&cImeP
           endif
         endif
        next // aStru

        select olddbf
        skip
     enddo  // prolaz kroz fajl

     close all
     nPos:=rat(".",cDbf)
     ferase(cpath+left(cDbf,npos)+"BAK")
     frename(cpath+cdbf, cpath+left(cDbf,npos)+"BAK")
     frename(cpath+cPath2+"tmp.tmp",cpath+cdbf)
     ferase(cpath+cPath2+"tmp.tmp")
     if file(cpath+cPath2+"tmp.fpt")  // postoje memo polja
        ferase(cpath+left(cdbf,npos)+"FPK")
        frename(cpath+left(cdbf,npos)+"FPT", cpath+left(cDbf,npos)+"FPK")
        frename(cpath+cPath2+"tmp.FPT",cpath+left(cdbf,npos)+"FPT")
        ferase(cpath+cPath2+"tmp.fpt")
        ferase(cpath+left(cdbf,npos)+"CDX")
        ferase(cpath+left(cdbf,npos)+"cdx")
     endif
endif  // fprom

return
*}

