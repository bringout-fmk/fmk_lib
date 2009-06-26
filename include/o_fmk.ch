
//#define INDEXEXTENS  "CDX"
#define  MEMOEXTENS  "FPT"

#xcommand O_KORISN    => select (F_KORISN);  use ( ToUnix (CURDIR + "korisn" ) ) ; set order to tag "IME"
#xcommand O_PARAMS    => select (F_PARAMS);  use ( PRIVPATH+"params"); set order to tag  "ID"
#xcommand O_GPARAMS   => select (F_GPARAMS); use ( ToUnix( SLASH + "gparams") )  ;   set order to tag  "ID"
#xcommand O_GPARAMSP  => select (F_GPARAMSP);use ( PRIVPATH + "gparams" )  ; set order to tag  "ID"
#xcommand O_MPARAMS   => select (F_MPARAMS); use ( CURDIR + "mparams" )   ; set order  to tag  "ID"
#xcommand O_KPARAMS   => select (F_KPARAMS); use ( KUMPATH + "kparams" ) ; set order to tag  "ID"
#xcommand O_SECUR     => select (F_SECUR); use ( KUMPATH + "secur" )  ; set order to tag "ID"
#xcommand O_ADRES     => select (F_ADRES); use ( SIFPATH + "adres" )  ; set order to tag "ID"

#xcommand O_SQLPAR    => select (F_SQLPAR); use ( ToUnix( KUMPATH + "SQL"+ SLASH + "SQLPAR" ) )


#xcommand O_SIFK => select(F_SIFK);  use  (SIFPATH+"sifk")     ; set order to tag "ID"
#xcommand O_SIFV => select(F_SIFV);  use  (SIFPATH+"sifv")     ; set order to tag "ID"

// PROIZVOLJNI IZVJESTAJI
#xcommand O_KONIZ  => select (F_KONIZ);    use  (KUMPATH + "KONIZ") ; set order to tag "ID"
#xcommand O_IZVJE  => select (F_IZVJE);    use  (KUMPATH + "IZVJE") ; set order to tag "ID"
#xcommand O_ZAGLI  => select (F_ZAGLI);    use  (KUMPATH + "ZAGLI") ; set order to tag "ID"
#xcommand O_KOLIZ  => select (F_KOLIZ);    use  (KUMPATH + "KOLIZ") ; set order to tag "ID"


#xcommand O_ROBA   => select(F_ROBA);  use  (SIFPATH + "roba")  ; set order to tag "ID"
#xcommand O_TARIFA   => select(F_TARIFA);  use  (SIFPATH + "tarifa" )  ; set order to tag "ID"
#xcommand O_KONTO   => select(F_KONTO);  use  (SIFPATH + "konto" ) ; set order to tag "ID"
#xcommand O_TRFP    => select(F_TRFP);   use  (SIFPATH + "trfp")       ; set order to tag "ID"
#xcommand O_TRMP    => select(F_TRMP);   use  (SIFPATH + "trmp")       ; set order to tag "ID"
#xcommand O_PARTN   => select(F_PARTN);  use  (SIFPATH + "partn")  ; set order to tag "ID"
#xcommand O_TNAL   => select(F_TNAL);  use  (SIFPATH + "tnal" )         ; set order to tag "ID"
#xcommand O_TDOK   => select(F_TDOK);  use  (SIFPATH + "tdok" )         ; set order to tag "ID"
#xcommand O_KONCIJ => select(F_KONCIJ);  use  (SIFPATH + "koncij" )     ; set order to tag "ID"
#xcommand O_VALUTE => select(F_VALUTE);  use  (SIFPATH + "valute" )     ; set order to tag "ID"
#xcommand O_SAST   => select (F_SAST); use  (SIFPATH + "sast" )         ; set order to tag "ID"

#xcommand O_BARKOD  => select(F_BARKOD);  usex (PRIVPATH + "barkod"); set order to tag "1"

#xcommand O_RJ   => select(F_RJ);  use  (KUMPATH + "rj")         ; set order to tag "ID"
#xcommand O_REFER   => select(F_REFER);  use  (SIFPATH+"REFER")         ; set order to tag "ID"
#xcommand O_OPS   => select(F_OPS);  use  (SIFPATH + "ops" )         ; set order to tag "ID"

#xcommand O_RNAL  => select(F_RNAL);  use  (SIFPATH + "rnal" )      ; set order to tag "ID"

#xcommand O_UGOV     => select(F_UGOV);  use  (KUMPATH + "ugov" )     ; set order to tag "ID"

#xcommand O_RUGOV    => select(F_RUGOV);  use  (KUMPATH + "rugov" )   ; set order to tag "ID"

// KALK

#xcommand O_PRIPR   => select(F_PRIPR); usex (PRIVPATH + "pripr") ; set order to tag "1"
#xcommand O_S_PRIPR   => select(F_PRIPR); use (PRIVPATH + "pripr") ; set order to tag "1"

#xcommand O_PRIPRRP   => select (F_PRIPRRP);   usex (strtran(cDirPriv,goModul:oDataBase:cSezonDir, SLASH) + "pripr") alias priprrp ; set order to tag "1"

