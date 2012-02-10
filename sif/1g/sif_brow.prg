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

#include "dbstruct.ch"

// static integer
static __PSIF_NIVO__:=0
// ;

static _LOG_PROMJENE := .f.

// static array __A_SIFV__;
#ifndef CPP
static __A_SIFV__:= { {NIL,NIL,NIL}, {NIL,NIL,NIL}, {NIL,NIL,NIL}, {NIL,NIL,NIL}}
#endif

function PostojiSif( nDbf, nNtx, nVisina, nSirina, cNaslov, cID, dx, dy, ;
                      bBlok, aPoredak, bPodvuci, aZabrane, fInvert, aZabIsp )

local cRet, cIdBK
local i
private cNazSrch
private cUslovSrch
private fPoNaz:=.f.  // trazenje je po nazivu
private fID_J := .f.
private cSFilt

if aZabIsp == nil
	aZabIsp := {}
endif

FOR i:=1 TO LEN(aZabIsp)
	aZabIsp[i] := UPPER(aZabIsp[i])
NEXT

// provjeri da li treba logirati promjene
if Logirati("FMK","SIF","PROMJENE")
	_LOG_PROMJENE := .t.	
endif

private nOrdId
private fBosanski:=.f.

// setuj match_code polje...
set_mc_imekol(nDbf)

PushWa()
PushSifV()

if finvert=NIL
 finvert:=.t.
endif

select (nDbf)
nOrderSif:=indexord()  // zapamti order sifranika !!


nOrdId := ORDNUMBER("ID")

// POSTAVLJANJE ORDERA...
if valtype(nNTX)="N"
  
  if nNTX==1
    
    if nordid<>0
     set order to tag "ID"
    else
     set order to tag "1"
    endif

  else
    
    if nordid<>0
     if OrdNumber("NAZ_B")<>0
        set order to tag "NAZ_B"
        fBosanski:=.t.
     else
        set order to tag "NAZ"
        fbosanski:=.f.
     endif
    else
     set order to tag "2"
    endif
  endif
  
elseif valtype(nNTX)="C" .and. right(upper(trim(nNTX)),2)="_J"
// postavi order na ID_J

  set order to tag (nNTX)
  fID_J:=.t.

else

  // IDX varijanta:  TAG_IMEIDXA
  nPos:=AT("_",nNTX)
  if nPos<>0
   if empty(left(nNtx,nPos-1))
     dbsetindex(substr(nNTX,nPos+1))
   else
     set order to tag (left(nNtx,nPos-1)) IN (substr(nNTX,nPos+1))
   endif
  else
   set order to tag (nNtx)
  endif
endif

private cUslovSrch:=""
IF cId <>NIL  
 // IZVRSI SEEK
 
 if VALTYPE(cid)=="N"
	
	seek STR(cId)
	
 elseif right(trim(cid),1)=="*"

   if  fieldpos("KATBR")<>0 // trazi po kataloskom broju
     // SEEK KATBR
     set order to tag "KATBR"
     seek LEFT(cId, len(trim(cid))-1)
     cId:=id
   else
     seek "‡·‚"
   endif

   if !FOUND()
     // trazi iz sifranika karakteristika
     cIdBK:=left(cid,len(trim(cid))-1)
     cId:=""
     ImauSifV("ROBA","KATB", cIdBK, @cId)
     if !empty(cID)
       select roba
       set order to tag "ID"
       seek cId  // nasao sam sifru !!
       cId:=Id
       if fid_j
          cId:=ID_J
	  set order to tag "ID_J"
	  seek cId
       endif

     endif
   endif

 elseif right(trim(cid),1) $ "./$"
 // POSTAVI FILTER SA "/"

   if nordid<>0
    if OrdNumber("NAZ_B")<>0
       set order to tag "NAZ_B"
       fBosanski:=.t.
    else
       set order to tag "NAZ"
       fbosanski:=.f.
    endif
   else
    set order to tag "2"
   endif
   
   fPoNaz:=.t.
   cNazSrch:=""
   cUslovSrch:=""

   if left(trim(cid),1)=="/"
     private GetList:={}
     Box(,1,60)
       cUslovSrch:=space(120)
       Beep(1)
       @ m_x+1,m_y+2 SAY "Zelim pronaci:" GET cUslovSrch pict "@!S40"
       read
       cUslovSrch:=trim(cUslovSrch)
       if right(cUslovSrch,1)=="*"
          cUslovSrch:=left( cUslovSrch , len(cUslovSrch)-1 )
       endif

     BoxC()

   elseif left(trim(cid),1)=="."
     // SEEK PO NAZ kada se unese DUGACKI DIO
     Box(,1,60)
       cNazSrch:=space(len(naz))
       Beep(1)
       private GetList:={}
       @ m_x+1,m_y+2 SAY "Unesi naziv:" GET cNazSrch PICTURE "@!S40"
       read
     BoxC()
     if fbosanski
        seek trim(BTOEU(cNazSrch))
     else
        seek trim(cNazSrch)
     endif

     cId:=Id
   
   elseif RIGHT(trim(cId),1) == "$"
   	
	// postavljanje filtera po dijelu naziva sifre
	cSFilt := cm2str( LEFT( UPPER(cId), LEN( TRIM( cId ) ) - 1 ) ) + " $ UPPER( naz ) "
	set filter to
	set filter to &( cSFilt )
	go top

   else
     
     if fbosanski
        seek left(BTOEU(cid), len(trim(cid))-1)
     else
        seek left(cid, len(trim(cid))-1)
     endif
   endif

 elseif len(trim(cId))>10 .and. fieldpos("BARKOD")<>0 
	
	SeekBarKod(@cId,@cIdBk,.f.)

 else
 
   // SEEK PO ID , SEEK PO ID_J
   seek cID
   
   cId := &(FIELDNAME(1))
   
   // pretrazi po barkod-u
   if !found() .and. fieldpos("barkod")<>0
	SeekBarKod( @cId, @cIdBk, .t. )
   endif
   
 endif
 
ENDIF


if dx<>NIL .and. dx<0
// u slucaju negativne vrijednosti vraca se vrijednost polja
// koje je na poziciji ABS(i)
      if !found()
        go bottom
        skip  // id na eof, tamo su prazne vrijednosti
        cRet:=&(FIELDNAME(-dx))
        skip -1
      else
        cRet:=&(FIELDNAME(-dx))
      endif
      PopSifV()
      PopWa()
      return cRet
endif

if !empty(cUslovSrch)
  SetSifFilt(cUslovSrch)  // postavi filter u sifrarniku
endif

if (fPonaz .and. (cNazSrch=="" .or. !trim(cNazSrch)==trim(naz))) .or.;
   (!found() .and. cNaslov<>NIL)  .or.;
   cId==NIL .or. ;
   (cNaslov<>NIL .and. left(cNaslov,1)="#")  // if cID== nil - pregled sifrarnika

  lPrviPoziv:=.t.
  if eof() //.and. !bof()
   skip -1
  endif
  if cId==NIL // idemo bez parametara
   go top
  endif

   ObjDbedit(, nVisina,nSirina, ;
       {|| EdSif(nDbf, cNaslov, bBlok, aZabrane, aZabIsp)}, ;
       cNaslov, "", finvert,;
       {"<c-N> Novi","<F2>  Ispravka","<ENT> Odabir","<c-T> Brisi",;
        "<c-P> Print","<F4>  Dupliciraj","<c-F9> Brisi SVE",;
        "<c-F> Trazi","<a-S> Popuni kol.","<a-R> Zamjena vrij.",;
        "<c-A> Cirk.ispravka"}, ;
	1, bPodvuci, , , aPoredak)

   IF TYPE("id") $ "U#UE"       
     cID:=(nDbf)->(FIELDGET(1))
   ELSE
     cID:=(nDbf)->id
     if fID_J
       __A_SIFV__[__PSIF_NIVO__,1]:=(nDBF)->ID_J
     endif
   ENDIF
else
// nisam ni ulazio u objdb
  if fID_J
      cId:=(nDBF)->id
      __A_SIFV__[__PSIF_NIVO__,1]:= (nDBF)->ID_J
  endif
endif

__A_SIFV__[__PSIF_NIVO__,2]:= recno()

if dx<>NIL .and. dy<>nil
	if (nDbf)->(fieldpos("naz")) <> 0
		@ m_x+dx,m_y+dy SAY PADR(TRIM((nDbf)->naz), 70-dy)
	endif
	if (nDbf)->(fieldpos("naziv")) <> 0
		@ m_x+dx,m_y+dy SAY PADR(TRIM((nDbf)->naziv), 70-dy)
	endif
elseif dx<>NIL .and. dx>0 .and. dx<25
	if (nDbf)->(fieldpos("naz")) <> 0
  		CentrTxt(trim((nDbf)->naz),dx)
	endif
	if (nDbf)->(fieldpos("naziv")) <> 0
  		CentrTxt(trim((nDbf)->naziv),dx)
	endif
endif


select (nDbf)

//vrati order sifranika !!
ordsetfocus(nOrderSif)    

set filter to
PopSifV()
PopWa()
return .t.

// --------------------------
// --------------------------
function ID_J(nOffSet)

if nOffset=NIL
 nOffset:=1
endif
if __PSIF_NIVO__ + nOffset > 0
  return __A_SIFV__[__PSIF_NIVO__+nOffset,1]
else
  return __A_SIFV__[1,1]
endif
return

// -------------------------------------------
// setuje match_code imekol {}
// -------------------------------------------
function set_mc_imekol(nDBF)
local nSeek
local bPom

cFldId := "ID"
cFldMatchCode := "MATCH_CODE"

// ako nema polja match code ... nista...
if (nDBF)->(fieldpos(cFldMatchCode)) == 0
	return
endif

nSeek := ASCAN(ImeKol, {|xEditFieldNaz| UPPER(xEditFieldNaz[3]) == "ID" })
//cFldId := ImeKol[nSeek, 3]

// setuj prikaz polja
if nSeek > 0

	bPom := { || ;
		PADR( ALLTRIM(&cFldID) + ;
		IF( !EMPTY(&cFldMatchCode), ;
			IF( LEN(ALLTRIM(&cFldMatchCode)) > 4 , ;
			   "/" + LEFT(ALLTRIM(&cFldMatchCode), 2) + "..", ;
			   "/" + LEFT(ALLTRIM(&cFldMatchCode), 4)), ;
		""), ;
		LEN(&cFldID) + 5 ) ;
		}
	
	ImeKol[nSeek, 1] := "ID/MC"
	ImeKol[nSeek, 2] := bPom
	
	
