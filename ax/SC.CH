* REQUEST DBFCDX

#define INDEXEXTENS  "CDX"
#define  MEMOEXTENS  "FPT"

#command DEL2                                                            ;
      => (nArr)->(DbDelete2())                                            ;
        ;(nTmpArr)->(DbDelete2())

#define DE_ADD  5
#define DE_DEL  6

#define F_KORISN 100
#define F_GPARAMS  98
#define F_GPARAMSP 98
#define F_PARAMS 99
#define F_MPARAMS 101
#define F_KPARAMS 102
#define F_SECUR   103
#define F_ADRES   105
#define F_HELP    106
#define F_SIFK    107
#define F_SIFV    108
#define F_TMP     109

#xcommand O_KORISN    => select (F_KORISN); if !used(); use (".\Korisn"); end ; set order to tag "IME"
#xcommand O_PARAMS    => select (F_PARAMS); if !used(); use (PRIVPATH+"params"); end  ; set order to tag  "ID"
#xcommand O_GPARAMS   => select (F_GPARAMS);if !used(); use ("\gparams"); end ;   set order to tag  "ID"
#xcommand O_GPARAMSP  => select (F_GPARAMSP);if !used();use (PRIVPATH+"gparams"); end ; set order to tag  "ID"
#xcommand O_MPARAMS   => select (F_MPARAMS);if !used(); use (".\mparams"); end       ; set order  to tag  "ID"
#xcommand O_KPARAMS   => select (F_KPARAMS);if !used(); use (KUMPATH+"kparams"); end  ; set order to tag  "ID"
#xcommand O_SECUR     => select (F_SECUR);if !used(); use (".\secur"); end ; set order to tag "ID"
#xcommand O_ADRES     => select (F_ADRES);if !used(); use (SIFPATH+"adres");end; set order to tag "ID"
#xcommand O_HELP      => select (F_HELP);if !used(); use (EXEPATH+"help")  ;end; set order to tag "1"
#xcommand O_SIFK => select(F_SIFK);  use  (SIFPATH+"SIFK")     ; set order to tag "ID"
#xcommand O_SIFV => select(F_SIFV);  use  (SIFPATH+"SIFV")     ; set order to tag "ID"
