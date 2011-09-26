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


#include "SC.CH"

/****h SC_CLIB/FMK_PI ***
* 
*AUTOR
  Mirsad Subasic, mirsad@sigma-com.net

*IME 

*OPIS
  SigmaCom FMK Proizvoljni Izvjestaji
  Bazni sistem za formiranje proizvoljnih izvjestaja u FMK

*DATUM
  04.2002

****/

procedure PrIz()
*

#command AP52 [FROM <(file)>]                                         ;
         [FIELDS <fields,...>]                                          ;
         [FOR <for>]                                                    ;
         [WHILE <while>]                                                ;
         [NEXT <next>]                                                  ;
         [RECORD <rec>]                                                 ;
         [<rest:REST>]                                                  ;
         [VIA <rdd>]                                                    ;
         [ALL]                                                          ;
                                                                        ;
      => __dbApp(                                                       ;
                  <(file)>, { <(fields)> },                             ;
                  <{for}>, <{while}>, <next>, <rec>, <.rest.>, <rdd>    ;
                )


local cScr:=SAVESCREEN(1,0,1,79), GetList:={}
private cV1,cv2,cv3,cv4,cv5,cv6

private opc[10], Izbor, nTekIzv:=1, cBrI:="01", cPotrazKon:="7;811;812;", gnPorDob:=30
                                               // ispitati koja su potr.konta

PRIVATE cPIKPolje:="", cPIKBaza:="", cPIKIndeks:="", cPITipTab:="", cPIKSif:=""
PRIVATE cPIImeKP:=""

O_PARAMS
Private cSection:="I",cHistory:=" ",aHistory:={}
RPar("pk",@cPotrazKon)
RPar("pd",@gnPorDob)
RPar("ti",@cBrI)
SELECT PARAMS; USE


OtBazPI()

P_Proizv(@cBrI,NIL,NIL,"#Odaberi izvjestaj :") // # hash na pocetku kaze - obavezno browsaj !


nTokens:=numtoken(izvje->naz,"#")

if nTokens>1

 Box(,nTokens+1,75)
  @ m_x+0,m_y+3 SAY "Unesi varijable0 izvjestaja:"


   // popuni ini fajl vrijednostima
   // formira varijable cV1, cV2 redom !!!!1

   for i:=2 to nTokens
      cPom:="cV"+alltrim(str(i-1))
      &cPom:=padr(UzmiIzIni(EXEPATH+'ProIzvj.ini','Varijable0',alltrim(token(izvje->naz,"#",i)),"",'READ'),45)
   next


  for i:=2 to nTokens
      cPom:="cV"+alltrim(str(i-1))
      @ m_X+i, m_y+2 SAY padr(token(izvje->naz,"#",i),20)
      @ m_x+i, col()+2 GET &cPom
  next

  read
 BoxC()

 // popuni ini fajl vrijednostima
 for i:=2 to nTokens
      cPom:="cV"+alltrim(str(i-1))
      UzmiIzIni(EXEPATH+'ProIzvj.ini','Varijable0',alltrim(token(izvje->naz,"#",i)),&cPom,'WRITE')
 next

endif


O_PARAMS
Private cSection:="I",cHistory:=" ",aHistory:={}


UzmiIzIni(EXEPATH+'ProIzvj.ini','Varijable','Modul',gModul,'WRITE')
UzmiIzIni(EXEPATH+'ProIzvj.ini','Varijable','OznakaIzvj',cBrI,'WRITE')

WPar("ti",cBrI)
select params; use


nTekIzv:=VAL(cBrI)

opc[1]:="1. generisanje izvjestaja                       "      //
opc[2]:="2. sifrarnik izvjestaja"               //
opc[3]:="3. redovi izvjestaja"                  // <- redovi izvjestaja
opc[4]:="4. zaglavlje izvjestaja"               //
opc[5]:="5. kolone izvjestaja"                  //
opc[6]:="6. parametri (svi izvjestaji) "         //
opc[7]:="7. tekuci izvjestaj: "+STR(nTekIzv,2)  //
opc[8]:="8. preuzimanje definicija izvjestaja sa diskete"  //
opc[9]:="9. promjeni broj izvjestaja"  //
opc[10]:="A. ispravka proizvj.ini"  //

Izbor:=1

IF KOLIZ->(FIELDPOS("SIZRAZ"))==0
  MsgBeep("Potrebna modifikacija struktura pomocu fajla FIN.CHS !")
  RESTSCREEN(1,0,1,79,cScr)
  CLOSERET
ENDIF

PrikaziTI(cBrI)


GenProIzv()
OtBazPI()

DO WHILE .T.
   h[1]:=""; h[2]:=""; h[3]:=""; h[4]:=""; h[5]:=""; h[6]:=""; h[7]:=""
   h[8]:=""
   Izbor:=Menu("ProIzv",opc,Izbor,.f.)
   DO CASE
      CASE izbor==0
        exit
      CASE izbor==1

         GenProIzv()
         OtBazPI()
      CASE izbor==2
         P_ProIzv()
         PrikaziTI(cBrI)
      CASE izbor==3
         P_KonIz()
      CASE izbor==4
         P_ZagProIzv()
      CASE izbor==5
         P_KolProIzv()
      CASE izbor==6
         ParSviIzvj()
      CASE izbor==7
         Box(,3,70)
          @ m_x+2,m_y+2 SAY "Izaberite tekuci izvjestaj (1-99):" GET nTekIzv VALID nTekIzv>0 .and. nTekIzv<100 PICT "99"
          READ
         BoxC()
         IF LASTKEY()!=K_ESC
           opc[7]:="7. tekuci izvjestaj: "+STR(nTekIzv,2)
           cBrI:=RIGHT("00"+ALLTRIM(STR(nTekIzv)),2)
           PrikaziTI(cBrI)
           O_PARAMS
           Private cSection:="I",cHistory:=" ",aHistory:={}
           UzmiIzIni(EXEPATH+'ProIzvj.ini','Varijable','OznakaIzvj',cBrI,'WRITE')
           WPar("ti",cBrI)
           SELECT PARAMS; USE
         ENDIF
      CASE izbor==8
         PreuzmiProIzv()
      CASE izbor==9
        PromBroj()
      CASE izbor==10
        private cKom:="q "+EXEPATH+"PROIZVJ.INI"
        Box(,25,80)
        run &ckom
        BoxC()
        IniRefresh() // izbrisi iz cache-a

   ENDCASE