#xcommand O_PRIPR2  => select(F_PRIPR2); usex (PRIVPATH + "pripr2") ; set order to tag "1"
#xcommand O_PRIPR9  => select(F_PRIPR9); usex (PRIVPATH + "pripr9") ; set order to tag "1"
#xcommand O__KALK  => select(F__KALK); usex (PRIVPATH + "_kalk" )

#xcommand O_FINMAT  => select(F_FINMAT); usex (PRIVPATH + "finmat")    ; set order to tag "1"

#xcommand O_KALK   => select(F_KALK);  use  (KUMPATH + "kalk")  ; set order to tag "1"
#xcommand O_KALKX  => select(F_KALK);  usex  (KUMPATH +"kalk")  ; set order to tag "1"

#xcommand O_KALKS  => select(F_KALKS);  use  (KUMPATH + "kalks")  ; set order to tag "1"
#xcommand O_KALKREP => if gKalks; select(F_KALK); use; select(F_KALK) ; use  (KUMPATH+"kalks") alias KALK ; set order to tag "1";else; select(F_KALK);  use  (KUMPATH+"KALK")  ; set order to tag "1"; end

#xcommand O_SKALK   => select(F_KALK);  use  (KUMPATH + "kalk")  alias PRIPR ; set order to tag "1"
#xcommand O_DOKS    => select(F_DOKS);  use  (KUMPATH + "doks")     ; set order to tag "1"
#xcommand O_DOKS2   => select(F_DOKS2);  use  (KUMPATH + "doks2")     ; set order to tag "1"
#xcommand O_PORMP  => select(F_PORMP); usex (PRIVPATH+"pormp")     ; set order to tag "1"

#xcommand O__ROBA   => select(F__ROBA);  use  (PRIVPATH+"_roba")

#xcommand O__PARTN   => select(F__PARTN);  use  (PRIVPATH+"_partn")


#xcommand O_KONTO   => select(F_KONTO);  use  (SIFPATH+"konto") ; set order to tag "ID"
#xcommand O_TRFP    => select(F_TRFP);   use  (SIFPATH+"trfp")       ; set order to tag "ID"
#xcommand O_TRMP    => select(F_TRMP);   use  (SIFPATH+"trmp")       ; set order to tag "ID"
#xcommand O_PARTN   => select(F_PARTN);  use  (SIFPATH+"partn")  ; set order to tag "ID"
#xcommand O_TNAL   => select(F_TNAL);  use  (SIFPATH+"tnal")         ; set order to tag "ID"
#xcommand O_TDOK   => select(F_TDOK);  use  (SIFPATH+"tdok")         ; set order to tag "ID"
#xcommand O_KONCIJ => select(F_KONCIJ);  use  (SIFPATH+"koncij")     ; set order to tag "ID"
#xcommand O_VALUTE => select(F_VALUTE);  use  (SIFPATH+"valute")     ; set order to tag "ID"
#xcommand O_SAST   => select (F_SAST); use  (SIFPATH+"sast")         ; set order to tag "ID"
#xcommand O_BANKE   => select (F_BANKE) ; use (SIFPATH+"banke")  ; set order to tag "ID"

#xcommand O_LOGK   => select (F_LOGK) ; use  (KUMPATH+"logk")         ; set order to tag "NO"
#xcommand O_LOGKD  => select (F_LOGKD); use  (KUMPATH+"logd")        ; set order to tag "NO"

#xcommand O_BARKOD  => select(F_BARKOD);  use (PRIVPATH+"barkod"); set order to tag "1"


#xcommand O_FAKT      => select (F_FAKT) ;   use  (KUMPATH+"fakt") ; set order to tag  "1"
#xcommand O__FAKT     => select(F__FAKT)  ; usex (PRIVPATH+"_fakt") 
#xcommand O__ROBA   => select(F__ROBA);  use  (PRIVPATH+"_roba")
#xcommand O_PFAKT     => select (F_FAKT);  use  (KUMPATH+"fakt") alias PRIPR; set order to tag   "1"
#xcommand O_DOKS      => select(F_DOKS);    use  (KUMPATH+"doks")  ; set order to tag "1"
#xcommand O_DOKS2     => select(F_DOKS2);    use  (KUMPATH+"doks2")  ; set order to tag "1"

#xcommand O_FTXT    => select (F_FTXT);    use (SIFPATH+"ftxt")    ; set order to tag "ID"
#xcommand O_DEST     => select(F_DEST);  use  (KUMPATH+"dest")     ; set order to tag "1"
#xcommand O_POR      => select 95; usex (PRIVPATH+"por") 

#xcommand O_VRSTEP => SELECT (F_VRSTEP); USE (SIFPATH+"vrstep"); set order to tag "ID"
#xcommand O_OPS    => SELECT (F_OPS)   ; USE (SIFPATH+"ops"); set order to tag "ID"

#xcommand O_RELAC  => SELECT (F_RELAC) ; USE (SIFPATH+"relac"); set order to tag "ID"
#xcommand O_VOZILA => SELECT (F_VOZILA); USE (SIFPATH+"vozila"); set order to tag "ID"
#xcommand O_KALPOS => SELECT (F_KALPOS); USE (KUMPATH+"kalpos"); set order to tag "1"

