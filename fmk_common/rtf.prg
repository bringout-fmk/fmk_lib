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


#define NL Chr(13)+Chr(10)
#define MM 56.69895

/****h SC_CLIB/RTF_UT ***
 
*AUTOR
  Ernad Husremovic, ernad@sigma-com.net

*IME 
  RTF_UT

*OPIS
  Funkcije za generaciju rtf dokumenata

*DATUM
  04.2002

****/


*
*
*   aRow[1] = { 10 mm, { "b", "s", 0.1 } , { "t", "s", 0.1} }
*   pozicija s lijeva

function WWRowDef(aRows,nLeft,ntrgaph,nHigh)

local nrow,i

?? "\trowd "
if nTrGaph==NIL
  nTrGaph:=1
endif
?? "\trgaph"+Top(nTrgaph)

if nLeft==NIL
 nLeft:=0
endif
?? "\trleft"+ToP(nLeft)

if nHigh<>NIL
 ?? "\trrh"+ToP(nHigh)
endif

nTekPos:=nLeft
for nrow:=1 to len(aRows)
   for i:=2 to len(aRows[nRow])
     ?? "\clbrdr"+aRows[nRow,i,1]
     ?? "\brdr"+aRows[nRow,i,2]
     ?? "\brdrw"+ToP(aRows[nRow,i,3])
   next
   nTekPos+=aRows[nRow,1]
   ?? "\cellx"+ToP(nTekPos)+NL
next
?? "\pard\intbl "
return


function WWCells(aCells)
*
*

for i:=1 to len(aCells)
 ?? aCells[i]+"\cell "
next
?? "\pard\intbl\row"+NL


function WWTBox(nL,nT,nWX,nWY,cTxt,cTipL,aCL,nWL,;
                aCF,aCB,cPatt)
*
*

?? "{\*\do\dobxpage\dobypage\dptxbx\dptxbxmar20{\dptxbxtext \pard\plain"+NL
??  cTxt+"\par}"+NL
?? "\dpx"+ToP(nL)+"\dpy"+ToP(nT)+"\dpxsize"+ToP(nWX)+"\dpysize"+ToP(nWY)
?? "\dpline"
if cTipL=="0"
  ?? "hollow"
elseif cTipL=="1"
  ?? "solid"
elseif cTipL=="2"
  ?? "dadodo"
elseif cTipL=="3"
  ?? "dado"
elseif cTipL=="4"
  ?? "dot"
elseif cTipL=="5"
  ?? "hash"
endif
?? "\dplinecor"+alltrim(str(aCL[1],3,0))
?? "\dplinecog"+alltrim(str(aCL[2],3,0))
?? "\dplinecob"+alltrim(str(aCL[3],3,0))
?? "\dplinew"+ToP(nWL)
?? "\dpfillfgcr"+alltrim(str(aCF[1],3,0))
?? "\dpfillfgcg"+alltrim(str(aCF[2],3,0))
?? "\dpfillfgcb"+alltrim(str(aCF[3],3,0))
?? "\dpfillbgcr"+alltrim(str(aCB[1],3,0))
?? "\dpfillbgcg"+alltrim(str(aCB[2],3,0))
?? "\dpfillbgcb"+alltrim(str(aCB[3],3,0))
?? "\dpfillpat"+cPatt+"}"+NL




function WWInit0()
*

?? "{\rtf1\ansi\ansicpg1250\deff4\deflang1050"
return nil


function WWinit1()
*

?? "\windowctrl\ftnbj\aenddoc\formshade \fet0\sectd\linex0\endnhere\pard\plain\f1\fs20"+NL
return nil



function WWFontTbl()
*

?? "{\fonttbl{\f1\fswiss\fcharset238\fprq2 Arial CE;}{\f2\fswiss\fcharset238\fprq2 "+trim(gPFont)+";}}"
?? NL
return


function WWStyleTbl()
*

?? "{\stylesheet {\f2\fs20 \snext0 Normal;}{\*\cs10 \additive Default Paragraph Font;}"
?? "{\s20\qc\sb40\sa0\sl-400\slmult0 \f2\fs20 \sbasedon0\snext20 estyle1;}}"+NL




function WWEnd()
?? "\par}"


function WWSetMarg(nLeft,nTop,nRight,nBottom)
*

if nLeft<>NIL
 ?? "\marglsxn"+ToP(nLeft)
endif
if nRight<>NIL
 ?? "\margrsxn"+ToP(nRight)
endif
if nTop<>NIL
 ?? "\margtsxn"+ToP(nTop)
endif
if nTop<>NIL
 ?? "\margbsxn"+ToP(nBottom)
endif




function ToP(nMilim)
*

return alltrim( str (round(nMilim*MM,0)) )


function ToRtfstr(cStr)

local cPom,i,cChar
cPom:=""
for i:=1 to len(cStr)
  cChar:=substr(cStr,i,1)
  if cChar=="{"
    cPom+="\{"
  elseif cChar=="}"
    cPom+="\}"
  elseif cChar=="\"
    cPom+="\\"
  elseif cChar $ "Á"
    cPom+="\'9a"
  elseif cChar $ "Ê"
    cPom+="\'8a"
  elseif cChar $ "Ü"
    if gWord97=="D"
     cPom+="\u263\'63"
    else
     cPom+="\'e6"
    endif
  elseif cChar $ "è"
    if gWord97=="D"
     cPom+="\u262\'43"
    else
     cPom+="\'c6"
    endif
  elseif cChar $ "ü"
    if gWord97=="D"
     cPom+="\u269\'63"
    else
     cPom+="\'e8"
    endif
  elseif cChar $ "¨"
    if gWord97=="D"
     cPom+="\u268\'43"
    else
     cPom+="\'c8"
    endif
  elseif cChar $ "–"
    if gWord97=="D"
     cPom+="\u273\'64"
    else
     cPom+="\'f0"
    endif
  elseif cChar $ "—"
    if gWord97=="D"
     cPom+="\u272\'do"
    else
     cPom+="\'d0"
    endif
  elseif cChar $ "ß"
    cPom+="\'9e"
  elseif cChar $ "¶"
    cPom+="\'8e"
  elseif substr(cStr,i,2)==NL
    cPom+="\par "
    ++i
  else
    cPom+=substr(cStr,i,1)
  endif
next
return cPom


function WWSetPage(cFormat,cPL)
*
*

if upper(cFormat)=="A4"
  if cpl==NIL .or. upper(cPL)="P" // portrait
     ?? "\pgwsxn11907\pghsxn16840"
  else
     ?? "\pgwsxn16840\pghsxn11907"
  endif

elseif upper(cFormat)=="A3"
  if cpl==NIL .or. upper(cPL)="P" // portrait
     ?? "\pgwsxn16839\pghsxn23814"
  else
     ?? "\pgwsxn23814\pghsxn16839"
  endif
endif
return NIL


function WWInsPict(cIme,cPath)

if cpath=NIL
  cPath:="c:/sigma/"
else
 cPath:=strtran(cpath,"\","/")  // rtf to trazi
endif
?? "{\field{\*\fldinst { INCLUDEPICTURE "+cpath+cime+"\\d  \\* MERGEFORMAT }}\par}"
return

