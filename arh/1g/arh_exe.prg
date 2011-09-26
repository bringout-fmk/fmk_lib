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


///////// kompajlirati sa CLPM2 //////////////

// koristiti ini.ch iz ovog direktorija

#include "ini0.ch"

PUBLIC cVer:='01.35'

#ifdef C50
PUBLIC cNaslov:="ARH , 06.95-12.98"
#else
PUBLIC cNaslov:="ARH  CDX, 06.95-12.98"
#endif

#include "inibsbz.ch"
private Izbor:=1


// ovaj program trazi korisn.dbf u tekucem direktoriju !!!


@ 4,5 SAY ""
private opc[3]
Opc[1]:="1. arhiviranje podataka   "
Opc[2]:="2. povrat starih podataka"
Opc[3]:="9. kraj posla"
h[1]:=h[2]:=h[3]:=""

do while .t.
Izbor:=menu("fin",opc,Izbor,.f.)

   do case
     case Izbor==0
       EXIT
     case izbor == 1
         Arhi()
     case izbor == 2
         Resto()
     case izbor == 3
        Izbor:=0
   endcase

enddo


quite()
return

*********************
*********************
function Arhi()

#define NL chr(13)+Chr(10)
local cdisk,cime

cDisk:="A"
cIme:=dtoc(date())
cIme:=left(cime,2)+substr(cime,4,2)
cIme:=trim(left(ImeKorisn,3))+"_"+cIme

cKritPRIV:=space(100)
cKritKUM:=space(100)
cKritSIF:=space(100)

