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

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/sclib/sif/1g/sif_prn.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.4 $
 * $Log: sif_prn.prg,v $
 * Revision 1.4  2002/07/30 17:40:59  ernad
 * SqlLog funkcije - Fin modul
 *
 * Revision 1.3  2002/07/04 16:33:53  ernad
 *
 *
 * debug StampaTabele - nije uziman uslov debug u obzir
 *
 *
 */
 

#define  MEMOEXT  ".MEM"


/*! \fn Izlaz(Zaglavlje,ImeDat,bFor,fIndex,lBezUpita)
 *
 *\code
 *
 *OPIS
 * a) Vrsi se odabir vrste izlaza  (D/N/V/E)
 * b) Formira se izlazni fajl
 * c) prikazuje se na ekranu (N,V,E) ili stampa na printer (D), ili salje
 *    PTXT-u (R)
 *   
 *ULAZI
 *bFor - uslov za prikaz zapisa
 *
 *KORISTIM
 * Koristi i sljedece public varijable
 *
 *- Kol - sarzi raspored polja,
 *        npr: 
 *	    Kol:={0,1,0,2.............}
 *
 *- RKol (opciono)
 *      [1] broj kolone u kojoj se prikazuje (iz niza Kol)
 *      [2] naziv kolone (kolona 2 u nizu ImeKol)
 *      [3] "D" ako ne moze stati podatak u sirinu kolone tj.
 *          ko treba omoguciti prelamanje u vise redova
 *      [4] sirina kolone koja se uzima u obzir ako je [3] "D"
 *
 */

function Izlaz(Zaglavlje, ImeDat, bFor, fIndex, lBezUpita)
local i,k
local bErrorHandler
local bLastHandler
local objErrorInfo
local nStr
local nSort
local cStMemo:="N"
local aKol:={}
local j
local xPom
local nDuz1
local nDuz2
local cRazmak:="N"
local nSlogova
local nSirIzvj:=0

private cNazMemo:=""
private RedBr
private Getlist:={}

if lBezUpita==nil
	lBezUpita:=.f.
endif
if fIndex==nil
	fIndex:=.t.
endif
if Zaglavlje==nil
	Zaglavlje:=""
endif
if ImeDat==nil
	ImeDat:=""
endif
if "U" $ TYPE("gOdvTab")
	gOdvTab:="N"
endif
if "U" $ TYPE("RKol")
	RKol:=nil
endif
if "U" $ TYPE("gPostotak")
	gPostotak:="N"
endif

 if lBezUpita
 else
  Zaglavlje:=PADR(Zaglavlje,70)
  UsTipke()
  nColStr:=80
  nSort:="ID       "
  Box(,8,76,.t.)
  SET CURSOR ON
  @ m_x+1,m_y+20 SAY "Tekst koji se stampa kao naslov:"
  @ m_x+2,m_y+3  GET Zaglavlje
  cValid:=""
  if fIndex
   for i:=1 to 10
    if upper(ordname(i))<>"BRISAN"
     cValid+="#"+upper(ordname(i))
    endif
   next
   @ m_x+3,m_y+3  SAY "Nacin sortiranja (ID/NAZ):" GET nSort VALID   alltrim(nSort) $ cValid pict "@!"
  endif
  @ m_x+4,m_y+3  SAY "Odvajati redove linijom (D/N) ?" GET gOdvTab VALID gOdvTab $ "DN" PICTURE "@!"
  @ m_x+5,m_y+3  SAY "Razmak izmedju redova   (D/N) ?" GET cRazmak VALID cRazmak $ "DN" PICTURE "@!"
  READ
 
 endif

 lImaSifK:=.f.
 if ASCAN( ImeKol , { |x| LEN(x)>2 .and. VALTYPE(x[3])=="C" .and. "SIFK->"$x[3] } ) <> 0
   lImaSifK:=.t.
 endif

 if LEN(ImeKol[1])>2 .and. !lImaSifK
  private aStruct:=DBSTRUCT(), anDuz[FCOUNT(),2], ctxt2
  for i:=1 to len(aStruct)
    
    // treci element jednog reda u matrici imekol
    k:= ASCAN(ImeKol, {|x| FIELD(i)==UPPER(x[3])})

    j:=IF(k<>0, Kol[k], 0)
    
    if j<>0
      xPom:=EVAL(ImeKol[k,2])
      anDuz[j,1]:=MAX( LEN(ImeKol[k,1]) , LEN(IF(VALTYPE(xPom)=="D",;
                  DTOC(xPom),IF(VALTYPE(xPom)=="N",STR(xPom),xPom))) )
      if anDuz[j,1]>100
        anDuz[j,1]:=100
        anDuz[j,2]:={ ImeKol[k,1], ImeKol[k,2],.f.,;
                      "P",;
                      anDuz[j,1], IIF(aStruct[i,2]=="N", aStruct[i,4],0) }
      else
        anDuz[j,2]:={ ImeKol[k,1],ImeKol[k,2],.f., VALTYPE(EVAL(ImeKol[k,2])), anDuz[j,1],IF(aStruct[i,2]=="N",aStruct[i,4],0) }
      endif
    else
     if aStruct[i,2]=="M"
       @ m_x+6, m_y+3 SAY "Stampati "+aStruct[i,1] GET cStMemo pict "@!" valid cStMemo $ "DN"
       READ
       if cStMemo=="D"
         cNazMemo:=aStruct[i,1]
       endif
     endif
    endif
  next

  AADD(aKol, {"R.br.", {|| STR(RedBr,4)+"."}, .f., "C", 5, 0, 1, 1})
  j:=1
  for i:=1 to len(aStruct)
    if anDuz[i,1]!=nil
      ++j
      AADD(anDuz[i,2],1); AADD(anDuz[i,2],j)
      AADD(aKol,anDuz[i,2])
    endif
  next

  if !EMPTY(cNazMemo)
    AADD(aKol,{cNazMemo,{|| ctxt2},.f.,"P",30,0,1,++j})
  endif
 else
  AADD(aKol,{"R.br.",{|| STR(RedBr,4)+"."},.f.,"C",5,0,1,1})
  aPom:={}
  for i:=1 to LEN(Kol); AADD(aPom,{Kol[i],i}); next
  ASORT(aPom,,,{|x,y| x[1]<y[1]})
  j:=0
  for i:=1 to LEN(Kol)
    if aPom[i,1]>0
      ++j
      aPom[i,1]:=j
    endif
  next
  ASORT(aPom,,,{|x,y| x[2]<y[2]})
  for i:=1 to LEN(Kol)
  	Kol[i]:=aPom[i,1]
  next
  aPom:={}
  for i:=1 to LEN(Kol)
    if Kol[i]>0
      xPom:=EVAL(ImeKol[i,2])
      if LEN(ImeKol[i])>2 .and. VALTYPE(ImeKol[i,3])=="C" .and. "SIFK->"$ImeKol[i,3]
        AADD(aKol,{ImeKol[i,1],ImeKol[i,2],IF(LEN(ImeKol[i])>2.and.VALTYPE(ImeKol[i,3])=="L",ImeKol[i,3],.f.),;
                 IF(SIFK->veza=="N","P",VALTYPE(xPom)),;
                 IF(SIFK->veza=="N",SIFK->duzina+1,MAX(SIFK->duzina,LEN(TRIM(ImeKol[i,1])))),;
                 IF(VALTYPE(xPom)=="N",SIFK->decimal,0),1,Kol[i]+1})
        loop
      endif
      nDuz1:=IF(LEN(ImeKol[i])>4.and.VALTYPE(ImeKol[i,5])=="N",ImeKol[i,5],LENx(xPom))
      nDuz2:=IF(LEN(ImeKol[i])>5.and.VALTYPE(ImeKol[i,6])=="N",ImeKol[i,6],IF( VALTYPE(xPom)=="N" , nDuz1-AT(".",STR(xPom)) , 0 ))
      nPosRKol:=0
      if RKol!=nil .and. TrebaPrelom(Kol[i],@nPosRKol)
        AADD(aKol,{ImeKol[i,1],ImeKol[i,2],IF(LEN(ImeKol[i])>2,ImeKol[i,3],.f.),;
                 "P",;
                 RKol[nPosRKol,4],nDuz2,1,Kol[i]+1})
      else
        AADD(aKol,{ImeKol[i,1],ImeKol[i,2],IF(LEN(ImeKol[i])>2.and.VALTYPE(ImeKol[i,3])=="L",ImeKol[i,3],.f.),;
                 IF(LEN(ImeKol[i])>3.and.VALTYPE(ImeKol[i,4])=="C".and.ImeKol[i,4]$"N#C#D#P",ImeKol[i,4],IF(nDuz1>100,"P",VALTYPE(xPom))),;
                 IF(nDuz1>100,100,nDuz1),nDuz2,1,Kol[i]+1})
      endif
    endif
  next
 endif
 
 BoxC()
 BosTipke()
 if !lBezUpita
	START PRINT RET
 endif

 for i:=1 to LEN(aKol)
   if aKol[i,7]==1
	nSirIzvj += ( aKol[i,5] + 1 )
   endif
 next
 ++nSirIzvj

 if "U" $ TYPE("gnLMarg")
 	gnLMarg:=0
 endif
 if "U" $ TYPE("gA43")
 	gA43:="4"
 endif
 if "U" $ TYPE("gTabela")
 	gTabela:=0
 endif
 if "U" $ TYPE("gOstr")
 	gOstr:="D"
 endif

 if lBezUpita
 	gOstr:="N"
 endif

 if gPrinter=="L" .or. gA43=="4" .and. nSirIzvj>165
   gPO_Land()
 endif

 if !EMPTY(Zaglavlje)
   QQOUT(SPACE(gnLMarg))
   gP10CPI(); gPB_ON()
   QQOUT(PADC(ALLTRIM(Zaglavlje),79*IF(gA43=="4",1,2)-gnLMarg))
   gPB_OFF()
   QOUT()
 endif
 if fIndex
   for i:=1 to 10
     if upper(TRIM(ordkey(i)))==upper(TRIM(nSort))
       nSort:=i
       exit
     endif
   next
   DBSETORDER(nSort)
 endif
 COUNT to nSlogova
 GO TOP
 RedBr:=0
 if cRazmak=="D"
 	AADD(aKol,{"",{|| " "},.f.,"C",aKol[1,5],0,2,1})
 endif


