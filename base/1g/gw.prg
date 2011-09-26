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
#include "fileio.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/sclib/base/1g/gw.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.18 $
 * $Log: gw.prg,v $
 * Revision 1.18  2003/11/14 08:47:15  sasavranic
 * Problem sa automatskim kupljenjem poruka
 *
 * Revision 1.17  2003/11/11 12:12:49  sasavranic
 * Auto citanje poruka
 *
 * Revision 1.16  2003/11/10 09:51:44  sasavranic
 * planika->messaging, automatsko kupljenje poruka
 *
 * Revision 1.15  2003/04/12 23:01:18  ernad
 * O_Edit (O_S_PRIREMA)
 *
 * Revision 1.14  2003/01/21 16:18:22  ernad
 * planika gSQL=D bug tops
 *
 * Revision 1.13  2003/01/15 12:39:10  ernad
 * bug 2003
 *
 * Revision 1.12  2002/08/19 10:01:47  ernad
 *
 *
 * podesenja za CLIP
 *
 * Revision 1.11  2002/08/05 11:03:58  ernad
 *
 *
 * Fin/SQLLog funkcije, debug bug RJ/KUMPATH
 *
 * Revision 1.10  2002/07/23 08:08:51  ernad
 *
 *
 * debug: Nakon dogadjaja "Nema in/out komande" ostane crni ekran - program zaglavi
 *
 * Revision 1.9  2002/07/03 07:31:12  ernad
 *
 *
 * planika, debug na terenu
 *
 * Revision 1.8  2002/07/01 11:24:11  ernad
 *
 *
 * gateway treba onemoguciti kada smo u meniju za odabir Db-a
 *
 * Revision 1.7  2002/07/01 10:46:40  ernad
 *
 *
 * oApp:lTerminate - kada je true, napusta se run metod oApp objekta
 *
 * Revision 1.6  2002/06/30 09:34:07  ernad
 *
 *
 *
 * doxy-ranje
 *
 * Revision 1.5  2002/06/24 07:00:37  ernad
 *
 *
 * GwDiskFree, ciscenja gateway
 *
 * Revision 1.4  2002/06/23 11:57:23  ernad
 * ciscenja sql - planika
 *
 * Revision 1.3  2002/06/21 02:28:36  ernad
 * interni sql parser - init, testiranje pos-sql
 *
 * Revision 1.2  2002/06/19 13:17:47  ernad
 * gateway funkcije
 *
 * Revision 1.1  2002/06/19 10:18:58  ernad
 * ubacne gw.prg - operacije gateway-a
 *
 *
 */
  
*string
static GW_STRING
*;


/*! \fn Gw(cStr, nHandle, cAkcija)
 *  \param cStr - string koji prosljedjujemo gateway-u
 *  \param nHandle - ne koristi se, izbaciti !
 *  \param cAkcija = A - azuriraj odmah, default value; P - pocetak; D - dodaj;  Z- zavrsi; L - upisi direktno u log fajl (ne salji gateway-u)
 */
 