ENDDO

RESTSCREEN(1,0,1,79,cScr)
CLOSERET





STATIC FUNCTION P_ProIzv(cId,dx,dy,cNaslov)
 LOCAL i:=0
 private imekol:={},kol:={}
 ImeKol:={ { "Sifra"           , {|| id     }, "ID"     ,, {|| vpsifra (wId)}},;
           { "Naziv"           , {|| naz    }, "NAZ"     },;
           { "Filter klj.baze" , {|| uslov  }, "USLOV"   },;
           { "Kljucno polje"   , {|| kpolje }, "KPOLJE"  },;
           { "Opis klj.polja"  , {|| imekp  }, "IMEKP"   },;
           { "Baza sif.k.polja", {|| ksif   }, "KSIF"    },;
           { "Kljucna baza"    , {|| kbaza  }, "KBAZA"   },;
           { "Kljucni indeks"  , {|| kindeks}, "KINDEKS" },;
           { "Tip tabele"      , {|| tiptab }, "TIPTAB"  };
        }
 FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
 aDefSpremBaz:={ { F_Baze("KONIZ"), "ID", "IZV", ""},;
                 { F_Baze("KOLIZ"), "ID", "ID", ""},;
                 { F_Baze("ZAGLI"), "ID", "ID", ""} }
if cNaslov=NIL
 cNaslov:="Izvjestaji"
endif
return PostojiSifra(F_Baze("IZVJE"),1,10,77,cNaslov ,@cId,dx,dy)





STATIC FUNCTION P_ZagProIzv(cId,dx,dy,lSamoStampaj)
 LOCAL i:=0
 IF lSamoStampaj==NIL; lSamoStampaj:=.f.; ENDIF
 private imekol:={},kol:={}
 SELECT ZAGLI
 SET FILTER TO
 SET FILTER TO ID==cBrI
 dbGoTop()
 ImeKol:={ { "Sifra"  , {|| Id}, "id", {|| wId:=cBrI,.t.}, {|| .t.} },;
           { "Koord.x", {|| x1 }  , "x1"     },;
           { "Koord.y", {|| y1 }  , "y1"     },;
           { "IZRAZ"  , {|| izraz}, "izraz"  };
        }
 FOR i:=1 TO LEN(ImeKol)
     AADD(Kol,i)
 NEXT
 IF lSamoStampaj
   dbGoTop()
   P_12CPI
   QOPodv("Izvjestaj "+cBrI+"("+TRIM(DoHasha(IZVJE->naz))+") - definicija zaglavlja izvjestaja")
   QOPodv("ZAGLI.DBF, (KUMPATH='"+TRIM(KUMPATH)+"')")
   ?
   Izlaz(,,,.f.,.t.)
   RETURN
 ENDIF
return PostojiSifra(F_Baze("ZAGLI"),"1",10,77,"ZAGLAVLJE IZVJESTAJA BR."+ALLTRIM(STR(nTekIzv)) ,@cId,dx,dy,{|Ch| APBlok(Ch)})


STATIC FUNCTION APBlok(Ch)

LOCAL lVrati:=DE_CONT, nRec:=0, i:=0
 IF Ch==K_ALT_P
     IF Pitanje(,"Zelite li preuzeti podatke iz drugog izvjestaja? (D/N)","N")=="D"
       i:=1
       Box(,3,60)
        @ m_x+2, m_y+2 SAY "Preuzeti podatke iz izvjestaja br.? (1-99)" GET i VALID i>0 .and. i<100 .and. i<>nTekIzv PICT "99"
        READ
       BoxC()
       IF LASTKEY()!=K_ESC
         SET FILTER TO
         dbGoTop()
         DO WHILE !EOF()
           SKIP 1; nRec:=RECNO(); SKIP -1
           IF id==RIGHT("00"+ALLTRIM(STR(i)),2)
             Scatter()
             _id:=cBrI
             APPEND BLANK
             Gather()
           ENDIF
           GO (nRec)
         ENDDO
         lVrati:=DE_REFRESH
         SET FILTER TO ID==cBrI
         dbGoTop()
       ENDIF
     ENDIF
 ENDIF
RETURN lVrati




