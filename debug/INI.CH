set deleted on

#ifndef PROBA
 SETCANCEL(.f.)
#ifndef TRIAL
 Izvrsen_In(p3)
 cNaslov+=" , Reg: "+SUBSTR(EVar,7,20)
#IFDEF  READONLY
 cNaslov+="-RO"
#ENDIF
#else
 cNaslov+=" , PROBNA VERZIJA"
#endif
 PUBLIC bGlobalErrorHandler:={|objError| GlobalErrorHandler(objError,.f.)}
 ErrorBlock(bGlobalErrorHandler)
#else
 PUBLIC EVar:="#Erky#12345678901234567890#0000"
 cNaslov+=" , Reg: "+SUBSTR(EVar,7,20)
#ifndef XBASE
 EXTERNAL _CLD
#endif
#endif

IniGparams()
InitE(cKorisn,cSifra,p3,p4,p5,p6,p7) // inicijalizacija

IniGparam2()

BosTipke()
KonvTable()


O_KPARAMS
PUBLIC gSezona:="    "
PRIVATE cSection:="1",cHistory:=" "; aHistory:={}
Rpar("se",@gSezona)
Rpar("rp",@gRadnoPodr)
select kparams; use

if empty(gSezona)
    GSezona()
endif

altd()
public gAppSrv:=.f.
if mpar37("/APPSRV")
        cKom:="{|| RunAppSrv() }"
        ? "Pokrecem App Serv ..."
        gAppSrv:=.t.
        Eval(&cKom)
endif

if gRadnoPodr<>"RADP"
  if mpar37("/XN") .or. Pitanje(,"Prosli put ste radili u sezonskom podrucju " +gRadnoPodr+". Nastaviti ?","D")=="N"
     gRadnoPodr:="RADP"
     O_KPARAMS
     private cSection:="1",cHistory:=" "; aHistory:={}
     Wpar("rp",gRadnoPodr)
     select kparams; use
  else
     LogAgain(gRadnoPodr,.t.)
  endif
endif

if !mpar37("/XN")
  ArhSigma() 
endif


#define PROCPRENOS


set epoch to 1960  // epoha je u stvari 1999, 2000 itd
IniPrinter()
JelReadOnly()

if mpar37("/XN")
  IF OzNoGod() <> gSezona .and. VAL(OzNoGod()) > VAL(gSezona) .and. VAL(OzNoGod())>2000
    IF JelSeRadilo()
      // MsgBeep("Radilo se!")
      // radilo se
      // --------------
      O_KPARAMS
      PUBLIC gSezona:="    "
      private cSection:="1",cHistory:=" "; aHistory:={}
      Rpar("se",@gSezona)
      gSezona := STR(VAL(OzNoGod())-1,4)  // !!
      Wpar("se",gSezona,gSQL=="D")
      select kparams; use
      // slijedi alt+F6
      ProcPrenos()
    ELSE
      // MsgBeep("Nije se radilo!")
      // nije se radilo
      // --------------
      O_KPARAMS
      PUBLIC gSezona:="    "
      private cSection:="1",cHistory:=" "; aHistory:={}
      Rpar("se",@gSezona)
      gSezona := OzNoGod()  // !!
      Wpar("se",gSezona,gSQL=="D")
      select kparams; use
    ENDIF
  ENDIF
  quite()
endif



