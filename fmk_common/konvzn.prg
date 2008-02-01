#include "fmk.ch"

FUNCTION KonvZnWin(cTekst, cWinKonv)
*
 //LOCAL aNiz:={  {"[","�","\'8a","S"}, {"{","�","\'9a","s"}, {"}","�","\'e6","c"}, {"]","�", "\'c6","C"}, {"^","�", "\'c8","C"},;
 //                {"~","�","\'e8","c"}, {"`","�","\'9e","z"}, {"@","�","\'8e","Z"}, {"|","�", "\'f0","dj"}, {"\","�", "\'d0","DJ"}  }

 LOCAL aNiz:={  {"[","�",chr(138),"S"}, {"{","�",chr(154),"s"}, {"}","�",chr(230),"c"}, {"]","�", chr(198),"C"}, {"^","�", chr(200),"C"},;
                {"~","�",chr(232),"c"}, {"`","�",chr(158),"z"}, {"@","�",chr(142),"Z"}, {"|","�", chr(240),"dj"}, {"\","�", chr(208),"DJ"}  }
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



function KSto7(cStr)
  cStr:=strtran(cStr,"�","{")
  cStr:=strtran(cStr,"�","|")
  cStr:=strtran(cStr,"�","`")
  cStr:=strtran(cStr,"�","~")
  cStr:=strtran(cStr,"�","}")
  cStr:=strtran(cStr,"�","[")
  cStr:=strtran(cStr,"�","\")
  cStr:=strtran(cStr,"�","@")
  cStr:=strtran(cStr,"�","^")
  cStr:=strtran(cStr,"�","]")
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
 SetPxLat(ASC("["),"�"  )
 SetPxLat(ASC("{"),"�"  )
 SetPxLat(ASC("}"),"�"  )
 SetPxLat(ASC("]"),"�"  )
 SetPxLat(ASC("^"),"�" )
 SetPxLat(ASC("~"),"�" )
 SetPxLat(ASC("`"),"�" )
 SetPxLat(ASC("@"),"�" )
 SetPxLat(ASC("|"),"�" )
 SetPxLat(ASC("\"),"�" )
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
 SetPxLat(ASC("�"),"["  )
 SetPxLat(ASC("�"),"{"  )
 SetPxLat(ASC("�"),"}"  )
 SetPxLat(ASC("�"),"]"  )
 SetPxLat(ASC("�"),"^" )
 SetPxLat(ASC("�"),"~" )
 SetPxLat(ASC("�"),"`" )
 SetPxLat(ASC("�"),"@" )
 SetPxLat(ASC("�"),"|" )
 SetPxLat(ASC("�"),"\" )
elseif left(gPTKonv,1)=="4"
 SetPxLat(ASC("�"),"S"  )
 SetPxLat(ASC("�"),"s"  )
 SetPxLat(ASC("�"),"c"  )
 SetPxLat(ASC("�"),"C"  )
 SetPxLat(ASC("�"),"C" )
 SetPxLat(ASC("�"),"c" )
 SetPxLat(ASC("�"),"z" )
 SetPxLat(ASC("�"),"Z" )
 SetPxLat(ASC("�"),"d" )
 SetPxLat(ASC("�"),"D" )
endif

if fGraf<>NIL .or. substr(gPtkonv,2,1)="1"
 SetPxLat(ASC("�"),"-" )
 SetPxLat(ASC("�"),":" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"=" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),":" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )

 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
 SetPxLat(ASC("�"),"+" )
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
   cInput:=STRTRAN(cInput,"�","S"+CHR(255))
   cInput:=STRTRAN(cInput,"�","D"+CHR(255))
   cInput:=STRTRAN(cInput,"�","C"+CHR(254))
   cInput:=STRTRAN(cInput,"�","C"+CHR(255))
   cInput:=STRTRAN(cInput,"�","Z"+CHR(255))
   cInput:=STRTRAN(cInput,"�","s"+CHR(255))
   cInput:=STRTRAN(cInput,"�","d"+CHR(255))
   cInput:=STRTRAN(cInput,"�","c"+CHR(254))
   cInput:=STRTRAN(cInput,"�","c"+CHR(255))
   cInput:=STRTRAN(cInput,"�","z"+CHR(255))
 ENDIF
RETURN PADR(cInput,100)