StampaTabele(aKol,{|| ZaRedBlok()},gnLMarg,;
          IF(UPPER(RIGHT(ALLTRIM(SET(_SET_PRINTFILE)),3))=="RTF",9,gTabela),;
          ,IF(gPrinter=="L","L4",gA43=="4"),;
          ,,IF(gOstr=="N",-1,),,gOdvTab=="D",,nSlogova,"Kreiranje tabele")

if (gPrinter=="L" .or. gA43=="4" .and. nSirIzvj>165)
	gPO_Port()
endif

if !lBezUpita
	END PRINT
endif

return nil


function ZaRedBlok()
*{
++RedBr
 
WhileEvent(RedBr,nil)
  
if !EMPTY(cNazMemo)
    ctxt2:=UkloniRet(cNazMemo,.f.)
endif
  
return .t.
*}

function UkloniRet(xTekst,lPrazno)
*{
local cTekst
 if lPrazno==nil; lPrazno:=.f.; endif
 if VALTYPE(xTekst)=="B"
   cTekst:=strtran(EVAL(xTekst),"ç"+Chr(10),"")
 else
   cTekst:=strtran(&xTekst,"ç"+Chr(10),"")
 endif
 if lPrazno
  cTekst:=strtran(cTekst,NRED,NRED+space(7))
 else
  cTekst:=strtran(cTekst,NRED," ")
 endif
return cTekst
*}


static function Karaktera(cK)
*{
if cK=="10"
  return 80
elseif cK=="12"
  return 92
elseif cK=="17"
  return 132
elseif cK=="20"
  return 156
endif
*}


