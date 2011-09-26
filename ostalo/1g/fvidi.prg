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


/*! \fn VidiFajl(cImeF, aLinFiks, aKolFiks)
 *  \brief Pregled tekstualnog fajla
 *
 *
 * aLinFiks se zadaje ako treba fiksirati dio fajla (npr.zaglavlje tabele)
 * To je niz od dva elementa (prvi el.je broj prvog reda u fajlu, a drugi el.
 * je broj redova koje treba fiksirati)
 *
 * aKolFiks se zadaje ako treba fiksirati dio fajla (npr.kolonu u tabeli)
 * To je niz od tri elementa (prvi el.je broj prve kolone u fajlu, drugi el.
 * je broj kolona koje zaredom, pocevsi od prve zadane, treba fiksirati, a
 * treci el. predstavlja broj reda pocevsi od kojeg se uzima za prikaz
 * fiksirana kolona)
 *
 * \todo Razbiti ogromni CASE na pojedinacne funkcije
 */

function VidiFajl(cImeF, aLinFiks, aKolFiks)
*{

local nDF:=VelFajla(cImeF,0)
local nKol:=1
local nOfset, nOf1l:=0, nZnak
local lNevazna:=.f.
local nRed:=1
local lSkrol:=.f.
local nURed:=BrLinFajla(cImeF),cKom,nLin:=21,nFRed:=0,nFRed2:=0
local cFajlPRN:="PRN777.TXT", nOfM1:=0 , nOfM2:=0
local nPrviRed:=1
local aZagFix:={}
local nPrvaKol:=0
local nUKol:=80
local aRedovi
local lPrintReady

private cTrazi:=SPACE(30)
private cMarkF:="1"
private cVStamp:="1"
private nStrOd:=1
private nStrDo:=1

CSETATMUPA(.t.)

if aLinFiks!=nil
   nPrviRed += aLinFiks[2]
   aZagFix  := DioFajlaUNiz( cImeF , aLinFiks[1] , aLinFiks[2] , nURed )
endif
if aKolFiks!=nil
   nPrvaKol := aKolFiks[2]
   nUKol    := 80 - aKolFiks[2]
endif

aRedovi:=ARRAY(nLin+1-nPrviRed,2)
ShemaBoja(gShemaVF)
@ 22,0 SAY "Pomjeranje slike.......<>.<>.<>.<"+CHR(26)+">."+;
            "<PgUp>.<PgDn>.<Ctrl>+<PgUp>.<Ctrl>+<PgDn>" COLOR cbokvira

@ 23,0 SAY "N.fajla:<Ctrl>+<N> Stampa:<Ctrl>+<P>,<Alt>+<P> Trazi:<F>/<F3> Marker:<Ctrl>+<J> " COLOR cbnaslova
@ 24,0 SAY "Pr.fajla:<Ctrl>+<O>     FAJL:                 KOLONA:         RED:              " COLOR cbnaslova
do while .t.
  nOfset:=nOf1l
  if !lNevazna
    @ 24,54 SAY STR(nKol,3)+"/321" COLOR cbokvira
    @ 24,67 SAY PADR(ALLTRIM(STR(nRed,6))+"/"+ALLTRIM(STR(nURed,6)),13) COLOR cbokvira
    @ 24,30 SAY PADR(AFTERATNUM(SLASH,cImeF),15) COLOR cbokvira
    if LEN(aZagFix)>0
      for i:=1 to LEN(aZagFix)
        if nPrvaKol>0
          @ i,       0 SAY SUBSTR(PADR(aZagFix[i],400),aKolFiks[1],nPrvaKol) COLOR "W+/B"
          @ i,nPrvaKol SAY SUBSTR(PADR(aZagFix[i],400),nKol+IF(aKolFiks[1]>1,0,nPrvaKol),nUKol) COLOR "W+/B"
        else
          @ i,0 SAY SUBSTR(PADR(aZagFix[i],400),nKol,80) COLOR "W+/B"
        endif
      next
    endif
    for i:=1 to nLin+1-nPrviRed
      if !lSkrol
        aPom:=SljedLin(cImeF,nOfset)
        aRedovi[i]:=aPom
      else
        aPom:=aRedovi[i]
      endif
      if nPrvaKol>0
        if LEN(aKolFiks)>3
          cPom77:=aKolFiks[4]
          @ i-1+nPrviRed,0 SAY IF(!&cPom77,SPACE(nPrvaKol),SUBSTR(PADR(aRedovi[i,1],400),aKolFiks[1],nPrvaKol)) COLOR IF(nRed+i-1==nFRed,"W+/B",IF(nRed+i-1==nFRed2,"W+/R",cbteksta))
        else
          @ i-1+nPrviRed,0 SAY IF(nRed+i-1<aKolFiks[3],SPACE(nPrvaKol),SUBSTR(PADR(aRedovi[i,1],400),aKolFiks[1],nPrvaKol)) COLOR IF(nRed+i-1==nFRed,"W+/B",IF(nRed+i-1==nFRed2,"W+/R",cbteksta))
        endif
        @ i-1+nPrviRed,nPrvaKol SAY SUBSTR(PADR(aRedovi[i,1],400),nKol+IF(aKolFiks[1]>1,0,nPrvaKol),nUKol) COLOR IF(nRed+i-1==nFRed,"W+/B",IF(nRed+i-1==nFRed2,"W+/R",cbteksta))
      else
        @ i-1+nPrviRed,0 SAY SUBSTR(PADR(aRedovi[i,1],400),nKol,80) COLOR IF(nRed+i-1==nFRed,"W+/B",IF(nRed+i-1==nFRed2,"W+/R",cbteksta))
      endif
      nOfset:=aPom[2]
    next
  endif
  lNevazna:=.f.
  lSkrol:=.f.
  
  KeyboardEvent(@nZnak)
  
  do CASE
    CASE nZnak==32         // svicuj zamrzavanje kolone
       if nUKol<80
         nPrvaKol := IF(nPrvaKol>0,0,aKolFiks[2])
       endif
    CASE nZnak==K_ESC
       exit
    CASE nZnak==K_CTRL_J  // pomjeri marker
       
       nPom1:=nFRed
       nPom2:=nFRed2
       nPom3:=nURed
       if VarEdit({{"Pozicija 1.(plavog) markera (broj reda)","nPom1","nPom1<=nPom3.and.nPom1>=0","9999999",},;
                   {"Pozicija 2.(crvenog) markera (broj reda)","nPom2","nPom2<=nPom3.and.nPom2>=0","9999999",}},10,1,15,78,;
                             "POMJERANJE MARKERA TEKSTA U FAJLU",gShemaVF)
         nPomRed:=1; nOfPom:=0; nOfM1:=0; nOfM2:=0
         do while nPomRed<=MAX(nPom1,nPom2) .and. nPomRed<=nURed
           aPom:=SljedLin(cImeF,nOfPom)
           ++nPomRed
           nOfPom:=aPom[2]
           if nPomRed==nPom1
             nOfM1:=nOfPom
           elseif nPomRed==nPom2
             nOfM2:=nOfPom
           endif
         enddo
         nFRed  := nPom1
         nFRed2 := nPom2
       endif
       
    CASE upper(chr(nZnak))=='F' .or. nZnak==K_F3  // trazi tekst
       if nZnak==K_F3 .or.;
          VarEdit({ ;
                    {"Tekst","cTrazi",,"@!",},;
                    {"Oznaciti nadjeno markerom (1-plavi,2-crveni)","cMarkF","cMarkF$'12'","",};
                   },10,10,15,69,;
                             "PRETRAGA TEKSTA U FAJLU",gShemaVF)
         aStaro:={nOf1l,nRed}
         if cMarkF=="1" .and. upper(chr(nZnak))=='F'
           nFRed:=0
         elseif upper(chr(nZnak))=='F'
           nFRed2:=0
         endif
         if upper(chr(nZnak))=='F' .or.;
            cMarkF=="1" .and. PripadaNInt(nFRed,nRed,nRed+19) .or.;
            cMarkF=="2" .and. PripadaNInt(nFRed2,nRed,nRed+19)
               for i:=IF(nZnak==K_F3,IF(cMarkF=="1",nFRed,nFRed2)-nRed+2,1) to nLin+1-nPrviRed
                 if (nFPoz:=AT(TRIM(cTrazi),UPPER(aRedovi[i,1])))>0
                   if cMarkF=="1"
                     nFRed:=nRed+i-1
                     nOfM1:=IF(i==1,nOf1l,aRedovi[i-1,2])
                   else
                     nFRed2:=nRed+i-1
                     nOfM2:=IF(i==1,nOf1l,aRedovi[i-1,2])
                   endif
                   if nFPoz<40
                     nKol:=1
                   elseif nFPoz>360
                     nKol:=321
                   else
                     nKol:=10*INT((nFPoz-40)/10)+1
                   endif
                   lSkrol:=.t.
                   exit
                 endif
               next
         endif
         do while !lSkrol .and. nRed<nURed-nLin+1-1+nPrviRed
           ++nRed
           aPom:=SljedLin(cImeF,aRedovi[nLin+1-nPrviRed,2])
           nOf1l:=aRedovi[1,2]; ADEL(aRedovi,1); aRedovi[nLin+1-nPrviRed]:=aPom
           if nZnak==K_F3 .and.;
              IF( cMarkF=="1" , nFRed>=nRed+nLin-1+1-nPrviRed , nFRed2>=nRed+nLin-1+1-nPrviRed )
             loop
           endif
           if (nFPoz:=AT(TRIM(cTrazi),UPPER(aRedovi[nLin+1-nPrviRed,1])))>0
             lSkrol:=.t.
             if cMarkF=="1"
               nFRed:=nRed+nLin-1+1-nPrviRed
               nOfM1:=aRedovi[nLin-1+1-nPrviRed,2]
             else
               nFRed2:=nRed+nLin-1+1-nPrviRed
               nOfM2:=aRedovi[nLin-1+1-nPrviRed,2]
             endif
             if nFPoz<40
               nKol:=1
             elseif nFPoz>360
               nKol:=321
             else
               nKol:=10*INT((nFPoz-40)/10)+1
             endif
           endif
         enddo
         if IF(cMarkF=="1",nFRed==0,nFRed2==0)  // vrati se na staru poziciju
           nOf1l:=aStaro[1]; nRed:=aStaro[2]
           lSkrol:=.f.
           Msg("Tekst nije nadjen!",4)
         endif
       endif

    CASE nZnak==K_ALT_F1  // spremi tekucu i/ili vise baza na diskete
       // na koji disk
       cDisk:="A"
       Box(,3,77)
        @ m_x+1,m_y+2 SAY "Izvrsiti prenos na disk A/B ?" GET cDisk pict "@!" valid cDisk>="A" .and.  diskprazan(cDisk)
        READ
       BoxC()

       if LASTKEY()!=K_ESC

       // koje baze
       if aDefSpremBaz!=nil .and. !EMPTY(aDefSpremBaz)     // vise njih
         nTekArr:=SELECT()
         for i:=1 to LEN(aDefSpremBaz)
           SELECT (aDefSpremBaz[i,1])
           cPomFilt:=aDefSpremBaz[i,4]
           PushWA()
           SET FILTER TO
           SET FILTER to &cPomFilt
           GO TOP
           MsgO("Kopiram '"+ALIAS(SELECT())+".DBF' u '"+cDisk+":\_"+ALIAS(SELECT())+".DBF"+"' !")
            CurToExtBase(cDisk+":\_"+ALIAS(SELECT())+".DBF")
           MsgC()
           SET FILTER TO
           PopWA()
         next
         SELECT (nTekArr)
       endif

       // odradi tekucu
       ccPom:=cDisk+":\_"+ALIAS(SELECT())
       PushWA(); GO TOP
       MsgO("Kopiram '"+ALIAS(SELECT())+".DBF' u '"+cDisk+":\_"+ALIAS(SELECT())+".DBF"+"' !")
        CurToExtBase(cDisk+":\_"+ALIAS(SELECT())+".DBF")
       MsgC()
       SET FILTER TO
       PopWA()

       // zapisi skript fajl

       MsgBeep("Kopiranje zavrseno!")
       endif  // LASTKEY()!=K_ESC

    CASE nZnak==K_CTRL_O  
       // ucitaj fajl
       nPom:=RAT(SLASH,cImeF)
       do while .t.
         ccPom:=PADR(SUBSTR(cImeF,nPom+1),12)
         if VarEdit({{"Fajl","ccPom",,"@!",}},10,20,14,59,;
                               "NAZIV FAJLA ZA PREGLED",gShemaVF)
           ccPom:=ALLTRIM(LEFT(cImeF,nPom)+ccPom)
           if FILE(ccPom)
             cImeF:=ccPom
             nPom:=RAT(SLASH,cImeF)
             nDF:=VelFajla(cImeF,0); nKol:=1; nOf1l:=0; lNevazna:=.f.
             nRed:=1; lSkrol:=.f.; nURed:=BrLinFajla(cImeF)
             aRedovi:=ARRAY(nLin+1-nPrviRed,2)
             exit
           else
             Msg("Zadani fajl ne postoji!",4)
           endif
         else
           exit
         endif
       enddo
    CASE (nZnak==K_LEFT .and. nKol>1)
       lSkrol:=.t.
       nKol-=10
    CASE (nZnak==K_RIGHT.and.nKol<321)
       lSkrol:=.t.
       nKol+=10
    CASE nZnak==K_UP.and.nRed>1
       lSkrol:=.t.
       aPom:=PrethLin(cImeF,nOf1l)
       --nRed
       AINS(aRedovi,1)
       aRedovi[1]:={aPom[1],nOf1l}
       nOf1l:=IF(aPom[2]<=0,0,aPom[2])
    CASE nZnak==K_DOWN.and.nRed<nURed-nLin+1-1+nPrviRed
       lSkrol:=.t.
       ++nRed
       aPom:=SljedLin(cImeF,aRedovi[nLin+1-nPrviRed,2])
       nOf1l:=aRedovi[1,2]
       ADEL(aRedovi,1)
       aRedovi[nLin+1-nPrviRed]:=aPom
    CASE nZnak==K_PGUP.and.nRed>1
       if nRed-nLin-1+nPrviRed>1
         lSkrol:=.t.
         for i:=1 to nLin+1-nPrviRed
           aRedovi[nLin+1+1-nPrviRed-i,2]:=IF(i==1,nOf1l,aPom[2])
           aPom:=PrethLin(cImeF,nOf1l)
           nOf1l:=aPom[2]
           aRedovi[nLin+1+1-nPrviRed-i,1]:=aPom[1]
         next
         nRed-=nLin+1-nPrviRed
         if nOf1l<=0; nOf1l:=0; nRed:=1; endif
       else
         nRed:=1
         nOf1l:=0
       endif
    CASE nZnak==K_PGDN.and.nRed<nURed-nLin+1-1+nPrviRed
       if nRed+nLin+1-nPrviRed<=nUred-nLin+1-1+nPrviRed
          nOf1l:=aRedovi[nLin+1-nPrviRed,2]
          nRed+=nLin+1-nPrviRed
       else
          nOf1l:=aRedovi[nURed-nLin+1-1+nPrviRed-nRed,2]
          nRed:=nURed-nLin+1-1+nPrviRed
       endif
    CASE ( nZnak==K_CTRL_PGUP .or. nZnak==K_HOME ) .and. nRed>1
       nOf1l:=0; nRed:=1
    CASE ( nZnak==K_CTRL_PGDN .or. nZnak==K_END ) .and. nURed>nLin+1-nPrviRed
       nOf1l:=nDF+2
       for i:=1 to IF(FILESTR(cImeF,2,nDF-2)!=NRED,nLin+1-nPrviRed,nLin+1+1-nPrviRed)
         if nOf1l>0
           aPom:=PrethLin(cImeF,nOf1l)
           nOf1l:=aPom[2]
         endif
       next
       nRed:=nURed-nLin+1-1+nPrviRed
    CASE nZnak==K_CTRL_N
       nPom:=RAT(SLASH,cImeF)
       do while .t.
         ccPom:=PADR(SUBSTR(cImeF,nPom+1),12)
         if VarEdit({{"Fajl","ccPom",,"@!",}},10,20,14,59,;
                               "PROMJENA NAZIVA FAJLA",gShemaVF)
           ccPom:=ALLTRIM(LEFT(cImeF,nPom)+ccPom)
           if RENAMEFILE(cImeF,ccPom)==0
             cImeF:=ccPom
             nPom:=RAT(SLASH,cImeF)
             exit
           endif
         else
           exit
         endif
       enddo
    case gPrinter="R" .and. (nZnak=K_CTRL_P .or. nZnak==K_ALT_P)
       
       if gPDFPrint == "X" .and. goModul:oDataBase:cName=="FAKT"
       	if Pitanje(,"Print u PDF/PTXT", "D") == "D"
		PDFView(cImeF)
	else
		Ptxt(cImeF)
	endif
       elseif gPDFPrint == "D" .and. goModul:oDataBase:cName == "FAKT"
       	PDFView(cImeF)
       else
       	Ptxt(cImeF)
       endif

    case nZnak==K_ALT_S
    	SendFile(cImeF)
	
    case nZnak==K_CTRL_P
       
       if nFRed>0 .and. nFRed2>0   // oba markera
         if VarEdit({{"1-sve, 2-dio izmedju markera, 3-sve ispod mark.1, 4-sve ispod mark.2)","cVStamp","cVStamp$'1234'","@!",}},10,1,14,78,;
                               "IZBOR OBLASTI ZA STAMPANJE",gShemaVF)
         else
           loop
         endif
       elseif nFRed>0       // marker 1 (plavi)
         if VarEdit({{"1-sve,  3-sve ispod markera 1","cVStamp","cVStamp$'13'","@!",}},10,1,14,78,;
                               "IZBOR OBLASTI ZA STAMPANJE",gShemaVF)
         else
           loop
         endif
       elseif nFRed2>0      // marker 2 (crveni)
         if VarEdit({{"1-sve,  4-sve ispod markera 2","cVStamp","cVStamp$'14'","@!",}},10,1,14,78,;
                               "IZBOR OBLASTI ZA STAMPANJE",gShemaVF)
         else
           loop
         endif
       else // citav fajl
         cVStamp:="1"
       endif

       if cVStamp=="1"
         cFajlPRN:=ALLTRIM(cImeF)
       else
         cFajlPRN:="PRN777.TXT"
         if FILE( cFajlPRN )
           FERASE( cFajlPRN )
         endif
         nOfPoc := IF( cVStamp=="2" , MIN(nOfM1,nOfM2) ,;
                   IF( cVStamp=="3" , nOfM1 ,;
                                      nOfM2 ) )
         nOfDuz := IF( cVStamp=="2" , ABS(nOfM1-nOfM2)+1 ,;
                   IF( cVStamp=="3" , nDF-nOfM1+1 ,;
                                      nDF-nOfM2+1 ) )
         nH := FCREATE( cFajlPRN , 0 )
         do while nOfDuz>0
           cPomF := FILESTR( cImeF , IF(nOfDuz>=400,400,nOfDuz) , nOfPoc )
           FWRITE( nH , cPomF )
           nOfPoc+=400
           nOfDuz-=400
         enddo
         FWRITE( nH , NRED )
         FCLOSE( nH )
       endif

       cKom:="LPT"+gPPort
       if gPPort>"4"
	 lPrintReady:=.t.
         if gPPort=="5"
           cKom:="LPT1"
         elseif gPPort=="6"
           ckom:="LPT2"
         elseif gPPort=="7"
           cKom:="LPT3"
         endif
       else
          lPrintReady:=.f.
       endif

       //cPom:=cFajlPRN+" "+cKom
       do while .t.
         if lPrintReady .or. PRINTREADY(VAL(gpport))
           MsgO("Sacekajte, stampanje u toku...")
           filecopy(cFajlPRN, cKom)
           MsgC()
           exit
         endif
         if Pitanje(,"Stampac nije spreman! Zelite li da probate ponovo?","N")!="D"
           exit
         endif
       enddo
    CASE nZnak==K_ALT_P
       if VarEdit({ {"Stampati od stranice br.","nStrOd","nStrOd>0","9999",},;
                    {"         do stranice br.","nStrDo","nStrDo>=nStrOd","9999",} },10,1,15,78,;
                             "IZBOR STRANICA ZA STAMPANJE",gShemaVF)
       else
         loop
       endif

       cFajlPRN:="PRN777.TXT"
       if FILE( cFajlPRN )
         FERASE( cFajlPRN )
       endif

       aPom   := VratiOfset( gPFF, nStrOd-1, nStrDo, cImeF, nDF)
       nOfPoc := aPom[1]
       nOfDuz := 1+aPom[2]-aPom[1]

       nH := FCREATE( cFajlPRN , 0 )
       FWRITE( nH , gPINI )
       do while nOfDuz>0
         cPomF := FILESTR( cImeF , IF(nOfDuz>=400,400,nOfDuz) , nOfPoc )
         FWRITE( nH , cPomF )
         nOfPoc+=400
         nOfDuz-=400
       enddo
       FWRITE( nH , NRED )
       FCLOSE( nH )

       cKom:="LPT"+gPPort
       if gpport>"4"
         if gpport=="5"
           cKom:="LPT1"
         elseif gpport=="6"
           ckom:="LPT2"
         elseif gpport=="7"
           cKom:="LPT3"
         endif
       endif
       //cPom:=cFajlPRN+" "+cKom
       do while .t.
         if PRINTREADY(VAL(gpport))
           MsgO("Sacekajte, stampanje u toku...")
           //!copy &cPom
           filecopy(cFajlPRN,cKom)
           MsgC()
           exit
         endif
         if Pitanje(,"Stampac nije spreman! Zelite li da probate ponovo?","N")!="D"
           exit
         endif
       enddo
    OTHERWISE
       goModul:GProc(nZnak)
       lNevazna:=.t.
  ENDCASE
 enddo
return
*}


