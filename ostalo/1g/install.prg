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

/* \fn KorPreg()
 * \brief Pregled korisnika programa
 */
 
function KorPreg()
*{
local nSir

O_KORISN

IF System .or. (KLevel='0' .and. Right(trim(ImeKorisn),1)='1')  // potpuni prioritet
  PRIVATE ImeKol,Kol
  Kol:={1,2,3,4,5,6}
  ImeKol:={ {'Ime'  , {|| korisn->ime}  },;
            {'Sifra', {|| CryptSC(korisn->sif)}  } ,;
            {'Level', {|| korisn->level}  } ,;
            {'Radni.dir', {|| korisn->dirrad}  } ,;
            {'Priv.dir',  {|| korisn->dirpriv}  } ,;
            {'Sif.dir',  {|| korisn->dirsif}  } ,;
           }
  nSir:=60
ELSE
 PRIVATE ImeKol[1,2],Kol[2]
 Kol:={1}
 ImeKol:={ {'Ime'  , {|| korisn->ime}  };
         }
 nSir:=12
END IF

GO TOP

ObjDbEdit ('ks',10,nSir,{|| EdKorisn() },"",iif(System .or. (KLevel='0' .and. Right(trim(ImeKorisn),1)='1'),"<F2> Edit, <c-N> Novi, <c-T> Brisi",""),.f.,"Pregled korisnika programa")

closeret
return
*}


function EdKorisn()
*{
do case
  case Ch==K_CTRL_N
      if System .or. (KLevel='0' .and. Right(trim(ImeKorisn),1)='1')
         Scatter()
         _sif:=space(6)
         if GetKorisn(.t.)<>K_ESC
            _sif:=CryptSC(_sif)
            append blank
            Gather()
            return DE_REFRESH
         endif
      endif
  case Ch==K_F2
      if System .or.(KLevel='0' .and. Right(trim(ImeKorisn),1)='1')
          Scatter()
          _sif:=CryptSC(_sif)
          if GetKorisn(.f.)<>K_ESC
               _sif:=CryptSC(_sif)
               Gather()
               return DE_REFRESH
          endif
      endif
  case Ch==K_CTRL_T
     if ime="SYSTEM"
         Beep(4)
         Msg("Ne mozete izbrisati korisnika SYSTEM",4)
         return DE_CONT
     endif
     if Pitanje(,"Izbrisati korisnika "+ trim(ime) +":"+CryptSC(sif)+" D/N ?","N")=="D"
         delete
         return DE_REFRESH
     endif
  case Ch==K_ESC
     return DE_ABORT

endcase
return DE_CONT
*}


function GetKorisn(fnovi)
*{
Box("",8,60,.F.,'Unos novog korisnika,sifre')
SET CURSOR ON
@ m_x+1,m_y+2 SAY "Ime korisnika......"
if fnovi
 @ row(),col()+1 GET _ime PICTURE "@!" VALID ProvIme(_ime) .and. !empty(_ime)
else
 @ row(),col()+1 GET _ime PICTURE "@!" VALID (_ime==ime) .or. (ProvIme(_ime) .and. !empty(_ime))
endif
@ m_x+2,m_y+2 SAY "Sifra.............." GET _sif PICTURE "@!" VALID !empty(_sif)
@ m_x+3,m_y+2 SAY "Nivo rada.........." GET _level PICTURE "@!"
@ m_x+4,m_y+2 SAY "Privatni podaci...." GET _DirPriv PICTURE "@!"
@ m_x+5,m_y+2 SAY "Radni podaci......." GET _DirRad PICTURE "@!"
@ m_x+6,m_y+2 SAY "Sifarski podaci...." GET _DirSif PICTURE "@!"
@ m_x+8,m_y+2 SAY "Upisi 99 za sezonske podatke" GET _Prov   PICTURE "99"

READ
BoxC()
return lastkey()
*}


/*
* NAZIV : l=ProvIme()
* OPIS  : Provjerava da li postoji zadato ime korisnika
* povziva je KorKreir()
*/