endif

return



function SIF_TEKREC(cDBF, nOffset)

local xVal
local nArr
if nOffset=NIL
 nOffset:=1
endif
if __PSIF_NIVO__ + nOffset > 0
 xVal:= __A_SIFV__[__PSIF_NIVO__+nOffset,2]
else
 xVal:= __A_SIFV__[1,2]
endif

if cDBF<>NIL
    nArr:=select()
    select (cDBF)
      go xVal
    select (nArr)
endif
return xVal

// ---------------------------------------------------
// ---------------------------------------------------
function PushSifV()
__PSIF_NIVO__ ++
if __PSIF_NIVO__ > len(__A_SIFV__)
  AADD(__A_SIFV__,{"",0,0})
endif
return


static function PopSifV()

--__PSIF_NIVO__
return

// ------------------------------------------------------------
// -----------------------------------------------------------
static function EdSif(nDbf, cNaslov, bBlok, aZabrane, aZabIsp)

local i
local j
local jg
local imin
local imax
local nGet
local nRet 
local nOrder
local nLen
local nRed
local nKolona
local nTekRed
local nTrebaRedova
private cPom
private aQQ
private aUsl
private aStruct
private lNovi

// matrica zabrana
if aZabrane=nil
 aZabrane:={}
endif
 
// matrica zabrana ispravki polja
if aZabIsp=nil
 aZabIsp:={}
endif

Ch:=LASTKEY()

// deklarisi privatne varijable sifrarnika
aStruct:=DBSTRUCT()
SkratiAZaD(@aStruct)
for i:=1 to LEN(aStruct)
     cImeP:=aStruct[i,1]
     cVar:="w"+cImeP
     PRIVATE &cVar:=&cImeP
next

nOrder:=indexord()
nRet:=-1
lZabIsp:=.f.

if bBlok<>NIL
  nRet:=Eval(bBlok,Ch)
  if nret>4
    if nRet==5
      return DE_ABORT
    elseif nRet==6
      return DE_CONT
    elseif nRet==7
      return DE_REFRESH
    elseif nRet==99 .and. LEN(aZabIsp)>0
      lZabIsp:=.t.
      nRet:=-1
    endif
  endif
endif

cSecur:=SecurR(klevel,"Sifrarnici")

if (Ch==K_CTRL_N .and.  !ImaSlovo("AN", cSecur)  )  .or. ;
   (Ch==K_CTRL_A .and.  !ImaSlovo("AI", cSecur)  )  .or. ;
   (Ch==K_F2     .and.  !ImaSlovo("AI", cSecur)  )  .or. ;
   (Ch==K_CTRL_T .and.  !ImaSlovo("AB", cSecur)  )  .or. ;
   (Ch==K_F4     .and.  !ImaSlovo("AI", cSecur)  )  .or. ;
   (Ch==K_CTRL_F9 .and.  !ImaSlovo("A9", cSecur)  ) .or. ;
   ASCAN(azabrane,Ch)<>0  
   MsgBeep("Nivo rada:"+klevel+":"+cSecur+": Opcija nedostupna !")
   return DE_CONT
endif

cSecur:=SecurR(klevel,"SGLEDAJ")
if (Ch==K_CTRL_N .and.  ImaSlovo("D",cSecur)  )  .or. ;
   (Ch==K_CTRL_A .and.  ImaSlovo("D",cSecur)  )  .or. ;
   (Ch==K_F2     .and.  ImaSlovo("D",cSecur)  )  .or. ;
   (Ch==K_CTRL_T .and.  ImaSlovo("D",cSecur)  )  .or. ;
   (Ch==K_F4     .and.  ImaSlovo("D",cSecur)  )  .or. ;
   (Ch==K_CTRL_F9 .and. ImaSlovo("D",cSecur)  )
   MsgBeep("Nivo rada:"+klevel+":"+cSecur+": Opcija nedostupna !")
   return DE_CONT
endif

if ((Ch==K_CTRL_N .or.Ch==K_CTRL_A .or. Ch==K_F2 .or. Ch==K_CTRL_T .or. Ch==K_F4 .or. Ch==K_CTRL_F9 .or. Ch==K_F10) .and. !ImaPravoPristupa(goModul:oDatabase:cName,"SIF","EDSIF")) 
	MsgBeep("Vi nemate pravo na promjenu podataka u sifrarnicima !")
	return DE_CONT
endif

do case

  case Ch==K_ENTER
    // ako sam u sifrarniku a ne u unosu dokumenta 
    if gMeniSif 
     return DE_CONT
    else
     // u unosu sam dokumenta
     lPrviPoziv:=.f.
     return DE_ABORT
    endif

  case UPPER(CHR(Ch)) == "F"
    // pretraga po MATCH_CODE
    if m_code_src() == 0
    	return DE_CONT
    else
    	return DE_REFRESH
    endif

  case Ch==ASC("/")

    cUslovSrch:=""
    Box(,1,60)
       cUslovSrch:=space(120)
       @ m_x+1,m_y+2 SAY "Zelim pronaci:" GET cUslovSrch pict "@!S40"
       read
       cUslovSrch:=trim(cUslovSrch)
       if right(cUslovSrch,1)=="*"
          cUslovSrch:=left( cUslovSrch , len(cUslovSrch)-1 )
       endif
    BoxC()

    if !empty(cUslovSrch)
      // postavi filter u sifrarniku
      SetSifFilt(cUslovSrch)  
    else
      set filter to
    endif
    return DE_REFRESH


  case (Ch==K_CTRL_N .or. Ch==K_F2 .or. Ch==K_F4 .or. Ch==K_CTRL_A)

    if EditSifItem(Ch,nOrder,aZabIsp)==1
      return DE_REFRESH
    endif
    RETURN DE_CONT
    
  case Ch==K_CTRL_P

    PushWa()
    IzborP2(Kol,PRIVPATH+alias())
    if lastkey()==K_ESC
        return DE_CONT
    endif
    Izlaz("Pregled: "+ALLTRIM(cNaslov)+" na dan "+dtoc(date())+" g.","sifrarnik")
    set filter to
    PopWa()
    return DE_CONT

  case Ch==K_ALT_F
     uslovsif()
     return DE_REFRESH

  case Ch==K_ALT_F9
	if SigmaSif("UNDEL")
		set deleted off
		go top
		do while !eof()
			dbrecall()
			replace brisano with " "
			skip 1
		enddo
	endif
	return DE_REFRESH

  case Ch==K_CTRL_T
    if Pitanje(,"Zelite li izbrisati ovu stavku ??","D")=="D"
      sql_delete()
      delete
      
      nTArea := SELECT()
      
      // logiraj promjenu brisanja stavke
      if _LOG_PROMJENE == .t.
      	EventLog(nUser, "FMK", "SIF", "PROMJENE", nil, nil, nil, nil, ;
		"stavka: " + to_str( FIELDGET(1) ), "", "", DATE(), DATE(), "", ;
		"brisanje sifre iz sifrarnika")
      endif
      
      select (nTArea)

      return DE_REFRESH
    else
      return DE_CONT
    endif

  case Ch==K_CTRL_F6
    Box(,1,30)
      public gIdFilter:=eval(ImeKol[TB:ColPos,2])
      @ m_x+1,m_y+2 SAY "Filter :" GET gidfilter
      read
    BoxC()
    if empty(gidfilter)
      set filter to
    else
      set filter to eval(ImeKol[TB:ColPos,2])==gidfilter
      go top
    endif
    return DE_REFRESH


  case Ch==K_CTRL_F9

        if Pitanje(,"Zelite li sigurno izbrisati SVE zapise ??","N")=="D"
          
	  Beep(6)
          
	  nTArea := SELECT()
	   // logiraj promjenu brisanja stavke
          if _LOG_PROMJENE == .t.
      	       EventLog(nUser, "FMK", "SIF", "PROMJENE", nil, nil, nil, nil, ;
	           "", "", "", DATE(), DATE(), "", ;
	           "pokusaj brisanja kompletnog sifrarnika")
          endif
	  select (nTArea)
	  
	  if Pitanje(,"Ponavljam : izbrisati BESPOVRATNO kompletan sifrarnik ??","N")=="D"
             zap

             nTArea := SELECT()
	     // logiraj promjenu brisanja stavke
             if _LOG_PROMJENE == .t.
      	        EventLog(nUser, "FMK", "SIF", "PROMJENE", nil, nil, nil, nil, ;
		     "", "", "", DATE(), DATE(), "", ;
		     "brisanje kompletnog sifrarnika")
             endif
	     
	     select (nTArea)

	  endif
          return DE_REFRESH
        else
          return DE_CONT
        endif

  case Ch==K_ALT_C
    
    return SifClipBoard()

  case Ch==K_F10
      SifPopup(nOrder)
      RETURN DE_CONT
  otherwise

     if nRet>-1
       return nRet
     else
       return DE_CONT
     endif

endcase
return


// -----------------------------------
// pretraga po match_code polju
// -----------------------------------
static function m_code_src()
local cSrch
local cFilter

if !is_m_code()
	// ne postoji polje match_code
	return 0
endif

Box(, 7, 60)
	private GetList:={}
	cSrch:=SPACE(20)
	set cursor on
	@ m_x+1, m_y+2 SAY "Match code:" GET cSrch VALID !EMPTY(cSrch)
	@ m_x+3, m_y+2 SAY "Uslovi za pretragu:" COLOR "I"
	@ m_x+4, m_y+2 SAY " /ABC = m.code pocinje sa 'ABC'  ('ABC001')"
	@ m_x+5, m_y+2 SAY " ABC/ = m.code zavrsava sa 'ABC' ('001ABC')"
	@ m_x+6, m_y+2 SAY " #ABC = 'ABC' je unutar m.code  ('01ABC11')"
	@ m_x+7, m_y+2 SAY " ABC  = m.code je striktno 'ABC'    ('ABC')"
	read
BoxC()

// na esc 0
if LastKey() == K_ESC
	return 0
endif

cSrch := TRIM(cSrch)
// sredi filter
g_mc_filter(@cFilter, cSrch)

if !EMPTY(cFilter)
	// set matchcode filter
     	s_mc_filter(cFilter)  
