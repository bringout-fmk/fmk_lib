

// 
// cTip je string sa dva znaka od kojih prvi uslovljava da li ce se
// izvrsiti zaokruzivanje, a drugi predstavlja broj decimala na koji
// ce se izvrsiti zaokruzivanje.
// Zaokruzivanje se vrsi uvijek izuzev ako je taj prvi znak "."
//
// Primjer round7(5.3342,";3") => 5.334     round7(6.321,".")=6.32
// 
FUNCTION Round7(nBroj,cTip)
 LOCAL cTip1:="", cTip2:=""
 cTip1:=LEFT(cTip,1)
 cTip2:=RIGHT(cTip,1)
 IF cTip1!="."
   IF cTip1==";"
     nBroj := ROUND( nBroj , VAL(cTIp2) )
   ELSE
     nBroj := ROUND( nBroj , 2 )
   ENDIF
 ENDIF
RETURN nBroj

