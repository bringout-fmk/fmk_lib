/*
 * ----------------------------------------------------------------
 *                         Copyright Sigma-com software 1996-2006 
 * ----------------------------------------------------------------
 */
 
#define SC_DEFINED
#define SC_LIB_VER  "02.28f"

#DEFINE SLASH "\"
#DEFINE INDEXEXTENS "CDX"
#DEFINE INDEXEXT "CDX"
#DEFINE DBFEXT "DBF"
#DEFINE MEMOEXT "FPT"
#DEFINE RDDENGINE "COMIX"
#DEFINE DRVPATH ":\"
#define NRED chr(13)+chr(10)

#define P_NRED QOUT()

#include "sc_base.ch"
#include "inkey.ch"
#include "box.ch"
#include "dbedit.ch"
#include "set.ch"
#include "getexit.ch"


#define METHOD static function

#command DEL2                                                            ;
      => (nArr)->(DbDelete2())                                            ;
        ;(nTmpArr)->(DbDelete2())

#define DE_ADD  5
#define DE_DEL  6

#define DBFBASEPATH "C:\SIGMA"

#define P_KUMPATH  1
#define P_SIFPATH  2
#define P_PRIVPATH 3
#define P_TEKPATH  4
#define P_MODULPATH  5
#define P_KUMSQLPATH 6
#define P_ROOTPATH 7
#define P_EXEPATH 8
#define P_SECPATH 9


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



#ifndef FMK_DEFINED
	#include "\dev\Fmk\AF\cl-AF\fmk.ch"
#endif

#include "sc_db.ch"
#include "cm52.ch"

//korisnicke licence
#define AL_INET 1
#define AL_STANDARD 2
#define AL_SILVER 3
#define AL_GOLD 4
#define AL_PLATINIUM 5