function IzborP2(Kol,cImef)
*{
private aOBjG,cKolona,Kl

Kl:=ARRAY(len(Kol))
ACOPY(Kol,Kl)

#ifdef CAX
 if gKesiraj == "X"
    cImeF:=strtran(cImeF,LEFT(cImeF,3),"C:\")
 endif
#endif


if FILE(cImef+MEMOEXT)
 RESTORE FROM &cImeF ADDITIVE // u~itavanje string kolona
 for i:=1 to LEN(Kl)
   if valtype(cKolona)=="C"
     Kl[i]:=VAL(SUBSTR(cKolona,(i-1)*2+1,2))
   else
     Kl[i]:=0
   endif
 next
endif

nDiv:=INT(Len(Kol)/3+1)
wx:=nDiv+2

BOX('',wx,77,.t.,"","Izbor polja za prikaz")
SET CURSOR ON

Odg=' '

aObjG:=ARRAY(Len(Kl)+1)

for i:=1 to Len(Kl)
 j:=(i-1) % nDiv
 cIDx:=alltrim(str(i))
 if i/nDiv<=1
   ystep=25
 elseif i/nDiv<=2
   yStep=51
 elseif i/nDiv<=3
   yStep=76
 else
   ? "Preveliki broj kolona ...(izl.prg)"
   quit
 endif
 aObjG[i]:=GetNew(m_x+j+1,m_y+yStep)
 @ aObjG[i]:row,(aObjG[i]:col)-22 SAY PADR(ALLTRIM(ImeKol[i,1]),20)
 aObjG[i]:name:="Kl["+cIdx+"]"

 b1:= "Kl["+cIdx+"]"                                                    // 3
 aObjG[i]:block:={|cVal| IF(PCOUNT()==0,&b1.,&b1.:=cVal)}               // 3

 aObjG[i]:picture:="99"
 aObjG[i]:postBlock:={|nVal| DobraKol(@Kl,&cIdx.)}

 aObjG[i]:display()
next

aObjG[Len(Kl)+1]:=GetNew()
aObjG[Len(Kl)+1]:row:=m_x+wx
aObjG[Len(Kl)+1]:col:=m_y+40
aObjG[Len(Kl)+1]:name:="Odg"
aObjG[Len(Kl)+1]:block:={|cVal| iif(cVal==nil,Odg,Odg:=cVal)}
aObjG[Len(Kl)+1]:display()
@ m_x+wx,m_y+8 SAY 'Kraj - <PgDown>, Nuliraj-<F5>'
set key K_F5  to Nuliraj()
 ReadModal(aObjG)
set key K_F5
BoxC()
if LastKey()== K_ESC
   return
END IF

cKolona:=""
AEVAL(Kl, {|broj| cKolona:=cKolona+STR(Broj,2)})
// Pretvaranje matrice u jedan string radi mogu}nosti pohranjivanja
// matrice kao karakterne memorijske varijable
SAVE  ALL LIKE cKolona to &cImeF
ACOPY(Kl,Kol)
return    
*}

/*
 * function DobraKol(Kol,i)
 * Nalazenje kolona koje se stampaju, Koristi je IzborP2
 */
 
function DobraKol(Kol,i)
*{
local n

if Kol[i]=0 ; return .T. ; END IF
n:=0
for k:=1 to LEN(Kol)
  if Kol[i]=Kol[k] ; n++ ; END IF
next
if n>1
  return .F.
else
  if Kol[i]>Len(Kol)
     return .f.
  endif
  return .t.
END IF

return
*}

function Nuliraj()
*{
local i
 for i:=1 to len(Kl)
   Kl[i]:=0
 next
 AEVAL(aObjG,{|oE|  oE:Display() })
return
*}

static function TrebaPrelom(nPos,nPosRKol)
*{
local lVrati:=.f., i:=0
 for i:=1 to LEN(RKol)
   if RKol[i,1]==nPos
     if RKol[i,3]=="D"; lVrati:=.t.; nPosRKol:=i ; endif
     exit
   endif
 next
return lVrati
*}

/*! \fn StampaTabele(aKol, bZaRed, nOdvoji, nCrtice, bUslov, lA4papir, cNaslov, bFor, nStr, lOstr, lLinija, bSubTot, nSlogova, cTabBr, lCTab, bZagl)
 *
 *   \brief Stampa tabele
 * 
 * \code
 * ULAZI
 * aKol - niz definicija kolona, npr.
 * aKol:={  { "R.br."     , {|| rbr+"."             }, .f., "C",  5, 0, 1, 1},;
 *         { "PPU"       , {|| nPPU                }, .t., "N", 11, 2, 1, 2},;
 *         { "MPC"       , {|| roba->mpc           }, .f., "N", 11, 2, 1, 3},;
 *         { "MP iznos"  , {|| kolicina*roba->mpc  }, .t., "N", 11, 2, 1, 4} }
 * gdje je (i,1) - zaglavlje kolone
 *         (i,2) - blok koji vraca vrijednost za ispis
 *         (i,3) - logicka vrijednost za izbor sumiranja (.t.)
 *         (i,4) - tip promjenjive koju vraca blok (i,2)
 *         (i,5) - duzina promjenjive koju vraca blok (i,2) ili sirina kolone
 *         (i,6) - broj decimalnih mjesta kod numerickih vrijednosti
 *         (i,7) - broj reda u stavki u kom ce se stampati vrijednost
 *         (i,8) - broj kolone u stavki u kojoj ce se stampati vrijednost
 *         (i,9) - bSuma - sumiranje se vrsi po ovoj koloni
 * bZaRed   - blok koji se izvrsava pri svakom stampanju sloga (reda u tabeli)
 * nOdvoji  - lijeva margina
 * nCrtice  - nacin crtanja tabele ( 0 za crtice, 1 za linije, ostalo za tip
 *           tabele sa duplim linijama )
 * bUslov   - blok koji odredjuje do kog sloga ce se uzimati vrijednosti,
 *           vraca logicku vrijednost (ako je uvijek .t. kraj ce biti tek
 *           pri pojavljivanju EOF (kraj baze)   - "while" blok
 * lA4papir - sirina papira, ako je .t. radice se sa A4 papirom. Moze se
 *           zadati i "4" za A4, "3" za A3, "POS" za 40 znakova u redu
 * cNaslov  - zaglavlje tabele, ispisuje se samo ako je proslijedjen parametar
 * bfor     - blok koji odredjuje da li ce slog biti obradjivan u tabeli
 * nStr     - broj strane na kojoj se trenutno nalazimo, ako je -1 uopste se
 *           nece prelamati tabela (kontinuirani papir)
 * lOstr    - .f. znaci da ne treba ostranicavati posljednju stranu
 * lLinija  - .t. znaci da ce se stavke odvajati linijom
 * bSubTot  - blok koji vraca {.t.,cSubTxt} kada treba prikazati subtotal
 * nSlogova - broj slogova za obradu    ƒƒø koristi se samo za prikaz
 * cTabBr   - oznaka (naziv) za tabelu  ƒƒŸ procenta uradjenog posla
 * lCTab    - horiz.centriranje tabele (.t. - da, .f. - ne)    nil->.t.
 * bZagl    - blok dodatnog zaglavlja koje ima prioritet nad zaglavljem
 *           koje se nalazi u ovoj f-ji
 *
 * blokovi se izvrsavaju ovim redom:   1. bUslov   2. bfor   3. bZaRed
 *
 */

function StampaTabele(aKol, bZaRed, nOdvoji, nCrtice, bUslov, lA4papir,cNaslov, bFor,nStr,lOstr,lLinija,bSubTot,nSlogova,cTabBr,lCTab,bZagl)

local cOk, nKol:=0, i:=0, xPom, cTek1:="Prenos sa str.", lMozeL:=.f.
local cTek2:="U K U P N O:"
local nDReda:=0
local cTek3:="Ukupno na str."
local cPom
local lPrenos:=.f.,cLM,cLM2,nMDReda,aPom:={},nSuma,nRed:=0,j:=0,xPom1,xPom2
local aPrZag:={},aPrSum:={},aPrStav:={},nSubTot,xTot:={.f.,""},lPRed:=.f.
local nPRed:=0,aPRed:={},l:=0,nBrojacSlogova:=0
local xPodvuci:="", cPodvuci:=" "
local lFor:=.f., k:=0
private glNeSkipuj:=.f.
if "U" $ TYPE("gaDodStavke"); gaDodStavke:={}; endif
if "U" $ TYPE("gaSubTotal"); gaSubTotal:={}; endif
if "U" $ TYPE("gnRedova"); gnRedova:=64; endif
if "U" $ TYPE("gbFIznos"); gbFIznos:=nil; endif
if !("U" $ TYPE("gPStranica")); gnRedova:=64+gPStranica; endif
if bSubTot==nil; bSubTot:={|| {.f.,}}; xTot:={.f.,}; endif
if lLinija==nil; lLinija:=.f.; endif
if lOstr==nil; lOstr:=.t.; endif
if nStr==nil; nStr:=1; endif
if nCrtice==nil; nCrtice:=1; endif
if nOdvoji==nil; nOdvoji:=0; endif
 
 if bUslov==nil
 	bUslov:={|| INKEY(),IF(LASTKEY()==27,PrekSaEsc(),.t.)}
 endif
 if bZaRed==nil
 	bZaRed:={|| .t.}
 endif
 
 if bFor==nil; bFor:={|| .t.}; endif
 if lCTab==nil; lCTab:=.t.; endif
 if lA4papir==nil; lA4papir:="4"; endif
 if VALTYPE(lA4papir)=="L"; lA4papir:=IF(lA4papir,"4","3"); endif
 if nCrtice==9; nStr:=-1; lOstr:=.f.; endif
 if nSlogova!=nil; Postotak(1,nSlogova,cTabBr,,,.f.); endif

 AEVAL(aKol,{|x| xPom:=x[8],xPom1:=x[5],xPom2:=x[3],IF(ASCAN(aPom,{|y| y[1]==xPom})==0,EVAL({|| nDReda+=xPom1,AADD(aPom,{xPom,xPom1,xPom2})}),),;
                 IF(x[3],lPrenos:=.t.,),IF(x[8]>nKol,nKol:=x[8],),IF(x[7]>nRed,nRed:=x[7],),IF(x[4]=="P",lPRed:=.t.,)})
 ASORT(aPom,,,{|x,y| x[1]<y[1]})

 for i:=1 to nRed
  for j:=1 to nKol
   if ASCAN(aKol,{|x| x[7]==i.and.x[8]==j})==0
     AADD(aKol,{"",{|| "#"},.f.,"C",aPom[j,2],0,i,j})
   endif
  next
 next

 ASORT(aKol,,,{|x,y| 100*x[7]+x[8]<100*y[7]+y[8]})

 for i:=1 to nKol
  for j:=1 to nRed
   if aKol[(j-1)*nKol+i][3]
     aPom[i][3]:=.t.
     if ASCAN(aPrSum,j)==0
       AADD(aPrSum,j)
     endif
   endif
   if !EMPTY(aKol[(j-1)*nKol+i][1])
     if ASCAN(aPrZag,j)==0
       AADD(aPrZag,j)
     endif
   endif
   xPom:=EVAL(aKol[(j-1)*nKol+i][2])
   if VALTYPE(xPom)=="C"
    if xPom!="#"
     if ASCAN(aPrStav,j)==0
       AADD(aPrStav,j)
     endif
    else
     aKol[(j-1)*nKol+i][2]:={|| ""}
    endif
   else
    if ASCAN(aPrStav,j)==0
      AADD(aPrStav,j)
    endif
   endif
  next
 next

 ASORT(aPrZag); ASORT(aPrSum); ASORT(aPrStav)
 nDReda+=nKol+1+nOdvoji
 nMDReda:=IF(lA4papir=="POS",40,MDDReda(nDReda,lA4papir))
 cLM:=IF(nMDReda-nDReda>=0,SPACE(nOdvoji+INT((nMDReda-nDReda)/2)),"")
 cLM2:=IF(nMDReda-nDReda>=0.and.!lCTab,SPACE(nOdvoji),cLM)
 GuSt2(nDReda,lA4papir)

 if nStr>=0.and.(prow()>(gnRedova+IF(gPrinter="R",2,0)-7-LEN(aPrStav)-LEN(aPrZag)).or.prow()>(gnRedova+IF(gPrinter="R",2,0)-11-LEN(aPrStav)-LEN(aPrZag)).and.cNaslov!=nil)
   if gPrinter!="R"
     do while prow()<gnRedova-2; QOUT(); enddo
     xPom:=STR(nStr,3)+". strana"
     QOUT(cLM+PADC(xPom,nDReda-nOdvoji))
   endif
   gPFF(); SETPRC(0,0)
   if !(bZagl==nil)
     EVAL(bZagl)
   endif
   ++nStr
 endif

 if nCrtice==0
     cOk:={"-", "-", " ", "-", " ", "-", " ", "-", "-", " ", "-", " ", "-", "-", "-", " "}
 elseif nCrtice==1
     cOk:={"⁄", "ƒ", "¬", "ø", "≥", "√", "≈", "¥", "¿", "¡", "Ÿ", "≥", "ƒ", "√", "¥", "≈"}
 elseif nCrtice==9    // rtf-fajlovi
     cOk:={" ", " ", " ", " ", "#", " ", " ", " ", " ", " ", " ", "#", " ", " ", " ", " "}
 else
     cOk:={"…", "Õ", "—", "ª", "≥", "Ã", "ÿ", "π", "»", "œ", "º", "∫", "ƒ", "«", "∂", "≈"}
 endif   // 1    2    3    4    5    6    7    8    9    10   11   12   13   14   15   16
         ////////////////////////////////////////////////////////////////////////////////

 nSuma:=ARRAY(nKol); AFILL(nSuma,0); nSuma:=AMFILL(nSuma,nRed)
 nSubTot:=ARRAY(nKol); AFILL(nSubTot,0); nSubTot:=AMFILL(nSubTot,nRed)
 if cNaslov!=nil
   QOUT(cLM2+cOk[1]+REPLICATE(cOk[2],nDReda-nOdvoji-2)+cOk[4])
   QOUT(cLM2+cOk[12]+SPACE(nDReda-nOdvoji-2)+cOk[12])
   QOUT(cLM2+cOk[12]+PADC(ALLTRIM(cNaslov),nDReda-nOdvoji-2)+cOk[12])
   QOUT(cLM2+cOk[12]+SPACE(nDReda-nOdvoji-2)+cOk[12])
 endif
 i:=0; QOUT(cLM2+IF(cNaslov!=nil,cOk[6],cOk[1]))
 AEVAL(aPom,{|x| ++i,QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,cOk[3],IF(cNaslov!=nil,cOk[8],cOk[4])))})

 for j:=1 to LEN(aPrZag)
   i:=0; QOUT(cLM2+cOk[12])
   AEVAL(aKol,{|x| ++i,QQOUT(PADC(x[1],x[5])+IF(i<nKol,cOk[5],cOk[12]))},(aPrZag[j]-1)*nKol+1,nKol)
 next

 i:=0; QOUT(cLM2+cOk[6])
 AEVAL(aPom,{|x| ++i,QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,cOk[7],cOk[8]))})

 // idemo po bazi
 // -------------
 do while !EOF() .and. EVAL(bUslov)

  if nSlogova!=nil
  	Postotak(2,++nBrojacSlogova)
  endif

  // evaluacija "ZA" bloka (korisnicke "FOR" funkcije)
  // -------------------------------------------------
  if !(lFor:=EVAL(bFor))
    if EMPTY(gaDodStavke) .and. EMPTY(gaSubTotal)
      if !glNeSkipuj
      	SKIP 1
      endif
      loop
    endif
  endif

  if lFor

    // evaluacija bloka internog subtotala
    // -----------------------------------
    if lMozeL; xTot:=EVAL(bSubTot); endif

    // izvrsimo blok koji se izvrsava za svaku stavku koja se stampa
    // -------------------------------------------------------------
    xPodvuci:=EVAL(bZaRed)
    // treba li na kraju izvrsiti podvlacenje
    // --------------------------------------
    if VALTYPE(xPodvuci)=="C" .and. LEFT(UPPER(xPodvuci),7)=="PODVUCI"
      cPodvuci:=RIGHT(xPodvuci,1)
      xPodvuci:=.t.
    else
      xPodvuci:=.f.
    endif

  endif

  // ako ima kolona koje moraju za jednu stavku ici u vise redova
  // potrebno je izracunati max.broj tih redova (nPRed)
  // ------------------------------------------------------------
  if lfor .and. lPRed
    aPRed:={}; nPRed:=0
    AEVAL(aKol,{|x| IF(LEFT(x[4],1)=="P", IF(!EMPTY(xPom:=LomiGa(EVAL(x[2]),IF(LEN(x[4])>1,VAL(SUBSTR(x[4],2)),1),0,x[5])),AADD(aPRed,{xPom,x[5],LEN(xPom)/x[5],x[8],LEN(xPom)/x[5],x[7]}),),)})
    ASORT(aPRed,,,{|x,y| x[4]<y[4]})
    AEVAL(aPRed,{|x| IF(nPRed<x[3]+x[6]-1,nPRed:=x[3]+x[6]-1,)})
  endif

  // ispitivanje uslova za prelazak na novu stranicu
  // -----------------------------------------------
  if lfor .and. nStr>=0 .and. (prow()>gnRedova+IF(gPrinter="R",2,0)-IF(xPodvuci,1,0)-5-MAX(LEN(aPrStav),nPRed)-IF(lPrenos,LEN(aPrSum)*IF(xTot[1],(2+1/LEN(aPrSum)),1),0))
    NaSljedStranu(@lMozeL,@lPrenos,cLM2,cOk,aPom,nKol,@nStr,cLM,;
                  nDReda,nOdvoji,aPrSum,aKol,nSuma,cTek3,bZagl,;
                  cNaslov,aPrZag,cTek1,xTot)
  endif

  // stampanje internog subtotala
  // ----------------------------
  if lfor .and. xTot[1]
    //  podvlacenje prije subtotala (ako nije prvi red na stranici)
    if lMozeL
     i:=0; QOUT(cLM2+cOk[6])
     AEVAL(aPom,{|x| ++i,;
      QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,IF(!x[3].and.!aPom[i+1,3],cOk[10],cOk[7]),cOk[8]))})
    endif
    for j:=1 to LEN(aPrSum)
      i:=0; cPom:=""
      AEVAL(aKol,{|x| ++i,;
       cPom+=IF(x[3],STR(nSubTot[aPrSum[j]][i],x[5],x[6]),SPACE(x[5]))+IF(i<nKol,IF(!aPom[i,3].and.!aPom[i+1,3]," ",cOk[5]),cOk[12]),nSubTot[aPrSum[j]][i]:=0},(aPrSum[j]-1)*nKol+1,nKol)
      xPom:=IF(j==LEN(aPrSum),xTot[2],SPACE(LEN(xTot[2])))
      QOUT(cLM2+cOk[12]+STRTRAN(cPom,SPACE(LEN(xPom)),xPom,1,1))
    next
    i:=0
    QOUT(cLM2+cOk[6])
    AEVAL(aPom,{|x| ++i,;
     QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,IF(!x[3].and.!aPom[i+1,3],cOk[3],cOk[7]),cOk[8]))})
    lMozeL:=.f.
  endif

  // odvajanje stavki linijom (ako je zadano i ako nije prvi red)
  // ------------------------------------------------------------
  if lLinija.and.lMozeL
   i:=0; QOUT(cLM2+cOk[14])
   AEVAL(aPom,{|x| ++i,QQOUT(REPLICATE(cOk[13],x[2])+IF(i<nKol,cOk[16],cOk[15]))})
  endif

  if lFor

    // dvostruka petlja u kojoj se vrsi sabiranje totala, internih subtotala
    // i stampanje stavke  ( j=broj reda stavke, i=kolona stavke )
    // ---------------------------------------------------------------------
    for j:=1 to MAX(LEN(aPrStav),nPRed)
     QOUT(cLM2+cOk[12])
     for i:=1 to nKol
       if j<=LEN(aPrStav)
        xPom:=EVAL(aKol[(aPrStav[j]-1)*nKol+i,2])
        if aKol[(aPrStav[j]-1)*nKol+i,3].and.VALTYPE(xPom)=="N"
          if len( aKol[(aPrStav[j]-1)*nKol+i] ) >=9   // postoji bSuma
           xPom:=EVAL(aKol[(aPrStav[j]-1)*nKol+i,9])
          endif
          nSuma[aPrStav[j]][i]+=xPom
          if xTot[2]!=nil; nSubTot[aPrStav[j]][i]+=xPom; endif
        endif
        xPom:=EVAL(aKol[(aPrStav[j]-1)*nKol+i,2])
        if aKol[(aPrStav[j]-1)*nKol+i,4]="N"
          if VALTYPE(xPom)!="N" .or. ROUND(xPom,aKol[(aPrStav[j]-1)*nKol+i,6])==0 .and. RIGHT(aKol[(aPrStav[j]-1)*nKol+i,4],1)=="-"
            QQOUT(SPACE(aKol[(aPrStav[j]-1)*nKol+i,5]))
          else
            if gbFIznos!=nil
              QQOUT( EVAL( gbFIznos,;
                           xPom,;
                           aKol[(aPrStav[j]-1)*nKol+i,5],;
                           aKol[(aPrStav[j]-1)*nKol+i,6] );
                   )
            else
              QQOUT(STR(xPom,aKol[(aPrStav[j]-1)*nKol+i,5],aKol[(aPrStav[j]-1)*nKol+i,6]))
            endif
          endif
        elseif aKol[(aPrStav[j]-1)*nKol+i,4]=="C"
          QQOUT(PADR(xPom,aKol[(aPrStav[j]-1)*nKol+i,5]))
        elseif aKol[(aPrStav[j]-1)*nKol+i,4]=="D"
          QQOUT(PADC(DTOC(xPom),aKol[(aPrStav[j]-1)*nKol+i,5]))
        elseif LEFT(aKol[(aPrStav[j]-1)*nKol+i,4],1)=="P"
          l:=ASCAN(aPRed,{|x| x[4]==i})
          if l>0
           xPom:=IF(aPRed[l,3]>0,SUBSTR(aPRed[l,1],(aPRed[l,5]-aPRed[l,3])*aPRed[l,2]+1,aPRed[l,2]),SPACE(aPRed[l,2]))
           --aPRed[l,3]
           QQOUT(xPom)
          else
           QQOUT(SPACE(aKol[i,5]))
          endif
        endif
       else
        if (l:=ASCAN(aPRed,{|x| x[4]==i}))!=0
          xPom:=IF(aPRed[l,3]>0,SUBSTR(aPRed[l,1],(aPRed[l,5]-aPRed[l,3])*aPRed[l,2]+1,aPRed[l,2]),SPACE(aPRed[l,2]))
          --aPRed[l,3]
          QQOUT(xPom)
        else
          QQOUT(SPACE(aKol[i,5]))
        endif
       endif
       QQOUT(IF(i<nKol,cOk[5],cOk[12]))
     next
    next

  endif

  // stampanje stavke koja sluzi samo za podvlacenje
  // -----------------------------------------------
  if lfor .and. xPodvuci
    i:=0
    QOUT(cLM2+cOk[12])
    AEVAL(aPom,{|x| ++i,QQOUT(REPLICATE(cPodvuci,x[2])+IF(i<nKol,cOk[5],cOk[12]))})
  endif

  if !( EMPTY(gaDodStavke) )
    for j:=1 to LEN(gaDodStavke)
      // ispitaj da li je potreban prelazak na novu stranicu
      if nStr>=0 .and. (prow()>gnRedova+IF(gPrinter="R",2,0)-5-1-IF(lPrenos,1,0))
        NaSljedStranu(@lMozeL,@lPrenos,cLM2,cOk,aPom,nKol,@nStr,cLM,;
                      nDReda,nOdvoji,aPrSum,aKol,nSuma,cTek3,bZagl,;
                      cNaslov,aPrZag,cTek1,xTot)
      endif
      // odstampaj liniju za odvajanje ako je potrebno (samo za j==1)
      if j==1 .and. lLinija.and.lMozeL
       i:=0; QOUT(cLM2+cOk[14])
       AEVAL(aPom,{|x| ++i,QQOUT(REPLICATE(cOk[13],x[2])+IF(i<nKol,cOk[16],cOk[15]))})
      endif

      QOUT(cLM2+cOk[12])
      for i:=1 to nKol
        // izvrsi sumiranje
         xPom:=gaDodStavke[j,i]
        if aKol[i,3] .and. xPom!=nil
          nSuma[1,i]+=xPom
        endif
        // odstampaj stavku
        StStavku(aKol,xPom,i,nKol,cOk)
      next
    next
  endif


  if !( EMPTY(gaSubTotal) )
    lMozeL:=.t.
    for k:=1 to LEN(gaSubTotal)
      // ispitaj da li je potreban prelazak na novu stranicu
      if nStr>=0 .and. (prow()>gnRedova+IF(gPrinter="R",2,0)-5-2-IF(lPrenos,1,0))
        if k>1
          i:=0; QOUT(cLM2+cOk[6])
          AEVAL(aPom,{|x| ++i,;
           QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,IF(!(x[3].or.VALTYPE(gaSubTotal[k,i])=="N").and.!(aPom[i+1,3].or.VALTYPE(gaSubTotal[k,i+1])=="N"),cOk[3],cOk[7]),cOk[8]))})
        endif
        NaSljedStranu(@lMozeL,@lPrenos,cLM2,cOk,aPom,nKol,@nStr,cLM,;
                      nDReda,nOdvoji,aPrSum,aKol,nSuma,cTek3,bZagl,;
                      cNaslov,aPrZag,cTek1,{.t.,})
      endif
      //  podvlacenje prije subtotala (ako nije prvi red na stranici)
      if lMozeL
       i:=0; QOUT(cLM2+cOk[6])
       AEVAL(aPom,{|x| ++i,;
        QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,IF(!(x[3].or.VALTYPE(gaSubTotal[k,i])=="N").and.!(aPom[i+1,3].or.VALTYPE(gaSubTotal[k,i+1])=="N"),cOk[10],cOk[7]),cOk[8]))})
      elseif k>1
       i:=0; QOUT(cLM2+cOk[6])
       AEVAL(aPom,{|x| ++i,;
        QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,IF(!(x[3].or.VALTYPE(gaSubTotal[k,i])=="N").and.!(aPom[i+1,3].or.VALTYPE(gaSubTotal[k,i+1])=="N"),cOk[2],cOk[7]),cOk[8]))})
      endif
      // stampanje subtotala
      i:=0; cPom:=""
      AEVAL(aKol,{|x| ++i,;
       cPom+=IF(x[3].or.VALTYPE(gaSubTotal[k,i])=="N",STR(gaSubTotal[k,i],x[5],x[6]),SPACE(x[5]))+IF(i<nKol,IF(!(aPom[i,3].or.VALTYPE(gaSubTotal[k,i])=="N").and.!(aPom[i+1,3].or.VALTYPE(gaSubTotal[k,i+1])=="N")," ",cOk[5]),cOk[12])},1,nKol)
      xPom:=ATAIL(gaSubTotal[k])
      QOUT(cLM2+cOk[12]+STRTRAN(cPom,SPACE(LEN(xPom)),xPom,1,1))
      if k==LEN(gaSubTotal)
        i:=0; QOUT(cLM2+cOk[6])
        AEVAL(aPom,{|x| ++i,;
         QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,IF(!(x[3].or.VALTYPE(gaSubTotal[k,i])=="N").and.!(aPom[i+1,3].or.VALTYPE(gaSubTotal[k,i+1])=="N"),cOk[3],cOk[7]),cOk[8]))})
      endif
      lMozeL:=.f.
    next
    if !glNeSkipuj
    	SKIP 1
    endif
    loop
  endif

  lMozeL:=.t.

  if !glNeSkipuj; SKIP 1; endif
 enddo  // kraj setnje po bazi

 if nSlogova!=nil
 	Postotak(-1,,,,,.f.)
 endif

 // na posljednjoj stranici prikazi interni subtotal ako treba
 // ----------------------------------------------------------
 if xTot[2]!=nil
   xTot:=EVAL(bSubTot)
   if lMozeL
    i:=0; QOUT(cLM2+cOk[6])
    AEVAL(aPom,{|x| ++i,;
     QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,IF(!x[3].and.!aPom[i+1,3],cOk[10],cOk[7]),cOk[8]))})
   endif
   for j:=1 to LEN(aPrSum)
     i:=0; cPom:=""
     AEVAL(aKol,{|x| ++i,;
      cPom+=IF(x[3],STR(nSubTot[aPrSum[j]][i],x[5],x[6]),SPACE(x[5]))+IF(i<nKol,IF(!aPom[i,3].and.!aPom[i+1,3]," ",cOk[5]),cOk[12])},(aPrSum[j]-1)*nKol+1,nKol)
     xPom:=IF(j==LEN(aPrSum),xTot[2],SPACE(LEN(xTot[2])))
     QOUT(cLM2+cOk[12]+STRTRAN(cPom,SPACE(LEN(xPom)),xPom,1,1))
   next
 endif

 if !lPrenos
   // zavrsi posljednju stranicu: bez sumiranja
   // -----------------------------------------
   i:=0; QOUT(cLM2+cOk[9])
   AEVAL(aPom,{|x| ++i, QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,cOk[10],cOk[11]))})
   if (nStr>=0 .and. lOstr)
     if gPrinter!="R"
       do while prow()<gnRedova-2; QOUT(); enddo
       xPom:=STR(nStr,3)+". strana"
       QOUT(cLM+PADC(xPom,nDReda-nOdvoji))
     endif
     gPFF(); SETPRC(0,0)
     if !(bZagl==nil)
       EVAL(bZagl)
     endif
   endif
 else
   // zavrsi posljednju stranicu: prikazi sumiranje
   // ---------------------------------------------
   i:=0; QOUT(cLM2+cOk[6])
   AEVAL(aPom,{|x| ++i,;
    QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,IF(!x[3].and.!aPom[i+1,3],IF(xTot[1],cOk[2],cOk[10]),cOk[7]),cOk[8]))})
   for j:=1 to LEN(aPrSum)
    i:=0; cPom:=""
    AEVAL(aKol,{|x| ++i,;
     cPom+=IF(x[3],STR(nSuma[aPrSum[j]][i],x[5],x[6]),SPACE(x[5]))+IF(i<nKol,IF(!aPom[i,3].and.!aPom[i+1,3]," ",cOk[5]),cOk[12])},(aPrSum[j]-1)*nKol+1,nKol)
    QOUT(cLM2+cOk[12]+IF(j==LEN(aPrSum),STRTRAN(cPom,SPACE(LEN(cTek2)),cTek2,1,1),cPom))
   next
   i:=0; QOUT(cLM2+cOk[9])
   AEVAL(aPom,{|x| ++i,;
    QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,IF(!x[3].and.!aPom[i+1,3],cOk[2],cOk[10]),cOk[11]))})
 endif

