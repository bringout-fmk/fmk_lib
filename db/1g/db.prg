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
static aWaStack:={}
static aBoxStack:={}

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 *
 */
 
*static integer
static nPos:=0
*;

*static string
static cPokPonovo:="Pokusati ponovo (D/N) ?"
*;

*string
static nPreuseLevel:=0
*;


/*! \fn Scatter(cZn)
  * \brief vrijednosti field varijabli tekuceg sloga prebacuje u public varijable
  * 
  * \param cZn - Default = "_"; odredjuje prefixs varijabli koje ce generisati
  *
  * \code
  *
  *  use ROBA
  *  Scatter("_")
  *  ? _id, _naz, _jmj
  *
  * \endcode
  *
  */
  
function Scatter(cZn)
*{
local i,aStruct
private cImeP,cVar

if cZn==nil
  cZn:="_"
endif
aStruct:=DBSTRUCT()
for i:=1 to len(aStruct)
cImeP:=aStruct[i,1]

if !("#"+cImeP+"#" $ "#BRISANO#_OID_#_COMMIT_#")
  cVar:=cZn+cImeP
  PUBLIC &cVar:=&cImeP
endif

next

return nil
*}


function Gather(cZn)
*{
local i,aStruct

if cZn==nil
  cZn:="_"
endif
aStruct:=DBSTRUCT()
while .t.
  if rlock()
     for i:=1 to len(aStruct)
     cImeP:=aStruct[i,1]
     if  (cImeP="BRISANO")

              // nista

     elseif gSQL=="D"

          // ako je gSQL=="D" desavace se da datoteka kumulativa
          //                  ima ova polja, a privatna nema
          if  !("#"+cImeP+"#" $ "#_SITE_#_OID_#_USER_#_COMMIT_#_DATAZ_#_TIMEAZ_#")
            cVar:=cZn+cImeP
            IF "U"$TYPE(cVar)
              MsgBeep2("Neuskladj.strukt.baza! "+;
                    "F-ja: GATHER(), Alias: "+ALIAS()+", Polje: "+cImeP)
            ELSE
              field->&cImeP:= &cVar
            ENDIF
          endif

     else

          cVar:=cZn+cImeP
          IF "U"$TYPE(cVar)
              MsgBeep2("Neuskladj.strukt.baza! "+;
                    "F-ja: GATHER(), Alias: "+ALIAS()+", Polje: "+cImeP)
          ELSE
            field->&cImeP:= &cVar
          ENDIF
      endif
    next
    dbunlock()
  else
      inkey(0.4)
      loop
  end
  exit
end

return nil
*}

function GatherR(cZn)
*{
local i,j,aStruct

if cZn==nil
  cZn:="_"
endif
aStruct:=DBSTRUCT()
SkratiAZaD(@aStruct)
while .t.
  if rlock()

         for j:=1 to len(aRel)
           if aRel[j,1]==ALIAS()  // {"K_0","ID","K_1","ID",1}
              // matrica relacija
              cVar:=cZn+aRel[j,2]
              xField:=&(aRel[j,2])
              if &cVar==xField // ako nije promjenjen broj
                loop
              endif
              select (aRel[j,3]); set order to aRel[j,5]
              do while .t.
               if flock()
                  seek xField
                  do while &(aRel[j,4])==xField .and. !eof()
                    skip
                    nRec:=RECNO()
                    skip -1
                    field->&(aRel[j,4]):=&cVar
                    go nRec
                  enddo

               else
                    inkey(0.4)
                    loop
               endif
               exit
              enddo // .t.
              select (aRel[j,1])
           endif
        next    // j


        for i:=1 to len(aStruct)
          cImeP:=aStruct[i,1]
          cVar:=cZn+cImeP
          field->&cImeP:= &cVar
        next
    dbunlock()
  else
      inkey(0.4)
      loop
  end
  exit
end

return nil
*}


/*! \fn Gather2(cZn)
*   \brief Gather ne versi rlock-unlock
*   \note Gather2 pretpostavlja zakljucan zapis !!
*/