else
	set filter to
	go top
endif
   
return 1


// ------------------------------------------
// provjerava da li postoji polje match_code
// ------------------------------------------
function is_m_code()
if fieldpos("MATCH_CODE")<>0
	return .t.
endif
return .f.


// ---------------------------------
// setuj match code filter
// ---------------------------------
static function s_mc_filter(cFilter)
set filter to &cFilter
go top
return


// -------------------------------------
// sredi filter po match_code za tabelu
// -------------------------------------
static function g_mc_filter(cFilt, cSrch)
local cPom
local nLeft

cFilt:="TRIM(match_code)"
cSrch := TRIM(cSrch)

do case
	case LEFT(cSrch, 1) == "/"
	
		// match code pocinje
		cPom := STRTRAN(cSrch, "/", "")
		cFilt += "=" + Cm2Str(cPom)
		
	case LEFT(cSrch, 1) == "#"
		
		// pretraga unutar match codea
		cPom := STRTRAN(cSrch, "#", "")
		
		cFilt := Cm2Str(ALLTRIM(cPom))
		cFilt += "$ match_code"

	case RIGHT(cSrch, 1) == "/"
		
		// match code zavrsava sa...
		cPom := STRTRAN(cSrch, "/", "")
		nLeft := LEN(ALLTRIM(cPom))
		
		cFilt := "RIGHT(ALLTRIM(match_code),"+ALLTRIM(STR(nLeft))+")"
		cFilt += "==" + Cm2Str(ALLTRIM(cPom))
		
	otherwise
		
		// striktna pretraga
		cFilt += "==" + Cm2Str(cSrch)
endcase

return


// ------------------------------------------
// ------------------------------------------
function EditSifItem(Ch, nOrder, aZabIsp)
local i
local j
local jg
local imin
local imax
local nGet
local nRet 
local nLen
local nRed
local nKolona
local nTekRed
local nTrebaRedova
local oTable
local nPrevRecNo
local cMCField
local nMCScan
private nXP
private nYP
private cPom
private aQQ
private aUsl
private aStruct

nPrevRecNo:=RECNO()
lNovi:=.f.

if _LOG_PROMJENE == .t.
        // daj stare vrijednosti
	cOldDesc := _g_fld_desc("w")
endif

// dodaj u matricu match_code ako ne postoji
cMCField := ALIAS()
if &cMCField->(fieldpos("MATCH_CODE")) <> 0
	nMCScan := ASCAN(ImeKol, {|xImeKol| UPPER(xImeKol[3]) == "MATCH_CODE"})
	
	// ako ne postoji dodaj ga...
	if nMCScan == 0
		// dodaj polje u ImeKol
		AADD(ImeKol, {"MATCH_CODE", {|| match_code}, "match_code" })
		// dodaj novu stavku u kol
		AADD( Kol, LEN(ImeKol) )
	endif
endif


__A_SIFV__[__PSIF_NIVO__,3]:=  Ch


if Ch==K_CTRL_N .or. Ch==K_F2
       if nordid<>0
        set order to tag "ID"
       else
        set order to tag "1"
       endif
	go (nPrevRecNo)
endif


if Ch==K_CTRL_N
	lNovi:=.t.
	go bottom
	skip 1
endif


if Ch==K_F4
	lNovi:=.t.
endif


do while .t.
   
    // setuj varijable za tekuci slog
    SetSifVars()
   

    nTrebaredova:=LEN(ImeKol)
    for i:=1 to LEN(ImeKol)
      if LEN(ImeKol[i])>=10 .and. Imekol[i,10]<>NIL
         nTrebaRedova--
      endif
    next

    i:=1 
    // tekuci red u matrici imekol
    for jg:=1 to 3  // glavna petlja
	    
	    // moguca su  tri get ekrana

	    if jg==1
	      Box(, min( 20, nTrebaRedova) + 1, 67 ,.f.)
	    else
	      BoxCLS()
	    endif
	    set cursor on
	    Private Getlist:={}


	    nGet:=1 // brojac get-ova
	    nNestampati:=0  // broj redova koji se ne prikazuju (_?_)

	    nTekRed:=1
	    do while .t.  // i brojac
	    
	    lShowPGroup := .f.
	    
	    if empty(ImeKol[i,3])  // ovdje se kroji matrica varijabli.......
		cPom:=""  // area->nazpolja
	     else
	       if left(ImeKol[i,3],6)!="SIFK->"
		cPom:="w"+ImeKol[i,3]    //npr WVPC2
		// ako provjerimo strukturu, onda mozemo vidjeti da trebamo uzeti
		// varijablu karakteristike("ROBA","V2")
	       else
	         // ako je SIFK->GRUP, prikazuj status
	         if ALIAS() == "PARTN" .and. RIGHT(ImeKol[i,3],4) == "GRUP"
		    lShowPGroup := .t.
		 endif
		 cPom:= "wSifk_"+substr(ImeKol[i,3],7)
		 &cPom:= IzSifk(ALIAS(),substr(ImeKol[i,3],7))
		 if &cPom = NIL  // ne koristi se !!!
		    cPom:=""
		 endif
	       endif
	     endif

	     cPic:=""
	     if !empty(cPom) // samo varijable koje mozes direktno mjenjati

		 // uzmi when, valid kodne blokove
		 if (Ch==K_F2 .and. lZabIsp .and. ASCAN(aZabIsp, UPPER(ImeKol[i,3]))>0)
		   bWhen := {|| .f.}
		 elseif (LEN(ImeKol[i])<4 .or. ImeKol[i,4]==nil)
		   bWhen := {|| .t.}
		 else
		   bWhen:=Imekol[i,4]
		 endif

		 if (len(ImeKol[i])<5 .or. ImeKol[i,5]==nil)
		   bValid := {|| .t.}
		 else
		   bValid:=Imekol[i,5]
		 endif

		 if LEN(ToStr(&cPom))>50
		    if gPicSif=="M"
		      UsTipke()
		      cPic:="@S50"
		    elseif gPicSif=="8"
		      BH7u8()
		      cPic:="@S50"
		    else
		      BosTipke()
		      cPic:="@!S50"
		    endif
		    @ m_x+nTekRed+1,m_y+67 SAY Chr(16)
		 elseif Len(ImeKol[i])>=7 .and. ImeKol[i,7]<>NIL
		     cPic:= ImeKol[i,7]
		 else
		    if gPicSif=="M"
		     UsTipke()
		     cPic:=""
		    elseif gPicSif=="8"
		      BH7u8()
		      cPic:=""
		    else
		     BosTipke()
		     cPic:="@!"
		    endif
		 endif

		 nRed:=1
		 nKolona:=1
		 if Len(ImeKol[i])>=10 .and. imekol[i,10]<>NIL
		  nKolona:= imekol[i,10]+1
		  nRed:=0
		 endif
		 if nKolona=1
		     nTekRed++
		 endif
		
		 if lShowPGroup
		   nXP := nTekRed
		   nYP := nKolona
		 endif
		 
		 @ m_x+nTekRed , m_y+nKolona SAY if(nKolona>1,"  "+alltrim(ImeKol[i,1]) , PADL( alltrim(ImeKol[i,1]) ,15))  GET &cPom VALID eval(bValid) PICTURE cPic
		 // stampaj grupu za stavku "GRUP"
		 if lShowPGroup
		 	p_gr(&cPom, nXP+1, nYP+1)
		 endif
		
		 if cPom = "wSifk_"
		   // uzmi when valid iz SIFK
		   private cWhenSifk, cValidSifk
		   IzSifKWV(ALIAS(),substr(cPom,7) ,@cWhenSifk,@cValidSifk)

		   if !empty(cWhenSifk)
		      Getlist[nGet]:PreBlock:=& ("{|| "+cWhenSifk +"}")
		   else
		       GetList[nGet]:PreBlock:=bWhen
		   endif
		   if !empty(cValidSifk)
		      Getlist[nGet]:PostBlock:= & ("{|| "+cValidSifk +"}")
		   else
		      GetList[nGet]:PostBlock:=bValid
		   endif
		   
		  
		 else

		  GetList[nGet]:PreBlock:=bWhen
		  GetList[nGet]:PostBlock:=bValid
		 endif
		 nGet++
	      else
		// Empty(cpom)  - samo odstampaj
		nRed:=1
		nKolona:=1
		if Len(ImeKol[i])>=10 .and. imekol[i,10]<>NIL
		 nKolona:= imekol[i,10]
		 nRed:=0
		endif
		if EVAL(ImeKol[i,2]) <> NIL .and. ToStr(EVAL(ImeKol[i,2]))<>"_?_"  // ne prikazuj nil vrijednosti
		  if nKolona=1
		   ++nTekRed
		  endif
		  @ m_x+nTekRed,m_y+nKolona SAY PADL( alltrim(ImeKol[i,1]) ,15)
		  @ m_x+nTekRed,col()+1 SAY EVAL(ImeKol[i,2])
		else
		  ++nNestampati
		endif

	      endif // empty(cpom)


	      i++                               // ! sljedeci slog se stampa u istom redu
	      if ( len(imeKol) < i) .or. ;
		 ( nTekRed>min(20,nTrebaRedova) .and. !(Len(ImeKol[i])>=10 .and. imekol[i,10]<>NIL)   )
		 
		exit // izadji dosao sam do zadnjeg reda boxa, ili do kraja imekol
	      endif
	    enddo // i
	    SET KEY K_F8 TO NNSifru()
	    SET KEY K_F9 TO n_num_sif()
	    SET KEY K_F5 TO NNSifru2()


	    READ
	    SET KEY K_F8 TO
	    SET KEY K_F9 TO
	    SET KEY K_F5 TO

	    if ( len(imeKol) < i)
	      exit
	    endif


   next 
   BoxC()


   if Ch<>K_CTRL_A
      exit
   else
     if lastkey()==K_ESC
     	exit
     endif
     GatherR("w")
     GatherSifk("w" , Ch==K_CTRL_N)

     sql_azur(.t.)

     GathSQL("w")
     Scatter("w")

     if lastkey()==K_PGUP
      skip -1
     else
      skip
     endif
     if eof()
         skip -1; exit
     endif
    endif

   enddo

   if Ch==K_CTRL_N .or. Ch==K_F2
      ordsetfocus(nOrder)
   endif

   if lastkey()==K_ESC
      if lNovi
	 go (nPrevRecNo)
         return 0
      elseif Ch==K_F2
         return 0
      else
         return 0
      endif
   else

     
      if lNovi
	
	// provjeri da li vec ovaj id postoji ?
	
	nNSInfo := _chk_sif("w")
	
	if nNSInfo = 1  
		msgbeep("Ova sifra vec postoji !")
		return 0
	elseif nNSInfo = -1
		return 0
	endif

	append blank

	if _LOG_PROMJENE == .t. 
	    // ako je novi zapis .. ovo su stare vrijednosti (prazno)
	    cOldDesc := _g_fld_desc("w")
	endif

	sql_append()
      
      endif
      
      GatherR("w")
      GatherSifk("w", lNovi )
      sql_azur(.t.)
      Scatter("w")
      GathSQL("w")
      
      if _LOG_PROMJENE == .t.
         // daj nove vrijednosti
         cNewDesc := _g_fld_desc("w") 
      endif

      nTArea := SELECT()
      
      // logiraj promjenu sifrarnika...
      if _LOG_PROMJENE == .t.
        
	cChanges := _g_fld_changes(cOldDesc, cNewDesc)
	if LEN(cChanges) > 250
		cCh1 := SUBSTR(cChanges,1,250)
		cCh2 := SUBSTR(cChanges,251,LEN(cChanges))
	else
		cCh1 := cChanges
		cCh2 := ""
	endif

      	EventLog(nUser, "FMK", "SIF", "PROMJENE", nil, nil, nil, nil, ;
		"promjena na sifri: " + to_str( FIELDGET(1) ), cCh1,cCh2, ;
		DATE(),DATE(), "", ;
		"promjene u tabeli " +  ALIAS() + " : " + ;
		IF(Ch==K_F2,"ispravka",IF(Ch==K_F4,"dupliciranje", ;
		"nova stavka")))
      endif
      select (nTArea)

      if Ch==K_F4 .and. Pitanje( , "Vrati se na predhodni zapis","D")=="D"
        go (nPrevRecNo)
      endif
      return 1
    endif