function SljedLin(cFajl,nPocetak)
*{
local cPom,nPom
cPom:=FILESTR(cFajl,400,nPocetak)
nPom:=AT(NRED,cPom)
if nPom==0; nPom:=LEN(cPom)+1; endif
return {LEFT(cPom,nPom-1),nPocetak+nPom+1}    // {cLinija,nPocetakSljedece}
*}

function PrethLin(cFajl,nKraj)
*{ 
 local nKor:=400,cPom,nPom
 if nKraj-nKor-2<0; nKor:=nKraj-2; endif
 cPom:=FILESTR(cFajl,nKor,nKraj-nKor-2)
 nPom:=RAT( NRED ,cPom)
return IF( nPom==0, { cPom, 0}, { SUBSTR(cPom,nPom+2), nKraj-nKor+nPom-1} )
                               // {cLinija,nNjenPocetak}

return
*}

function BrLinFajla(cImeF)
*{ 
 local nOfset:=0,nSlobMem:=0,cPom:="",nVrati:=0
 if FILESTR(cImeF,2,VelFajla(cImeF)-2)!= NRED ; nVrati:=1; endif
 do while LEN(cPom)>=nSlobMem
  nSlobMem:=MEMORY(1)*1024-100
  cPom:=FILESTR(cImeF,nSlobMem,nOfset)
  nOfset=nOfset+nSlobMem-1
  nVrati=nVrati+NUMAT( NRED ,cPom)
 enddo
return nVrati
*}