return nSuma
*}


function MDDReda(nZnak,lA4papir)
*{
nZnak=IF(lA4papir=="4",nZnak*2-1,IF(lA4papir=="L4",nZnak*1.4545-1,nZnak))
return INT(IF(nZnak<161,160,IF(nZnak<193,192,IF(nZnak<275,274,320)))/IF(lA4papir=="4",2,IF(lA4papir=="L4",1.4545,1)))

return
*}


function StZaglavlje(cImeFajla,cPutanja,cTxt1,cTxt2,cTxt3,cTxt4,cTxt5,cTxt6,cTxt7,cTxt8)

local cZag:="",i:=0,cLin:="",cNLin:=""

if "U" $ TYPE("gnTMarg"); gnTMarg:=0; endif
 if ctxt1==nil
    cTxt1:=""
 endif
 if ctxt2==nil
    cTxt2:=""
 endif
 if ctxt3==nil
    cTxt3:=""
 endif
 if ctxt4==nil
    cTxt4:=""
 endif
 if ctxt5==nil
    cTxt5:=""
 endif
 if ctxt6==nil
    cTxt6:=""
 endif
 if cTxt7==nil
    cTxt7:=""
 endif
 if cTxt8==nil
    cTxt8:=""
 endif

if empty(cImeFajla)
   for i:=1 to gnTMarg
   	QOUT()
   next