function Gw(cStr, nHandle, cAkcija)
*{
local nHgw
local cBaza
local cBazaInOut


if gSQL=="N"
	return
endif

cBazaInOut:=ToUnix("C:"+SLASH+"SIGMA")

cBaza:=goModul:cSqlLogBase

//MsgBeep(cBaza + "; gSqlLogBase" + gSqlLogBase)

if (goModul==nil .or. cBaza==nil)
	return
endif

if nHandle==nil
	nHandle:=0
endif

if cAkcija==nil
 	cAkcija:="A"
 	GW_STRING:=""
 	// azuriraj
endif

if (cAkcija=="L" .and. !goModul:lSqlDirektno)
	// nije dopusteno ici direktno
	cAkcija:="A"
	GW_STRING:=""
endif

if  gRadnoPodr<>"RADP"
	// NE VRSI SE LOGIRANJE VAN RADNOG PODRUCJA
	return ""
endif

if cAkcija=="L"
	//upisi direktno u SqlLog
	return GwDirektno(cStr)
endif 


if cAkcija=="A" .or. cAkcija=="Z"
	FERASE(cBazaInOut+SLASH+"out"+SLASH+"komanda")
	FERASE(cBazaInOut+SLASH+"in" +SLASH+"komanda")
endif

do while .t.

	if cAkcija=="A" // odmah sve zavrsi
    		nHgw:=FCREATE(cBazaInOut+SLASH+"out"+SLASH+"komanda")
    		if nHgw>0
      			FWRITE(nHgw,"---"+NRED+cStr)
      			FSEEK(nHgw,0)
      			// upisi zaglavlje ...
      			FWRITE(nHgw,"#H#"+NRED)
      			FCLOSE(nHgw)
      			exit
    		endif

  	elseif cAkcija=="P" 
		// zapocni
       		GW_STRING:="---"+NRED+cStr
       		exit

  	elseif cAkcija=="D" 
		// dodaj
      		GW_STRING+=NRED+cStr
      		exit

  	elseif cAkcija=="Z"  
		// zavrsi
      		if !(cStr=="")
        		GW_STRING+=NRED+cStr
      		endif

      		nHgw:=FCREATE(cBazaInOut+"\out\komanda")
      		
		if nHgw>0
        		nHandle:=nHGw
        		FWRITE(nHgw,GW_STRING)
        		GW_STRING:=""
        		// upisi zaglavlje ...
        		FSEEK(nHGw,0)
        		FWRITE(nHGw,"#H#"+NRED)
        		FCLOSE(nHGw)
      		endif
      		exit

  	endif

enddo

if cAkcija=='A' .or. cAkcija=='Z'
	// uzmi odgovor
 	return GwOdgovor(@cBazaInOut)

else

  	return "..."

endif
return ""
*}

/*! \fn GwOdgovor(cBazaInOut)
 *  \param cBazaInOut  - c:/sigma
 */
