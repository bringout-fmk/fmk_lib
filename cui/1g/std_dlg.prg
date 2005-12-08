#include "SC.CH"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/sclib/cui/1g/std_dlg.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.8 $
 * $Log: std_dlg.prg,v $
 * Revision 1.8  2003/01/18 12:33:18  ernad
 * -
 *
 * Revision 1.6  2002/07/01 10:46:40  ernad
 *
 *
 * oApp:lTerminate - kada je true, napusta se run metod oApp objekta
 *
 * Revision 1.5  2002/06/24 17:04:15  ernad
 *
 *
 * omoguceno da se "restartuje" program .... nakon podesenja sistemskog sata -> oApp:run() ....
 *
 * Revision 1.4  2002/06/15 09:19:34  sasa
 * no message
 *
 * Revision 1.3  2002/06/15 09:03:44  sasa
 * no message
 *
 *
 */
 

/*! \fn Pitanje(cId,cPitanje,cOdgDefault,cMogOdg)
 *  \brief Otvara box sa zadatim pitanjem na koje treba odgovoriti sa D,N,..
 *  \param cId
 *  \param cPitanje       - Pitanje
 *  \param cOdgDefault    - Odgovor koji ce biti ponudjen na boxu
 *  \cMogOdg              - Moguci odgovori  
 */
 
function Pitanje(cId,cPitanje,cOdgDefault,cMogOdg)
*{
local cPom
local cOdgovor

IF cMogOdg=NIL
  cMogOdg := "YDNL"
ENDIF

private GetList:={}


if gAppSrv
	return cOdgDefault
endif

cPom:=SET(_SET_DEVICE)
SET DEVICE TO SCREEN

if cOdgDefault==NIL .or. !(cOdgDefault $ cMogOdg)
  cOdgovor:=" "
else
  cOdgovor:=cOdgDefault
endif

set escape off
set confirm off

Box(,3,LEN(cPitanje)+6,.f.)
 set cursor on
 @ m_x+2,m_y+3 SAY cPitanje GET cOdgovor PICTURE "@!" ; 
 	VALID ValidSamo(cOdgovor,cMogOdg)
 READ
BoxC()
set escape on; set confirm on

SET(_SET_DEVICE,cPom)
return cOdgovor

static function ValidSamo(cOdg,cMogOdg)
if cOdg $ cMogOdg
  return .t.
else
  MsgBeep("Uneseno: "+cOdg+"#Morate unijeti nesto od :"+cMogOdg)
  return .f.
endif

RETURN .f.
*}


/*! \fn Pitanje2(cId,cPitanje,cOdgDefault)
 *  \brief 
 *  \param cId
 *  \param cPitanje       - Pitanje
 *  \cOdgDefault          - Ponudjeni odgovor
 */
 
function Pitanje2(cId,cPitanje,cOdgDefault)
*{
local cOdg
local nDuz:=LEN(cPitanje)+4
local cPom:=SET(_SET_DEVICE)
private GetList:={}

if gAppSrv
	return cOdgDefault
endif

SET DEVICE TO SCREEN
if nDuz<54; nDuz:=54; endif

if cOdgDefault==NIL .or. !(cOdgDefault $ 'DNAO')
  cOdg:=' '
else
  cOdg:=cOdgDefault
endif

set escape off; set confirm off
Box("",5,nDuz+4,.f.)
 set cursor on
 @ m_x+2,m_y+3 SAY PADR(cPitanje,nDuz) GET cOdg PICTURE "@!" VALID cOdg $ 'DNAO'
 @ m_x+4,m_y+3 SAY PADC("Moguci odgovori:  D - DA  ,  A - DA sve do kraja",nDuz)
 @ m_x+5,m_y+3 SAY PADC("                  N - NE  ,  O - NE sve do kraja",nDuz)
 READ
BoxC()
set escape on; set confirm on

SET(_SET_DEVICE,cPom)

return cOdg
*}


/*! \fn IzlazPrn(cDirekt)
 *  \brief 
 *  \param cDirekt
 */
 
function IzlazPrn(cDirekt)
*{
if gAppSrv
	return cDirekt
endif

set confirm off
set cursor on
if !gAppSrv
	cDirekt:=UpitPrinter(@cDirekt)
endif

return cDirekt
*}


/*! \fn UpitPrinter(cDirekt)
 *  \brief
 *  \param cDirekt   
 */
 