STATIC FUNCTION P_KolProIzv(cId,dx,dy,lSamoStampaj)
 LOCAL i:=0
 IF lSamoStampaj==NIL; lSamoStampaj:=.f.; ENDIF
 private imekol:={}, kol:={}
 SELECT KOLIZ
 SET FILTER TO
 SET FILTER TO ID==cBrI
 dbGoTop()
 ImeKol:={ { "Sifra"          , {|| Id      }, "id", {|| wId:=cBrI,.t.}, {|| .t.}},;
           { "Red.broj"       , {|| RBR     }, "RBR"      },;
           { "Ime kol."       , {|| NAZ     }, "NAZ"      },;
           { "Formula"        , {|| FORMULA }, "FORMULA"  },;
           { "Uslov"          , {|| KUSLOV  }, "KUSLOV"   },;
           { "Izraz zbrajanja", {|| SIZRAZ  }, "SIZRAZ"   },;
           { "Tip"            , {|| TIP     }, "TIP"      },;
           { "Sirina"         , {|| SIRINA  }, "SIRINA"   },;
           { "Decimale"       , {|| DECIMALE}, "DECIMALE" },;
           { "Sumirati"       , {|| SUMIRATI}, "SUMIRATI" },;
           { "K1"             , {|| K1      }, "K1"       },;
           { "K2"             , {|| K2      }, "K2"       },;
           { "N1"             , {|| N1      }, "N1"       },;
           { "N2"             , {|| N2      }, "N2"       };
        }
 IF lSamoStampaj
   dbGoTop()
   P_12CPI
   QOPodv("Izvjestaj "+cBrI+"("+TRIM(DoHasha(IZVJE->naz))+") - definicija kolona izvjestaja")
   QOPodv("KOLIZ.DBF, (KUMPATH='"+TRIM(KUMPATH)+"')")
   P_COND2
   ?
   ? ".........................................."
   DO WHILE !EOF()

     IF ( prow() > 50+gPStranica )
       FF
       P_12CPI
       QOPodv("Izvjestaj "+cBrI+"("+TRIM(DoHasha(IZVJE->naz))+") - definicija kolona izvjestaja")
       QOPodv("KOLIZ.DBF, (KUMPATH='"+TRIM(KUMPATH)+"')")
       P_COND2
       ?
       ? ".........................................."
     ENDIF
     ? PADR("Redni broj     :",16); ?? RBR
     ? PADR("Ime kolone     :",16); ?? NAZ
     ? PADR("Formula        :",16); ?? TRIM(FORMULA)
     ? PADR("Uslov          :",16); ?? KUSLOV
     ? PADR("Izraz zbrajanja:",16); ?? SIZRAZ
     ? PADR("Tip            :",16); ?? TIP
     ? PADR("Sirina         :",16); ?? SIRINA
     ? PADR("Decimale       :",16); ?? DECIMALE
     ? PADR("Sumirati       :",16); ?? SUMIRATI
     ? PADR("K1             :",16); ?? K1
     ? PADR("K2             :",16); ?? K2
     ? PADR("N1             :",16); ?? N1
     ? PADR("N2             :",16); ?? N2
     ? ".........................................."

     SKIP 1
   ENDDO
   RETURN
 ENDIF
 FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
return PostojiSifra(F_Baze("KOLIZ"),"1",10,77,"KOLONE IZVJESTAJA BR."+ALLTRIM(STR(nTekIzv)) ,@cId,dx,dy,{|Ch| APBlok(Ch)})





STATIC PROCEDURE P_KonIz()
 LOCAL i:=0
 PRIVATE ImeKol:={},Kol:={}

 IF LASTKEY()==K_ESC; RETURN; ENDIF

 SELECT KONIZ
 SET ORDER TO TAG "1"
 SET FILTER TO
 SET FILTER TO IZV==cBrI
 dbGoTop()

 AADD( ImeKol , { "IZVJ."        , {|| IZV }, "IZV"  } )
 AADD( ImeKol , { cPIImeKP       , {|| ID  }, "ID"   } )
 AADD( ImeKol , { "R.BROJ"       , {|| RI  }, "RI"   } )
 AADD( ImeKol , { "K(  /Sn/An)"  , {|| K   }, "K"    } )
 AADD( ImeKol , { "FORMULA"      , {|| FI  }, "FI"   } )
 AADD( ImeKol , { "PREDZNAK"     , {|| PREDZN }, "PREDZN"   } )
 AADD( ImeKol , { "OPIS"         , {|| OPIS}, "OPIS" , {|| UsTipke(),.t.},{|| BosTipke(),.t.}  } )
 AADD( ImeKol , { cPIImeKP+"2"   , {|| ID2 }, "ID2"  } )
 AADD( ImeKol , { "K2(  /Sn/An)" , {|| K2  }, "K2"   } )
 AADD( ImeKol , { "FORMULA2"     , {|| FI2 }, "FI2"  } )
 AADD( ImeKol , { "PREDZNAK2"    , {|| PREDZN2 }, "PREDZN2"   } )
 AADD( ImeKol , { "PODVUCI"      , {|| PODVUCI }, "PODVUCI"   } )
 IF FIELDPOS("K1")<>0
   AADD( ImeKol , { "K1"           , {|| K1      }, "K1"        } )
   AADD( ImeKol , { "U1"           , {|| U1      }, "U1"        } )
 ENDIF

 FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT

 Box(,20,77)
  @ m_x+18,m_y+2 SAY "<a-P> popuni bazu iz sifrarnika   <a-N> preuzmi iz drugog izvjestaja"
  @ m_x+19,m_y+2 SAY "<c-N> nova stavka                 <c-I> nuliranje po uslovu         "
  @ m_x+20,m_y+2 SAY "<c-T> brisi stavku              <Enter> ispravka stavke             "
  ObjDBEdit("PKONIZ",20,77,{|| KonIzBlok()},"","Priprema redova za izvjestaj br."+cBrI+"อออออ<c-P> vidi komplet definiciju", , , , ,3)
 BoxC()
RETURN



