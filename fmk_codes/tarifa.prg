#include "fmk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/roba/tarifa.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.18 $
 * $Log: tarifa.prg,v $
 * Revision 1.18  2004/05/14 14:58:42  sasavranic
 * no message
 *
 * Revision 1.17  2004/05/13 10:20:05  sasavranic
 * Uvedena varijanta gUVarPP="I", u sl.n.objavljeno da se iz vrijednosti PRUCMP ne izbija PPP
 *
 * Revision 1.16  2004/01/13 19:07:59  sasavranic
 * appsrv konverzija
 *
 * Revision 1.15  2003/09/29 13:26:32  mirsadsubasic
 * sredjivanje koda za poreze u ugostiteljstvu
 *
 * Revision 1.14  2003/09/20 07:37:27  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.13  2003/09/08 08:41:43  ernad
 * porezi u ugostiteljstvu
 *
 * Revision 1.12  2003/09/04 16:51:17  ernad
 * komentiranje koda da bih skontao algoritam za poreze u ugostiteljstvu
 * (Kumpath/PPUgostKaoPPU=T)
 *
 * Revision 1.11  2003/02/10 02:17:49  mirsad
 * no message
 *
 * Revision 1.10  2002/10/17 14:28:35  mirsad
 * uveden novi parametar f-je MpcBezPor: (,,nRabat)
 *
 * Revision 1.9  2002/10/17 14:25:32  mirsad
 * uveden novi parametar f-je MpcBezPor: (,,nRabat)
 *
 * Revision 1.8  2002/07/18 13:49:00  mirsad
 * uba�ene varijante "M" i "J" za poreze u ugostiteljstvu
 *
 * Revision 1.7  2002/07/04 19:04:08  ernad
 *
 *
 * ciscenje sifrarnik fakt
 *
 * Revision 1.6  2002/07/01 08:05:25  ernad
 *
 *
 * debug kada nema polja tarifa->mpp
 *
 * Revision 1.5  2002/06/30 11:08:53  ernad
 *
 *
 * razrada: kalk/specif/planika/rpt_ppp.prg; pos/prikaz privatnog direktorija na vrhu; doxy
 *
 * Revision 1.4  2002/06/29 17:32:02  ernad
 *
 *
 * planika - pregled prometa prodavnice
 *
 * Revision 1.3  2002/06/20 16:52:06  ernad
 *
 *
 * ciscenje planika, uvedeno fmk/svi/specif.prg
 *
 * Revision 1.2  2002/06/16 14:16:54  ernad
 * no message
 *
 *
 */




/*! \fn P_Tarifa(cId,dx,dy)
 *  \brief Otvara sifrarnik tarifa
 *  \param cId
 *  \param dx
 *  \param dy
 */

function P_Tarifa(cid,dx,dy)
*{
private ImeKol,Kol:={}

ImeKol:={ { "ID ",  {|| id },       "id"  , {|| .t.}, {|| vpsifra(wId)}      },;
          { PADC("Naziv",10), {|| left(naz,10)},      "naz"       },;
          { "PPP ", {|| opp},     "opp"      },;
          { "PPU ", {|| ppp},     "ppp"      },;
          { "PP  ", {|| zpp},  "zpp"      },;
          { "P.na Marzu", {|| vpp},  "vpp"      };
        }
IF TARIFA->(FIELDPOS("MPP"))<>0
  AADD (ImeKol,{ PADC("Por.RUC MP",10) , {|| MPP} , "MPP" })
ENDIF
IF TARIFA->(FIELDPOS("DLRUC"))<>0
  AADD (ImeKol,{ PADC("Min.RUC(%)",10) , {|| DLRUC} , "DLRUC" })
ENDIF
FOR i:=1 TO LEN(ImeKol)
	AADD(Kol,i)
NEXT
return PostojiSifra(F_TARIFA,1,10,75,"Tarifne grupe",@cid,dx,dy)
*}



