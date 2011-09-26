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

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/sclib/sql/1g/sql_db.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.5 $
 * $Log: sql_db.prg,v $
 * Revision 1.5  2003/01/15 12:39:10  ernad
 * bug 2003
 *
 * Revision 1.4  2002/06/25 23:46:15  ernad
 *
 *
 * pos, prenos pocetnog stanja
 *
 * Revision 1.3  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.2  2002/06/19 19:51:00  ernad
 *
 *
 * rad u sezonama, gateway
 *
 *
 */
 

function OKreSQLPAr(cPom)
*{
local nOid1, nOid2

if goModul:oDatabase:cRadimUSezona<>"RADP"
	return 0
endif

if !file(ToUnix(cPom+"\SQLPAR.DBF"))
 //sql parametri
 aDbf := {}
 AADD (aDbf, {"_OID_POC",   "N", 12, 0})
 AADD (aDbf, {"_OID_KRAJ",  "N", 12, 0})
 AADD (aDbf, {"_OID_TEK",   "N", 12, 0})
 AADD (aDbf, {"_SITE_",    "N",  2, 0})
 AADD (aDbf, {"K1",   "C", 20, 0})
 AADD (aDbf, {"K2",   "C", 20, 0})
 AADD (aDbf, {"K3",   "C", 20, 0})
 Dbcreate2 (cPom+"\SQLPAR.DBF",aDBF)

 O_SQLPAR
 append blank

 do while .t.
 nOid1:=nOid2:=0
 nSite:=1
 Box(,3,40)
   @ m_x+1,m_y+2 SAY "Inicijalni _OID_" GET nOid1 PICTURE "999999999999"
   @ m_x+2,m_y+2 SAY "Krajnji    _OID_" GET nOid2 PICTURE "999999999999" valid nOid2>nOid1
   @ m_x+3,m_y+2 SAY "Site            " GET nSite PICTURE "99"
   read
 BoxC()

 if pitanje(,"Jeste li sigurni ?","N")=="D"
   replace _oid_poc with nOid1, _oid_kraj with nOid2, _oid_tek with nOid1, _SITE_ with nSite
   exit
 else
   loop
 endif
 enddo

 MsgBeep("SQL parametri inicijalizirani#Pokrenuti ponovo program")
 goModul:quit()

else
 O_SQLPAR
endif

*}

function GetSqlSite()
*{
if gSQL=="D"
	return gSQLSite
else
	return 0
endif
*}
