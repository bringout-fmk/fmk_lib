#include "fmk.ch"

/*! \fn KarticaLog()
 *  \brief Stampa pregleda dogadjaja
 */
 
function KarticaLog()
*{
O_USERS
O_EVENTS
O_EVENTLOG

select eventlog
private dDatumOd:=Date()-1
private dDatumDo:=Date()
private cModul:=PADR(goModul:oDataBase:cName,10)
private cKomponenta:=SPACE(15)
private cFunkcija:=SPACE(30)
private cSirokiIspis:="N"
private cPrikUkupno:="N"
private cKorisn:=PADR(nUser,3)

Box(,10,60)
	@ m_x+1,m_y+2 SAY "Od datuma: " GET dDatumOd
	@ m_x+2,m_y+2 SAY "Do datuma: " GET dDatumDo
	@ m_x+4,m_y+2 SAY "Modul (prazno-svi)      :" GET cModul PICT "@!"
	@ m_x+5,m_y+2 SAY "Komponenta (prazno-sve) :" GET cKomponenta PICT "@!"
	@ m_x+6,m_y+2 SAY "Funkcija (prazno-sve)   :" GET cFunkcija PICT "@!"
	@ m_x+7,m_y+2 SAY "User (prazno-svi)       :" GET cKorisn //VALID {|| EMPTY(nUser) .or. P_User(@nUser)}
	read
	@ m_x+9,m_y+2 SAY "Detalji (D/N) :" GET cSirokiIspis VALID cSirokiIspis$"DN" PICT "@!"
	if (!EMPTY(cModul) .and. !EMPTY(cKomponenta) .and. !EMPTY(cFunkcija) .and. !EMPTY(cKorisn))
		@ m_x+10,m_y+2 SAY "Prikazati ukupno (D/N) :" GET cPrikUkupno VALID cPrikUkupno$"DN" PICT "@!"
	endif
	read
BoxC()

if (LastKey()==K_ESC)
	return
endif

IzvjEvents(dDatumOd,dDatumDo,cModul,cKomponenta,cFunkcija,cKorisn)

return
*}



/*! \fn IzvjEvents(dDatumOd,dDatumDo,cModul,cKomponenta,cFunkcija,nUser)
 *  \brief Stampa izvjestaja dogadjaja
 *  \param dDatumOd - datum od kojeg se pravi izvjestaj
 *  \param dDatumDo - datum do kojeg se pravi izvjestaj
 *  \param cModul - naziv modula-objekta (eg. LD)
 *  \param cKomponenta - naziv komponente (eg. DOK)
 *  \param cFunkcija - naziv funkcije (eg. UNOS)
 *  \param nKorisnik - korisnik 
 */
 
function IzvjEvents(dDatumOd,dDatumDo,cModul,cKomponenta,cFunkcija,cKorisnik)
*{

private cFilter:=".t."

select eventlog

if (!EMPTY(dDatumOd) .or. !EMPTY(dDatumDo))
	cFilter+=".and.  datum>=" + Cm2Str(dDatumOd) + " .and. datum<="+Cm2Str(dDatumDo)
endif

if (!EMPTY(cModul))
	cFilter+=" .and. objekat=" + Cm2Str(cModul)
endif

if (!EMPTY(cKomponenta))
	cFilter+=" .and. komponenta=" + Cm2Str(cKomponenta)
endif

if (!EMPTY(cFunkcija))
	cFilter+=" .and. funkcija=" + Cm2Str(cFunkcija)
endif

if (!EMPTY(cKorisnik))
	cFilter+=" .and. user=" + Cm2Str(VAL(cKorisnik))
endif

if (cFilter=" .t. .and. ") 
	cFilter:=SubStr(cFilter,9)
endif

if (cFilter==".t.")
	set filter to
else
	set filter to &cFilter
endif

go top

EOF CRET

START PRINT CRET

//         ID   USER    DATUM    VRIJEME   OBJEKAT      KOMPONENTA     FUNKCIJA                     
cLinija:="---- ------ --------- --------- ---------- --------------- ------------------------------- "

ZaglKartEvent(cLinija)

nUkN1:=0
nUkN2:=0
nUkCount1:=0
nUkCount2:=0

aGrupe:={}

if (goModul:oDataBase:nGroup1<>nil)
	AADD(aGrupe, goModul:oDataBase:nGroup1)
endif

if (goModul:oDataBase:nGroup2<>nil)
	AADD(aGrupe, goModul:oDataBase:nGroup2)
endif

if (goModul:oDataBase:nGroup3<>nil)
	AADD(aGrupe, goModul:oDataBase:nGroup3)
endif

// provrti filterisane zapise
do while !eof() 
	if prow()>61	
		FF
		ZaglKartEvent(cLinija)
	endif
	
	// provjeri da li korisnik iz date grupe ima pravo
	// da vidi ovaj dogadjaj

	cObj:=field->objekat
	cKomp:=field->komponenta
	cFunc:=field->funkcija
	select events
	set order to tag "1"
	seek cObj+cKomp+cFunc
	if !(ASCAN(aGrupe,field->security1)>0) 
		if !(ASCAN(aGrupe,field->security2)>0) 
			if !(ASCAN(aGrupe,field->security3)>0)	
				if !(goModul:oDataBase:nGroup1==900)
					select eventlog
					skip
					loop
				endif
			endif
		endif
	endif
	select eventlog
	
	? SPACE(2)+STR(field->id,4)
	?? SPACE(2)
	@ prow(),pcol()+1 SAY STR(field->user,3)  
	@ prow(),pcol()+1 SAY SPACE(2)+DTOC(field->datum)
	@ prow(),pcol()+1 SAY SPACE(2)+field->vrijeme+SPACE(3)
	@ prow(),pcol()+1 SAY field->objekat
	@ prow(),pcol()+1 SAY field->komponenta
	@ prow(),pcol()+1 SAY field->funkcija
	if cSirokiIspis=="D"
		?
		? SPACE(8)+"* N1: "+STR(field->n1,10,2)+SPACE(5)+"N2: "+STR(field->n2,10,2)
		nUkN1+=field->n1
		nUkN2+=field->n2
		? SPACE(8)+"* Count1: "+STR(field->count1,10,2)+" Count2: "+STR(field->count2,10,2)
		nUkCount1+=field->count1
		nUkCount1+=field->count2
		? SPACE(8)+"* C1: "+field->c1 
		? SPACE(8)+"* C2: "+field->c2 
		? SPACE(8)+"* C3: "+field->c3 
		? SPACE(8)+"* D1: "+DTOC(field->d1)+"  D2 : "+DTOC(field->d2)
		? SPACE(8)+"* Opis: "+ALLTRIM(field->opis)
		? SPACE(8)+"* SQL/Ostalo: "+ALLTRIM(field->sql)
		?
	endif
	skip
enddo      

if prow()>59
	FF
	ZaglKartEvent(cLinija)
endif

? SPACE(2)+cLinija

if cPrikUkupno=="D"
	UkIzvjEvents(nUkN1,nUkN2,nUkCount1,nUkCount2)

endif

set filter to  // ukini filter

FF
END PRINT

return
*}



