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