/*! fn Tarifa(cIdKonto, cIdRoba, aPorezi, cIdTar)
 *\brief Ispitivanje tarife, te punjenje matrice aPorezi
 *\param cIdKonto - Oznaka konta
 *\param cIdRoba - Oznaka robe
 *\param aPorezi - matrica za vrijednosti poreza
 *\param cIdTar - oznaka tarife, ovaj parametar je nil, ali se koristi za izvjestaje radi starih dokumenata (gdje je bilo promjene tarifa)
 */
 
function Tarifa(cIdKonto, cIdRoba, aPorezi, cIdTar)
*{
local cTarifa
local lUsedRoba
local lUsedTarifa
local cIdTarifa

private cPolje

lUsedRoba:=.t.
lUsedTarifa:=.t.

PushWa()

if empty(cIdKonto)
 cPolje:="IdTarifa"

else
	SELECT (F_KONCIJ)
	if (!used())
	   O_KONCIJ
	endif
	seek cIdKonto
	if !found()
	  cPolje:="IdTarifa"
	else
	  if FIELDPOS("region")<>0
	    if (koncij->region=="1" .or. koncij->region==" ")
	       cPolje:="IdTarifa"
	    elseif koncij->region=="2"
	       cPolje:="IdTarifa2"
	    elseif koncij->region=="3"
	       cPolje:="IdTarifa3"
	    else
	       cPolje:="IdTarifa"
	    endif
	  else
	    cPolje:="IdTarifa"
	  endif
	endif
endif

if cIdTar==nil
	SELECT(F_ROBA)
	if (!USED())
		lUsedRoba:=.f.
		O_ROBA
	endif
	seek cIdRoba
	cTarifa:=&cPolje

	SELECT(F_TARIFA)
	if (!USED())
		lUsedTarifa:=.f.
		O_TARIFA
	endif
	seek cTarifa
	cIdTarifa:=tarifa->id
else
	cIdTarifa:=cIdTar
endif

SetAPorezi(@aPorezi)

if (!lUsedRoba)
	SELECT(F_ROBA)
	USE
endif

if (!lUsedTarifa)
	SELECT(F_TARIFA)
	USE
endif

PopWa()
return cIdTarifa
*}


/*! \fn SetAPorezi(aPorezi)
 *  \brief Filovanje matrice aPorezi sa porezima
 *  \param aPorezi Matrica poreza, aPorezi:={PPP,PP,PPU,PRUC,PRUCMP,DLRUC}
 */
function SetAPorezi(aPorezi)
*{
if (aPorezi==nil)
	aPorezi:={}
endif
if (LEN(aPorezi)==0)
  	//inicijaliziraj poreze
  	aPorezi:={0,0,0,0,0,0,0}
endif
aPorezi[POR_PPP]:=tarifa->opp
aPorezi[POR_PP ]:=tarifa->zpp
aPorezi[POR_PPU]:=tarifa->ppp
aPorezi[POR_PRUC]  :=tarifa->vpp
if tarifa->(FIELDPOS("mpp"))<>0
	aPorezi[POR_PRUCMP]:=tarifa->mpp
	aPorezi[POR_DLRUC]:=tarifa->dlruc
else
	aPorezi[POR_PRUCMP]:=0
	aPorezi[POR_DLRUC]:=0
endif
return nil
*}


/*! \fn MpcSaPorUgost(nPosebniPorez, nPorezNaRuc, aPorezi)
 *  \brief Racuna maloprodajnu cijenu u ugostiteljstvu
 *  \param nPosebniPorez Posebni porez
 *  \param nPorezNaRuc Porez na razliku u cijeni
 *  \param aPorezi Matrica sa porezima
 */
function MpcSaPorUgost(nPosebniPorez, nPorezNaRuc, aPorezi)
*{
local nPom

// (MpcSapp - PorezNaRuc) * StopaPP = PosebniPorez
// PosebniPorez/StopaPP = MpcSaPP - PorezNaRuc
// MpcSaPP = PosebniPorez/StopaPP + PorezNaRuc

nPom:= nPosebniPorez/(aPorezi[POR_P_PRUC]/100) + nPorezNaRUC
	
return nPom
*}

/*! \fn MpcSaPor(nMpcBP, aPorezi, aPoreziIzn)
 *  \brief Racuna maloprodajnu cijenu sa porezom
 *  \param nMpcBP Maloprodajna cijena bez poreza
 *  \param aPorezi Matrica poreza
 *  \param aPoreziIzn Matrica sa izracunatim porezima
 */
