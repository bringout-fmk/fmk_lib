
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/sclib/sc.ch,v $
 * $Author: mirsad $ 
 * $Revision: 1.39 $
 * $Log: sc.ch,v $
 * Revision 1.39  2003/03/05 08:38:34  mirsad
 * no message
 *
 * Revision 1.38  2003/01/29 06:00:36  ernad
 * citanje ini fajlova
 *
 * Revision 1.37  2003/01/19 23:44:18  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.36  2003/01/18 18:26:49  ernad
 * speed testing exclusive
 *
 * Revision 1.35  2003/01/18 12:08:50  ernad
 * no message
 *
 * Revision 1.34  2003/01/15 12:39:10  ernad
 * bug 2003
 *
 * Revision 1.33  2003/01/14 03:23:34  ernad
 * exclusiv ... probelm mreza W2K ...
 *
 * Revision 1.32  2003/01/10 00:25:43  ernad
 *
 *
 * - popravka make systema
 * make zip ... \\*.chs -> \\\*.chs
 * ispravka std.ch ReadModal -> ReadModalSc
 * uvoðenje keyb/get.prg funkcija
 *
 * Revision 1.31  2002/12/21 10:50:34  mirsad
 * uveo parametar koji po defaultu iskljucuje koristenje PID-ova
 *
 * Revision 1.30  2002/11/22 10:31:52  mirsad
 * prebacivanje security iz modula u SCLIB; korekcija u PostojiSifra() za CTRL_N i F4
 *
 * Revision 1.29  2002/08/19 10:01:47  ernad
 *
 *
 * podesenja za CLIP
 *
 * Revision 1.28  2002/08/05 11:03:58  ernad
 *
 *
 * Fin/SQLLog funkcije, debug bug RJ/KUMPATH
 *
 * Revision 1.27  2002/07/30 17:40:59  ernad
 * SqlLog funkcije - Fin modul
 *
 * Revision 1.26  2002/07/23 08:08:51  ernad
 *
 *
 * debug: Nakon dogadjaja "Nema in/out komande" ostane crni ekran - program zaglavi
 *
 * Revision 1.25  2002/07/17 11:48:16  ernad
 *
 *
 * debug "Alias does not exist" SIFV, IzSifK
 *
 * Revision 1.24  2002/07/17 08:19:55  ernad
 *
 *
 * debug "Alias does not exist" funkcija IzSifK()
 *
 * Revision 1.23  2002/07/12 10:21:31  ernad
 *
 *
 * debug CDEXT - nisu radili izvjestaji bruto bilans
 *
 * Revision 1.22  2002/07/09 08:46:02  ernad
 *
 *
 * evidencija prometa po vrstama placanja: debug, nadogradnja (sada pokaze poruku o ukupnom pologu nakon unosa)
 * bug je bio sto nije mogao unijeti promet danas za juce
 *
 * Revision 1.21  2002/07/08 23:03:55  ernad
 *
 *
 * trgomarket debug dok 80, 81, izvjestaj lager lista magacin po proizv. kriteriju
 *
 * Revision 1.20  2002/07/04 16:52:42  ernad
 *
 *
 * DEBUG P_NRED macro
 *
 * Revision 1.19  2002/07/04 16:33:53  ernad
 *
 *
 * debug StampaTabele - nije uziman uslov debug u obzir
 *
 * Revision 1.18  2002/07/03 23:55:19  ernad
 *
 *
 * ciscenja planika (tragao za nepostojecim bug-om u prelgedu finansijskog obrta)
 *
 * Revision 1.17  2002/07/03 07:31:12  ernad
 *
 *
 * planika, debug na terenu
 *
 * Revision 1.16  2002/07/01 17:49:28  ernad
 *
 *
 * formiranje finalnih build-ova (fin, kalk, fakt, pos) pred teren planika
 *
 * Revision 1.15  2002/07/01 13:58:56  ernad
 *
 *
 * izvjestaj StanjePm nije valjao za gVrstaRs=="S" (prebacen da je isti kao za kasu "A")
 *
 * Revision 1.14  2002/06/27 17:22:41  ernad
 *
 *
 * ciscenja, prenos fja iz fakt-a
 *
 * Revision 1.13  2002/06/25 12:04:07  ernad
 *
 *
 * ubaceno kreiranje SECUR-a (posto je prebacen u kumpath)
 *
 * Revision 1.12  2002/06/25 08:58:07  ernad
 *
 *
 * \group Planika, var tbl_roba_k2
 *
 * Revision 1.11  2002/06/24 07:00:37  ernad
 *
 *
 * GwDiskFree, ciscenja gateway
 *
 * Revision 1.10  2002/06/22 19:08:54  ernad
 *
 *
 * modstru debug (PreUseEvent), ciscenja planika
 *
 * Revision 1.9  2002/06/21 16:00:51  ernad
 *
 *
 *
 * debug TDB:cRadimUSezona = NIL
 *
 * Revision 1.8  2002/06/21 13:32:42  ernad
 *
 *
 * planika - debug aZabIsp / EditSifIte, razrada gw - import db
 *
 * Revision 1.7  2002/06/20 12:53:11  ernad
 *
 *
 * ciscenje rada sezonsko<->radno podrucje ... prebacivanje db/1g -> db/2g
 *
 * Revision 1.6  2002/06/20 12:35:34  ernad
 * AL_*  varijable - Aplikacijska licenca (ili level) svejedno
 *
 * Revision 1.5  2002/06/19 19:51:00  ernad
 *
 *
 * rad u sezonama, gateway
 *
 * Revision 1.4  2002/06/19 08:16:00  ernad
 * ciscenje - razbijanje Gw funkcije, doxy ...
 *
 * Revision 1.3  2002/06/17 09:49:59  ernad
 *
 *
 * headeri, make sistem
 *
 * Revision 1.2  2002/06/16 14:06:44  ernad
 * no message
 *
 * Revision 1.1  2002/06/16 12:05:37  ernad
 * prenos u cl/sigma/sclib iz cl/sigma/base/1g
 *
 *
 */
 

#define SC_DEFINED
#define SC_CLIB_VER  "1.w.0.9.67"

#ifdef CLIP
	#DEFINE SLASH "/"
	#DEFINE INDEXEXTENS "cdx"
	#DEFINE INDEXEXT "cdx"
	#DEFINE DBFEXT "dbf"
	#DEFINE MEMOEXT "fpt"
	#DEFINE RDDENGINE "DBFCDX"
	#DEFINE DRVPATH "/c/"
	#define NRED chr(10)
#else
	#DEFINE SLASH "\"
	#DEFINE INDEXEXTENS "CDX"
	#DEFINE INDEXEXT "CDX"
	#DEFINE DBFEXT "DBF"
	#DEFINE MEMOEXT "FPT"
	#DEFINE RDDENGINE "COMIX"
	#DEFINE DRVPATH ":\"
	#define NRED chr(13)+chr(10)
#endif

#define P_NRED QOUT()

#include "h:\dev\af\cl-sclib\sclib\base\1g\sc_std.ch"
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
	#include "h:\dev\Fmk\AF\cl-AF\fmk.ch"
#endif

#ifdef CDX
	#include "h:\dev\AF\cl-sclib\sclib\db\1g\sc_db.ch"
	#ifndef CLIP
		#include "cm52.ch"
	#endif
#else
	#include "ax\sc_db.ch"
#endif

//korisnicke licence
#define AL_INET 1
#define AL_STANDARD 2
#define AL_SILVER 3
#define AL_GOLD 4
#define AL_PLATINIUM 5

#ifdef CLIP

#xcommand method <Met> =>;
   static function <Met>

#endif