return 0



// --------------------------------------------------
// --------------------------------------------------
static function _chk_sif( cMarker )
local cFName
local xFVal
local cFVal
local cType
local nTArea := SELECT()
local nTREC := RECNO()
local nRet := 0
local i := 1
local cArea := ALIAS( nTArea )
private cF_Seek
private GetList := {}

cFName := ALLTRIM( FIELD(i) )
xFVal := FIELDGET(i)
cType := VALTYPE(xFVal)
cF_Seek := &( cMarker + cFName )

if ( cType == "C" ) .and. ( cArea $ "#PARTN##" )
	
	Box(,1,40)
		@ m_x + 1, m_y + 2 SAY "Potvrdi sifru sa ENTER: " GET cF_seek
		read
	BoxC()
	
	if LastKey() == K_ESC
		nRet := -1
		return nRet
	endif
	
	go top
	seek cF_seek
	if FOUND()
		nRet := 1
		go (nTREC)
	endif
endif
	
select (nTArea)
return nRet


// --------------------------------------------------
// vraca naziv polja + vrijednost za tekuci alias
// cMarker = "w" ako je Scatter("w")
// --------------------------------------------------
static function _g_fld_desc( cMarker )
local cRet := ""
local i
local cFName
local xFVal
local cFVal
local cType

for i := 1 to FCOUNT()

	cFName := ALLTRIM( FIELD(i) )
	
	xFVal := FIELDGET(i)
	
	cType := VALTYPE(xFVal)
	
	if cType == "C"
		// string
		cFVal := ALLTRIM(xFVal)
	elseif cType == "N"
		// numeric
		cFVal := ALLTRIM(STR(xFVal, 12, 2))
	elseif cType == "D"
		// date
		cFVal := DTOC(xFVal)
	endif
	
	cRet += cFName + "=" + cFVal + "#"
next

return cRet

// ------------------------------------------------------------
// vraca vrijednost u tip string - bilo kojeg polja
// ------------------------------------------------------------
static function to_str( val )
local cVal := ""
local cType := VALTYPE(val)

if cType == "C"
	cVal := val
elseif cType == "N"
	cVal := STR(val)
elseif cType == "D"
	cVal := DTOC(val)
endif

return cVal


// ----------------------------------------------------
// uporedjuje liste promjena na sifri u sifrarniku
// ----------------------------------------------------
static function _g_fld_changes( cOld, cNew )
local cChanges := "nema promjena - samo prolaz sa F2"
local aOld
local aNew
local cTmp := ""

// stara matrica
aOld := TokToNiz(cOld, "#")
// nova matrica
aNew := TokToNiz(cNew, "#")

// kao osnovnu referencu uzmi novu matricu
for i := 1 to LEN( aNew )
	cVOld := ALLTRIM(aOld[i])
	cVNew := ALLTRIM(aNew[i])
	if cVNew == cVOld
		// do nothing....
	else
		cTmp += "nova " + cVNew + " stara " + cVOld + ","
	endif
next

if !EMPTY(cTmp)
	cChanges := cTmp
endif

return cChanges


function SetSifVars()

aStruct:=DBSTRUCT()
SkratiAZaD(@aStruct)
for i:=1 to LEN(aStruct)
     cImeP:=aStruct[i,1]
     cVar:="w"+cImeP
     &cVar:=&cImeP
next
return


//-------------------------------------------------------
//-------------------------------------------------------
function SifPopup(nOrder)

private Opc:={}
private opcexe:={}
private Izbor

AADD(Opc, "1. novi                  ")
AADD(opcexe, {|| EditSifItem(K_CTRL_N, nOrder) } )
AADD(Opc, "2. edit  ")
AADD(opcexe, {|| EditSifItem(K_F2, nOrder) } )
AADD(Opc, "3. dupliciraj  ")
AADD(opcexe, {|| EditSifItem(K_F4, nOrder) } )
AADD(Opc, "4. <a+R> za sifk polja  ")
AADD(opcexe, {|| repl_sifk_item() } )
AADD(Opc, "5. copy polje -> sifk polje  ")
AADD(opcexe, {|| copy_to_sifk() } )

Izbor:=1
Menu_Sc("bsif")

return 0



function SifClipBoard()

if !SigmaSif("CLIP")
       msgBeep("Neispravna lozinka ....")
       return DE_CONT
endif

     private am_x:=m_x,am_y:=m_y
     m_x:=am_x; m_y:=am_y
     private opc2[2]
     opc2[1]:="1. prenesi  -> sif0 (clipboard)  "
     opc2[2]:="2. uzmi    <-  sif0 (clipboard)  "
     private Izbor2:=1
     if reccount2()==0
       // ako je sifrarnik prazan, logicno je da ce se zeli preuzeti iz
       // clipboarda
       Izbor2:=2
     endif

     do while .t.
      Izbor2:=menu("9cf9",opc2,Izbor2,.f.)
      do case
        case Izbor2==0
            EXIT
        case izbor2 == 1
           // sifrarnik -> sif0

           nDBF:=select()
           if reccount2()==0
             MsgBeep("Sifrarnik je prazan, nema smisla prenositi u sif0")
             loop
           endif

           copy structure extended to struct
           nP2:=AT("\SIF",SIFPATH)         // c:\sigma\sif
           cPath:=left(SIFPATH,nP2) +"SIF0\"
           cDBF:=ALIAS()+".DBF"
           // c:\sigma\sif1\trfp.dbf -> c:\sigma\sif0\trfp.dbf
           DirMak2(cPath)
           if file(cPath+cDBF)
               MsgBeep("Tabela "+cPath+cDBF+" vec postoji !")
               if pitanje(,"Zelite li ipak prebaciti podatke u clipboard ?","N")=="N"
                    loop
               endif
           endif

           select (F_TMP)

#ifdef CAX
           create (cPath+cDBF) from struct  alias TMP
#else
           create (cPath+cDBF) from struct  VIA RDDENGINE alias TMP
#endif


           USE
           USEX (cPath+cDBF) ALIAS novi NEW 
           select (nDBF)
           set order to 0; go top
           do while !eof()
             scatter()
             select novi
             append blank; gather()
             select (nDBF)
             skip
           enddo
           SELECT novi; use

           select (nDBF); go top
           MsgBeep("sifrarnik je prenesen u clipboard ")

        case izbor2 == 2

           // sifrarnik <- sif0

           nDBF:=select()
           nP2:=AT("\SIF",SIFPATH)         // c:\sigma\sif
           cPath:=left(SIFPATH,nP2) +"SIF0\"
           cDBF:=ALIAS()+".DBF"   // TROBA.DBF
           // c:\sigma\sif1\trfp.dbf -> c:\sigma\sif0\trfp.dbf
           if !file(cPath+cDBF)
               MsgBeep("U clipboardu tabela "+cPath+cDBF+" ne postoji !")
               loop
           else
               // za svaki slucaj izbrisi CDX !! radi moguce korupcije
               ferase(strtran(cPath+cDbf,".DBF",".CDX"))
           endif

           USEX (cPath+cDBF)  NEW alias CLIPB
           select (nDBF)
           if reccount2()<>0
              if pitanje(,"Sifrarnik nije prazan, izbrisati postojece stavke ?"," ")=="D"
                   zap
              else
                 if pitanje(,"Da li zelite na postojece stavke dodati clipboard ?","N")=="N"
                    loop
                 endif
              endif
           endif

           select CLIPB
           set order to 0; go top
           do while !eof()
             select (nDBF); Scatter(); select CLIPB
             scatter()
             select (nDBF)
             append blank; gather()
             select CLIPB
             skip
           enddo
           SELECT CLIPB; use

           select (nDBF); go top
           MsgBeep("Sifrarnik je osvjezen iz clipboarda")


      end case
     enddo
     m_x:=am_x; m_y:=am_y
     
return DE_REFRESH

// --------------------------------------------
// validacija da li polje postoji
// --------------------------------------------
static function val_fld(cField)
local lRet := .t.
if (ALIAS())->(FieldPOS(cField)) == 0
	lRet := .f.
endif

if lRet == .f.
	msgbeep("Polje ne postoji !!!")
endif

return lRet

// ----------------------------------------------------------
// kopiranje vrijednosti nekog polja u neko SIFK polje
// ----------------------------------------------------------
function copy_to_sifk()