function Gather2(cZn)
*{
local i,aStruct

if cZn==nil
  cZn:="_"
endif
aStruct:=DBSTRUCT()
for i:=1 to len(aStruct)
  cImeP:=aStruct[i,1]
  if  !("#"+cImeP+"#"  $ "#BRISANO#_SITE_#_OID_#_USER_#_COMMIT_#_DATAZ_#_TIMEAZ_#")
   cVar:=cZn+cImeP
   IF "U"$TYPE(cVar)
     MsgBeep2("Neuskladj.strukt.baza! "+;
              "F-ja: GATHER2(), Alias: "+ALIAS()+", Polje: "+cImeP)
   ELSE
     field->&cImeP:= &cVar
   ENDIF
  endif
next
return
*}

function delete2()
*{
local nRec

do while .t.

if rlock()
  dbdelete2()
  DBUNLOCK()
  exit
else
    inkey(0.4)
    loop
endif

enddo
return nil
*}

function dbdelete2()
*{
if gReadonly
	return
endif
if !eof() .or. !bof()
 field->Brisano:="1"
 Dbdelete()
endif
return nil
*}

/*
*
* fcisti =  .t. - pocisti polja
*           .f. - ostavi stare vrijednosti polja
* funl    = .t. - otkljucaj zapis, pa zakljucaj zapis
*           .f. - ne diraj (pretpostavlja se da je zapis vec zakljucan)
*/

function appblank2(fcisti,funl)
*{
local aStruct,i, nPrevOrd, cnew_oid

if fcisti==nil
  fcisti:=.t.
endif

if funl==nil; funl:=.t.; endif

if gReadonly; return; endif

do while .t.
set deleted off

if gSQL=="D"  .and. fieldpos("_OID_")<>0
 // hocu da se uzmu u obzir i brisani slogovi !
 cNew_oid:=New_Oid()
endif

nPrevOrd:=indexord()

if ORDNUMBER("BRISAN")<>0
  set order to tag "BRISAN"
  seek "1"
endif

if !(found() .and. deleted())
     if !funl .or. flock()
       dbappend(.t.)
        field->brisano:=" "
        if gSQL=="D" .and. fieldpos("_OID_")<>0
         field->_OID_:=cNew_OID // setuj OID koji slijedi !!!
         sql_azur()
        endif
     else // if flock
       set deleted on
       inkey(0.4)
       loop
     endif // if flock
     if funl; dbunlockall(); endif

else
      if !funl .or. rlock()
          if fcisti // ako zelis pocistiti stare vrijednosti
                aStruct:=DBSTRUCT()
                for i:=1 to len(aStruct)
                 cImeP:=aStruct[i,1]
                 if !("#"+cImeP+"#"  $ "#BRISANO#_OID_#_COMMIT_#")
                 do case
                   case aStruct[i,2]=='C'
                     field->&cImeP:=""
                   case aStruct[i,2]=='N'
                     field->&cImeP:=0
                   case aStruct[i,2]=='D'
                     field->&cImeP:=ctod("")
                   case aStruct[i,2]=='L'
                     field->&cImeP:=.f.
                 endcase
                 endif
                next
          endif  // fcisti
        field->brisano:=" "
        dbrecall()
        field->brisano:=" "
        if gSQL=="D" .and. fieldpos("_OID_")<>0
         field->_OID_:=cnew_OID // setuj OID koji slijedi !!!
         sql_azur()
        endif
        set deleted on
        ordsetfocus(nPrevOrd)
        if funl; dbunlockall(); endif

      else // rlock
         inkey(0.4)
         loop
      endif // rlock
endif

set deleted on
ordsetfocus(nPrevOrd)
exit
enddo

return nil
*}


/*! \fn AppFrom(cFDbf, fOtvori)
*  \brief apenduje iz cFDbf-a u tekucu tabelu
*  \param cFDBF - ime dbf-a
*  \param fOtvori - .t. - otvori DBF, .f. - vec je otvorena
*/