/*! \fn ZaglKartEvent(cLinija)
 *  \brief Zaglavlje kartice dogadjaja
 *  \param cLinija linija za zaglavlje
 */
 
function ZaglKartEvent(cLinija)
*{
nStrana:=0

set century on

P_12CPI

? SPACE(2)
?? "Pregled logiranih dogadjaja:  ",Date(),SPACE(30),"Strana:",STR(++nStrana,3)

? SPACE(2)
?? "Period: ",dDatumOd," - ",dDatumDo
? SPACE(2)+"-------------------------------"
cStatus:=""

if !EMPTY(cModul)
	cStatus:=ALLTRIM(cModul)
else
	cStatus:="SVI"
endif

? SPACE(2)
?? "Objekat - modul: ",cStatus

if !Empty(cKomponenta)
	cStatus:=ALLTRIM(cKomponenta)
else
	cStatus:="SVE"
endif

? SPACE(2)
?? "Komponenta: ",cStatus

if !EMPTY(cFunkcija)
	cStatus:=ALLTRIM(cFunkcija)
else
	cStatus:="SVE"
endif

? SPACE(2)
?? "Funkcija: ",cStatus

if !EMPTY(cKorisn)
	select users
	set order to tag "ID"
	select eventlog 
	cStatus:=ALLTRIM(cKorisn)
	cStatus+=" - "+Ocitaj(F_USERS,PADL(ALLTRIM(cKorisn),3),"NAZ")
else
	cStatus:="SVI"
endif

? SPACE(2)
?? "User (korisnik): ",cStatus
? SPACE(2)+"-------------------------"

set century off

P_12CPI

? SPACE(2)+cLinija
? SPACE(2)+" Id   User    Datum    Vrijeme   Objekat    Komponenta      Funkcija "
? SPACE(2)+cLinija

return
*}


/*! \fn UkIzvjEvents(nN1,nN2,nCnt1,nCnt2)
 *  \brief Dodaje ukupno na kraju izvjestaja
 *  \param nN1 - ukupno polje eventlog->n1
 *  \param nN2 - ukupno polje eventlog->n2
 *  \param nCnt1 - ukupno polje eventlog->count1
 *  \param nCnt2 - ukupno polje eventlog->count2
 */
 
function UkIzvjEvents(nN1,nN2,nCnt1,nCnt2)
*{
?
? SPACE(2)+"-----------------------------------------"
? SPACE(2)+"UKUPNO: "
? SPACE(10)+"N1:     "+STR(nN1)
? SPACE(10)+"N2:     "+STR(nN2)
? SPACE(10)+"Count1: "+STR(nCnt1)
? SPACE(10)+"Count2: "+STR(nCnt2)	
? SPACE(2)+"-----------------------------------------"
?
return
*}