local cTable := ALIAS()
local cFldFrom := SPACE(8)
local cFldTo := SPACE(4)
local cEraseFld := "D"
local cRepl := "D"
local nTekX 
local nTekY

Box(, 6, 65, .f.)
	
	private GetList:={}
	set cursor on
	
	nTekX := m_x
	nTekY := m_y
	
	@ m_x+1,m_y+2 SAY PADL("Polje iz kojeg kopiramo (polje 1)", 40) GET cFldFrom VALID !EMPTY(cFldFrom) .and. val_fld(cFldFrom)
	@ m_x+2,m_y+2 SAY PADL("SifK polje u koje kopiramo (polje 2)", 40) GET cFldTo VALID g_sk_flist(@cFldTo)
	
	@ m_x+4,m_y+2 SAY "Brisati vrijednost (polje 1) nakon kopiranja ?" GET cEraseFld VALID cEraseFld $ "DN" PICT "@!"
	
	@ m_x+6,m_y+2 SAY "*** izvrsiti zamjenu ?" GET cRepl VALID cRepl $ "DN" PICT "@!"
	read
 
BoxC()

if cRepl == "N"
	return 0
endif

if LastKey()==K_ESC
	return 0
endif

nTRec := RecNo()
go top

do while !EOF()
	
	skip
	nRec := RECNO()
	skip -1
	
	cCpVal := (ALIAS())->&cFldFrom
	if !EMPTY( cCpval)
		USifK( ALIAS(), cFldTo, (ALIAS())->id, cCpVal)
	endif
	
	if cEraseFld == "D"
		replace (ALIAS())->&cFldFrom with ""
	endif
	
	go (nRec)
enddo

go (nTRec)

return 0


// --------------------------------------------------
// zamjena vrijednosti sifk polja
// --------------------------------------------------
function repl_sifk_item()

local cTable := ALIAS()
local cField := SPACE(4)
local cOldVal
local cNewVal
local cCurrVal
local cPtnField

Box(,3,60, .f.)
	private GetList:={}
	set cursor on
	
	nTekX := m_x
	nTekY := m_y
	
	@ m_x+1,m_y+2 SAY " SifK polje:" GET cField VALID g_sk_flist(@cField)
	read
	
	cCurrVal:= "wSifk_" + cField
	&cCurrVal:= IzSifk(ALIAS(), cField)
	cOldVal := &cCurrVal
	cNewVal := SPACE(LEN(cOldVal))
	
	m_x := nTekX
	m_y := nTekY
	
	@ m_x+2,m_y+2 SAY "      Trazi:" GET cOldVal
        @ m_x+3,m_y+2 SAY "Zamijeni sa:" GET cNewVal
	
        read 
BoxC()

if LastKey()==K_ESC
	return 0
endif

if Pitanje(,"Izvrsiti zamjenu polja? (D/N)","D") == "N"
	return 0
endif

nTRec := RecNo()

do while !EOF()
	&cCurrVal := IzSifK(ALIAS(), cField)
	if &cCurrVal == cOldVal
		USifK(ALIAS(), cField, (ALIAS())->id, cNewVal)
	endif
	skip
enddo

go (nTRec)

return 0



function g_sk_flist(cField)

local aFields:={}
local cCurrAlias := ALIAS()
local nArr
local nField

nArr := SELECT()

select sifk
set order to tag "ID"
cCurrAlias := PADR(cCurrAlias,8)
seek cCurrAlias

do while !EOF() .and. field->id == cCurrAlias
	AADD(aFields, {field->oznaka, field->naz})
	skip
enddo

select (nArr)

if !EMPTY(cField) .and. ASCAN(aFields, {|xVal| xVal[1] == cField}) > 0
	return .t.
endif

if LEN(aFields) > 0
	private Izbor:=1
	private opc:={}
	private opcexe:={}
	private GetList:={}
	
	for i:=1 to LEN(aFields)
		AADD(opc, PADR(aFields[i, 1] + " - " + aFields[i, 2], 40))
		AADD(opcexe, {|| nField := Izbor, Izbor:=0})
	next
	
	Izbor:=1
	Menu_SC("skf")
endif

cField := aFields[nField, 1]

return .t.



/*!
 *\fn IzSifk
 *\brief Izvlaci vrijednost iz tabele SIFK
 *\param cDBF ime DBF-a
 *\param cOznaka oznaka BARK , GR1 itd
 *\param cIDSif  interna sifra, npr  000000232  ,
 *               ili "00000232,XXX1233233" pri pretrazivanju
 *\param fNil    NIL - vrati nil za nedefinisanu vrijednost,
 *               .f. - vrati "" za nedefinisanu vrijednost
 *\fpretrazivanje
 *
 * Vrsi se analiza postojanaja
 * Pretpostavke:
 * Otvorene tabele SIFK, SIFV
 *
 */
function IzSifk(cDBF,cOznaka, cIdSif, fNiL, fPretrazivanje)

local cJedanod:=""
local xRet:=""
local nTr1, nTr2 , xVal
private cPom:=""

if cIdSif=NIL
  cIdSif:=(cDBF)->id
endif


if numtoken(cOznaka,",")=2
     cJedanod:=token( cOznaka,",",2)
     cOznaka :=token( cOznaka,",",1)
endif

PushWa()

cDBF:=padr(cDBF,8)
cOznaka:=padr(cOznaka,4)

// ako tabela sifk, sifv nije otvorena - otvoriti
SELECT(F_SIFK)
if (!USED())
	O_SIFK	
endif

SELECT(F_SIFV)
if (!USED())
	O_SIFV	
endif

SELECT sifk
SET ORDER TO TAG "ID2"
SEEK cDBF+cOznaka


xVal:=nil

if found()
  // da li uopste traziti
  cPom:=Uslov   
  if !empty(cPom)
     xVal=&cPom
  endif

  if empty(cPom) .or. xVal
    select sifv
    if len(cIdSif)>15  // ADRES.DBF
      cIdSif:=left(cIdSif,15)
    endif
    hseek cDBf+cOznaka+cIdSif
    xRet:=UVSifv()
    // pokupi sve vrijednosti
    if sifk->veza="N" .and. fpretrazivanje<>NIL // radi se o artiklu sa vezom 1->N
      // ova varijanta poziva desava se samo pri pretrazivanju
      seek cDbf+cOznaka+padr(cIdSif,len(idsif))+cJedanod
      if found()
         xRet:=cJedanod
      else
         xRet:=""+cJedanod+""
      endif

    elseif sifk->veza="N"
     skip
     do while !eof() .and.  ((id+oznaka+idsif) = (cDBf+cOznaka+cIdSif))
      xRet+=","+ToStr(UvSifv()) //kalemi u jedan string
      skip
     enddo
     xRet:=padr(xRet,190)
    endif

  else   // daj praznu vrijednost
    if xVal  .or. (fNil<>NIL)
       if sifk->tip=="C"
          xRet:= padr("",sifk->duzina)
       elseif sifk->tip=="N"
          xRet:=  val( str(0,sifk->duzina,sifk->decimal) )
       elseif sifk->tip=="D"
          xRet:= ctod("")
       else
          xRet:= "NEPTIP"
       endif
    else
     // ne koristi se
     xRet:=nil
    endif
  endif

endif

PopWa()

return xRet


static function UVSifv()

local xRet
if sifk->tip=="C"
   xRet:= padr(naz,sifk->duzina)
elseif sifk->tip=="N"
   xRet:= val(alltrim(naz))
elseif sifk->tip=="D"
   xRet:= STOD(trim(naz))
else
   xRet:= "NEPTIP"
endif
return xRet


function IzSifkNaz(cDBF,cOznaka)

local xRet:="", nArea

PushWA()
cDBF:=padr(cDBF,8)
cOznaka:=padr(cOznaka,4)
select sifk; set order to tag "ID2"
seek cDBF+cOznaka
xRet:=sifk->Naz
PopWA()
return xRet

// ------------------------------------------
// ------------------------------------------
function IzSifkWV
parameters cDBF, cOznaka, cWhen, cValid

local xRet:=""

PushWa()

cDBF:=padr(cDBF,8)
cOznaka:=padr(cOznaka,4)
select sifk; set order to tag "ID2"
seek cDBF+cOznaka

cWhen:=sifk->KWHEN
cValid:=sifk->KVALID

PopWa()
return NIL


/*!
 *\fn USifk
 *\brief Postavlja vrijednost u tabel SIFK
 *\note Pretpostavke: Otvorene tabele SIFK, SIFV
 *
 *\param cDBF ime DBF-a
 *\param cOznaka oznaka xxxx
 *\param cIdSif  Id u sifrarniku npr. 2MON0001
 *\param xValue  vrijednost (moze biti tipa C,N,D)
 *
 */
function USifk(cDBF, cOznaka, cIdSif, xValue)

local ntrec, numtok
private cPom:=""

cDBF:=padr(cDBF,8)
cOznaka:=padr(cOznaka,4)

PushWa()

select sifk
set order to tag "ID2"
seek cDBF+cOznaka
// karakteristika ovo postoji u tabeli SIFK

if len(cIdSif)>15   // ADRES.DBF
  cIdSif:=left(cIdSif,15)
endif

if found()

if sifk->Veza="N" 
// veza 1->N posebno se tretira !!

  select sifv
  seek cDBf+cOznaka+cIdSif
  //izbrisi stare vrijednost !!!
  do while !eof() .and. ( (id+oznaka+idsif)= (cDBf+cOznaka+cIdSif) )
     skip
     ntrec:=recno()
     skip -1
     sql_delete()
     delete
     go nTrec
  enddo

  numTok:=numtoken(xValue,",")
  for i:=1 to numtok
    append blank
    sql_append()
    replace Id with cDbf, oznaka with cOznaka, IdSif with cIdSif
    sql_azur(.t.);Scatter()
    replsql Id with cDbf, oznaka with cOznaka, IdSif with cIdSif
    xValue_i:=token(xValue,",",i)
    if sifk->tip=="C"
        replace naz with xValue_i
        replsql naz with xValue_i
    elseif sifk->tip=="N"
        replace naz with str(xValue_i,sifk->duzina,sifk->decimal)
        replsql naz with str(xValue_i,sifk->duzina,sifk->decimal)
    elseif sifk->tip=="D"
     	replace naz with DTOS(xValue_i)
     	replsql naz with DTOS(xValue_i)
    endif
  next

