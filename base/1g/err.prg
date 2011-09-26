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
#include "error.ch"
#include "dbstruct.ch"
#include "set.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/sclib/base/1g/err.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.5 $
 * $Log: err.prg,v $
 * Revision 1.5  2003/01/18 14:26:01  ernad
 * izadji obezno pri zelite li pokusati ponovo = N
 *
 * Revision 1.4  2002/07/03 07:31:12  ernad
 *
 *
 * planika, debug na terenu
 *
 * Revision 1.3  2002/06/22 18:41:04  ernad
 *
 *
 * uklanjanje debug-poruka
 *
 * Revision 1.2  2002/06/20 14:28:23  ernad
 *
 *
 * sistemske funkcije tastature prebacene sclib/keyb/1g komponentu
 *
 *
 */
 

function MyErrorHandler(objErr,lLocalHandler)
*{
local cOldDev
local cOldCon
local Odg
local nErr

 ? "Greska .......... myerrorhandler"
 sleep(5)
 
 if lLocalHandler
  Break objErr
 endif

 cOldDev:=SET(_SET_DEVICE,"SCREEN")
 cOldCon:=SET(_SET_CONSOLE,"ON")
 cOldPrn:=SET(_SET_PRINTER,"")
 cOldFile:=SET(_SET_PRINTFILE,"")
 BEEP(5)
 nErr:=objErr:genCode

 if objErr:genCode =EG_PRINT
     MsgO(objErr:description+':Greska sa stampacem !!!!')
 elseif ObjErr:genCode =EG_CREATE
     MsgO(ObjErr:description+':Ne mogu kreirati fajl !!!!')
 elseif objErr:genCode =EG_OPEN
     MsgO(ObjErr:description+':Ne mogu otvoriti fajl !!!!')
 elseif objErr:genCode =EG_CLOSE
     MsgO(objErr:description+':Ne mogu zatvoriti fajl !!!!')
 elseif objErr:genCode =EG_READ
     MsgO(objErr:description+':Ne mogu procitati fajl !!!!')
 elseif objErr:genCode =EG_WRITE
     MsgO(objErr:description+':Ne mogu zapisati u fajl !!!!')
 else
     MsgO(objErr:description+' Greska !!!!')
 endif


 DO WHILE NEXTKEY()==0; OL_YIELD(); ENDDO
 INKEY()
 MsgC()

Odg:=Pitanje(,'Zelite li pokusati ponovo (D/N) ?',' ')=="D"


if (Odg=='D')
	 SET(_SET_DEVICE,cOldDev)
	 SET(_SET_CONSOLE,cOldCon)
	 SET(_SET_PRINTER,cOldPrn)
	 SET(_SET_PRINTFILE,cOldFile)
	 return .t.
else

	//goModul:quit()
	QUIT
	return .f.

endif

return .t.
*}

