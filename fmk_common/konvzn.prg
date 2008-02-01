#include "fmk.ch"

FUNCTION KonvZnWin(cTekst, cWinKonv)
*
 //LOCAL aNiz:={  {"[","Ê","\'8a","S"}, {"{","Á","\'9a","s"}, {"}","Ü","\'e6","c"}, {"]","è", "\'c6","C"}, {"^","¨", "\'c8","C"},;
 //                {"~","ü","\'e8","c"}, {"`","ß","\'9e","z"}, {"@","¶","\'8e","Z"}, {"|","–", "\'f0","dj"}, {"\","—", "\'d0","DJ"}  }

 LOCAL aNiz:={  {"[","Ê",chr(138),"S"}, {"{","Á",chr(154),"s"}, {"}","Ü",chr(230),"c"}, {"]","è", chr(198),"C"}, {"^","¨", chr(200),"C"},;
                {"~","ü",chr(232),"c"}, {"`","ß",chr(158),"z"}, {"@","¶",chr(142),"Z"}, {"|","–", chr(240),"dj"}, {"\","—", chr(208),"DJ"}  }
 LOCAL i,j

 if cWinKonv=NIL
  cWinKonv:=IzFmkIni("DelphiRb","Konverzija","5")
 endif

 i:=1; j:=1
 if cWinKonv=="1"
    i:=1; j:=2
 elseif cWinKonv=="2"
    i:=1; j:=4  // 7->A
 elseif cWinKonv=="3"
    i:=2; j:=1   // 852->7
 elseif cWinKonv=="4"
    i:=2; j:=4  // 852->A
 elseif cWinKonv=="5"
    i:=2; j:=3  // 852->win1250
 elseif cWinKonv=="6"
    i:=1; j:=3  // 7->win1250
 endif
 if i<>j
  AEVAL(aNiz,{|x| cTekst:=STRTRAN(cTekst,x[i],x[j])})
 endif

RETURN cTekst


/*! \fn StrKZN(cInput, cIz, cU)
 *  \brief Vrsi zamjenu cInputa
 */
 
function StrKZN(cInput,cIz,cU)
*{
local a852:={"Ê","—","¨","è","¶","Á","–","ü","Ü","ß"}
local a437:={"[","\","^","]","@","{","|","~","}","`"}
local aEng:={"S","D","C","C","Z","s","d","c","c","z"}
local aEngB:={"SS","DJ","CH","CC","ZZ","ss","dj","ch","cc","zz"}
local i:=0, aIz:={}, aU:={}

// sasa, 04.02.04, konverzija "B"
if cIz=="7"
	aIz:=a437
elseif cIz=="8"
	aIz:=a852
elseif (goModul:oDataBase:cName=="LD" .and. cIz=="B")
	aIz:=aEngB
else
	aIz:=aEng
endif

if cU=="7"
	aU:=a437
elseif cU=="8"
	aU:=a852
elseif goModul:oDataBase:cName=="LD" .and. cU=="B"
	aU:=aEngB
else
	aU:=aEng
endif

// Ove dvije linije zamjenio sa gornjim kodom
// aIz:=IF(cIz=="7", a437, IF(cIz=="8", a852, aEng))
// aU:=IF(cU=="7", a437, IF(cU=="8", a852, aEng))

cPocStanjeSif:=cInput

for i:=1 to 10
	if (goModul:oDataBase:cName=="LD" .and. i==5)
		if AT("D@", cInput)<>0
			cInput:=STRTRAN(cInput, "D@", "DZ")
		elseif AT("D|", cInput)<>0
			cInput:=STRTRAN(cInput, "D|", "DZ")
		endif
	endif
	if (goModul:oDataBase:cName=="LD" .and. i==10)
		if AT("dß", cInput)<>0
			cInput:=STRTRAN(cInput, "dß", "dz")
		elseif AT("d`", cInput)<>0
			cInput:=STRTRAN(cInput, "d`", "dz")
		endif
	endif

	cInput:=STRTRAN(cInput,aIz[i],aU[i])
next


if (cU=="B" .and. LEN(ALLTRIM(cInput)) > 6)
	altd()
	// provjeri da li ovaj par postoji u nizu
	nPos:=ASCAN(aKonvZN, {|aVal| aVal[1] == cPocStanjeSif})
	if nPos > 0
		cRet:=aKonvZN[nPos, 2]
	else
		cNoviId:=SPACE(6)
		Box(,3,25)
		@ 1+m_x, 2+m_y SAY "Unesi novi ID za sifru: "
		@ 2+m_x, 2+m_y SAY "Stari ID: " + cPocStanjeSif
		@ 3+m_x, 2+m_y SAY "Novi ID: " GET cNoviID
		read
		BoxC()
		AADD(aKonvZN, {cPocStanjeSif, cNoviId})
		cRet:=cNoviID
	endif
else
	cRet:=cInput
endif

cKrajnjeStanjeSif:=cRet

return cRet
*}


function KSto7(cStr)
  cStr:=strtran(cStr,"Á","{")
  cStr:=strtran(cStr,"–","|")
  cStr:=strtran(cStr,"ß","`")
  cStr:=strtran(cStr,"ü","~")
  cStr:=strtran(cStr,"Ü","}")
  cStr:=strtran(cStr,"è","[")
  cStr:=strtran(cStr,"—","\")
  cStr:=strtran(cStr,"¶","@")
  cStr:=strtran(cStr,"¨","^")
  cStr:=strtran(cStr,"è","]")
return cStr

* ako je gPTKonv == 0   nema konverzije
* ako je gPTKonv == 1   7bih - 852
* ako je gPTKonv == 2   7bih - Americki
* ako je gPTKonv == 3   852 -  7bih
* ako je gPTKonv == 4   852 -  Americki

function KonvTable(fGraf)
if left(gPTKonv,1)=="0"
 SetPxLat()
elseif left(gPTKonv,1)=="1"
 SetPxLat(ASC("["),"Ê"  )
 SetPxLat(ASC("{"),"Á"  )
 SetPxLat(ASC("}"),"Ü"  )
 SetPxLat(ASC("]"),"è"  )
 SetPxLat(ASC("^"),"¨" )
 SetPxLat(ASC("~"),"ü" )
 SetPxLat(ASC("`"),"ß" )
 SetPxLat(ASC("@"),"¶" )
 SetPxLat(ASC("|"),"–" )
 SetPxLat(ASC("\"),"—" )
elseif left(gPTKonv,1)=="2"
 SetPxLat(ASC("["),"S"  )
 SetPxLat(ASC("{"),"s"  )
 SetPxLat(ASC("}"),"c"  )
 SetPxLat(ASC("]"),"C"  )
 SetPxLat(ASC("^"),"C" )
 SetPxLat(ASC("~"),"c" )
 SetPxLat(ASC("`"),"z" )
 SetPxLat(ASC("@"),"Z" )
 SetPxLat(ASC("|"),"d" )
 SetPxLat(ASC("\"),"D" )
elseif left(gPTKonv,1)=="3"
 SetPxLat(ASC("Ê"),"["  )
 SetPxLat(ASC("Á"),"{"  )
 SetPxLat(ASC("Ü"),"}"  )
 SetPxLat(ASC("è"),"]"  )
 SetPxLat(ASC("¨"),"^" )
 SetPxLat(ASC("ü"),"~" )
 SetPxLat(ASC("ß"),"`" )
 SetPxLat(ASC("¶"),"@" )
 SetPxLat(ASC("–"),"|" )
 SetPxLat(ASC("—"),"\" )
elseif left(gPTKonv,1)=="4"
 SetPxLat(ASC("Ê"),"S"  )
 SetPxLat(ASC("Á"),"s"  )
 SetPxLat(ASC("Ü"),"c"  )
 SetPxLat(ASC("è"),"C"  )
 SetPxLat(ASC("¨"),"C" )
 SetPxLat(ASC("ü"),"c" )
 SetPxLat(ASC("ß"),"z" )
 SetPxLat(ASC("¶"),"Z" )
 SetPxLat(ASC("–"),"d" )
 SetPxLat(ASC("—"),"D" )
endif

if fGraf<>NIL .or. substr(gPtkonv,2,1)="1"
 SetPxLat(ASC("ƒ"),"-" )
 SetPxLat(ASC("≥"),":" )
 SetPxLat(ASC("⁄"),"+" )
 SetPxLat(ASC("¿"),"+" )
 SetPxLat(ASC("ø"),"+" )
 SetPxLat(ASC("Ÿ"),"+" )
 SetPxLat(ASC("ﬂ"),"=" )
 SetPxLat(ASC("…"),"+" )
 SetPxLat(ASC("…"),"+" )
 SetPxLat(ASC("ª"),"+" )
 SetPxLat(ASC("Ã"),"+" )
 SetPxLat(ASC("π"),"+" )
 SetPxLat(ASC("»"),"+" )
 SetPxLat(ASC("º"),"+" )
 SetPxLat(ASC("∫"),":" )
 SetPxLat(ASC("≈"),"+" )
 SetPxLat(ASC("√"),"+" )

 SetPxLat(ASC("√"),"+" )
 SetPxLat(ASC("¥"),"+" )
 SetPxLat(ASC("¬"),"+" )
 SetPxLat(ASC("¡"),"+" )
endif



FUNCTION BHSORT(cInput)
 IF gKodnaS=="7"
   cInput:=STRTRAN(cInput,"[","S"+CHR(255))
   cInput:=STRTRAN(cInput,"\","D"+CHR(255))
   cInput:=STRTRAN(cInput,"^","C"+CHR(254))
   cInput:=STRTRAN(cInput,"]","C"+CHR(255))
   cInput:=STRTRAN(cInput,"@","Z"+CHR(255))
   cInput:=STRTRAN(cInput,"{","s"+CHR(255))
   cInput:=STRTRAN(cInput,"|","d"+CHR(255))
   cInput:=STRTRAN(cInput,"~","c"+CHR(254))
   cInput:=STRTRAN(cInput,"}","c"+CHR(255))
   cInput:=STRTRAN(cInput,"`","z"+CHR(255))
 ELSE  // "8"
   cInput:=STRTRAN(cInput,"Ê","S"+CHR(255))
   cInput:=STRTRAN(cInput,"—","D"+CHR(255))
   cInput:=STRTRAN(cInput,"¨","C"+CHR(254))
   cInput:=STRTRAN(cInput,"è","C"+CHR(255))
   cInput:=STRTRAN(cInput,"¶","Z"+CHR(255))
   cInput:=STRTRAN(cInput,"Á","s"+CHR(255))
   cInput:=STRTRAN(cInput,"–","d"+CHR(255))
   cInput:=STRTRAN(cInput,"ü","c"+CHR(254))
   cInput:=STRTRAN(cInput,"Ü","c"+CHR(255))
   cInput:=STRTRAN(cInput,"ß","z"+CHR(255))
 ENDIF
RETURN PADR(cInput,100)