else
// veza 1-1
  select sifv
  seek cDBf+cOznaka+cIdSif
  //do sada nije bilo te vrijednosti
  if !found()
    if !empty(ToStr(xValue))
     append blank
     sql_append()
     replace Id with cDbf, oznaka with cOznaka, IdSif with cIdSif
     replsql Id with cDbf, oznaka with cOznaka, IdSif with cIdSif
    else    // ne dodaji prazne vrijednosti
      PopWa()
      return
    endif
  endif

 if xValue<>NIL

   sql_azur(.t.);Scatter()
   if sifk->tip=="C"
     replace naz with xValue
     replsql naz with xValue
   elseif sifk->tip=="N"
     replace naz with str(xValue,sifk->duzina,sifk->decimal)
     replsql naz with str(xValue,sifk->duzina,sifk->decimal)
   elseif sifk->tip=="D"
     replace naz with DTOS(xValue)
     replsql naz with DTOS(xValue)
   endif

 endif

endif 
// veza
endif  
// found

PopWa()
return


/*!
 @function ImauSifv
 @abstract Povjerava ima li u sifv vrijednost ...
 @discussion - poziv ImaUSifv("ROBA","BARK","BK0002030300303",@cIdSif)
 @param cDBF ime DBF-a
 @param cOznaka oznaka BARK , GR1 itd
 @param cVOznaka oznaka BARK003030301
 @param cIDSif   00000232 - interna sifra
*/
function ImaUSifv(cDBF,cOznaka,cVOznaka, cIdSif)

local cJedanod:=""
local xRet:=""
local nTr1, nTr2 , xVal
private cPom:=""

PushWa()
cDBF:=padr(cDBF,8)
cOznaka:=padr(cOznaka,4)

xVal:=NIL

select sifv
PushWa() 
set order to tag "NAZ"
hseek cDbf + cOznaka + cVOznaka
if found()
   cIdSif:=IdSif
endif
PopWa()

PopWa()
return



/*
 @function   GatherSifk
 @abstract
 @discussion Popunjava ID_J (uz pomoc fje NoviId_A()),
             te puni SIFV (na osnovu ImeKol)
 @param cTip  prefix varijabli sa kojima se tabela puni
 @param lNovi .t. - radi se o novom slogu

*/
function GatherSifk(cTip, lNovi)

local i
private cPom

if lNovi
if IzFmkIni('Svi','SifAuto','N')=='D'
    sql_azur(.t.)
    Scatter()
    replace ID with NoviID_A()
    replsql ID with NoviID_A()
endif
endif

for i:=1 to len(ImeKol)

   if left(ImeKol[i,3],6)=="SIFK->"
     cPom:= cTip+"Sifk_"+substr(ImeKol[i,3],7)
     if IzSifk(ALIAS(),substr(ImeKol[i,3],7),(ALIAS())->id) <> NIL
       // koristi se
       USifk(ALIAS(),substr(ImeKol[i,3],7),(ALIAS())->id,&cPom)
     endif
   endif
next

return


/*!
 @function    NoviID_A
 @abstract    Novi ID - automatski
 @discussion  Za one koji ne pocinju iz pocetak, ID-ovi su dosadasnje sifre
              Program (radi prometnih datoteka) ove sifre ne smije dirati)
              Zato ce se nove sifre davati po kljucu Chr(246)+Chr(246) + sekvencijalni dio
*/
function NoviID_A()

local cPom , xRet

PushWA()

nCount:=1
do while .t.

set filter to 
// pocisti filter
set order to tag "ID"
go bottom
if id>"99"
   seek "ˆˆ·"  
   // ˆ - chr(246) pokusaj
   skip -1
   if id<"ˆˆ9"
      cPom:=   str( val(substr(id,4))+nCount , len(id)-2 )
      xRet:= "ˆˆ"+padl(  cPom , len(id)-2 ,"0")
   endif
else
  cPom:= str( val(id) + nCount , len(id) )
  xRet:= cPom
endif

++nCount
SEEK xRet
if !found()
  exit
endif

if nCount>100
  MsgBeep("Ne mogu da dodijelim sifru automatski ????")
  xRet:=""
  exit
endif

enddo

PopWa()

return xRet



// -------------------------------------------------------------------
// @function   Fill_IDJ
// @abstract   Koristi se za punjenje sifre ID_J sa zadatim stringom
// @discussion fja koja punjeni polje ID_J tako sto ce se uglavnom definisati
//             kao validacioni string u sifrarniku Sifk
//             Primjer:
//             - Zelim da napunim sifru po prinicpu ( GR1 + GR2 + GR3 + sekvencijalni dio)
//             - Zadajem sljedeci kWhenBlok:
//               When: FILL_IDJ( WSIFK_GR1 + WSIFK_GR2 + WSIFK_GR3)
// @param      cStr  zadati string
// --------------------------------------------------------------------
function Fill_IDJ(cSTR)

local nTrec , cPoz

PushWA()


nTrec:=recno()
set order to tag "ID_J"
seek cStr+"‚"
skip -1
// ova fja se uvijek poziva nakon Edsif-a
// ako je __LAST_CH__=f4 onda se radi o dupliciranju

if (__A_SIFV__[__PSIF_NIVO__,3]==K_F4) .or. ;
   ( recno()<>nTrec .and. ( left(wId_J, len(cStr)) != cStr) ) 
   // ne mjenjam samog sebe
        if  right(alltrim(wNAZ),3)=="..."
           // naziv je u formi "KATEGORIJA ARTIKALA.........."
           cPoz:=  REPLICATE (".",len(ID_J)-LEN(cStr))
        elseif (left( ID_J, len(cStr) ) = cStr ) .and. ( SUBSTR(ID_J , len(cstr)+1,1)<>".")
           // GUMEPODA01
           // Len(id_j) - len( cStr )  = 10 - 8 = 2
           cPoz:=  PADL ( alltrim( STR( VAL (substr( ID_J , len(cstr)+1)) +1)) , len(ID_J) - LEN(cStr), "0" )
        else
           cPoz:=  PADL ( "1" , len(ID_J)-LEN(cStr), "0" )
        endif

        go nTrec
        //replace ID_J with   ( cStr +  cPoz)
        wID_J :=  ( cStr +  cPoz)
endif
PopWa()
return .t.


/*!
 @function   SetSifFilt
 @abstract
 @discussion postavlja _M1_ na "*" za polja kod kojih je cSearch .t.;
             takodje parsira ulaz (npr. RAKO, GSLO 10 20 30, GR1>55, GR2 20 $55#66#77#88 )

 @param
 @param
 @param
 @param
*/
// formiraj filterski uslov
// Ulaz 
function SetSifFilt(cSearch)

local n1,n2,cVarijabla, cTipVar
local fAddNaPost := .f.
local fOrNaPost  := .f.
local nCount, nCount2
private cFilt:=".t. "


cSearch:=ALLTRIM(trim(cSearch))
// zamjenit "NAZ $ MISHEL"  -> NAZ $MISHEL
cSearch:=strtran(cSearch,"$ ","$")

n1:= NumToken(cSearch,",")
for i:=1 to n1
 cUslov:= token(cSearch,",",i)
 n2:=numtoken(cUslov," ")
 if n2 = 1
   if cUslov="+"  // dodaj na postojeci uslov
      fAddNaPost := .t.
   elseif upper(cUslov)="*"  // dodaj na postojeci uslov
      fOrNaPost := .t.
   else
     cFilt += ".and."+;
              iif(fieldpos("ID_J")=0,"Id","ID_J")+"=" + token(cUslov," ",1)
   endif

 elseif n2 >= 2  // npr ....,GSLO 33 55 77,.......

   if  fieldpos( token(cUslov," ",1) ) <> 0  // radi se o polju unutar baze
      cVarijabla:=token(cUslov," ",1)
   else
      // radi se o polju sifk
      cVarijabla:="IzSifk('"+ALIAS()+"','"+ALLTRIM(token(cUslov," ",1))+",####',NIL,.f.,.t.)"
   endif


   cOperator:=NIL
   cFilt += ".and. ("
   for j:=2 to n2  // sada nastiklaj uslove ...
     if left(token(cUslov," ",j),1)=">"
        cOperator:=">"
     elseif left(token(cUslov," ",j),1)="$"
        cOperator:="$"
     elseif left(token(cUslov," ",j),1)="!"
        cOperator:="!"
     elseif left(token(cUslov," ",j),2)="<>"
        cOperator:="<>"
     elseif left(token(cUslov," ",j),1)="<"
        cOperator:="<"
     elseif left(token(cUslov," ",j),2)=">="
        cOperator:=">="
     elseif left(token(cUslov," ",j),2)="<="
        cOperator:="<="
     endif

     if coperator=NIL
      cOperator:="="
      cV2:= substr(token(cUslov," ",j),1)
     else
      //cV2:= substr(token(cUslov," ",j), 1+len(cOperator)) bug 31.10.2000
      if cOperator="="
       cV2:= substr(token(cUslov," ",j), len(cOperator))
      else
       cV2:= substr(token(cUslov," ",j), 1 + len(cOperator))
      endif
     endif
     cV2 := strtran(cV2,"_"," ")  // !!! pretvori "_" u " "


     if cVarijabla = "IzSifk("
       if cOperator="="
        cVarijabla:=strtran(cVarijabla,"####",cV2)
       else
        cVarijabla:=strtran(cVarijabla,",####","")
       endif
     endif

     cTipVar:=  VALTYPE( &cVarijabla )
     if j>2 ;  cFilt += ".or. " ; endif

     if cOperator="$"
         cFilt +=  "'" +cV2 + "'"  + cOperator + cVarijabla
     else

      if cOperator=="!"
        cOperator := "!="
      endif

      if cTipVar = "C"
         cFilt += cVarijabla + cOperator + "'" +cV2 + "'"
      elseif cTipVar = "N"
         cFilt += cVarijabla + cOperator +cV2
      elseif cTipVar = "D"
         cFilt += cVarijabla + "CTOD(" +cOperator +cV2 +")"
      endif
     endif

   next
   cFilt +=")"
 endif
next

if !fAddNaPost
  set filter to