Box(,9,77,.f.)
 @ m_x+1,m_y+2 SAY "Izvrsiti arhiviranje na disk A/B ?" GET cDisk pict "@!" valid cDisk>="A" .and.  diskprazan(cDisk)
 @ m_x+2,m_y+2 SAY "Ime arhive ?" GET cIme pict "@!" valid parhiva(cdisk+":\"+cime+".arj")

 @ m_x+4,m_y+2 SAY "Direktorij PRIVATNI  :prazno - svi fajlovi, XX -nijedan fajl iz direktorija,"
 @ m_x+5,m_y+2 SAY "ili samo neki fajlovi (NPR:SUBAN.dbf NALOG.DBF)" GET cKritPriv pict "@!S25"

 @ m_x+6,m_y+2 SAY "Direktorij KUMULATIV :prazno - svi fajlovi, XX -nijedan fajl iz direktorija,"
 @ m_x+7,m_y+2 SAY "ili samo neki fajlovi (NPR:PRIPR.dbf)          " GET cKritKum pict "@!S25"

 @ m_x+8,m_y+2 SAY "Direktorij SIFRARNICI:prazno - svi fajlovi, XX -nijedan fajl iz direktorija"
 @ m_x+9,m_y+2 SAY "ili samo neki fajlovi (NPR:SUBAN.dbf NALOG.DBF)" GET cKritSIF pict "@!S25"

 read

BoxC(); ESC_RETURN 0
cIme:=alltrim(cime)

if empty(cKritKum)
 cKom1:="arj a -e -va "+cDisk+":\"+cIme+".arj "+trim(cDirRad)+"\*.db? "+trim(cDirRad)+"\*.fpt "+trim(cDirRad)+"\*.cdx"
else
 cKom1:="arj a -e -va "+cDisk+":\"+cIme+".arj "+trim(cDirRad)+" "+trim(cKritKum)
endif

if upper(PRIVPATH)==upper(cDirRad)+"\"
  cKom2:=""
else

 if empty(cKritPriv)
  //cKom2:="arj a -e -va "+cDisk+":\"+cIme+".brj "+PRIVPATH+"*.db? "
  cKom2:="arj a -e -va "+cDisk+":\"+cIme+".brj "+PRIVPATH+"*.db? "+PRIVPATH+"*.fpt "+PRIVPATH+"*.cdx"
 else
  cKom2:="arj a -e -va "+cDisk+":\"+cIme+".brj "+PRIVPATH+" "+ trim(cKritPriv)
 endif

endif

if (upper(SIFPATH)==upper(cDirRad)+"\") .or. (upper(SIFPATH)==upper(PRIVPATH))
  cKom3:=""
else
 if empty(cKritSif)
  // cKom3:="arj a -e -va "+cDisk+":\"+cIme+".crj "+SIFPATH+"*.db? "
  cKom3:="arj a -e -va "+cDisk+":\"+cIme+".crj "+SIFPATH+"*.db? "+SIFPATH+"*.fpt "+SIFPATH+"*.cdx"
 else
  cKom3:="arj a -e -va "+cDisk+":\"+cIme+".crj "+SIFPATH+" "+cKritSif
 endif
endif


nH:=fcreate("1com1.bat")
fwrite(nH,"@echo off"); fwrite(nH,NL)
fwrite(nH,cKom1); fwrite(nH,NL)
fwrite(nH,cKom2); fwrite(nH,NL)
fwrite(nH,cKom3); fwrite(nH,NL)
fclose(nH)
errorlevel(1)
quite()
return

function diskprazan(cDisk)
 if diskspace(asc(cDisk)-64)<15000
   Beep(4)
   Msg("Nema dovoljno prostora na ovom disku, stavite drugu disketu",6)
   return .f.
 endif
return .t.

function parhiva(cImeF)
 if file(cImeF)
   Beep(4)
   Msg("Vec postoji arhiva sa tim imenom na disketi",6)
   return .f.
 endif
return .t.

*********************
function Resto()
*
*********************
local cdisk,cime

cDisk:="A"
cIme:=dtoc(date())
cIme:=left(cime,2)+substr(cime,4,2)
cIme:=trim(left(ImeKorisn,3))+"_"+cIme

k_ime=Space(10)
k_sif=Space(6)

Box(,5,60,.f.)
 @ m_x+1,m_y+2 SAY "Ovom operacijom ce trenutno stanje podataka biti IZBRISANO"
 @ m_x+2,m_y+2 SAY "i ZAMJENJENO sa podacima koji se nalaze u ARHIVI !!!"
 @ m_x+4,m_y+2 SAY "Izvrsiti povrat podataka sa diska A/B ?" GET cDisk pict "@!"  valid cDisk>="A"
 read
BoxC(); ESC_RETURN 0

private aFajlovi:=directory(cDisk+":\*.?rj")
private opc:={}
for i:=1 to len(aFajlovi)
  aFajlovi[i,1]:=strtran(UPPER(aFajlovi[i,1]),".BRJ",".ARJ")
  aFajlovi[i,1]:=strtran(UPPER(aFajlovi[i,1]),".CRJ",".ARJ")
  if ASCAN(opc,aFajlovi[i,1])==0 // nejma ga u opcijama
    AADD(opc,padr(aFajlovi[i,1],15))
  endif
next

if len(opc)<1; return; endif


//O_KORISN
//Box(,1,50)
//do while .t.
 //@ m_x+1,m_y+2 SAY "Destinacija - korisnik:"  GET  k_ime   PICTURE "@!"
 //@ m_x+1,col()+2 SAY "Sifra:" GET k_sif PICTURE "@!"  COLOR Nevid
 //read ; ESC_BCR
 //seek k_ime
 //if found()
   //if CryptSC(k_sif)==sif
    //   exit
   //endif
 //endif
//enddo
//BoxC()

Beep(2)
if Pitanje(,"Nastaviti proceduru povrata podataka ?","N")=="N"
  closeret
endif

izb:=1
do while .t.
  Izb:=menu("afa",opc,izb,.f.)
  do case
     case izb=0
        exit
     case izb>0
        cIme:=trim(opc[izb])
        exit
  endcase
enddo
ESC_RETURN 0

//PRIVATE cDirRad:=trim(dirrad)
//PRIVATE cDirPriv:=trim(dirpriv)
//PRIVATE cDirSif:=trim(dirsif)
//use //korisn

//#define NL   chr(13)+chr(10)
cIme:=alltrim(cime)
nPos:=at(".",cIme)
cIme:=left(cIme,nPos)
cKom1:="arj e -jyaco -vv "+cDisk+":\"+cIme+"ARJ "+cDirRad+"\"
cKom2:="arj e -jyaco -vv "+cDisk+":\"+cIme+"BRJ "+cDirPriv+"\"
cKom3:="arj e -jyaco -vv "+cDisk+":\"+cIme+"CRJ "+cDirSif+"\"
nH:=fcreate("2com2.bat")
fwrite(nH,"@echo off"); fwrite(nH,NL)
fwrite(nH,"cd \"); fwrite(nH,NL)
fwrite(nH,"del "+cDirSif+"\*.ntx");  fwrite(nH,NL)
fwrite(nH,"del "+cDirPriv+"\*.ntx"); fwrite(nH,NL)
fwrite(nH,"del "+cDirRad+"\*.ntx"); fwrite(nH,NL)
fwrite(nH,"cls"); fwrite(nH,NL)
fwrite(nH,"echo Otpakujem fajlove u radni direktorij") ; fwrite(nH,NL)
fwrite(nH,cKom1);  fwrite(nH,NL)
fwrite(nH,"echo Otpakujem fajlove u privatni direktorij") ; fwrite(nH,NL)
fwrite(nH,cKom2);  fwrite(nH,NL)
fwrite(nH,"echo Otpakujem fajlove u direktorij sifrarnika") ; fwrite(nH,NL)
fwrite(nH,cKom3);  fwrite(nH,NL)
fwrite(nH,"cd \"+curdir()); fwrite(nH,NL)
fwrite(nH,"echo Indexsni fajlovi izbrisani - INSTALISITE IH ODGOVARAJUCIM INSTALL programom !") ; fwrite(nH,NL)
fwrite(nH,"pause") ; fwrite(nH,NL)
fclose(nH)
errorlevel(2)
quite()
return

***************************************
function GProc(Ch)
do case
       CASE Ch==K_F1
          Help()
       CASE Ch==K_SH_F6
         LogAgain()
endcase
CLEAR TYPEAHEAD

******************************
function ucitajparams()
******************************
return