else
  private nHZ:=fopen(cPutanja+cImeFajla)
  private cBuf:="",nRead:=0
  do while .t.
      //nRead:=fread(nHZ,@cBuf,50)
      cBuf = FReadLn( nHZ, 1, 1000 )
      // djokeri #1#, #2#, #3#, #4#, #5# #6#
      if "#1#"$cBuf .and. VALTYPE(cTxt1)=="A"
        cBuf := strtran(strtran(strtran(strtran(strtran(strtran(strtran(cBuf,"#2#",ctxt2),"#3#",ctxt3),"#4#",ctxt4),"#5#",ctxt5),"#6#",ctxt6), "#7#", cTxt7), "#8#", ctxt8)
        // koji je to red
        cLin := DajRed(cBuf,"#1#")
        // napravimo string cNLin koji treba ubaciti
        for i:=1 to LEN(cTxt1)
          cNLin += STRTRAN(cLin,"#1#",cTxt1[i])
        next
        // taj red tj.cLin zamijeniti redovima koje treba ubaciti
        cBuf := strtran(cBuf,cLin,cNLin)
        QQOUT(cBuf)
      else
        QQOUT(strtran(strtran(strtran(strtran(strtran(strtran(strtran(strtran(cBuf,"#1#",ctxt1),"#2#",ctxt2),"#3#",ctxt3),"#4#",ctxt4),"#5#",ctxt5),"#6#",ctxt6),"#7#", ctxt7), "#8#", ctxt8) )
      endif
      cZag+=cBuf
      if cBuf==""
      	exit
      endif