function MpcSaPor(nMPCBp, aPorezi, aPoreziIzn)
*{
local nPom
local nDLRUC
local nMPP
local nPP
local nPPP
local nPPU
nDLRUC:=aPorezi[POR_DLRUC]/100
nMPP:=aPorezi[POR_PRUCMP]/100
nPP:=aPorezi[POR_PP]/100
nPPP:=aPorezi[POR_PPP]/100
nPPU:=aPorezi[POR_PPU]/100

if !glPoreziLegacy
	nPom:=nMpcBp*(nPP+(nPPP+1)*(1+nPPU))
else

//legacy
if (gUVarPP=="J" .and. !IsPlanika())
	nPom:=nMpcBp/(1+nDLRUC*(1-nPP)*(nPPP/(1+nPPP)-1)*nMPP/(1+nMPP)+(nPP-1)*nPPP/(1+nPPP)-nPP)
elseif (gUVarPP=="M" .and. !IsPlanika())
	nPom:=nMpcBp/(1-(nPP+nPPP/(1+nPPP)+nDLRUC*(1-nPP)*nMPP/(1+nMPP)))
elseif (gUVarPP=="R" .and. !IsPlanika())
	nPom:=nMpcBp*(1+nPPP+nPP) 
elseif gUVarPP=="D"
	nPom:=nMpcBp*((1+nPP+nPPU)*(1+nPPP))
else
	// obicno robno poslovanje
	nPom:=nMpcBp*(nPP+(nPPP+1)*(1+nPPU))
endif

endif

return nPom
*}



/*! \fn MpcBezPor(nMpcSaPP, aPorezi, nRabat, nNC)
 *  \brief Racuna maloprodajnu cijenu bez poreza
 *  \param nMpcSaPP maloprodajna cijena sa porezom
 *  \param aPorezi Matrica poreza
 *  \param nRabat Rabat
 *  \param nNC Nabavna cijena
 */
function MpcBezPor(nMpcSaPP, aPorezi, nRabat, nNC)
*{
local nPor1
local nPor2
local nPom
local nDLRUC
local nMPP
local nPP
local nPPP
local nPPU
local nBrutoMarza
local nMpcBezPor

if nRabat==nil
	nRabat:=0
endif

nDLRUC:=aPorezi[POR_DLRUC]/100
nMPP:=aPorezi[POR_PRUCMP]/100
nPP:=aPorezi[POR_PP]/100
nPPP:=aPorezi[POR_PPP]/100
nPPU:=aPorezi[POR_PPU]/100

if (!IsVindija()).and.nMpcSaPP<>nil
	nMpcSaPP:=nMpcSaPP-nRabat
endif


if !glPoreziLegacy
	if glUgost
		// ovo je zapetljano ali izgleda da radi
		// racun se sigurno moze pojednostaviti 
		
		//porez na promet proizvoda
		if !IsJerry()
			nPor1:=Izn_P_PPP(,aPorezi,,nMpcSaPP)
		endif
		
		// porez na razliku u cijeni u maloprodaji
		// =  bruto_marza * preracunata_stopa_poreza
		nPor2:=Izn_P_PRugost(nMpcSaPP,,nNC,aPorezi)
		/*if gUgostVarijanta="MPCSAPOR".or.IsJerry()
			nBrutoMarza:=nMpcSaPP*nDLRUC
			nPor2:=nBrutoMarza*nMPP/(1+nMPP)
		else
			nBrutoMarza:=nMpcSaPP-nPor1-nNC
			nPor2:=nBrutoMarza*nMPP/(1+nMPP)
		endif*/
		
		// osnovica porez na potrosnju = 
		// ( cijena_sa_porezom - porez_na_razliku_u_cijeni )
		// posebni porez - porez na potrosnju
		nPor3:=(nMpcSaPP-nPor2)*nPP

		if IsJerry()
			nPor1:=Izn_P_PPP(,aPorezi,,nMpcSaPP-nPor2-nPor3)
		endif
		
		nPom:=nMpcSaPP-nPor1-nPor2-nPor3
	else
		nPom:=nMpcSaPP/(nPP+(nPPP+1)*(1+nPPU))
	endif

else

// legacy
if (gUVarPP=="T" .and. !IsPlanika())
	if nNC==NIL
		// ako nije data NC preuzecu za sad varijantu gUVarPP=="M"
		nPom:=nMpcSaPP*(1-(nPP+nPPP/(1+nPPP)+nDLRUC*(1-nPP)*nMPP/(1+nMPP)))
	else
		//porez na promet proizvoda
		nPor1:=nMpcSaPP*nPPP/(1+nPPP)
		// porez na razliku u cijeni u maloprodaji
		nPor2:=(nMpcSaPP-nPor1-nNC)*nMPP/(1+nMPP)
		// osnovica porez na potrosnju = 
		// ( cijena_sa_porezom - porez_na_razliku_u_cijeni )
		nPor3:=(nMpcSaPP-nPor2)*nPP
		nPom:=nMpcSaPP-nPor1-nPor2-nPor3
	endif
elseif (gUVarPP=="J" .and. !IsPlanika())
	nPom:=nMpcSaPP*(1+nDLRUC*(1-nPP)*(nPPP/(1+nPPP)-1)*nMPP/(1+nMPP)+(nPP-1)*nPPP/(1+nPPP)-nPP)
elseif (gUVarPP=="M" .and. !IsPlanika())
	nPom:=nMpcSaPP*(1-(nPP+nPPP/(1+nPPP)+nDLRUC*(1-nPP)*nMPP/(1+nMPP)))
elseif (gUVarPP=="R" .and. !IsPlanika())
	nPom:=nMpcSaPP/(1+nPPP+nPP)
elseif (gUVarPP=="D" .and. !IsPlanika())
	nPom:=nMpcSaPP/((1+nPP+nPPU)*(1+nPPP))
else
	nPom:=nMpcSaPP/(nPP+(nPPP+1)*(1+nPPU))
endif

endif

return nPom
*}