static function GwOdgovor(cBazaInOut)
*{
local nGwSec

nHgw:=-100
nGwSec:=seconds()
do while .t.
  	nHgw:=FOPEN(cBazaInOut+"\in\komanda")
  	OL_Yield()
	if nHgw>0
    		exit
	else
    		// napravi ovo samo da bi isprovocirao gateway-a
    		FILECOPY( cBazaInOut+"\out\komanda" , cBazaInOut+"\out\komanda.tmp" )
    		FERASE(cBazaInOut+"\out\komanda.tmp")
    		Sleep(0.2)
 	endif

  	if File(cBazaInOut+"\in\VeryBusy")
		// cekaj dok gateway u potpunosti ne zavrsi posao ...
		// oslobodi resurse
		MsgO("Gateway je VeryBusy ... sacekajte ... ")
	  	do while .t.
			if File(cBazaInOut+"\in\VeryBusy")
		 		// trenutno se vrsi import SQL loga
		 		// pusti GW-a neka radi ...
				Sleep(gVeryBusyInterval)
				Beep(1)
			else
				goModul:oDatabase:scan()
				// pokusajmo ovo sa FIN, ne smijem dirati
				// TOP
				
				MsgC()
				if gModul=="FIN"
					goModul:mMenu()
				endif
				exit
			endif
		enddo
		MsgC()
		  
	else  
		if TimeOutIzaci(@nGwSec)
			exit
		endif

	endif
enddo
	
cBuf:=SPACE(16384)
nRead:=FREAD(nHgw,@cBuf,5)
if LEFT(cBuf,3)="#H#"
	nRead:=FREAD(nHgw,@cBuf,16384)
endif
FCLOSE(nHgw)

ZGwPoruka:=LEFT(cBuf,nRead)
// obradi ovu poruku
GwStaMai(-44)

// vrati rezultat koji ti je gw poslao
return LEFT(cBuf,nRead)



/*! \fn TimeOutIzaci(nGwSec)
 */
 
static function TimeOutIzaci(nGwSec)
*{
private cKom

if (SECONDS()-nGwSec)> 60 + iif(gAppSrv, 60, 0)
	if gAppSrv
		goModul:quit()
	endif
	clear typeahead
	Box(,1,40)
		@ m_x+1,m_y+2 SAY  "Nema in/komanda. Izaci ?"
		inkey(7)
	BoxC()
	do case
		case UPPER(CHR(LASTKEY()))=='D'
			//i ako se radi o podmodulu moramo izaci
			goModul:oParent:=nil
			goModul:quit()
			return .t.
		otherwise
			cKom:="start"+" "+ToUnix("c:\tops\gateway.exe")
			RUN &cKom
			Sleep(5)
			//ponovo inicijalizirati gateway
			Gw("SET SITE "+STR(gSqlSite))
			Gw("SET MODUL "+gModul)
			
	endcase
endif
return .f.
*}


/*! \fn GwStaMai(nBroji2)
 *  \brief
 *  \param nBroji2
 *
 *
 * Svakih 10 sekundi uzima stanje od gateway-a (iz c:/sigma/out)
 *
 * Rezultati:
 *
 * "HOCU_SYNCHRO" - upit udaljene strane za sinhronizaciju
 *
 * "HOCU_SHUTDOWN" - udaljena strana trazi gasenje racunara
 *
 * "Import SQL loga zapocet!" - postavlja globalnu varijablu 
 *                             GW_STATUS := "NA_CEKI_K_SQL"
 *
 *
 *  Kada je GW_STATUS=="NA_CEKI_K_SQL":
 *
 *    -  ZGwPoruka="IMPORTSQL_OK" .or.  ZGwPoruka="DIALUPSRV_IS_OFF"
 *       Prijavi da je zavrsena sinhronizacija
 *
 *    -  ZGwPoruka!="DIALUPSRV_IS_OFF")
 *	  Ako je posljednja procedura IZ_SQL_LOG
 *
 *
 *    Ako je ZGwPoruka=="IMPORTSQL_ERR"
 *
 *       MsgBeep("NEUSPJESNO Zavrsena sinhronizacija  !!!!")
 *     
 *
 *    Ako nije nijedna od navedenih: 
 *       ZGwPoruka:="-"  
 *       GW_STATUS:="-"
 *
 *  endcase
 *
 *
 *
 * \code
 *  nBroji2:=Seconds()
 *  do while .t.
 *    cTmp:=GwStaMai(@nBroji2)
 *    if "U"$type("GW_STATUS") .or. GW_STATUS != "NA_CEKI_K_SQL"
 *       Exit
 *    endif
 *  enddo
 *
 * \endcode
 *
 *
 */

function GwStaMai(nBroji2)
*{
local cRezultat
local xRez
local nOldcursor
local nRow
local nCol

if gSQL="N"
	return "CLP_NISTA"
endif

cRezultat:="CLP_NISTA"

if nBroji2==-1  .or. nBroji2==-44
	// obavezno uzmi stanje

elseif (seconds()-nBroji2) < 10
	return cRezultat
// citanje poruka
//elseif (seconds()-nBroji2) < 500
//	if (IsPlanika() .and. gSamoProdaja=="D" .and. IsNewMsgExists())
//		MsgBeep("Postoje nove poruke !!!")
//		if Pitanje(,"Pregledati poruke (D/N)?","D")=="D"
//			nBroji2:=seconds()
//			ReadMsg(.f.)
//			return cRezultat
//		else
//			nBroji2:=seconds()
//			return cRezultat
//		endif
//	endif

else
   	// resetujemo brojac
   	nBroji2:=seconds()
endif

if nBroji2=-44
 	cRezultat:=ZGwPoruka
else
	if type("gSQLSite")<>"U"
		cRezultat:=Gw("OMSG STA_MAI "+alltrim(str(gSQLSite,0)))
 	endif
 	ZGwPoruka:=cRezultat  // ubiljezi zadnju poruku
endif

if VALTYPE(cRezultat)<>"C"
	return ""
endif

nRow:=row()
nRol:=col()
@ 24,50 SAY padr(cRezultat,30)
@ 24,1 SAY padr(GW_STATUS,30)

#ifdef PROBA
if IzFmkIni("Gateway","Debug","N",EXEPATH)=="D"
	@ 23,1 SAY padr(procname(1),10)
	@ 22,1 SAY padr(procname(2),10)
	@ 21,1 SAY padr(procname(3),10)
	@ 20,1 SAY padr("18:41",10)
endif
#endif

SETPOS(nRow,nCol)

do case

 case LEFT(cRezultat,12)=="HOCU_SYNCHRO"
	cmdHocuSynchro(@cRezultat, @GW_STATUS, @ZGwPoruka)
  
 case left(cRezultat,13)=="HOCU_SHUTDOWN"
	cmdHocuShutdown(@cRezultat, @GW_STATUS, @ZGwPoruka)
	
 case GW_STATUS<>"NA_CEKI_K_SQL" .and. LEFT(cRezultat,14)="IMPORTSQL_STAT"
       cmdImportStat(@cRezultat, @GW_STATUS, @ZGwPoruka)

 case  (cRezultat=="Import SQL loga zapocet!")
       CLOSE ALL
       GW_STATUS:="NA_CEKI_K_SQL"

 case (GW_STATUS=="NA_CEKI_K_SQL")
	cmdNaCekiSql(@cRezultat, @GW_STATUS, @ZGwPoruka)

endcase

return cRezultat
*}


static function cmdHocuSynchro(cRezultat, GW_STATUS, ZGwPoruka)
*{

Beep(6)
MsgBeep("Zahtjev:" + cRezultat)

public gRemoteSite

gRemoteSite:=val(substr(cRezultat,13))
clear typeahead
Box(,1,50)
	@ m_x+1,m_y+2 SAY "Omoguciti ? "
     	inkey(3)
BoxC()
 
if UPPER(CHR(LASTKEY()))=="N"
       Gw("OMSG SACEKAJ")
       cRezultat:="OTKAZAO_SYNCHRO"
       GW_STATUS:="-"
else


       // prihvatio sam zahtjev za sinhronizacijom, stavljam program na cekanje
       
       CLOSE ALL
       Keyboard chr(K_ESC)+chr(K_ESC)+chr(K_ESC)+chr(K_ESC)+chr(K_ESC)+chr(K_ESC)
       Gw("OMSG OK_SYNCHRO")
       GW_STATUS:="NA_CEKI_K_SQL"


endif
return
*}

static function cmdHocuShutdown(cRezultat, GW_STATUS, ZGwPoruka)
*{
   
Beep(6)
MsgBeep("Udaljena strana "+substr(cRezultat,13)+" ugasiti racunar.")
clear typeahead
Box(,1,40)
	@ m_x+1,m_y+2 SAY "Omoguciti     ? "
	inkey(3.5)
BoxC()
   
if upper(chr(lastkey()))=="N"
	Gw("OMSG SACEKAJ")
else
	close all
	Gw("OMSG OK_SHUTDOWN")
	goModul:quit()
endif

return
*}

static function cmdImportStat(cRezultat,GW_STATUS, ZGwPoruka)
*{

// ali GW_STATUS nije NA_CEKI_K_SQL
Beep(1)
MsgBeep("U toku import sql:"+cRezultat)

return
*}

static function cmdNaCekiSql(cRezultat, GW_STATUS, ZGwPoruka)
*{

do case

case ZGwPoruka="IMPORTSQL_OK" .or.  ZGwPoruka="DIALUPSRV_IS_OFF"
        cmdZavrsenaSyn(@cRezultat, @GW_STATUS, @ZGwPoruka)
       	
case  ZGwPoruka=="IMPORTSQL_ERR"
	cmdImpSqlError(@cRezultat, @GW_STATUS, @ZGwPoruka)
	

case LEFT(cRezultat,14)="IMPORTSQL_STAT"

        //@  m_x+4,m_y+2 SAY  "ZP: "+padr(ZGwPoruka,40)

otherwise
        ZGwPoruka:="-"  // poruka je obradjena
        GW_STATUS:="-"

endcase

return
*}

static function cmdZavrsenaSyn(cRezultat, GW_STATUS, ZGwPoruka)
*{

GW_STATUS:="-"
Beep(5)
MsgBeep("Zavrsena sinhronizacija  !!!!")
Beep(5)
MsgBeep("Zavrsena sinhronizacija  !!!!!!!!!")

if (ZGwPoruka=="IMPORTSQL_OK")
	  
	close all
	goModul:oDatabase:open()
	  
	ZGwPoruka:="-"  // poruka je obradjena
	GW_STATUS:="-"

	if procname(1)="IZ_SQL_LOG"  .or. procname(2)="IZ_SQL_LOG" .or. procname(3)="IZ_SQL_LOG"
		
	else
		KEYBOARD chr(K_ESC)+chr(K_ESC)+chr(K_ESC)+chr(K_ESC)+chr(K_ESC)+chr(K_ESC)
	endif

	endif

         ZGwPoruka:="-"  // poruka je obradjena
         GW_STATUS:="-"

return
*}


static function cmdImpSqlError(cRezultat, GW_STATUS, ZGwPoruka)
*{
Beep(5)
MsgBeep("NEUSPJESNO Zavrsena sinhronizacija  !!!!")
Beep(5)
MsgBeep("NEUSPJESNO Zavrsena sinhronizacija  !!!!!!!!!")
GW_STATUS:="-"
close all

Box(,2,40)
          @ m_X+1,m_y+2 SAY "Reindeksiram podatke:"
          goModul:oDatabase:reindex()        
BoxC()
Beep(10)

goModul:oDatabase:open()

ZGwPoruka:="-"  // poruka je obradjena
GW_STATUS:="-"

if procname(1)="IZ_SQL_LOG"  .or. procname(2)="IZ_SQL_LOG" .or. procname(3)="IZ_SQL_LOG"
else
	KEYBOARD chr(K_ESC)+chr(K_ESC)+chr(K_ESC)+chr(K_ESC)+chr(K_ESC)+chr(K_ESC)
endif

return
*}

function ZGwPoruka()
*{
// uzmi trenutno stanje ...
GwStamai(-1)
return ZGwPoruka
*}


function GW_STRING()
*{
return GW_STRING
*}



/*! \fn GwDirektno(cSql)
 *  \brief Upisuje SQL komandu u log fajl direktno
 */

function GwDirektno(cSql)
*{

local nHLog
local cLogName

if (gSQL=="N")
	return ""
endif

if VALTYPE(goModul:cSqlLogBase)<>"C"
	MsgBeep("Nije definisan cSqlLogBase ?? ##Ne mogu izvrsiti:#" + cSql)
	return
endif

if VALTYPE(GetSqlSite())<>"N"
	MsgBeep("Nije definisan SqlSite ?? ##Ne mogu izvrsiti:#" + cSql)
endif

cLogName:=goModul:cSqlLogBase+'\SQL\'+ALLTRIM(STR(GetSqlSite()))+'.log'
//MsgBeep("GwDirektno:"+cLogName)

nHLog:=OpenLog(cLogName)
if nHLog==-999
	MsgBeep("Izlazim iz programa ....")
	goModul:quit()
endif

FSEEK(nHLog,0,FS_END)
FWRITE(nHLog,cSql+NRED)
FCLOSE(nHLog)
return ""
*}

static function OpenLog(cLogName)
*{
local nHLog

if !FILE(cLogName)
	do while .t.
		nHLog:=FCREATE(cLogName)
		if nHLog>0
			return nHLog
		else
			MsgBeep("Ne mogu kreirati log#"+cLogName+"## !?????")
			if Pitanje(,"Pokusati ponovo ?"," ")=="N"
				return -999
			endif
    		endif
	enddo
else
	do while .t.
		nHLog:=FOPEN(cLogName,2)
		if nHLog>0
			return nHLog
		else
			MsgBeep("Ne mogu otvoriti log#"+cLogName+"## !?????")
			if Pitanje(,"Pokusati ponovo ?","D")=="N"
				return -999
			endif
    		endif
	enddo
endif
return
*}

function GwDiskFree()
*{
local cOdgovor

cOdgovor:=Gw('GETINFO DISKFREE')
//MsgBeep(cOdgovor)

return VAL(cOdgovor)	
*}