enddo
setprc(prow()+nPodStr(NRED,cZag),pcol())
  ?
  fclose(nHZ)
 endif
return


function nPodStr(cPod,cStr)
*{
local nVrati:=0,nPod:=LEN(cPod)
 for i:=1 to LEN(cStr)+1-nPod
  if SUBSTR(cStr,i,nPod)==cPod; nVrati++; endif
 next
return nVrati
*}

function PrekSaEsc()
*{
Msg("Priprema izvjestaja prekinuta tipkom <Esc>!",2)
return .f.
*}

function NaSljedStranu(lMozeL,lPrenos,cLM2,cOk,aPom,nKol,nStr,cLM,nDReda,nOdvoji,aPrSum,aKol,nSuma,cTek3,bZagl,cNaslov,aPrZag,cTek1,xTot)
*{
  local i, xPom, j, cPom
    lMozeL:=.f.
    if !lPrenos
      i:=0; QOUT(cLM2+cOk[9])
      AEVAL(aPom,{|x| ++i,QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,cOk[10],cOk[11]))})
      if gPrinter!="R"
        QOUT(); QOUT(); xPom:=STR(nStr,3)+". strana"
        QOUT(cLM+PADC(xPom,nDReda-nOdvoji))
      endif
    else
      i:=0; QOUT(cLM2+cOk[6])
      AEVAL(aPom,{|x| ++i,;
       QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,IF(!x[3].and.!aPom[i+1,3],cOk[10],cOk[7]),cOk[8]))})
      for j:=1 to LEN(aPrSum)
        i:=0; cPom:=""
        AEVAL(aKol,{|x| ++i,;
         cPom+=IF(x[3],STR(nSuma[aPrSum[j]][i],x[5],x[6]),SPACE(x[5]))+IF(i<nKol,IF(!aPom[i,3].and.!aPom[i+1,3]," ",cOk[5]),cOk[12])},(aPrSum[j]-1)*nKol+1,nKol)
        xPom:=IF(j==LEN(aPrSum),cTek3+STR(nStr,3)+":",SPACE(LEN(cTek3)+4))
        QOUT(cLM2+cOk[12]+STRTRAN(cPom,SPACE(LEN(xPom)),xPom,1,1))
      next
      i:=0; QOUT(cLM2+cOk[9])
      AEVAL(aPom,{|x| ++i,;
       QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,IF(!x[3].and.!aPom[i+1,3],cOk[2],cOk[10]),cOk[11]))})
    endif
    gPFF(); SETPRC(0,0)
    if !(bZagl==nil)
      EVAL(bZagl)
    endif
    if cNaslov!=nil
      QOUT(cLM2+cOk[1]+REPLICATE(cOk[2],nDReda-nOdvoji-2)+cOk[4])
      QOUT(cLM2+cOk[12]+SPACE(nDReda-nOdvoji-2)+cOk[12])
      QOUT(cLM2+cOk[12]+PADC(ALLTRIM(cNaslov),nDReda-nOdvoji-2)+cOk[12])
      QOUT(cLM2+cOk[12]+SPACE(nDReda-nOdvoji-2)+cOk[12])
    endif
    i:=0; QOUT(cLM2+IF(cNaslov!=nil,cOk[6],cOk[1]))
    AEVAL(aPom,{|x| ++i,QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,cOk[3],IF(cNaslov!=nil,cOk[8],cOk[4])))})
    for j:=1 to LEN(aPrZag)
      i:=0; QOUT(cLM2+cOk[12])
      AEVAL(aKol,{|x| ++i,QQOUT(PADC(x[1],x[5])+IF(i<nKol,cOk[5],cOk[12]))},(aPrZag[j]-1)*nKol+1,nKol)
    next
    if !lPrenos
       i:=0; QOUT(cLM2+cOk[6])
       AEVAL(aPom,{|x| ++i,QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,cOk[7],cOk[8]))})
    else
       i:=0; QOUT(cLM2+cOk[6])
       AEVAL(aPom,{|x| ++i,;
        QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,IF(!x[3].and.!aPom[i+1,3],cOk[10],cOk[7]),cOk[8]))})
       for j:=1 to LEN(aPrSum)
         i:=0; cPom:=""
         AEVAL(aKol,{|x| ++i,;
          cPom+=IF(x[3],STR(nSuma[aPrSum[j]][i],x[5],x[6]),SPACE(x[5]))+IF(i<nKol,IF(!aPom[i,3].and.!aPom[i+1,3]," ",cOk[5]),cOk[12])},(aPrSum[j]-1)*nKol+1,nKol)
         xPom:=IF(j==LEN(aPrSum),cTek1+STR(nStr,3)+":",SPACE(LEN(cTek1)+4))
         QOUT(cLM2+cOk[12]+STRTRAN(cPom,SPACE(LEN(xPom)),xPom,1,1))
       next
        i:=0; QOUT(cLM2+cOk[6])
        AEVAL(aPom,{|x| ++i,;
         QQOUT(REPLICATE(cOk[2],x[2])+IF(i<nKol,IF(!x[3].and.!aPom[i+1,3],IF(xTot[1],cOk[2],cOk[3]),cOk[7]),cOk[8]))})
    endif
    ++nStr