static function ProvIme(m_ime)
*{
local nRec:=recno()

*seek m_ime
*IF Found()
*  Beep(2)
*  Msg(" Ime vec postoji ! ",15)
*  go nRec
*  RETURN .F.
*ELSE
*  go nRec
*  RETURN .T.
*END IF

return .t.
*}


function Zabrana()
*{
if !( System  .or. (KLevel='0' .and. Right(trim(ImeKorisn),1)='1') )
  MsgO("Samo korisnik SYSTEM ima pristup ovoj opciji")
  Beep(4)
  DO WHILE NEXTKEY()==0; OL_YIELD(); ENDDO
  INKEY()
  // Inkey(0)
  MsgC()
  return .t.
else
 return .f.
endif
return
*}


function Secur()
*{
PRIVATE ImeKol,Kol
Kol:={1,2,3,4,5,6}

O_SECUR

ImeKol:={}
AADD(ImeKol, {'Nivo'  , {|| Fsec}  } )
AADD(ImeKol, {'Opcija'  , {|| Fvar}  } )
AADD(ImeKol, {'Pristup' , {|| Fv}  } )

Kol:={1,2,3}

ObjDbEdit ('ks',10,50,{|| EdSecur() },"","",.f.,"Sistem pristupa opcijama programa")
closeret
return
*}


function EdSecur()
*{
do case
  case Ch==K_CTRL_N
       GetSecur(.t.)
       return DE_REFRESH
  case Ch==K_F2
       GetSecur(.f.)
       return DE_REFRESH
  case Ch==K_CTRL_T
     if Pitanje(,"Izbrisati stavku","N")=="D"
        delete
        return DE_REFRESH
     endif
  case Ch==K_ESC
     return DE_ABORT

endcase
return DE_CONT
*}


function GetSecur(fnovi)
*{
Box("",8,60,.F.,'Definicija pristupa')
SET CURSOR ON

if fnovi
 private cSec:="0"
 private cOpcija:=space(15)
 private cPristup:=space(15)
else
 private cSection:=sec,cHistory:=" "; aHistory:={}
 cSec:=cSection
 cOpcija:=Fvar
 cPristup:=""
 RPar(cOpcija,@cPristup)
 cPristup:=padr(cPristup,15)
endif

@ m_x+1,m_y+2 SAY "Nivo rada - level.." GET csec PICTURE "@!" VALID !empty(cSec)
@ m_x+3,m_y+2 SAY "Opcija ............" GET cOpcija  PICTURE "@!" VALID !empty(cOpcija)
@ m_x+5,m_y+2 SAY "Pristup  .........." GET cPristup PICTURE "@!" VALID !empty(cPristup)
READ
BoxC()

cPristup:=trim(cPristup)

if lastkey()<>K_ESC
 private cSection:=csec,cHistory:=" "; aHistory:={}
 WPar(cOpcija,cPristup)
endif

return NIL
*}

function ServisKom
*{
local cScr
local izbor

if !sigmasif("SKOM")
  msgbeep("Ne cackaj !")
  return
endif

private opc[4]
Opc[1]:="1. poziv dos komandna linija "
Opc[2]:="2. vidi autoexec.bat"
Opc[3]:="3. vidi config.sys"
Opc[4]:="4. ncd"
h[1]:="Vrati se nazad sa EXIT"
h[2]:=""
h[3]:=""
h[4]:=""

Izbor:=1
do while .t.
   Izbor:=menu("spo",opc,Izbor,.f.)

   if izbor==0
      exit
   endif
   save screen to cscr
   do case
     case izbor==1
       cls
       swpruncmd("",0,"","")
     case izbor==2
       swpruncmd("q c:\autoexec.bat",0,"","")
     case izbor==3
       swpruncmd("q c:\config.sys",0,"","")
     case izbor==4
       swpruncmd("ncd",0,"","")
   endcase
   restore screen from cscr
enddo
return
*}