STATIC FUNCTION KonIzBlok()
 LOCAL GetList:={}
 LOCAL lVrati:=DE_CONT, i:=0, nRec:=0, n0:=0, n1:=0, nSRec:=0, cUslov:=""
 PRIVATE aUslov:=""
 DO CASE
   CASE Ch==K_CTRL_P
     // --------- stampanje definicije izvjestaja ---------
     // ---------------------------------------------------
     SELECT IZVJE
     SEEK cBrI
     StartPrint()

     P_12CPI
     QOPodv("Izvjestaj "+cBrI+"("+TRIM(DoHasha(IZVJE->naz))+") - osnovna definicija izvjestaja")
     QOPodv("IZVJE.DBF, (KUMPATH='"+TRIM(KUMPATH)+"')")

     ?
     ? PADL("Sifra"           ,17); ?? ":", id
     ? PADL("Naziv"           ,17); ?? ":", TRIM(naz)
     ? PADL("Filter klj.baze" ,17); ?? ":", TRIM(uslov)
     ? PADL("Kljucno polje"   ,17); ?? ":", TRIM(kpolje)
     ? PADL("Opis klj.polja"  ,17); ?? ":", TRIM(imekp)
     ? PADL("Baza sif.k.polja",17); ?? ":", TRIM(ksif)
     ? PADL("Kljucna baza"    ,17); ?? ":", TRIM(kbaza)
     ? PADL("Kljucni indeks"  ,17); ?? ":", TRIM(kindeks)
     ? PADL("Tip tabele"      ,17); ?? ":", tiptab


     FF

     P_ZagProizv(,,,.t.); FF

     P_KolProizv(,,,.t.); FF

     P_12CPI
     QOPodv("Izvjestaj "+cBrI+"("+TRIM(DoHasha(IZVJE->naz))+") - definicija redova izvjestaja")
     QOPodv("KONIZ.DBF, (KUMPATH='"+TRIM(KUMPATH)+"')")
     SELECT KONIZ; nRec:=RECNO()
     dbGoTop()
     ?
     ? ".........................................."
     DO WHILE !EOF()
       IF prow() > 50+gPStranica
         P_12CPI
         FF
         QOPodv("Izvjestaj "+cBrI+"("+TRIM(DoHasha(IZVJE->naz))+") - definicija redova izvjestaja")
         QOPodv("KONIZ.DBF, (KUMPATH='"+TRIM(KUMPATH)+"')")
         ?
         ? ".........................................."
       ENDIF
       ?  "Redni broj  :"           ; ?? ri
       ?  PADR(cPIImeKP,12)+":"     ; ?? id
       ?  "K(  /Sn/An) :"           ; ?? k
       ?  "Formula     :"           ; ?? fi
       ?  "Predznak    :"           ; ?? predzn
       ?  PADR(cPIImeKP+"2",12)+":" ; ?? id2
       ?  "K2(  /Sn/An):"           ; ?? k2
       ?  "Formula2    :"           ; ?? fi2
       ?  "Predznak2   :"           ; ?? predzn2
       ?  "OPIS        :"           ; ?? opis
       ?  "PODVUCI( /x):"           ; ?? podvuci
       IF FIELDPOS("K1")<>0
         ? "K1          :"          ; ?? k1
         ? "U1 ( ,>0,<0):"          ; ?? u1
       ENDIF
       ? ".........................................."
       SKIP 1
     ENDDO
     FF

     EndPrint()
     SELECT KONIZ; GO (nRec)

   CASE Ch==K_ALT_P      // popuni nanovo iz sifrarnika kljucnog polja
     IF cPIKSif!="BEZ" .and. Pitanje(,"Zelite li obrisati bazu i formirati novu na osnovu sifrar.klj.polja?(D/N)","N")=="D"
       SELECT KONIZ; ZAP
       O_KSIF()
       dbGoTop()
       DO WHILE !EOF()
         ++i
         SELECT KONIZ
         APPEND BLANK
         REPLACE izv WITH RIGHT("00"+ALLTRIM(STR(nTekIzv)),2),;
                 id WITH IzKSIF("id"),  ri WITH i
         SEL_KSif()
         SKIP 1
       ENDDO
       USE      // zatvaram KONTO.DBF
       SELECT KONIZ; dbGoTop()
       lVrati:=DE_REFRESH
     ENDIF
   CASE Ch==K_ALT_N      // popuni iz drugog izvjestaja
     IF Pitanje(,"Zelite li postojece zamijeniti podacima iz drugog izvjestaja?(D/N)","N")=="D"
       i:=1
       Box(,3,60)
        @ m_x+2, m_y+2 SAY "Preuzeti podatke iz izvjestaja br.? (1-99)" GET i VALID i>0 .and. i<100 .and. i<>nTekIzv PICT "99"
        READ
       BoxC()
       IF LASTKEY()!=K_ESC
         SELECT KONIZ
         dbGoTop()
         DO WHILE !EOF() .and. izv==cBrI
           SKIP 1; nRec:=RECNO(); SKIP -1; DELETE; GO (nRec)
         ENDDO
         SET FILTER TO
         SEEK RIGHT("00"+ALLTRIM(STR(i)),2)
         DO WHILE !EOF() .and. izv==RIGHT("00"+ALLTRIM(STR(i)),2)
           SKIP 1; nRec:=RECNO(); SKIP -1
           Scatter()
           _IZV:=cBrI
           APPEND BLANK
           Gather()
           GO (nRec)
         ENDDO
         SET FILTER TO izv==cBrI
         dbGoTop()
         lVrati:=DE_REFRESH
       ENDIF
     ENDIF
   CASE Ch==K_ENTER              // ispravka
     Box(,15,77)
     Scatter()
     n0:=_ri
      @ m_x, m_y+2 SAY "ISPRAVKA STAVKE - IZVJESTAJ "+cBrI
      @ m_x+ 2, m_y+2 SAY "Redni broj  :" GET _ri PICT "9999"
      @ m_x+ 3, m_y+2 SAY PADR(cPIImeKP,12)+":" GET _id
      @ m_x+ 4, m_y+2 SAY "K(  /Sn/An) :" GET _k
      @ m_x+ 5, m_y+2 SAY "Formula     :" GET _fi PICT "@S60"
      @ m_x+ 6, m_y+2 SAY "Predznak    :" GET _predzn VALID _predzn<=1 .and. _predzn>=-1 PICT "99"
      @ m_x+ 7, m_y+2 SAY PADR(cPIImeKP+"2",12)+":" GET _id2
      @ m_x+ 8, m_y+2 SAY "K2(  /Sn/An):" GET _k2
      @ m_x+ 9, m_y+2 SAY "Formula2    :" GET _fi2 PICT "@S60"
      @ m_x+10, m_y+2 SAY "Predznak2   :" GET _predzn2 VALID _predzn2<=1 .and. _predzn2>=-1 PICT "99"
      @ m_x+11, m_y+2 SAY "OPIS        :" GET _opis  when {|| UsTipke(),.t.} valid {|| BosTipke(),.t.}
      @ m_x+12, m_y+2 SAY "PODVUCI( /x):" GET _podvuci
      IF FIELDPOS("K1")<>0
        @ m_x+13, m_y+2 SAY "K1          :" GET _k1
        @ m_x+14, m_y+2 SAY "U1 ( ,>0,<0):" GET _u1
      ENDIF
      READ
     BoxC()
     n1:=_ri
     IF LASTKEY()!=K_ESC
       Gather()
       // DbfRBrSort(n0,n1,"RI",RECNO())
       lVrati:=DE_REFRESH
     ENDIF
   CASE Ch==K_CTRL_N             // nova stavka
     Box(,15,77)
     SET KEY K_ALT_R TO UzmiIzPreth()
     DO WHILE .t.
       nRec:=RECNO()
       GO BOTTOM
       i:=ri; SKIP 1
       Scatter()
       _izv:=cBrI
       _ri:=i+1
       n0:=_ri
        @ m_x, m_y+2 SAY "UNOS NOVE STAVKE - IZVJESTAJ "+cBrI
        @ m_x+ 2, m_y+2 SAY "Redni broj  :" GET _ri PICT "9999"
        @ m_x+ 3, m_y+2 SAY PADR(cPIImeKP,12)+":" GET _id
        @ m_x+ 4, m_y+2 SAY "K(  /Sn/An) :" GET _k
        @ m_x+ 5, m_y+2 SAY "Formula     :" GET _fi PICT "@S60"
        @ m_x+ 6, m_y+2 SAY "Predznak    :" GET _predzn VALID _predzn<=1 .and. _predzn>=-1 PICT "99"
        @ m_x+ 7, m_y+2 SAY PADR(cPIImeKP+"2",12)+":" GET _id2
        @ m_x+ 8, m_y+2 SAY "K2(  /Sn/An):" GET _k2
        @ m_x+ 9, m_y+2 SAY "Formula2    :" GET _fi2 PICT "@S60"
        @ m_x+10, m_y+2 SAY "Predznak2   :" GET _predzn2 VALID _predzn2<=1 .and. _predzn2>=-1 PICT "99"
        @ m_x+11, m_y+2 SAY "OPIS        :" GET _opis  when {|| UsTipke(),.t.} valid {|| BosTipke() ,.t.}
        @ m_x+12, m_y+2 SAY "PODVUCI( /x):" GET _podvuci
        IF FIELDPOS("K1")<>0
          @ m_x+13, m_y+2 SAY "K1          :" GET _k1
          @ m_x+14, m_y+2 SAY "U1 ( ,>0,<0):" GET _u1
        ENDIF
        READ
       n1:=_ri
       IF LASTKEY()!=K_ESC
         APPEND BLANK
         Gather()
         // DbfRBrSort(n0,n1,"RI",RECNO())
         lVrati:=DE_REFRESH
       ELSE
         GO BOTTOM
         EXIT
       ENDIF
     ENDDO
     SET KEY K_ALT_R TO
     BoxC()
   CASE Ch==K_CTRL_I             // iskljucenje (nuliranje) po uslovu
     cUslov:=SPACE(80)
     Box(,4,77)
     DO WHILE .t.
      @ m_x+2, m_y+2 SAY "Uslov za nuliranje stavki (za "+cPIImeKP+"):"
      @ m_x+3, m_y+2 GET cUslov PICT "@S70"
      READ
      aUslov:=Parsiraj(cUslov,"ID","C")
      IF aUslov<>NIL .or. LASTKEY()==K_ESC; EXIT; ENDIF
     ENDDO
     BoxC()
     IF LASTKEY()!=K_ESC
       i:=0
       dbGoTop()
       SEEK cBrI
       DO WHILE !EOF() .and. izv==cBrI
         SKIP 1; nSRec:=RECNO(); SKIP -1
         IF ri<>0 .and. &aUslov
           Scatter(); _ri:=0; Gather()
         ELSEIF ri<>0
           ++i
           Scatter(); _ri:=i; Gather()
         ENDIF
         GO (nSRec)
       ENDDO
       lVrati:=DE_REFRESH
     ENDIF

   CASE Ch==K_CTRL_T
     IF Pitanje(,"Zelite li izbrisati ovu stavku ?","D")=="D"
       n0:=ri
       DELETE
       // DbfRBrSort(n0,0,"ri",RECNO())     // recno() je ovdje nebitan
       lVrati:=DE_REFRESH
     ENDIF
 ENDCASE