/*! \fn Izn_P_PPP(nMPCBp, aPorezi, aPoreziIzn, nMpcSaP)
 *  \brief Racuna iznos PPP
 *  \param nMpcBp Maloprodajna cijena bez poreza
 *  \param aPorezi Matrica poreza
 *  \param aPoreziIzn Matrica izracunatih poreza
 *  \param nMpcSaP Maloprodajna cijena sa porezom
 */
function Izn_P_PPP(nMPCBp, aPorezi, aPoreziIzn, nMpcSaP)
*{
local nPom
altd()
if !glPoreziLegacy 
	if glUgost 
		if gUgostVarijanta=="MPCSAPOR"
			if IsJerry() .and. nMpcBp<>nil
				nPom:=nMpcBp*(aPorezi[POR_PPP]/100) 
			else
				nPom:=nMpcSaP*(aPorezi[POR_PPP]/100)/((aPorezi[POR_PPP]/100)+1)
			endif
		else
			nPom:=nMpcSaP*(aPorezi[POR_PPP]/100)/((aPorezi[POR_PPP]/100)+1)
		endif
	else
		nPom:=nMpcSaP*(aPorezi[POR_PPP]/100)/((aPorezi[POR_PPP]/100)+1)
	endif
else
	if gUVarPP$"MT"
		nPom:=nMpcSaP*(aPorezi[POR_PPP]/100)/((aPorezi[POR_PPP]/100)+1)
	else
		nPom:=nMpcBp*(aPorezi[POR_PPP]/100) 
	endif
endif
return nPom
*}


/*! \fn Izn_P_PPU(nMpcBp, aPorezi, aPoreziIzn)
 *  \brief Racuna iznos PPU
 *  \param nMpcBp Maloprodajna cijena bez poreza
 *  \param aPorezi Matrica poreza
 *  \param aPoreziIzn Matrica izracunatih poreza
 */
function Izn_P_PPU(nMPCBp, aPorezi, aPoreziIzn)
*{
local nPom
nPom:= nMpcBp * (aPorezi[POR_PPP]/100+1)*(aPorezi[POR_PPU]/100) 
return nPom
*}