function VelFajla(cImeF,cAttr)
*{
 local aPom:=DIRECTORY(cImeF,cAttr)
return if (!EMPTY(aPom),aPom[1,2],0)
*}




function PripadaNInt(nBroj,nOd,nDo,lSaKrajnjim)
*{
local lVrati:=.f.
  if lSaKrajnjim==nil; lSaKrajnjim:=.t.; endif
  if lSaKrajnjim .and. nBroj>=nOd .and. nBroj<=ndo .or.;
                        nBroj>nOd .and. nBroj<nDo
    lVrati:=.t.
  endif
return lVrati
*}


function DioFajlaUNiz(cImeF,nPocRed,nUkRedova,nUkRedUF)
*{  
  local aVrati:={},nTekRed:=0,nOfset:=0,aPom:={}
  if nUkRedUF==nil; nUkRedUF:=BrLinFajla(cImeF); endif
  for nTekRed:=1 to nUkRedUF
    aPom:=SljedLin(cImeF,nOfset)
    if nTekRed>=nPocRed .and. nTekRed<nPocRed+nUkRedova
      AADD(aVrati,aPom[1])
    endif
    if nTekRed>=nPocRed+nUkRedova-1
      exit
    endif
    nOfset:=aPom[2]
  next
return aVrati
*}