function GlobalErrorHandler(objErr,lLocalHandler)
*{
local cOldDev
local cOldCon
local cScr
local cStampaj
local nErr
local cOdg

private ckom

if llocalHandler==NIL
    lLocalHandler:=.f.
endif

 
if lLocalHandler
  Break objErr
endif

 
/* test presretanja variable not found
 if (objErr:genCode=EG_NOVAR)
     if trim(objErr:operation) ="KK1"  .or.;
        trim(objErr:operation) ="WKK1" .or.;
        trim(objErr:operation) ="_KK1"   // izmajmunisi KK1

          private cVarijabla:=objErr:operation
          PUBLIC &cVarijabla:=NIL
          return .t.

     endif
 endif
*/

cOldDev:=SET(_SET_DEVICE,"SCREEN")
cOldCon:=SET(_SET_CONSOLE,"ON")
cOldPrn:=SET(_SET_PRINTER,"")
cOldFile:=SET(_SET_PRINTFILE,"")


lInstallDB:=.f.

BEEP(5)
SETCANCEL(.t.)

nErr:=objErr:genCode
do case

   CASE objErr:genCode=EG_ARG
     MsgO(objErr:description+' Neispravan argument')
   CASE objErr:genCode=EG_BOUND
     MsgO(objErr:description+' Greska-EG_BOUND')
   CASE objErr:genCode=EG_STROVERFLOW
     MsgO(objErr:description+' Prevelik string')
   CASE objErr:genCode=EG_NUMOVERFLOW
     MsgO(objErr:description+' Prevelik broj')
   CASE objErr:genCode=36
     //Workarea not indexed
     lInstallDB:=.t.
     
   CASE objErr:genCode=EG_ZERODIV
     MsgO(objErr:description+' Dijeljenje sa nulom')
   CASE objErr:genCode=EG_NUMERR
     MsgO(objErr:description+' EG_NUMERR')
   CASE objErr:genCode=EG_SYNTAX
     MsgO(objErr:description+' Greska sa sintaksom')
   CASE objErr:genCode=EG_COMPLEXITY
     MsgO('Prevelika kompleksnost za makro operaciju')

   CASE objErr:genCode=EG_MEM
     MsgO(objErr:description+' Nepostojeca varijabla')


   CASE objErr:genCode=EG_NOFUNC
     MsgO(objErr:description+' Nepostojeca funkcija')
   CASE objErr:genCode=EG_NOMETHOD
     MsgO(objErr:description+' Nepostojeci metod')
   CASE objErr:genCode=EG_NOVAR
    MsgO(objErr:description+' Nepostojeca varijabla -?-')

   CASE objErr:genCode=EG_NOALIAS
     MsgO(objErr:description+' Nepostojeci alias')
   CASE objErr:genCode=EG_NOVARMETHOD
     MsgO(objErr:description+' Nepostojeci metod')

   CASE objErr:genCode=EG_CREATE
     MsgO(ObjErr:description+' Ne mogu kreirati fajl '+ObjErr:filename)
   CASE objErr:genCode=EG_OPEN
     MsgO(ObjErr:description+' Ne mogu otvoriti fajl '+ObjErr:filename)
     lInstallDB:=.t.
     
  //if file(strtran(objerr:filename,gSezonDir,"")) .and. !file(ObjErr:Filename) // ako se radi sa sezonskim podacima
    //    filecopy(strtran(objerr:filename,gSezonDir,""),ObjErr:fileName)
        // primjer :\sigma\fin\kum1\params.dbf
        // primjer :\sigma\fin\kum1\1997\params.dbf
   //  endif

   CASE objErr:genCode=EG_CLOSE
     MsgO(objErr:description+':Ne mogu zatvoriti fajl '+ObjErr:filename)
   CASE objErr:genCode=EG_READ
     MsgO(objErr:description+':Ne mogu procitati fajl '+ObjErr:filename)
   CASE objErr:genCode=EG_WRITE
     MsgO(objErr:description+':Ne mogu zapisati u fajl '+ObjErr:filename)
   CASE objErr:genCode=EG_PRINT
     MsgO(objErr:description+':Greska sa stampacem !!!!')

   CASE objErr:genCode=EG_UNSUPPORTED
     MsgO(objErr:description+' Greska - nepodrzano')

   CASE objErr:genCode=EG_CORRUPTION
     MsgO(objErr:description+' Grska - ostecenje pomocnih CDX fajlova')
     lInstallDB:=.t.

   CASE objErr:genCode=EG_DATATYPE
     MsgO(objErr:description+' Greska - tip podataka neispravan')
   CASE objErr:genCode=EG_DATAWIDTH
     MsgO(objErr:description+' Greska EG_DATAWIDTH')
   CASE objErr:genCode=EG_NOTABLE
     MsgO(objErr:description+' Greska - EG_NOTABLE')
   CASE objErr:genCode=EG_NOORDER
     MsgO(objErr:description+' Greska - no order ')
   CASE objErr:genCode=EG_SHARED
     MsgO(objErr:description+' Greska - dijeljenje')
   CASE objErr:genCode=EG_UNLOCKED
     MsgO(objErr:description+' Greska - nije zakljucan zapis/fajl')
   CASE objErr:genCode=EG_READONLY
     MsgO(objErr:description+' Greska - samo za citanje')
   CASE objErr:genCode=EG_APPENDLOCK
     MsgO(objErr:description+' Greska - nije zakljucano pri apendovanju')
   OTHERWISE
     MsgO(objErr:description+' Greska !!!!')
 endcase


 do while NEXTKEY()==0
    Ol_Yield()
 enddo
 INKEY()
 MsgC()

 if (lInstallDB .and. !(goModul:oDatabase:lAdmin) .and. Pitanje(,"Install DB procedura ?","D")=="D")
 	goModul:oDatabase:install()
 	return .t.
 endif

 cOdg:="N"
 if (objErr:genCode>=EG_ARG .and.  objErr:genCode<=EG_NOVARMETHOD) .or.;
    (objErr:genCode>=EG_UNSUPPORTED .and. objErr:genCode<=EG_APPENDLOCK)
   cOdg:="N"
 else

  SET(_SET_DEVICE,cOldDev)
  SET(_SET_CONSOLE,cOldCon)
  SET(_SET_PRINTER,cOldPrn)
  SET(_SET_PRINTFILE,cOldFile)
  cOdg:=Pitanje(,"Zelite li pokusati ponovo D/N ?",cOdg)
 endif


if (cOdg=='D')
  SET(_SET_DEVICE,cOldDev)
  SET(_SET_CONSOLE,cOldCon)
  SET(_SET_PRINTER,cOldPrn)
  SET(_SET_PRINTFILE,cOldFile)
  cOdg:=Pitanje(,"Zelite li pokusati ponovo D/N ?"," ")
  SETCANCEL(.f.)
  return .t.
endif

SETCOLOR(StaraBoja)

CLS

cStampaj:="N"

do while .t.

  if cStampaj=="D"
    start print cret
    P_10CPI
  endif

  ?
  ? "Verzija programa:", gVerzija ," verzija ELIB-a:",elibver()
  ?
  ? "Podsistem klipera:",objErr:SubSystem
  ? "GenKod:",str(objErr:GenCode,3),"OpSistKod:",str(objErr:OsCode,3)
  ? "Opis:",objErr:description
  ? "ImeFajla:",objErr:filename
  ? "Operacija:",objErr:operation
  ? "Argumenti:",objErr:args
  for i:=10 to 2 STEP -1
   if !empty(PROCNAME(i))
    ? "Procedura:",padr(PROCNAME(i),10),"Linija:",ProcLine(i)
   endif
  next
  ?
  ? "Trenutno radno podrucje:",alias(),", na zapisu broj:",recno()
  ?
  ?

  if cStampaj=="D"
   ?
   ?
   end print
   exit
  else
   ?
   ? "Odstampati gornje podatke na stampac D/N ?"
   DO WHILE NEXTKEY()==0; OL_YIELD(); ENDDO
   INKEY()
   
   cStampaj:=upper(chr(lastkey()))
   if cstampaj=="D"
     loop
   else
    exit
   endif
  endif

enddo //.t.


close all
goModul:quit()

RETURN
*}

function ShowFERROR()
*{
LOCAL aGr:={ {  0, "Successful"},;
              {  2, "File not found"},;
              {  3, "Path not found"},;
              {  4, "Too many files open"},;
              {  5, "Access denied"},;
              {  6, "Invalid handle"},;
              {  8, "Insufficient memory"},;
              { 15, "Invalid drive specified"},;
              { 19, "Attempted to write to a write-protected"},;
              { 21, "Drive not ready"},;
              { 23, "Data CRC error"},;
              { 29, "Write fault"},;
              { 30, "Read fault"},;
              { 32, "Sharing violation"},;
              { 33, "Lock violation"} }
  LOCAL n:=0, k:=FERROR()
  n:=ASCAN(aGr,{|x| x[1]==k})
  IF n>0
    MsgBeep( "FERROR: " + ALLTRIM(STR(aGr[n,1])) + "-" + aGr[n,2] )
  ELSEIF k<>0
    MsgBeep( "FERROR: " + ALLTRIM(STR(k)) )
  ENDIF
RETURN
*}


function MyErrH(o)
*{
BREAK o
return
*}
