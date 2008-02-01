#include "fmk.ch"

 
function sql_repl(cField, xxVar, nHandle, cAkcija )
*{
local i,nh,cSQL

if (gSQL=="N" .or. fieldpos("_OID_")==0)
	return .f.
endif
if goModul:lSqlDirektno
	cAkcija:="L"
endif

cSQL:="update "+alias()+" set "+cfield+"="+SqlValue(xxVar)+;
      " where _OID_="+SQLValue(Oid2Num(field->_OID_),0)
Gw(cSQL, @nHandle, cAkcija )
return .t.
*}

function sql_append( nHandle, cAkcija )
*{
local i,nh, cSQL

if (gSQL=="N" .or. fieldpos("_OID_")==0)
	return .f.
endif
if goModul:lSqlDirektno
	cAkcija:="L"
endif

cSQL:="insert into "+ALIAS()+" (_OID_) values("+sqlvalue(oid2num(field->_OID_),0)+")"

Gw(cSQL, @nHandle, cAkcija )

return .t.
*}

function sql_delete(cTip, nHandle, cAkcija)
*{
local i,nh, cSQL

if fieldpos("_SITE_")==0
   return .f.
endif

if (gSQL=="N" .or. fieldpos("_OID_")==0)
	return .f.
endif
if goModul:lSqlDirektno
	cAkcija:="L"
endif

cSQL:="delete from "+alias()+" where _oid_="+sqlvalue(oid2num(field->_OID_))

if cTip==nil
	cTIP:="DBF"
endif

if cTip=="DBF"
  	// setuj polje brisano
	replsql BRISANO with "1"
endif
Gw(cSQL, @nHandle, cAkcija )
return .t.
*}


function GathSQL(cZnak,fAppend, nHandle, cAkcija)
*{
local i,j,aStruct
private cVar

if gSQL=="N" .or. fieldpos("_OID_")=0
  return
endif

if cZnak==NIL
  cZnak:="_"
endif

if fAppend==NIL
 fAppend:=.f.
endif


if fAppend
 cSQL:="insert into "+alias()
else
 cSQL:="update "+alias()
endif

aStruct:=DBSTRUCT()
nSet:=0

for i:=1 to len(aStruct)
  cImeP:=aStruct[i,1]
  cVar:=cZnak+cImeP
  if  !("#"+cImeP+"#" $ "#BRISANO#_OID_#_COMMIT_#")
    if cImeP=="_SITE_"
      cSQL:=cSQL+iif(nSet=0," SET ",",")+cImeP+"="+SQLValue(gSQLSite)
    elseif cImeP=="_USER_"
      cSQL:=cSQL+iif(nSet=0," SET ",",")+cImeP+"="+SQLValue(gSQLUser)
    elseif cImeP=="_TIMEAZ_"
      cSQL:=cSQL+iif(nSet=0," SET ",",")+cImeP+"="+SQLValue(Time())
    elseif cImeP=="_DATAZ_"
      cSQL:=cSQL+iif(nSet=0," SET ",",")+cImeP+"="+SQLValue(Date())
    else
      cSQL:=cSQL+iif(nSet=0," SET ",",")+cImeP+"="+SQLValue(&cVar)
    endif
    nSet++
  endif
  if fAppend .and. (cImeP=="_OID_")
    cSQL:=cSQL+iif(nSet=0," SET ",",")+cImeP+"="+SQLValue(field->_OID_)
    nSet++
  endif
next

if !fAppend
 cSQL:=cSql+" where _OID_="+SqlValue(field->_OID_)
endif

if goModul:lSqlDirektno
	cAkcija:="L"
endif
Gw(cSQL, @nHandle, cAkcija)
return
*}



/*! \fn sql_azur(fLock)
 *  \brief
 *  \param fLock - True - zakljucaj record u koji upisujes; False - vec je zakljucan, default value
 *  \return True - uspjesno, False - neuspjesno
 */
 
function sql_azur(fLock)
*{
if gSQL=="N"
	return .f.
endif

if fieldpos("_SITE_")==0
	return .f.
endif

if flock==nil
	fLock:=.f.
endif

if fLock
	do while .not. rlock()
		inkey(0.4)
	enddo
endif

field->_SITE_:=gSQLSite
field->_USER_:=gSQLUser
field->_TIMEAZ_:=TIME()
field->_DATAZ_:=DATE()

if fLock
   UNLOCK
endif
return .t.
*}


function SQLValue(xVar,nDec, cKonv)
*{
local cPom, cChar, cChar2, nStat,ilok

if cKonv=NIL
  cKonv:="DBF"
endif

if valtype(xVAR)="C"
   if cKonv=="DBF"
     cPom:=""
     nStat:=0
     for ilok:=1 to len(xVar)
        cChar:=substr(xVar,ilok,1)
        cChar2:="CHAR("+alltrim(str(asc(cChar)))+")"
        if ASC(cChar)=39 .or. ASC(cChar)>127 // "'"
           if nStat=0
             cPom:=cChar2
           elseif nStat=1
             cPom:=cPom+"'+"+cChar2
           elseif nStat=2
             cPom:=cPom+"+"+cChar2
           endif
           nStat:=2
        else
           if nStat=0
             cPom:="'"+cChar
           elseif nStat=1
             cPom:=cPom+cChar
           else
             cPom:=cPom+"+'"+cChar
           endif
           nstat:=1
        endif
     next
     if nStat=0
        cPom:="''"
     elseif nStat=1
        cPom:=cPom+"'"
     elseif nStat=2
        // nista ... gotovo je
     endif
   endif
   return cPom
elseif valtype(xVAR)="N"
   if nDec<>NIL
     return alltrim(str(xVar,25,nDec))
   else
     return alltrim(str(xVar))
   endif
elseif valtype(xVar)="D"
   cPom:=dtos(xVar)
   if empty(cPom)
     cPom:=replicate('0',8)
   endif
   //1234-56-78
   cPom:="'"+substr(cPom,1,4)+"-"+substr(cPom,5,2)+"-"+substr(cPom,7,2)+"'"
   return cPom
else
   return "NULL"
endif
*}


/*! \fn New_OID()
 *  \brief utvrdjuje novi OID (Object identification)
 */
 
function New_OID()
*{
local nPom

PushWa()
select(F_SQLPAR)
if !used()
    O_SQLPAR
endif

do while .not. RLOCK()
    // moras lockovati tekuci slog !!
    inkey(0.4)
enddo
nPom:=_OID_TEK
nPom++
if (nPom>_OID_KRAJ)
     MsgBeep("Opseg za OID, iscrpljen ???????")
else
     //setuj novi oid
     field->_OID_TEK:= nPom
endif
UNLOCK

PopWa()
return nPom
*}

function Last_OID()
*{
local nPom
PushWa()
set order to tag "_OID_"
go bottom
if empty(field->_OID_)
  nPom:=0
else
  nPom:=Oid2Num(field->_OID_)
endif
PopWa()
return Num2Oid(nPom+1) // novi OID
*}

/*! \fn Oid2Num(cOID)
 *  \todo izbaciti ovu funkciju - nepotrebna
 */
function Oid2Num(cOID)
*{
local i,nPom
return cOID
*}

/*! \fn Num2Oid(cOID)
 *  \todo izbaciti ovu funkciju - nepotrebna
 */
function Num2Oid(nOid)
*{
return nOid
*}

function sql_log(cSQL, nHandle, cAkcija )
*{
local i
i:=0
Gw(cSQL, @nHandle, cAkcija )
return
*}