function UpitPrinter(cDirekt)
*{

local nWidth

nWidth:=35
   
Tone(400,2)
// radi pozicioniranja dijaloga na sredinu ekrana
m_x:=8
m_y:=38-ROUND(nWidth/2,0)
@ m_x, m_y SAY ""
Box(,8,nWidth)
	@ m_x+1,m_y+2 SAY "   Izlaz direktno na printer:" GET cDirekt pict "@!" valid cDirekt $ "DNERV"

	@ m_x+2,m_y+2 SAY "----------------------------------" 
	@ m_x+3,m_y+2 SAY "D - direktno na printer"
	@ m_x+4,m_y+2 SAY "N - prikaz na ekranu u LL-u"
	@ m_x+5,m_y+2 SAY "V - prikaz na ekranu iz programa"
	@ m_x+6,m_y+2 SAY "E - prikaz na ekranu u Q-editoru"
	@ m_x+7,m_y+2 SAY "R - Windows printer"
	@ m_x+8,m_y+2 SAY "---------- O P C I J E -----------"
	read
BoxC()
   
return cDirekt
*}


/*! \fn GetLozinka(nSiflen)
 *  \brief
 *  \param nSiflen
 */
 
function GetLozinka(nSiflen)
*{
local cKorsif

cKorsif:=""
Box(, 2, 30 )
@ m_x+2,m_y+2 SAY "Lozinka..... "

DO WHILE .T.

   nChar:=WaitScrSav()

   if nChar==K_ESC
      cKorsif:=""
   
   elseif (nChar==0) .or. (nChar > 128)
       loop
   
   elseif (nChar==K_ENTER)
       exit
   
   elseif (nChar==K_BS)
       cKorSif:=left(ckorsif,len(cKorsif)-1)
   
   else
   
      
      if len(cKorsif)>=nSifLen // max 15 znakova
         Beep(1)
      endif
      
      if (nChar > 1)
        cKorsif:=cKorSif+Chr(nChar)
      endif
   
   endif

   @ m_x+2,m_y+15 SAY padr(replicate("*",len(cKorSif)),nSifLen)
   if (nChar==K_ESC)
      loop
   endif

ENDDO

BoxC()

set cursor on
return padr(cKorSif,nSifLen)
*}


/*! \fn TrebaRegistrovati(nSlogova)
 *  \brief Provjera da li je program registrovan
 *  \param nSlogova
 */
 
function TrebaRegistrovati(nSlogova)
*{
if gAppSrv
	return
endif

if empty(substr(Evar,32,1))  
  return
endif

Beep(4)
Msg("Probna verzija !!!##Ogranicena obrada - maksimalno 20 raŸuna !!")

if reccount2()>nSlogova
	Beep(4)
	PUBLIC  Normal:="GR+/B,R/N+,,,N/W"
	Box(,6,60)
	@ m_x+1,m_y+2 SAY "Potrebno je registrovati kopiju od strane"
	@ m_x+2,m_y+2 SAY "ovlastenog distributera SIGMA-COM software-a"
	@ m_x+4,m_y+2 SAY "Podaci koje ste unosili NISU izgubljeni !"
	@ m_x+5,m_y+2 SAY "Nakon instalacije registrovane verzije mozete"
	@ m_x+6,m_y+2 SAY "nastaviti sa radom."
	inkey(0)
	Boxc()
	PUBLIC  Normal:="W/B,R/N+,,,N/W"
	goModul:quit()

endif
return
*}

/*! \fn PozdravMsg(cNaslov,cVer,nk)
 *  \brief Ispisuje ekran sa pozdravnom porukom
 *  \param cNaslov
 *  \param cVer       
 *  \param nk
 */
 
function PozdravMsg(cNaslov,cVer, lGreska)
*{
local lInvert

if gAppSrv
	return
endif

lInvert:=.f.

// Pozdravna poruka
Box("por",11, 60, lInvert)      
Set cursor off

     @ m_x+2,m_y+2 SAY PADC(cNaslov,60)
     @ m_x+3,m_y+2 SAY PADC("Ver. "+cVer,60)
     @ m_x+5,m_y+2 SAY PADC("SIGMA-COM",60)
     @ m_x+7,m_y+2 SAY PADC("Travnicka 64, Zenica, BiH", 60)
     @ m_x+8,m_y+2 SAY PADC("tel: 032/440-170, fax: 032/440-173", 60)
     @ m_x+9,m_y+2 SAY PADC("web: http://www.sigma-com.net",60)
     @ m_x+10,m_y+2 SAY PADC("email: cs@sigma-com.net",60)
     IF lGreska
         @ m_x+11,m_y+4 SAY "Prosli put program nije regularno zavrsen"
         Beep(2)
     ENDIF

     Inkey(5)

BoxC()
return
*}