RETURN lVrati


STATIC PROCEDURE UzmiIzPreth()
 LOCAL nRec:=RECNO()
 GO BOTTOM
 _id:=id; _id2:=id2; _k:=k; _k2:=k2; _fi:=fi; _fi2:=fi2; _opis:=opis
 _predzn:=predzn; _predzn2:=predzn2; _podvuci:=podvuci
 GO (nRec)
 AEVAL(GetList,{|o| o:display()})
RETURN




FUNCTION TxtUKod(cTxt,cBUI)
 LOCAL lPrinter:=SET(_SET_PRINTER,.t.)
 LOCAL nRow:=PROW(), nCol:=PCOL()
 IF "B" $ cBUI; gPB_ON(); ENDIF
 IF "U" $ cBUI; gPU_ON(); ENDIF
 IF "I" $ cBUI; gPI_ON(); ENDIF
 SETPRC(nRow,nCol)
 SET(_SET_PRINTER,lPrinter)
 ?? cTxt
 lPrinter:=SET(_SET_PRINTER,.t.); nRow:=PROW(); nCol:=PCOL()
 IF "B" $ cBUI; gPB_OFF(); ENDIF
 IF "U" $ cBUI; gPU_OFF(); ENDIF
 IF "I" $ cBUI; gPI_OFF(); ENDIF
 SETPRC(nRow,nCol)
 SET(_SET_PRINTER,lPrinter)