endif
go top
// prodji kroz bazu i markiraj
@ 25,1 SAY cFilt
MsgO("Vrsim odabir zeljenih stavki: ....")
nCount:=0
nCount2:=0
do while !eof()
  sql_azur(.t.);Scatter()
  if empty(cFilt) .or. &cFilt
    replace _M1_ with "*"
    replsql _M1_ with "*"
    ++nCount2
  else
    if !fOrNaPost
      replace _M1_ with " "
      replsql _M1_ with " "
    endif
  endif
  ++nCount
  if (nCount%10 = 0)
   @ m_x+6,m_y+40 SAY nCount
  endif
  skip
enddo
Msgc()

@ m_x+1, m_y+20 SAY  str(nCount2,3)+"/"

#IFDEF PROBA
 CLS
 ? ncount, ncount2, cFilt
 DO WHILE NEXTKEY()==0; OL_YIELD(); ENDDO
 INKEY()
 // inkey(0)
#ENDIF

private cFM1:="_M1_='*'"
SET FILTER TO  &cFM1
go top

return


// prikaz idroba
// nalazim se u tabeli koja sadrzi IDROBA, IDROBA_J
function StIdROBA()

static cPrikIdRoba:=""

if cPrikIdroba == ""
  cPrikIdRoba:=IzFmkIni('SIFROBA','PrikID','ID',SIFPATH)
endif

if cPrikIdRoba="ID_J"
  return IDROBA_J
else
  return IDROBA
endif

function aTacno(aUsl)
local i
for i=1 to len(aUsl)
   if !(Tacno(aUsl[i]))
       return .f.
   endif
next
return .t.


// -----------------------------------------
// nadji sifru, v2 funkcije
// -----------------------------------------
function n_num_sif()
local cFilter := "val(id) <> 0"
local i
local nLId
local lCheck
local lLoop

// ime polja : "wid"
private cImeVar := READVAR()
// vrijednost unjeta u polje
cPom := &(cImeVar)

if cImeVar == "WID"
	
	PushWA()
	
	nDuzSif := LEN( cPom )

	// postavi filter na numericke sifre
	set filter to &cFilter
  	
	// kreiraj indeks
	index on VAL(id) tag "_VAL"
	
	go bottom

	// zapis
	nTRec := RECNO()
	nLast := nTRec

	// sifra kao uzorak
	nLId := VAL( ID )
	lCheck := .f.

	do while lCheck = .f.
	   
	   lLoop := .f.
	   // ispitaj prekid sifri
	   for i := 1 to 10

		skip -1

		if nLId = VAL( field->id )
			// ako je zadnja sifra ista kao i prethodna
			// idi na sljedecu
			// ili idi na zadnju sifru
			nTRec := nLast
			lLoop := .t.
			exit
		endif

		if nLId - VAL( field->id ) <> i
			// ima prekid
			// idi, ponovo...
			nLID := VAL( field->id )
			nTRec := RECNO()
			lCheck := .f.
			lLoop := .f.
			exit
		else
			lLoop := .t.
		endif

	   next

	   if lLoop = .t.
	   	lCheck := .t.
	   endif

	enddo

	go (nTREC)
	
    	&(cImeVar) := PADR(NovaSifra( IF( EMPTY(id) , id , RTRIM(id) ) ), nDuzSif, " " )

	set filter to

	if nOrdId <> 0
   		set order to tag "ID"
  	else
   		set order to tag "1"
  	endif
  	
	GO TOP

endif

AEVAL(GetList,{|o| o:display()})
PopWA()

return nil


// ----------------------------------------------------
// nadji novu sifru - radi na pritisak F8 pri unosu
// nove sifre
// ----------------------------------------------------
function NNSifru()      
local cPom
local nDuzSif:=0
local lPopuni:=.f.
local nDuzUn:=0
local cLast:="¨è¶Ê—"
local nKor:=0

IF IzFmkIni("NovaSifraOpc_F8","PopunjavaPraznine","N")=="D"
	lPopuni:=.t.
ENDIF

// ime polja
private cImeVar := READVAR()
// vrijednost unjeta u polje
cPom := &(cImeVar)

IF cImeVar == "WID"
	
	nDuzSif := LEN(cPom)
  	nDuzUn := LEN(TRIM(cPom))
  	cPom := PADR(RTRIM(cPom),nDuzSif,"Z")
  	
	PushWA()
  	
	if nOrdId <> 0
   		set order to tag "ID"
  	else
   		set order to tag "1"
  	endif
  	
	GO TOP
  	IF lPopuni
    		SEEK LEFT(cPom,nDuzUn)
    		DO WHILE !EOF() .and. LEFT(cPom,2)=LEFT(id,2)
      			// preskoci stavke opisa grupe artikala
      			IF LEN(TRIM(id))<=nDuzUn .or. RIGHT(TRIM(id),1)=="."
				SKIP 1
			ENDIF
      			IF cLast=="¨è¶Ê—" // tj. prva konkretna u nizu
        			IF VAL(SUBSTR(id,nDuzUn+1)) > 1
          				// rupa odmah na poüetku
          				nKor:= nDuzSif-LEN(TRIM(id))
          				EXIT
        			ENDIF
      			ELSEIF VAL(SUBSTR(id,nDuzUn+1))-VAL(cLast) > 1
        			// rupa izme–u
        			EXIT
      			ENDIF
      			cLast:=SUBSTR(id,nDuzUn+1)
      			SKIP 1
    		ENDDO
    		// na osnovu cLast formiram slijedeÜu Áifru
    		cPom:=LEFT(cPom,nDuzUn)+IF(cLast=="¨è¶Ê—",REPL("0",nDuzSif-nDuzUn-nKor),cLast)
    		&(cImeVar):=PADR(NovaSifra( IF( EMPTY(cPom) , cPom , RTRIM(cPom) ) ),nDuzSif," ")
  	ELSE
    		
		SEEK cPom
    		SKIP -1
    		&(cImeVar):=PADR(NovaSifra( IF( EMPTY(id) , id , RTRIM(id) ) ),nDuzSif," ")
  	
	ENDIF

  	AEVAL(GetList,{|o| o:display()})
	PopWA()
ENDIF

RETURN (NIL)



/*! \fn VpSifra(wId)
 *  \brief Stroga kontrola ID-a sifre pri unosu nove ili ispravci postojece!
 *  \param wId - ID koji se provjerava
 */

function VpSifra(wId)

local nRec:=RecNo()
local nRet:=.t.
local cUpozorenje:=" !!! Ovaj ID vec postoji !!! "
seek wId

if (FOUND() .and. Ch==K_CTRL_N)
	MsgBeep(cUpozorenje)
  	nRet:=.f.
elseif (gSKSif=="D" .and. FOUND())   // nasao na ispravci ili dupliciranju
	if nRec<>RecNo()
		MsgBeep(cUpozorenje)
    		nRet:=.f.
  	else       // bio isti zapis, idi na drugi
    		skip 1
    		if (!EOF() .and. wId==id)
			MsgBeep(cUpozorenje)
      			nRet:=.f.
    		endif
  	endif
endif
go nRec
return nRet




/*! \fn VpNaziv(wNaziv)
 *  \brief Stroga kontrola naziva sifre pri unosu nove ili ispravci postojece sifre
 *  \param wNaziv - Naziv koji se provjerava
 */
 
function VpNaziv(wNaziv)


local nRec:=RecNo()
local nRet:=.t.
local cId
local cUpozorenje:="Ovaj naziv se vec nalazi u sifri:   "

set order to tag "naz"
HSeek wNaziv
cId:=roba->id

if (FOUND() .and. Ch==K_CTRL_N)
	MsgBeep(cUpozorenje + ALLTRIM(cId) + " !!!")
  	nRet:=.f.
elseif (gSKSif=="D" .and. FOUND()) 
	if nRec<>RecNo()
		MsgBeep(cUpozorenje + ALLTRIM(cId) + " !!!")
    		nRet:=.f.
  	else       // bio isti zapis, idi na drugi
    		skip 1
    		if !EOF() .and. wNaziv==naz
			MsgBeep(cUpozorenje + ALLTRIM(cId) + " !!!")
      			nRet:=.f.
    		endif
  	endif
endif

set order to tag "ID"
go nRec

return nRet


// ---------------------------------
// ---------------------------------
function ImaSlovo(cSlova, cString)
local i
for i:=1 to len(cSlova)
 if substr(cSlova,i,1)  $ cString
    return .t.
 endif
next
return .f.

// ------------------------------
// ------------------------------
function UslovSif()
local aStruct:=DBSTRUCT()

SkratiAZaD(@aStruct)

Box("", IF(len(aStruct)>22, 22, LEN(aStruct)), 67, .f. ,"","Postavi kriterije za pretrazivanje")

private Getlist:={}

*
* postavljanje uslova
*
aQQ:={}
aUsl:={}

IF "U" $ TYPE("aDefSpremBaz")
	aDefSpremBaz := NIL
ENDIF

IF aDefSpremBaz != NIL .and. !EMPTY(aDefSpremBaz)
	FOR i:=1 TO LEN(aDefSpremBaz)
    		aDefSpremBaz[i,4]:=""
  	NEXT
ENDIF

set cursor on

for i:=1 to len(aStruct)
	if i==23
   		@ m_x+1,m_y+1 CLEAR TO m_x+22,m_y+67
 	endif
 	AADD(aQQ, SPACE(100))
 	AADD(aUsl, NIL)
 	@ m_x+IF(i>22, i-22, i), m_y+67 SAY Chr(16)
 	@ m_x+IF(i>22,i-22,i),m_y+1 SAY PADL( alltrim(aStruct[i,1]),15) GET aQQ[i] PICTURE "@S50" ;
    		valid {|| aUsl[i]:=Parsiraj(aQQ[i]:=_fix_usl(aQQ[i]),aStruct[i,1],iif(aStruct[i,2]=="M","C",aStruct[i,2])) , aUsl[i] <> NIL  }
 read
 IF LASTKEY()==K_ESC
   EXIT
 ELSE
   IF aDefSpremBaz!=NIL .and. !EMPTY(aDefSpremBaz) .and. aUsl[i]<>NIL .and.;
   aUsl[i]<>".t."
     FOR j:=1 TO LEN(aDefSpremBaz)
       IF UPPER(aDefSpremBaz[j,2]) == UPPER(aStruct[i,1])
         aDefSpremBaz[j,4] := aDefSpremBaz[j,4] +;
                              IF( !EMPTY(aDefSpremBaz[j,4]), ".and.", "") +;
                              IF( UPPER(aDefSpremBaz[j,2]) == UPPER(aDefSpremBaz[j,3]), aUsl[i],;
                                   Parsiraj(aQQ[i]:=_fix_usl(aQQ[i]),aDefSpremBaz[j,3],iif(aStruct[i,2]=="M","C",aStruct[i,2])) )
       ENDIF
     NEXT
   ENDIF
 ENDIF