function VratiOfset(cTrazeniTekst,nOdPojavljivanja,nDoPojavljivanja,cUFajlu,nVelicinaFajla)
*{
 local nOfset:=0, aPom:={}, aOfsetOdDo:={0,0}, nPojava:=0
 do while nVelicinaFajla>nOfset            // ?? mozda treba >nOfset+1
   aPom:=SljedLin(cUFajlu,nOfset)
   if cTrazeniTekst $ aPom[1]
     nPojava++
   else
     nOfset:=aPom[2]
     loop
   endif
   if nOdPojavljivanja>0 .and. nOdPojavljivanja==nPojava
     aOfsetOdDo[1] := nOfset + AT(cTrazeniTekst,aPom[1]) + LEN(cTrazeniTekst) - 1
   endif
   if nDoPojavljivanja==nPojava
     nOfset := nOfset + AT(cTrazeniTekst,aPom[1]) + LEN(cTrazeniTekst) - 2
     exit
   endif
   nOfset:=aPom[2]
 enddo
 aOfsetOdDo[2] := nOfset
return aOfsetOdDo
*}

static function SendFile(cImeF)
*{
local cSendIme
local cLokacija
private cKom

cSendIme:=PADR("send",8)

if Pitanje(,"Izvrsiti snimanje izvjestaja - dokumenta ?","D")=="N"
	return
endif
cLokacija:=IzFmkIni("FMK","SendLokacija",ToUnix("c:\sigma\send"))
DirMak2(cLokacija)

Box(,3,60)
@ m_x+1, m_y+2 SAY "Lokacija: FmkIni_KumPath/[FMK]/SendLokacija "+cLokacija
@ m_x+3, m_y+2 SAY "Ime dokumenta je " GET cSendIme 
@ m_x+3, COL()+2 SAY ".txt"
READ
BoxC()
if (LASTKEY()==K_ESC)
	return 0
endif

AddBs(@cLokacija)
COPY FILE (cImeF) TO (cLokacija+ALLTRIM(cSendIme)+".txt")

cKom:="start "+cLokacija
RUN &cKom

return 1
*}