RETURN ""




FUNCTION StKod(cKod)
  Setpxlat(); qqout(cKod); konvtable()
RETURN ""


PROCEDURE RazvijUslove(cUsl)
 LOCAL nPoz:=0, i:=0
 PRIVATE cPom:=""
 DO WHILE .t.
   nPoz:=AT("#",cUsl)
   cPom:="USL"+ALLTRIM(STR(++i))
   IF nPoz>0
     REPLACE &cPom WITH LEFT(cUsl,nPoz-1)
     cUsl := SUBSTR(cUsl,nPoz+1)
   ELSE
     REPLACE &cPom WITH TRIM(cUsl)
     EXIT
   ENDIF
 ENDDO
RETURN



FUNCTION PreformIznos(x,y,z)
  LOCAL xVrati:=""
  IF INT(x)==x     // moze format bez decimala
    xVrati:=STR(x,y)
  ELSE             // ide format sa decimalama ukoliko su zadane
    xVrati:=STR(x,y,z)
  ENDIF
RETURN xVrati


STATIC PROCEDURE PreuzmiProIzv()
  LOCAL cId:="", nRec:=0, cDisk:="", GetList:={}
  // preuzeti sa diska
  cDisk:="A"
  Box(,3,77)
   @ m_x+1,m_y+2 SAY "Preuzeti podatke sa diska A/B ?" GET cDisk pict "@!" valid cDisk>="A" .and.  diskprazan(cDisk)
   READ
  BoxC()

  IF LASTKEY()!=K_ESC

    MsgO("1) Kopiram _*.DBF fajlove iz '"+cDisk+":\' u '"+PRIVPATH+"'!")
     FILECOPY( cDisk+":\_IZVJE.DBF" , PRIVPATH+"_IZVJE.DBF" )
     FILECOPY( cDisk+":\_KOLIZ.DBF" , PRIVPATH+"_KOLIZ.DBF" )
     FILECOPY( cDisk+":\_KONIZ.DBF" , PRIVPATH+"_KONIZ.DBF" )
     FILECOPY( cDisk+":\_ZAGLI.DBF" , PRIVPATH+"_ZAGLI.DBF" )
    MsgC()

    MsgO("2) Otvaram iskopirane baze!")
     SELECT 0
     USE (PRIVPATH+"_IZVJE.DBF")
     SELECT 0
     USE (PRIVPATH+"_KOLIZ.DBF")
     SELECT 0
     USE (PRIVPATH+"_KONIZ.DBF")
     SELECT 0
     USE (PRIVPATH+"_ZAGLI.DBF")
    MsgC()

    SELECT IZVJE; SET FILTER TO; SET ORDER TO TAG "ID"
    SELECT KOLIZ; SET FILTER TO; SET ORDER TO TAG "ID"
    SELECT KONIZ; SET FILTER TO; SET ORDER TO TAG "1"
    SELECT ZAGLI; SET FILTER TO; SET ORDER TO TAG "ID"
    SELECT _IZVJE
    dbGoTop()
    DO WHILE !EOF()
      PushWA()
      cId:=ID
      SELECT IZVJE
      HSEEK cid
      IF FOUND() .and. Pitanje(,"Postoji izvj.br."+cid+" ! (D-zamijeniti ili N-dodati stavke ?)","D")=="D"
        MsgO("Brisem izvj.br."+cId+"iz 'KOLIZ.DBF'!")
        SELECT KOLIZ
        HSEEK cid
        DO WHILE !EOF() .and. ID==cid
          SKIP 1; nRec:=RECNO(); SKIP -1
          DELETE
          GO (nRec)
        ENDDO
        MsgC()
        MsgO("Brisem izvj.br."+cId+"iz 'KONIZ.DBF'!")
        SELECT KONIZ
        HSEEK cid
        DO WHILE !EOF() .and. IZV==cid
          SKIP 1; nRec:=RECNO(); SKIP -1
          DELETE
          GO (nRec)
        ENDDO
        MsgC()
        MsgO("Brisem izvj.br."+cId+"iz 'ZAGLI.DBF'!")
        SELECT ZAGLI
        HSEEK cid
        DO WHILE !EOF() .and. ID==cid
          SKIP 1; nRec:=RECNO(); SKIP -1
          DELETE
          GO (nRec)
        ENDDO
        MsgC()
        MsgO("Brisem izvj.br."+cId+"iz 'IZVJE.DBF'!")
        SELECT IZVJE
        HSEEK cid
        DO WHILE !EOF() .and. ID==cid
          SKIP 1; nRec:=RECNO(); SKIP -1
          DELETE
          GO (nRec)
        ENDDO
        MsgC()
      ENDIF
      MsgO("3.1) Dodajem izvj.br."+cId+"iz '"+PRIVPATH+"_KOLIZ.DBF'!")
      SELECT KOLIZ
      AP52 FROM (PRIVPATH+"_KOLIZ.DBF") FOR ID==cID
      MsgC()
      MsgO("3.2) Dodajem izvj.br."+cId+"iz '"+PRIVPATH+"_KONIZ.DBF'!")
      SELECT KONIZ
      AP52 FROM (PRIVPATH+"_KONIZ.DBF")  FOR IZV==cID
      MsgC()
      MsgO("3.3) Dodajem izvj.br."+cId+"iz '"+PRIVPATH+"_ZAGLI.DBF'!")
      SELECT ZAGLI
      AP52 FROM (PRIVPATH+"_ZAGLI.DBF")  FOR ID==cID
      MsgC()
      MsgO("3.4) Dodajem izvj.br."+cId+"iz '"+PRIVPATH+"_IZVJE.DBF'!")
      SELECT IZVJE
      AP52 FROM (PRIVPATH+"_IZVJE.DBF")  FOR ID==cID
      MsgC()
      SELECT _IZVJE
      PopWA()
      SKIP 1
    ENDDO
    MsgBeep("4) Preuzimanje podataka zavrseno!")
    SELECT _IZVJE; USE
    SELECT _KOLIZ; USE
    SELECT _KONIZ; USE
    SELECT _ZAGLI; USE

  ENDIF