next
read
BoxC()
if lastkey()==K_ESC; return DE_CONT; endif
aOKol:=ACLONE(Kol)

private cFilter:=".t."
for i:=1 to len(aUsl)
 if ausl[i]<>NIL .and. aUsl[i]<>".t."
   cFilter+=".and."+aUsl[i]
 endif
next
if cFilter==".t."
  set filter to
else
  if left(cfilter,8)==".t..and."
   cFilter:=substr(cFilter,9)
   set filter to &cFilter
  endif
endif
go top
return NIL

// -------------------------------------------
// sredi uslov ako nije postavljeno ; na kraj
// -------------------------------------------
static function _fix_usl(xUsl)
local nLenUsl := LEN(xUsl)
local xRet := SPACE(nLenUsl)

if EMPTY(xUsl)
	return xUsl
endif

if RIGHT(ALLTRIM(xUsl), 1) <> ";"
	xRet := PADR( ALLTRIM(xUsl) + ";", nLENUSL )
else
	xRet := xUsl
endif

return xRet


//---------------------------------
//---------------------------------
function P_Sifk(cId, dx, dy)
local i
private imekol,kol
Kol:={}
O_SIFK
O_SIFV
ImeKol:={ { padr("Id",15), {|| id}, "id"  }           ,;
          { padr("Naz",25), {||  naz}, "naz" }         ,;
          { padr("Sort",4), {||  sort}, "sort" } ,;
          { padr("Oznaka",4), {||  oznaka}, "oznaka" } ,;
          { padr("Veza",4), {||  veza}, "veza" }       ,;
          { padr("Izvor",15), {||  izvor}, "izvor" }   ,;
          { padr("Uslov",30), {||  uslov}, "uslov" }   ,;
          { padr("Tip",3), {|| tip}, "tip" }   ,;
          { padr("Unique",3), {|| Unique}, "Unique", NIL, NIL,NIL,NIL,NIL,NIL, 20}   ,;
          { padr("Duz",3), {|| duzina}, "duzina" }   ,;
          { padr("Dec",3), {|| decimal}, "decimal" }   ,;
          { padr("K Validacija",50), {|| KValid}, "KValid" }   ,;
          { padr("K When",50), {|| KWhen }, "KWhen" }   ,;
          { padr("UBrowsu",4), {|| UBrowsu}, "UBrowsu" }             ,;
          { padr("EdKolona",4), {|| EdKolona}, "EdKolona" }             ,;
          { padr("K1",4), {||  k1}, "k1" }             ,;
          { padr("K2",4), {||  k2}, "k2" }             ,;
          { padr("K3",4), {||  k3}, "k3" }             ,;
          { padr("K4",4), {||  k4}, "k4" }             ;
       }

FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
Private gTBDir:="N"
return PostojiSif(F_SIFK,1,10,65,"sifk - Karakteristike",@cId,dx,dy)


/*!
 @function    NoviBK_A
 @abstract    Novi Barkod - automatski
 @discussion  Ova fja treba da obezbjedi da program napravi novi interni barkod
              tako sto ce pogledati Barkod/Prefix iz fmk.ini i naci zadnji
              
	      dodjeljen barkod. Njeno ponasanje ovisno je op parametru
              Barkod / EAN ; Za EAN=13 vraca trinaestocifreni EANKOD,
              Kada je EAN<>13 vraca broj duzine DuzSekvenca BEZ PREFIXA
*/
function NoviBK_A(cPrefix)

local cPom , xRet
local nDuzPrefix, nDuzSekvenca, cEAN

PushWA()

nCount:=1

if cPrefix=NIL
   cPrefix:=IzFmkIni("Barkod","Prefix","",SIFPATH)
endif
cPrefix:=trim(cPrefix)
nDuzPrefix:=len(cPrefix)

nDuzSekv:=  val ( IzFmkIni("Barkod","DuzSekvenca","",SIFPATH) )
cEAN:= IzFmkIni("Barkod","EAN","",SIFPATH)

cRez:= padl(  alltrim(str(1))  , nDuzSekv , "0")
if cEAN="13"
   cRez := cPrefix + cRez + KEAN13(cRez)
   //      0387202   000001   6
else
   cRez := cRez
endif

set filter to // pocisti filter
set order to tag "BARKOD"
seek cPrefix+"·" // idi na kraj
skip -1 // lociraj se na zadnji slog iz grupe prefixa
if left(barkod,nDuzPrefix) == cPrefix
 if cEAN=="13"
  cPom:=   alltrim ( str( val (substr( BARKOD, nDuzPrefix + 1, nDuzSekv)) + 1 ))
  cPom:=   padl(cPom,nDuzSekv,"0")
  cRez:=   cPrefix + cPom
  cRez:=   cRez + KEAN13(cRez)
 else
  // interni barkod varijanta planika koristicemo Code128 standard
  cPom:=   alltrim ( str( val (substr( BARKOD, nDuzPrefix + 1, nDuzSekv)) + 1 ))
  cPom:=   padl(cPom,nDuzSekv,"0")
  cRez:=   cPom  // Prefix dio ce dodati glavni alogritam
 endif
endif

PopWa()

return cRez


/*!
 @function   KEAN13 ( ckod)
 @abstract   Uvrdi ean13 kontrolni broj
 @discussion xx
 @param      ckod   kod od dvanaest mjesta
*/
function KEAN13(cKod)

local n2,n4
local n1:= val(substr(cKod,2,1)) + val(substr(cKod,4,1)) + val(substr(ckod,6,1)) + val(substr (ckod,8,1)) + val(substr(ckod,10,1)) + val(substr(ckod,12,1))
local n3:= val(substr(cKod,1,1)) +val(substr(cKod,3,1)) + val(substr(ckod,5,1)) + val(substr (ckod,7,1)) + val(substr(ckod,9,1)) + val(substr(ckod,11,1))
n2:=n1 * 3

n4:= n2 + n3
n4:= n4 % 10
if n4=0
 return  "0"   // n5
else
 return  str( 10 - n4 , 1)   // n5
endif

// -------------------------
// -------------------------
function Barkod(cId)

// postoje barcodovi!!!!!!!!!!!!!
*
local cIdRoba:=""

gOcitBarCod:=.f.
PushWa()
select ("ROBA")
if !empty(cId) .and. fieldpos("BARKOD")<>0
  set order to tag "BARKOD"
  seek trim(cid)
  if found() .and. trim(cid)==trim(barkod) // ista je duzina sifre
      cId:=Id  // nasao sam sifru po barkodu
     gOcitBarCod:=.t.
  endif

  // trazi alternativne sifre
  cIDRoba:=""
  ImauSifV("ROBA","BARK", cId, @cIdRoba)
  if !empty(cIdRoba)
    select roba; set order to tag "ID"; seek cId  // nasao sam sifru !!
    cId:=cIdRoba
    gOcitBarCod:=.t.
  endif

endif
cId:=padr(cId,10)
PopWa()
return


// nadji novu sifru - radi na pritisak F5 pri unosu
// nove sifre
function NNSifru2()     

local cPom
local cPom2
local nOrder
local nDuz

private cK1:=""
private cImeVar:=""
private cNumDio:=""

if ALIAS()<>"ROBA" .or. IzFMKINI("ROBA","Planika","N",SIFPATH)<>"D" .or. FIELDPOS("K1")==0 .or. !((cImeVar:=READVAR())=="WID") .or. !EMPTY(cK1:=SPACE(LEN(K1))) .or. !VarEdit({ {"Unesite K1","cK1",,"@!",} },10,23,14,56,"Odredjivanje nove sifre artikla","B5")
	return (NIL)
endif
cNumDio := IzFMKINI("ROBA","NumDio","SUBSTR(ID,7,3)",SIFPATH)
cPom2   := &(cImeVar)
nDuz    := LEN(cPom2)
cPom2   := RTRIM(cPom2)
cPom    := cK1+CHR(255)
PushWA()

nOrder:=ORDNUMBER("BROBA")
IF nOrder=0
	MsgBeep("Ako ste u mrezi, svi korisnici moraju napustiti FMK. Zatim pritisnite Enter!")
   	MsgO("Kreiram tag(index) 'BROBA'")
    	cSort := IzFMKINI("ROBA","Sort","K1+SUBSTR(ID,7,3)",SIFPATH)
    	INDEX ON &cSort TAG BROBA
   	MsgC()
ENDIF
set order to tag "BROBA"
GO TOP
SEEK cPom
SKIP -1
cNumDio := &cNumDio
IF K1 == cK1
	&(cImeVar) := PADR( cPom2 + PADL(ALLTRIM(STR(VAL(cNumDio)+1)),LEN(cNumDio),"0") , nDuz )
else
   	&(cImeVar) := PADR( cPom2 + PADL("1",LEN(cNumDio),"0") , nDuz )
ENDIF

wk1 := cK1
AEVAL(GetList,{|o| o:display()})
PopWA()
KEYBOARD CHR(K_END)
RETURN (NIL)



function SeekBarKod(cId,cIdBk,lNFGR)
local nRec
if lNFGR==nil
	lNFGR:=.f.
endif
if lNFGR
	nRec:=RECNO()
endif

if fieldpos("BARKOD")<>0 // traßi glavni barkod
	set order to tag "BARKOD"
	seek cID
	gOcitBarkod:=.t.
	cId:=ID
	if fID_J
		cID:=ID_J
		set order to tag "ID_J"
		seek cID
	endif
else
	seek "‡·‚"
endif

// nisam nasao barkod u polju BARKOD
if !found()   
	cIdBK:=cID
	cId:=""
	ImauSifV("ROBA","BARK", cIdBK, @cId)
	if !empty(cID)
		Beep(1)
		select roba
		set order to tag "ID"
		seek cId  // nasao sam sifru !!
		cId:=Id
		if fID_J
			gOcitBarkod:=.t.
			cID:=ID_J
			set order to tag "ID_J"
			seek cID
		endif
	endif
endif

if lNFGR .and. !FOUND()
	set order to tag "ID"
	go (nRec)
endif
return