/*! \fn Izn_P_PP(nMpcBp, aPorezi, aPoreziIzn)
 *  \brief Racuna iznos PP
 *  \param nMpcBp Maloprodajna cijena bez poreza
 *  \param aPorezi Matrica poreza
 *  \param aPoreziIzn Matrica izracunatih poreza
 */
function Izn_P_PP(nMPCBp, aPorezi, aPoreziIzn)
*{
local nOsnovica
local nMpcSaPor
local nPom

if (gUVarPP=="R" .and. !IsPlanika())
	nPom:= nMpcBp * aPorezi[POR_PP]/100  
elseif (gUVarPP=="D" .and. !IsPlanika())
 	nPom:= nMpcBp * (1+ aPorezi[POR_PPP]/100 ) * aPorezi[POR_PP]/100
else
 	// obicno robno poslovanje
 	nPom:= nMpcBp * aPorezi[POR_PP]/100  
endif
return nPom
*}

/*! \fn Izn_P_PPUgost(nMpcSaPP, nIznPRuc, aPorezi)
 *  \brief Racuna posebni porez u ugostiteljstvu
 *  \param nMpcSaPP Maloprodajna cijena sa porezom
 *  \param nIznPRuc Iznos poreza na razliku u cijeni
 *  \param aPorezi Matrica poreza
 */
function Izn_P_PPUgost(nMpcSaPP, nIznPRuc, aPorezi)
*{
local nPom
local nDLRUC
local nMPP
altd()
nDLRUC:=aPorezi[POR_DLRUC]/100
nMPP:=aPorezi[POR_PRUCMP]/100

if gUgostVarijanta="MPCSAPOR"
	nIznPRuc:=nMpcSaPP*nDLRUC*nMPP/(1+nMPP)
endif

// osnovica je cijena sa porezom umanjena za porez na ruc
nPom:= (nMpcSaPP - nIznPRuc)*aPorezi[POR_PP]/100

return nPom
*}


/*! \fn Izn_P_PRugost(nMpcSaPP, nMPCBp, nNc, aPorezi, aPoreziIzn)
 *  \brief Porez na razliku u cijeni u ugostiteljstvu
 *  \param nMpcSaPP maloprodajna cijena sa porezom
 *  \param nMpcBp maloprodajna cijena bez poreza
 *  \param nNc nabavna cijena
 *  \param aPorezi matrica poreza
 *  \param aPoreziIzn matrica izracunatih poreza
 */
function Izn_P_PRugost(nMpcSaPP, nMPCBp, nNc, aPorezi, aPoreziIzn)
*{
local nPom
local nMarza
local nDLRUC
//preracunata stopa poreza na ruc
local nPStopaMPP
altd()
//donji limit stope RUC-a
nDLRUC:=aPorezi[POR_DLRUC]/100

//porez na ruc
nMPP:=aPorezi[POR_PRUCMP]/100

//preracunata stopa poreza na ruc
nPStopaMPP:= nMPP/(1 + nMPP)

// varijanta "I", izaslo u sl.novinama.
if gUVarPP=="I"
	// ako je nc=0 marzu racunaj kao mpc * dlruc
	if nNc==0
		nMarza:=nMpcSaPP*nDLRUC
	else
		nMarza:= nMpcSaPP-nNc
	endif
else
	nMarza:= nMpcSaPP-nNc-Izn_P_PPP(,aPorezi,,nMpcSaPP)
endif

DO CASE
	CASE gUgostVarijanta$"MPCSAPOR"
		// uvijek je osnova mpc
		nPom:= (nMpcSaPP*nDLRUC)*nPStopaMPP
		
	CASE gUgostVarijanta="RMARZA_DLIMIT"
		// realizovana marza ili dlimit 
		nPom := MAX( (nMpcSaPP*nDLRUC)*nPStopaMPP, nMarza*nPStopaMPP )
	OTHERWISE
		nPom := -9999999
ENDCASE
				
return nPom
*}



/*! \fn KorekTar()
 *  \brief Korekcija tarifa
 */