RETURN


STATIC FUNCTION RacForm(cForm,cSta)
LOCAL nVrati:=0, nRec:=RECNO(), nPoz:=0, cAOP:=""
PRIVATE cForm77:=ALLTRIM(SUBSTR(cForm,2))
DO WHILE .t.
  nPoz:=AT("ST",cForm77)
  IF nPoz>0
    cAOP:=""
    DO WHILE .t.
      IF LEN(cForm77)>=nPoz+2 .and. SUBSTR(cForm77,nPoz+2,1)$"0123456789"
        cAOP+=SUBSTR(cForm77,nPoz+2,1)
        ++nPoz
      ELSE
        EXIT
      ENDIF
    ENDDO
    cForm77:=STRTRAN(cForm77,"ST"+cAOP,"("+ALLTRIM(STR(CupajAOP(cAOP,cSta)))+")",1,1)
    IF !lObradjen
      EXIT
    ENDIF
  ELSE
    EXIT
  ENDIF
ENDDO
IF lObradjen
  nVrati:=&cForm77
ENDIF
GO (nRec)
RETURN nVrati


STATIC FUNCTION CupajAOP(cAOP,cSta)
  LOCAL nVrati:=0
  PRIVATE cSta77:=cSta
  HSEEK PADL(cAOP,5)
  IF FOUND()
    IF EMPTY(U1)
      nVrati:=&cSta77
    ELSE
      cPUTS:=cSta77+TRIM(U1)
      IF &cPUTS
        nVrati:=&cSta77
      ENDIF
    ENDIF
    IF LEFT(uslov,1)=="="
      lObradjen:=.f.
    ENDIF
  ENDIF
RETURN nVrati




PROCEDURE O_KSif()
 O_Bazu(cPIKSif)
 SET ORDER TO TAG "ID"
RETURN

FUNCTION F_KSif()
RETURN F_Baze(cPIKSif)

PROCEDURE Sel_KSif()
 Sel_Bazu(cPIKSif)
RETURN

FUNCTION IzKSif(cPolje)
 PRIVATE cPom:=cPIKSif+"->"+cPolje
RETURN (&cPom)

PROCEDURE O_KBaza()
 O_Bazu(cPIKBaza)
RETURN

FUNCTION F_KBaza()
RETURN F_Baze(cPIKBaza)

PROCEDURE Sel_KBaza()
 Sel_Bazu(cPIKBaza)
RETURN

FUNCTION IzKBaza(cPolje)
 PRIVATE cPom:=cPIKBaza+"->"+cPolje
RETURN (&cPom)


PROCEDURE PripKBPI()

  IF cPIKSif!="BEZ"
    O_KSif()
  ENDIF
  SELECT IZVJE                    // u sifrarniku pozicioniramo se
  SET ORDER TO TAG "ID"
  SEEK cBrI                       // na trazeni izvjestaj
  IF !EMPTY(IZVJE->uslov)
    cFilter+=".and.("+ALLTRIM(IZVJE->uslov)+")"
  ENDIF
  cFilter:=CistiTacno(cFilter)
  O_KBaza()
  IF cPIKIndeks=="BEZ"
    SET ORDER TO
    SET FILTER TO
    SET FILTER TO &cFilter
  ELSEIF UPPER(LEFT(cPIKIndeks,3))=="TAG"
    SET ORDER TO TAG (SUBSTR(cPIKIndeks,4))     // idkonto
    SET FILTER TO
    SET FILTER TO &cFilter
  ELSE
    INDEX ON &cPIKIndeks TO "KBTEMP" FOR &cFilter
  ENDIF

RETURN