function AppFrom(cFDbf,fOtvori)
*{
local nArr
nArr:=SELECT()

cFDBF:=ToUnix(cFDBF)

do while .t.
 if !flock()
     inkey(0.4)
     loop
 endif
 exit
enddo

if fotvori
 use (cFDbf) new
else
 select (cFDbF)
endif

go top

do while !eof()
  select (nArr)
  Scatter("f")

  select (cFDBF)
  Scatter("f")

  select (nArr)   // prebaci se u tekuci fajl-u koji zelis staviti zapise
  appblank2(.f.,.f.)
  Gather2("f") // pretpostavlja zakljucan zapis

  select (cFDBF)
  skip
enddo
if fOtvori
  use // zatvori from DBF
endif


//dbcommit()
dbunlock()
select (nArr)

return
*}

function PrazanDbf()
*{
local fret:=.f.,nRec, nPrevOrd

nPrevOrd:=indexord()
set order to tag "BRISAN"
nRec:=recno()
//set deleted off
seek " "
if !found()
   fRet:=.t.
endif
//set deleted on
dbsetorder(nPrevOrd)
go nRec
return fret
*}


#ifdef CAX

/*! \fn reccount2()
 * \note CAX - Advantage db server verzija
 */
 
function reccount2()
*{
local nC:=0,nRec, nPrevOrd

if ORDNUMBER("BRISAN")<>0
  nRec:=recno()
  nPrevOrd:=indexord()
  set deleted off
  set order to tag "BRISAN"
  set scope to "1"  // postavi scope na brisane
  nC:=AX_KeyCount()
  set deleted on
  set scope to
  dbsetorder(nPrevOrd)
  go nRec
endif
return reccount()-nC
*}

#else

/*! \fn reccount2()
 * \note COMIX - CDX verzija
 */
function reccount2()
*{
local nC:=0,nRec, nPrevOrd

if ORDNUMBER("BRISAN")<>0
  nPrevOrd:=indexord()
  set order to tag "BRISAN"
  set scope to "1"  // postavi scope na brisane

#ifdef CLIP
  nC:=ordkeycount()
#else  
  nC:=cmxKeyCount()
#endif

  set scope to
  dbsetorder(nPrevOrd)
endif
return reccount()-nC
*}

#endif


function seek2(cArg)
*{
dbseek( cArg)
return nil
*}

/*
* markira za brisanje sve zapise u bazi
*/

function zapp()
*{
if gReadonly; return; endif

PushWa()

if cmxShared()
       do while .t.
       if flock()
          set order to 0 // neophodno, posto je index po kriteriju deleted() !!
          go top
          do while !eof()
            sql_delete()
            dbdelete2()
            skip
          enddo
       else  // flock
            inkey(0.4)
            loop
       endif // flock

       exit
       enddo
else
   __dbzap()
endif

PopWa()
return nil
*}

function nerr(oe)
*{
break oe
*}

/*! \fn EofFndRet(ef, close)
 *  \brief Daje poruku da ne postoje podaci
 *  \param ef = .t.   gledaj eof();  ef == .f. gledaj found()
 *  \return  .t. ako ne postoje podaci
 */
 
function EofFndRet(ef, close)
*{
local fRet:=.f., cStr:="Ne postoje trazeni podaci.."
if ef // eof()
  if eof()
    if !gAppSrv
     Beep(1)
     Msg(cStr,6)
    endif
    fRet:=.t.
  endif
else
  if !found()
     if !gAppSrv
       Beep(1); Msg(cStr,6)
     endif
     fRet:=.t.
  endif
endif

if close .and. fRet
  close all
endif
return fRet
*}


/*! \fn SigmaSif(cSif)
 *  \brief zasticene funkcije sistema
 *
 * za programske funkcije koje samo serviser
 * treba da zna, tj koje obicni korisniku
 * nece biti dokumentovane
 *
 * \note Default cSif=SIGMAXXX
 *
 * \return .t. kada je lozinka ispravna
*/

