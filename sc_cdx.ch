
//#define INDEXEXTENS  "CDX"
#define  MEMOEXTENS  "FPT"

#xcommand O_KORISN    => select (F_KORISN);  use (CURDIR+"Korisn") ; set order to tag "IME"
#xcommand O_PARAMS    => select (F_PARAMS);  use (PRIVPATH+"params"); set order to tag  "ID"
#xcommand O_GPARAMS   => select (F_GPARAMS); use (SLASH+"gparams")  ;   set order to tag  "ID"
#xcommand O_GPARAMSP  => select (F_GPARAMSP);use (PRIVPATH+"gparams")  ; set order to tag  "ID"
#xcommand O_MPARAMS   => select (F_MPARAMS); use (CURDIR+"mparams")   ; set order  to tag  "ID"
#xcommand O_KPARAMS   => select (F_KPARAMS); use (KUMPATH+"kparams") ; set order to tag  "ID"
#xcommand O_SECUR     => select (F_SECUR); use (CURDIR+"secur")  ; set order to tag "ID"
#xcommand O_ADRES     => select (F_ADRES); use (SIFPATH+"adres")  ; set order to tag "ID"

#xcommand O_SQLPAR    => select (F_SQLPAR); use (KUMPATH+"SQL"+SLASH+"SQLPAR")


#xcommand O_SIFK => select(F_SIFK);  use  (SIFPATH+"SIFK")     ; set order to tag "ID"
#xcommand O_SIFV => select(F_SIFV);  use  (SIFPATH+"SIFV")     ; set order to tag "ID"

// PROIZVOLJNI IZVJESTAJI
#xcommand O_KONIZ  => select (F_KONIZ);    use  (KUMPATH+"KONIZ") ; set order to tag "ID"
#xcommand O_IZVJE  => select (F_IZVJE);    use  (KUMPATH+"IZVJE") ; set order to tag "ID"
#xcommand O_ZAGLI  => select (F_ZAGLI);    use  (KUMPATH+"ZAGLI") ; set order to tag "ID"
#xcommand O_KOLIZ  => select (F_KOLIZ);    use  (KUMPATH+"KOLIZ") ; set order to tag "ID"