PROCEDURE StTabPI()
 LOCAL nRed:=1, aKol:={}
  SELECT KOLIZ
  dbGoTop()
  DO WHILE !EOF()
    IF ALLTRIM(KOLIZ->formula)=='"#"'
      ++nRed
    ELSE
      nRed:=1
    ENDIF
    cPom77:="{|| "+KOLIZ->formula+" }"
    AADD( aKol , { KOLIZ->naz , &cPom77. , KOLIZ->sumirati=="D" ,;
                   ALLTRIM(KOLIZ->tip) , KOLIZ->sirina , KOLIZ->decimale ,;
                   nRed , KOLIZ->rbr  } )
    SKIP 1
  ENDDO

  IF lIzrazi
    // potrebna dorada ka univerzalnosti (polje TEKSUMA ?)
    // ---------------------------------------------------
    SELECT POM; SET ORDER TO TAG "3"

    nProlaz:=0
    DO WHILE .t.

      lJos:=.f.

      ++nProlaz

      if nProlaz>10
        MsgBeep("Greska! Rekurzija(samopozivanje) u formulama tipa '=STXXX+STYYY...'!")
        EXIT
      endif

      dbGoTop()
      DO WHILE !EOF()
        IF LEFT(uslov,1)=="="
          PRIVATE lObradjen:=.t.
          REPLACE POM->TEKSUMA WITH RacForm(uslov,"TEKSUMA")
          IF lObradjen
            REPLACE uslov WITH SUBSTR(uslov,2)
          ELSE
            lJos:=.t.
            SKIP 1; LOOP
          ENDIF
        ENDIF

        IF !EMPTY(U1)
           PRIVATE cPUTS
           cPUTS:="TEKSUMA"+TRIM(U1)  // U1 JE USLOV
           IF &cPUTS
             uTekSuma:=ABS(TEKSUMA)
           ELSE
             uTekSuma:=0
           ENDIF
           REPLACE TEKSUMA WITH uTekSuma,;
                   U1      WITH SPACE(LEN(U1))
        ENDIF

        SKIP 1
      ENDDO

      IF !lJos; EXIT; ENDIF

    ENDDO

  ENDIF

  SELECT POM; SET ORDER TO; dbGoTop()
  cPodvuci:=" "
  IF cPrikBezDec=="D"
    gbFIznos:={|x,y,z| PreformIznos(x,y,z)}
  ELSE
    gbFIznos:=NIL
  ENDIF

  PRIVATE uTekSuma:=0

  StampaTabele(aKol,{|| FSvakiPI()},,gTabela,,;
       ,,;
                               {|| FForPI()},IF(gOstr=="D",,-1),,,,,)

  IF nBrRedStr>-99
    gPO_Port()
    gPStranica := nBrRedStr
  ENDIF

//  FF
  END PRINT
  // -------------------------
  // KRAJ STAMPANJA IZVJESTAJA
  // -------------------------



RETURN



PROCEDURE StZagPI()
 LOCAL xKOT:=0
  START PRINT CRET
  SELECT ZAGLI
  SET FILTER TO
  SET FILTER TO id==cBrI
  SET ORDER TO TAG "1"
  dbGoTop()
  xKOT:=PROW()
  DO WHILE !EOF()
    IF "GPO_LAND()" $ UPPER(ZAGLI->izraz)
       nBrRedStr  := gPStranica
       gPStranica := nKorZaLands
    ENDIF
    cPom77 := ZAGLI->izraz
    @ xKOT+ZAGLI->x1, ZAGLI->y1 SAY ""
    @ xKOT+ZAGLI->x1, ZAGLI->y1 SAY &cPom77
    SKIP 1
  ENDDO
RETURN


static function prombroj()
local i,cstbroj,cnbroj


MsgBeep("Nije jos implementirano ...")
return

OtBazPI()

cStBroj:=space(2)
cNBroj:="99"
Box(,2,50)
  @ m_x+1,m_y+2 SAY "Stari broj:" GET cStBroj
  @ m_x+2,m_y+2 SAY "Novi  broj:" GET cNBroj
  read
BoxC()


if pitanje(,"Promjeniti broj izvjestaja ?","N")=="D"
  select  izvje
  seek cnbroj
  if found()
     Msgbeep("Vec postoji izvjestaj pod zadatim brojem !")
     closeret
  else
   for i:=1 to 4
     if i=1
       select izvje; set order to tag "ID"
     elseif i=2
       select koliz; set order to tag "ID"
     elseif i=3
       select zagli; set order to tag "ID"
     elseif i=4
       select koniz; set order to tag "1"
     endif
     seek cStBroj
     do while !eof() .and. iif(i<4,id=cStBroj,izv=cStBroj)
       skip; nTrec:=recno(); skip -1
       if i=4
         replace izv with cnbroj
       else
         replace id with cnbroj
       endif
       go nTrec
     enddo
   next
  endif

endif

return


PROCEDURE QOPodv(cT)
 ? cT
 ? REPL("-",LEN(cT))
RETURN

FUNCTION DoHasha(cT)
  LOCAL n:=AT("#",cT)
RETURN IF(n=0,cT,LEFT(cT,n-1))



FUNCTION CistiTacno(cFilter)
  LOCAL nT:=0, cSta:="", nZ:=0, nP:=0, cPom:=""
  cSta:="Tacno("
  nT:=AT(cSta,cFilter)
  IF nT>0
    nZ:=1
    nP:=nT+LEN(cSta)
    DO WHILE nZ>0
      cPom:=SUBSTR(cFilter,nP,1)
      IF cPom=="("; ++nZ; ENDIF
      IF cPom==")"; --nZ; ENDIF
      IF LEN(cPom)<1; EXIT; ENDIF
      IF nZ>0; ++nP; ENDIF
    ENDDO
    cSta:=SUBSTR(cFilter,nT,nP-nT+1)
    cPom777:=SUBSTR(cSta,7); cPom777:=LEFT(cPom777,LEN(cPom777)-1)
    cFilter:=STRTRAN(cFilter,cSta,&cPom777)
  ENDIF
RETURN cFilter



/****f SC_FMKPI/Cre_PI_DBF ***

*AUTOR
 Ernad Husremovic ernad@sigma-com.net

*IME
   Cre_PI_DBF
   
*SYNOPSIS
   Cre_PI_DBF()
*OPIS
  Kreiraj DBF tabele za proizvoljne izvjestaje:
     - IZVJE.DBF
     - KOLIZ.DBF
     - KONIZ.DBF
     - ZAGLI.DBF
     
*BILJESKE

****/


PROCEDURE OProizv()
O_KOLIZ
O_KONIZ
O_ZAGLI
O_IZVJE
return