function SigmaSif(cSif)
local lGw_Status

lGw_Status:=IF("U"$TYPE("GW_STATUS"),"-",gw_status)

GW_STATUS:="-"

if csif==nil
  cSif:="SIGMAXXX"
else
 cSif:=padr(cSif,8)
endif
Box(,2,60)
  cSifra:=space(8)
  @ m_x+1,m_y+2 SAY "Sifra za koristenje specijalnih fja:"
  cSifra:=upper(GETSECRET( cSifra))
BoxC()

GW_STATUS:=lGW_Status
if cSifra==csif
  return .t.
else
 return .f.
endif

return

/*! \fn O_POMDB(nArea,cImeDBF)
 *  \brief otvori pomocnu tabelu, koja ako se nalazi na CDU npr se kopira u lokalni
 *   direktorij pa zapuje
 */

function O_POMDB(nArea,cImeDBF)

select (nArea)

if right(upper(cImeDBF),4)<>"."+DBFEXT
  cImeDBF:=cImeDBf+"."+DBFEXT
endif
cImeCDX:=strtran(UPPER(cImeDBF),"."+DBFEXT,"."+INDEXEXT)
cImeCDX:=ToUnix(cImeCDX)

#xcommand USEXX <(db)>                                                    ;
             [VIA <rdd>]                                                ;
             [ALIAS <a>]                                                ;
             [<new: NEW>]                                               ;
             [<ro: READONLY>]                                           ;
             [INDEX <(index1)> [, <(indexn)>]]                          ;
                                                                        ;
      => dbUseArea(                                                     ;
                    <.new.>, <rdd>, <(db)>, <(a)>,                      ;
                     .f., .f.        ;
                  )                                                     ;

// podaci na cdu
if (gReadonly .or. gKesiraj=="X")  
    cPom:=STRTRAN(PRIVPATH,LEFT(PRIVPATH,3),"C:"+SLASH)

    // dir na c
    DirMak2(cpom)

    if !file(cPom+cImeDBF) .or. !file(cPom+cImeCDX)
          COPY FILE (PRIVPATH+cImeDBF)  TO  (cPom+cImeDBF)
          COPY FILE (PRIVPATH+cImeCDX)  TO  (cPom+cImeCDX)
          SETFATTR(cPom+cImeDBF, 32)  // normal
          SETFATTR(cPom+cImeCDX, 32)  // normal
    endif
    usexx (cPom+cImeDBF)
    __dbzap()
    return

else
    usex (PRIVPATH+cImeDBF)
endif

return

function JelReadOnly()
IF !( "U" $ TYPE("gGlBaza") )
	IF !EMPTY(gGlBaza)
		#ifdef CLIP      
      			gReadOnly := ( FILEATTR(ToUnix(goModul:oDatabase:cDirKum+SLASH+gGlBaza))==1 )
		#else
      			gReadOnly := ( FILEATTR(ToUnix(cDirRad+SLASH+gGlBaza))==1 )
		#endif
    	ENDIF
ENDIF
return nil


function CheckROnly( cFileName )
if FILEATTR(cFileName) == 1 
	gReadOnly := .t.
	@ 1, 55 SAY "READ ONLY" COLOR "W/R"
else
	gReadOnly := .f.
	@ 1, 55 SAY "         "
endif

return


function SetROnly(lSilent)
if (lSilent == nil)
	lSilent := .f.
endif

if lSilent
	MsgO("Zakljucavam sezonu...")
endif

IF !lSilent .and. gReadOnly
   	MsgBeep("Podrucje je vec zakljucano!")
   	if Pitanje(,"Zelite otkljucati podrucje ?","N") == "D"
		SetWOnly()
		return
	endif
	RETURN
ENDIF

if !lSilent .and. !SigmaSif("ZAKSEZ")
	return
endif