#xcommand O_ADRES     => select (F_ADRES); use (ToUnix(SIFPATH+"adres")) ; set order to tag "ID"

#xcommand O_DOKSTXT  => select (F_DOKSTXT); use (ToUnix(SIFPATH+"dokstxt")) ; set order to tag "ID"

#xcommand O_EVENTS  => select (F_EVENTS); use (ToUnix(goModul:oDatabase:cSigmaBD+SLASH+"security"+SLASH+"events")) ; set order to tag "ID"

#xcommand O_EVENTLOG  => select (F_EVENTLOG); use (ToUnix(goModul:oDatabase:cSigmaBD+SLASH+"security"+SLASH+"eventlog")) ; set order to tag "ID"

#xcommand O_USERS  => select (F_USERS); use (ToUnix(goModul:oDatabase:cSigmaBD+SLASH+"security"+SLASH+"users")) ; set order to tag "ID"

#xcommand O_GROUPS  => select (F_GROUPS); use (ToUnix(goModul:oDatabase:cSigmaBD+SLASH+"security"+SLASH+"groups")) ; set order to tag "ID"

#xcommand O_RULES  => select (F_RULES); use (ToUnix(goModul:oDatabase:cSigmaBD+SLASH+"security"+SLASH+"rules")) ; set order to tag "ID"

//KALK ProdNC
#xcommand O_PRODNC   => select(F_PRODNC);  use  (KUMPATH+"prodnc")  ; set order to tag "PRODROBA"

//KALK RVrsta
#xcommand O_RVRSTA   => select(F_RVRSTA);  use  (SIFPATH+"rvrsta")  ; set order to tag "ID"

#xcommand O_R_EXP => select (F_R_EXP); usex (PRIVPATH+"r_export")


#xcommand O_FMKRULES  => select (F_FMKRULES); use (SIFPATH+"fmkrules") ; set order to tag "2"


#xcommand O_GEN_UG   => select(F_GEN_UG);  use  (KUMPATH+"gen_ug")  ; set order to tag "DAT_GEN"

#xcommand O_G_UG_P  => select(F_G_UG_P);  use  (KUMPATH+"gen_ug_p")   ; set order to tag "DAT_GEN"

// grupe i karakteristike
#xcommand O_STRINGS  => select(F_STRINGS);  use  (SIFPATH + "strings")   ; set order to tag "1"

#xcommand O_LOKAL => select (F_LOKAL); usex (SIFPATH+"lokal")


// tabele DOK_SRC
#xcommand O_DOKSRC => SELECT (F_DOKSRC); USE (KUMPATH+"doksrc"); set order to tag "1"
#xcommand O_P_DOKSRC => SELECT (F_P_DOKSRC); USEX (PRIVPATH+"p_doksrc"); set order to tag "1"

#xcommand O_RELATION => SELECT (F_RELATION); USE (SIFPATH+"relation"); set order to tag "1"

// POS modul

#xcommand O_KALKSEZ   => select(F_KALKSEZ);  use  (KUMPATH+"2005"+SLASH+"kalk") alias kalksez ; set order to tag "1"
#xcommand O_ROBASEZ   => select(F_ROBASEZ);  use  (SIFPATH+"2005"+SLASH+"kalk") alias robasez ; set order to tag "ID"


// stampa PDV racuna
#xcommand O_DRN => select(F_DRN); use (PRIVPATH+"drn"); set order to tag "1"
#xcommand O_RN => select(F_RN); use (PRIVPATH+"rn"); set order to tag "1"
#xcommand O_DRNTEXT => select(F_DRNTEXT); use (PRIVPATH+"drntext"); set order to tag "1"
#xcommand O_DOKSPF => select(F_DOKSPF); use (KUMPATH+"dokspf"); set order to tag "1"

// tabele provjere integriteta
#xcommand O_DINTEG1 => SELECT (F_DINTEG1); USEX (KUMPATH+"dinteg1"); set order to tag "1"
#xcommand O_DINTEG2 => SELECT (F_DINTEG2); USEX (KUMPATH+"dinteg2"); set order to tag "1"
#xcommand O_INTEG1 => SELECT (F_INTEG1); USEX (KUMPATH+"integ1"); set order to tag "1"
#xcommand O_INTEG2 => SELECT (F_INTEG2); USEX (KUMPATH+"integ2"); set order to tag "1"
#xcommand O_ERRORS => SELECT (F_ERRORS); USEX (PRIVPATH+"errors"); set order to tag "1"


// sql messages

#define F_MSGNEW 234

#xcommand O_MESSAGE   => select(F_MESSAGE); use (KUMPATH+"message"); set order to tag "1"
#xcommand O_AMESSAGE   => select(F_AMESSAGE); use (EXEPATH+"amessage"); set order to tag "1"
#xcommand O_TMPMSG  => select(F_TMPMSG); use (EXEPATH+"tmpmsg"); set order to tag "1"