function KorekTar()
*{
local cTekIdTarifa
local cPriprema

if !SigmaSif("SIGMATAR")
	return
endif

CLOSE ALL

O_ROBA

SELECT 0

cIdVD:=space(2)
cIdTarifa:=space(6)

set cursor on

cPriprema:="D"

Box(,3,60)
  @ m_x+1,m_y+2 SAY "Vrsta dokumenta (prazno svi)" GET cIdVD
  @ m_x+2,m_y+2 SAY "Tarifa koju treba zamijeniti (prazno svi)" GET cIdTarifa pict "@!"
if gModul=="KALK" 
 @ m_x+3,m_y+2 SAY "Izvrsiti korekciju nad pripremom D/N ? " GET cPriprema pict "@!" valid cPriprema  $ "DN"
endif

  read
Boxc()
if lastkey()==K_ESC
	return
endif

nKumArea:=0

if gModul=="KALK"
 if cPriprema=="D"
   use (PRIVPATH+"PRIPR")
 else  
   use (KUMPATH+"KALK")
 endif
elseif gModul=="TOPS"
 use (KUMPATH+"POS")
else
 CLOSERET
endif
nKumArea:=SELECT()

nC:=0
Box(,1,50)
go top
do while !eof()
  if ( empty(cIdVD) .or. cIdvd==IDVD ) .and. ( empty(cIdTarifa) .or. cIdTarifa==(nKumArea)->IdTarifa )
    select roba; hseek (nKumArea)->idroba
    if !found()
      MsgBeep("Artikal "+(nKumArea)->idroba+" ne postoji u sifraniku robe")
    else
      select (nKumArea)
      
      private aPorezi:={}
      if gModul=="KALK"
         cTekIdTarifa:=Tarifa( (nKumArea)->PKONTO , (nKumArea)->IdRoba, @aPorezi)
      else
         cTekIdTarifa:=roba->IdTarifa
      endif
      if (nKumArea)->IdTarifa<>cTekIdTarifa
        select (nKumArea)
        @ m_x+1, m_y+2 SAY ++Nc pict "999999"
        @ m_x+1, col()+2 SAY IdTarifa
        @ m_x+1, col()+2 SAY "->"
        @ m_x+1, col()+2 SAY cTekIdTarifa

        REPLACE IdTarifa with cTekIdTarifa
	REPLSQL IdTarifa with cTekIdTarifa
      endif
    endif
  endif
  select (nKumArea)
  skip 1
enddo
BoxC()

select(nKumArea)
use

CLOSERET
return
*}


/*! \fn PrPPUMP()
 *  \brief Vraca procenat poreza na usluge. U ugostiteljstvu to je porez na razliku u cijeni. aPorezi, _mpp i _ppp moraju biti definisane (privatne ili javne var.)
*/
function PrPPUMP()
*{
local nV
if !glPoreziLegacy
	if glUgost
		nV:=aPorezi[POR_PRUCMP]
	else
		nV:=aPorezi[POR_PPU]
	endif
else
	if gUVarPP$"MJT"
		nV:=_mpp*100
	else
		nV:=_ppp*100
	endif
endif
return nV
*}



/* \fn RacPorezeMP(aPorezi, nMpc, nMpcSaPP, nNc)
 * \brief Racunanje poreza u maloprodaji
 * \param aPorezi Matrica poreza
 * \param nMpc Maloprodajna cijena
 * \param nMpcSaPP Maloprodajna cijena sa porezom
 * \param nNc Nabavna cijena
*/
function RacPorezeMP(aPorezi, nMpc, nMpcSaPP, nNc)
*{
local nIznPRuc
local nP1, nP2, nP3
altd()
nP1:=Izn_P_PPP(nMpc, aPorezi, , nMpcSaPP)
if glUgost
	nIznPRuc:=Izn_P_PRugost( nMpcSaPP, nMpc, nNc, aPorezi)
	nP2:=nIznPRuc
	nP3:=Izn_P_PPUgost(nMpcSaPP, nIznPRuc, aPorezi)
else
	nP2:=Izn_P_PPU( nMpc, aPorezi )
	nP3:=Izn_P_PP( nMpc, aPorezi )
endif
return {nP1,nP2,nP3}
*}			