IF "U" $ TYPE("gGlBaza")
	if !lSilent
		MsgBeep("Nemoguce izvrsiti zakljucavanje##Varijabla gGlBaza nedefinisana!")
   	endif
	RETURN
ENDIF

IF EMPTY(gGlBaza)
  	if !lSilent
		MsgBeep("Nemoguce izvrsiti zakljucavanje##Varijabla gGlBaza prazna!")
   	endif
	RETURN
ENDIF

if !lSilent
	MsgBeep("Izabrana opcija (Ctrl+F10) sluzi za zakljucavanje poslovne godine. #"+;
         "To znaci da nakon ove opcije nikakve ispravke podataka u trenutno #"+;
         "aktivnom podrucju nece biti moguce. Ukoliko ste sigurni da to zelite #"+;
         "na sljedece pitanje odgovorite potvrdno!" )
endif

IF !lSilent .and. Pitanje(,"Jeste li sigurni da zelite zastititi trenutno podrucje od ispravki? (D/N)","N")=="D"

   		IF SETFATTR(cDirRad + SLASH + gGlBaza, 1) == 0
     			gReadOnly:=.t.
			CheckROnly(cDirRad + SLASH + gGlBaza)
		ELSE
 			MsgBeep("Greska! F-ja zastite trenutno izabranog podrucja onemogucena! (SETFATTR)")
   		ENDIF
ELSE
	IF SETFATTR(cDirRad + SLASH + gGlBaza, 1) == 0
		gReadOnly:=.t.
	ENDIF	
ENDIF

if lSilent
	Sleep(3)
	MsgC()
	CheckROnly(cDirRad + SLASH + gGlBaza)
endif

return
*}

/*! \fn SetWOnly()
 *  \brief Set write atributa
 */