return
*}

static function StStavku(aKol,xPom,i,nKol,cOk)
*{
if xPom==nil
   QQOUT(SPACE(aKol[i,5]))
 elseif aKol[i,4]="N"
   if VALTYPE(xPom)!="N" .or. ROUND(xPom,aKol[i,6])==0 .and. RIGHT(aKol[i,4],1)=="-"
     QQOUT(SPACE(aKol[i,5]))
   else
     if gbFIznos!=nil
       QQOUT( EVAL( gbFIznos,;
                    xPom,;
                    aKol[i,5],;
                    aKol[i,6] );
            )
     else
       QQOUT(STR(xPom,aKol[i,5],aKol[i,6]))
     endif
   endif
 elseif aKol[i,4]=="C"
   QQOUT(PADR(xPom,aKol[i,5]))
 elseif aKol[i,4]=="D"
   QQOUT(PADC(DTOC(xPom),aKol[i,5]))
 endif
 QQOUT(IF(i<nKol,cOk[5],cOk[12]))

return
*}

function DajRed(tekst,kljuc)
*{
local cVrati:="", nPom:=0, nPoc:=0
  nPom := AT( kljuc , tekst )
  nPoc := RAT( NRED , LEFT(tekst,nPom) )
  nKraj:= AT(  NRED , SUBSTR(tekst,nPom) )
  nPoc := IF(nPoc==0,1,nPoc+2)
  nKraj:= IF(nKraj==0,LEN(tekst),nPom-1+nKraj+1)
  cVrati:=SUBSTR(tekst,nPoc,nKraj-nPoc+1)
return cVrati
*}

function WhileEvent(nValue, nCnt)
*{

/*!
if (nCnt==nil)
  nCnt:=reccount()
endif
ShowKorner(nValue, 5, nCnt)
*/

return
*}