function SetWOnly(lSilent)
*{

if (lSilent == nil)
	lSilent := .f.
endif

if lSilent
	MsgO("Otkljucavam sezonu...")
endif

if !lSilent .and. !SigmaSif("OTKSEZ")
	return
endif

IF "U" $ TYPE("gGlBaza")
	if !lSilent
		MsgBeep("Nemoguce izvrsiti otljucavanje. Varijabla gGlBaza nedefinisana!")
   	endif
	RETURN
ENDIF

IF EMPTY(gGlBaza)
  	if !lSilent
		MsgBeep("Nemoguce izvrsiti otkljucavanje. Varijabla gGlBaza prazna!")
   	endif
	RETURN
ENDIF

IF !lSilent .and. Pitanje(,"Jeste li sigurni da zelite ukloniti zastitu? (D/N)","N")=="D"
	#ifdef CLIP
   		IF SETFATTR(goModul:oDatabase:cDirKum + SLASH + gGlBaza, 0) == 0
	#else
   		IF SETFATTR(cDirRad + SLASH + gGlBaza, 0) == 0
	#endif
     			gReadOnly:=.f.
			CheckROnly(cDirRad + SLASH + gGlBaza)
   		ELSE
     			MsgBeep("Greska! F-ja ukidanje zastite onemogucena! (SETFATTR)")
   		ENDIF
ELSE
   		IF SETFATTR(cDirRad + SLASH + gGlBaza, 0) == 0
			gReadOnly:=.f.
		ENDIF
ENDIF

if lSilent
	Sleep(3)
	MsgC()
	CheckROnly(cDirRad + SLASH + gGlBaza)
endif

return


/*! \fn SkratiAZaD(aStruct)
 *  \brief skrati matricu za polje D
 
 *  \code
 *  SkratiAZaD(@aStruct)
 *  \endcode
*/

function SkratiAZaD(aStruct)
nLen:=len(aStruct)
for i:=1 to nLen
    // sistemska polja
    if ("#"+aStruct[i,1]+"#" $ "#BRISANO#_SITE_#_OID_#_USER_#_COMMIT_#_DATAZ_#_TIMEAZ_#")
     ADEL (astruct,i)
     nLen--
     i:=i-1
    endif
next
ASIZE(aStruct,nLen)

return nil

 
/*! \fn Append2()
 * \brief Dodavanje novog zapisa u (nArr) -
 * \note koristi se kod dodavanja zapisa u bazu nakon Izdvajanja zapisa funkcijom Izdvoji()
 */

function Append2()
local nRec
select(nArr)
DbAppend()
nRec:=RECNO()
select(nTmpArr)
DbAppend()
replace recno with nRec

return nil

/*! \fn DbfName(nArea, lFull)
 *  \param nArea
 *  \param lFull True - puno ime cPath + cDbfName; False - samo cDbfName; default=False
 *
 */
 
function DbfName(nArea, lFull)
local nPos
local cPrefix

if lFull==nil
	lFull:=.f.
endif
cPrefix:=""
nPos:=ASCAN(gaDbfs,{|x| x[1]==nArea})

if nPos<1
 nPos:=ASCAN(gaSDbfs,{|x| x[1]==nArea})
 if nPos<1
   //MsgBeep("Ne postoji DBF Arrea "+STR(nArea)+" ?")
   return ""
 endif
 if lFull
 	cPrefix:=DbfPath(gaSDbfs[nPos,3])
 endif
 return cPrefix + gaSDbfs[nPos,2]
else
 if lFull 
 	cPrefix:=DbfPath(gaDbfs[nPos,3])
 endif
 return cPrefix+gaDbfs[nPos,2]
endif
return

function DbfPath(nPath)
do case
	CASE nPath==P_PRIVPATH
		return PRIVPATH
	CASE nPath==P_KUMPATH
		return KUMPATH
	CASE nPath==P_SIFPATH
		return SIFPATH
	CASE nPath==P_EXEPATH
		return EXEPATH
	CASE nPath==P_MODULPATH
		return DBFBASEPATH+SLASH+gModul+SLASH
	CASE nPath==P_TEKPATH
		return "."+SLASH
	CASE nPath==P_ROOTPATH
		return SLASH
	CASE nPath==P_KUMSQLPATH
		return KUMPATH+"SQL"+SLASH
	CASE nPath==P_SECPATH
		return goModul:oDatabase:cSigmaBD+SLASH+"SECURITY"+SLASH
end case
return 

function DbfArea(cImeDBF, nVarijanta)
local nPos

cImeDBF:=ToUnix(cImeDBF)

if (nVarijanta==nil)
  // vrati oznaku Working area-e
  nVarijanta:=0
endif

nPos:=ASCAN(gaDBFS,{|x| x[2]==cImeDBF})

if nPos<1
 nPos:=ASCAN(gaSDBFS,{|x| x[2]==cImeDBF})
 if nPos<1
   ? "Ne postoji "+cImeDBF+" u gaDBFs ili gaSDBFs ?"
   goModul:quit()
 endif
 nArray:=2
 if nVarijanta==0 
  return gaSDBFS[nPos,1]
 else
  return nPos
 endif 
else
 nArray:=1
 if nVarijanta==0  
   return gaDBFS[nPos,1]
 else
   return nPos
 endif
endif
return

function nDBF(cBaza)
return DbfArea(cBaza)

function nDBFPos(cBaza)
// pozicija u agDBFs
return DbfArea(cBaza,1)

function F_Baze(cBaza)
local nPos
nPos:=nDBF(cBaza)
IF nPos<=0
	CLOSE ALL
	QUIT
ENDIF
return nPos

function Sel_Bazu(cBaza)
local nPos
 
 nPos:=nDBFPos(cBaza)
 IF nPos>0
   SELECT (gaDBFs[nPos,1])
 ELSE
   CLOSE ALL; QUIT
 ENDIF
return

function gaDBFDir(nPos)
nPom:=gaDBFs[nPos,3]
do case
  case nPom=P_KUMPATH
   return KUMPATH
  case nPom=P_PRIVPATH
   return  PRIVPATH
  case nPom=P_SIFPATH
   return SIFPATH
  case nPom=P_MODPATH
   return "."+SLASH
  case nPom=P_EXEPATH
   return EXEPATH
  otherwise
   return ""
endcase

function O_Bazu(cBaza)

LOCAL nPos:=nDBFPos(cBaza)
IF nPos>0
   SELECT (gaDBFs[nPos,1])
   USE ( gaDBFDir(nPos) +  gaDBFs[nPos,2])
ELSE
   CLOSE ALL
   QUIT
ENDIF
return


/*! \fn ExportBaze(cBaza)

   Vidljive slogove tekuce baze kopira u bazu cBaza. Prije toga izbrise
   bazu cBaza i pripadajuce indekse ukoliko postoje. cBaza ostaje zatvorena
   a tekuca baza i dalje ostaje ista
*/

function ExportBaze(cBaza)
LOCAL nArr:=SELECT()
  FERASE(cBaza+"."+INDEXEXT)
  FERASE(cBaza+"."+DBFEXT)
  cBaza+="."+DBFEXT
  COPY STRUCTURE EXTENDED TO (PRIVPATH+"struct")
  CREATE (cBaza) FROM (PRIVPATH+"struct") NEW
  MsgO("apendujem...")
  APPEND FROM (ALIAS(nArr))
  MsgC()
  USE
  SELECT (nArr)
return


function PoljeBrisano(cImeDbf)
*{
* select je na bazi koju ispitujes

if fieldpos("BRISANO")=0 // ne postoji polje "brisano"
  use
  save screen to cScr
  cls
  Modstru(cImeDbf,"C  V C 15 0  FV C 15 0",.t.)
  Modstru(cImeDbf,"A BRISANO C 1 0",.t.)  // dodaj polje "BRISANO"
  inkey(10)
  restore screen from cScr

  use (cImeDBf)
endif
return nil
*}


/*! \fn SmReplace(cField, xValue, lReplAlways)
 *  \brief Smart Replace - vrsi replace. Ako je lReplAlways .T. uvijek vrsi, .F. samo ako je vrijdnost polja razlicita 
 *  \note vrsi se i REPLSQL, kada je gSql=="D"
 */
 
function SmReplace(cField, xValue, lReplAlways)
*{
private cPom

if (lReplAlways == nil)
	lReplAlways := .f.
endif

cPom:=cField

if ((&cPom<>xValue) .or. (lReplAlways == .t.))
	REPLACE &cPom WITH xValue
	if (gSql=="D")
		REPLSQL &cPom WITH xValue
	endif
endif

return
*}

/*! \fn  PreUseEvent(cImeDbf, fShared)
 *  \brief Poziva se prije svako otvaranje DBF-a komanom USE
 *
 * Za gSQL=="D":
 * Ako fajl KUMPATH + DOKS.gwu postoji, to znaci da je Gateway izvrsio
 * update fajla pa zato reindeksiraj i pakuj DBF
 * Na kraju izbrisi *.gwu fajl
 *
 */

function PreUseEvent(cImeDbf, fShared)
*{
local cImeCdx
local cImeGwu
local nArea
local cOnlyName

if (goModul:oDatabase<>nil) 
	if (goModul:oDatabase:lAdmin)
		return 0
	endif
else
	//sistem jos nije inicijaliziran, samo vrati isto ime tabele
	return cImeDbf
endif

if nPreuseLevel>0
	return 0
endif
// ne dozvoli rekurziju funkcije
nPreuseLevel:=1

cOnlyName:=ChangeEXT(ExFileName(cImeDbf),"DBF","")

cImeGwu:=ChangeEXT(cImeDbf, DBFEXT, "gwu")
cImeCdx:=ChangeEXT(cImeDbf, DBFEXT, INDEXEXT)

cImeDbf:=LOWER(cImeDbf)
cImeDbf:=STRTRAN(cImeDbf, ".korisn","korisn")
cImeGw:=ChangeEXT(cImeDbf, DBFEXT, "gwu")

if gReadOnly 
	nPreuseLevel:=0
	return cImeDbf
endif


if (GW_STATUS="-" .and. FILE(cImeGwu))

	nArea:=DbfArea(UPPER(cOnlyName))
	FERASE(cImeCdx)
	goModul:oDatabase:kreiraj(nArea)
	FERASE(cImeGwu)
		
endif

nPreuseLevel:=0
return cImeDbf
*}

/*! \fn ScanDb()
 *  \brief Prodji kroz sve tabele i pokreni PreuseEvent
 *  \note sve tabele koje je gateway azurirao bice indeksirane
 */
function ScanDb()
local i
local cDbfName

CLOSE ALL

for i:=1 to 250
	MsgO("ScanDb "+STR(i))
	cDbfName:=DbfName(i,.t.)
	if !EMPTY(cDbfName)
		if FILE(cDbfName+"."+DBFEXT)
			USEX (cDbfName)
			if (RECCOUNT()<>RecCount2())
				MsgO("Pakujem "+cDbfName)
					__DBPACK()
				MsgC()
			endif
			USE
		endif
		PreUseEvent(cDbfName, .f.)
	endif
	MsgC()
		
next
CLOSE ALL
return

// --------------------------------
// --------------------------------
function PushWA()
if used()
 StackPush(aWAStack,{select(),IndexOrd(),DBFilter(),RECNO()})
else
 StackPush(aWAStack,{NIL,NIL,NIL,NIL})
endif
return NIL


// ---------------------------
// ---------------------------
function PopWA()

local aWa
local i

aWa:=StackPop(aWaStack)
if aWa[1]<>nil
   
   // select
   SELECT(aWa[1])
   
   // order
   if used()
	   if !empty(aWa[2])
	      ordsetfocus(aWa[2])
	   else
	    set order to
	   endif
   endif

   // filter
   if !empty(aWa[3])
     set filter to &(aWa[3])
   else
     if !empty(dbfilter())
       set filter to
     endif
     //   DBCLEARFILTER( )
   endif
   
   go aWa[4]
   
endif  // wa[1]<>NIL
return NIL



// ---------------------------------------------------------
// modificiranje polja, ubacivanje predznaka itd...
//
// params:
//   - cField = "SIFRADOB" 
//   - cIndex - indeks na tabeli "1" ili "ID" itd...
//   - cInsChar - karakter koji se insertuje
//   - nLen - duzina sifra na koju se primjenjuje konverzija
//            i insert (napomena: nije duzina kompletne sifre)
//            IDROBA = LEN(10), ali mi zelimo da konvertujemo
//            na LEN(5) sifre sa vodecom nulom
//   - nSufPref - sufiks (1) ili prefiks (2)
//   - funkcija vraca konvertovani broj zapisa
//   - lSilent - tihi mod rada .t. ili .f.
//   
//   Napomena:
//   tabela na kojoj radimo konverziju moraju biti prije pokretanja 
//   funkcije otvoreni
// ---------------------------------------------------------
function mod_f_val( cField, cIndex, cInsChar, nLen, nSufPref, lSilent )
local nCount := 0

if cIndex == nil
	cIndex := "1"
endif

if nSufPref == nil
	nSufPref := 2
endif

if lSilent == nil
	lSilent := .f.
endif

if lSilent == .f. .and. Pitanje(,"Izvrsiti konverziju ?", "N") == "N"
	return -1
endif

set order to tag cIndex
go top

do while !EOF()
	
	// trazena vrijednost iz polja
	cVal := ALLTRIM( field->&cField )
	nFld_len := LEN( field->&cField )
 
 	if !EMPTY( cVal ) .and. LEN( cVal ) < nLen

		if nSufPref == 1
			// sufiks
			cNew_val := PADR( cVal, nLen, cInsChar )
		else
			// prefiks
			cNew_Val := PADL( cVal, nLen, cInsChar )
 		endif

		// ubaci novu sifru sa nulama
		replace field->&cField with PADR( cNew_val, nFld_len )
		++ nCount 
	endif
	
	skip

enddo

return nCount



