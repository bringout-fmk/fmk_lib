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


#include "fmk.ch"

//---------------------------------------------------
//---------------------------------------------------
function OFmkRoba()

O_SIFK
O_SIFV
O_KONTO
O_KONCIJ
O_TRFP
O_TARIFA
O_ROBA
O_SAST
return

//---------------------------------------------------
//---------------------------------------------------
function CreRoba()

aDbf:={}
AADD(aDBf,{ 'ID'                  , 'C' ,  10 ,  0 })
add_f_mcode(@aDbf)
AADD(aDBf,{ 'NAZ'                 , 'C' , 250 ,  0 })
AADD(aDBf,{ 'STRINGS'             , 'N' ,  10 ,  0 })
AADD(aDBf,{ 'JMJ'                 , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'IDTARIFA'            , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'NC'                  , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'VPC'                 , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'VPC2'                , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'PLC'                 , 'N' ,  18 ,  8 })
// plc - mislim da ni ovo bas niko ne koristi treba analizirati
//       vidjeti kod korisnika

AADD(aDBf,{ 'MPC'                 , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'MPC2'                , 'N' ,  18 ,  8 })
AADD(aDBf,{ 'MPC3'                , 'N' ,  18 ,  8 })
// mpc2, mpc3 ------ ?? perspektivno ubaciti u sifk

AADD(aDBf,{ 'Carina'              , 'N' ,   5 ,  2 })
// mislim da se treba izbrisati

AADD(aDBf,{ 'K1'                  , 'C' ,   4 ,  0 })
// planika: dobavljac   - grupe artikala

AADD(aDBf,{ 'K2'                  , 'C' ,   4 ,  0 })
// planika: stavljaju se oznake za velicinu obuce
//          X - ne broji se parovno

AADD(aDBf,{ 'N1'                  , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'N2'                  , 'N' ,  12 ,  2 })

AADD(aDBf,{ 'TIP'                 , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'MINK'                , 'N' ,  12 ,  2 })


AADD(aDBf,{ 'Opis'                , 'M' ,  10 ,  0 })
// koliko mi je poznato, opis treba ukinuti !!!!
// napraviti opciju u ikalk za brisanje opisa !!! a u kodu uslovno
// omoguciti editovanje opisa
AADD(aDBf,{ 'BARKOD'                , 'C' ,  13 ,  0 })

if !file(SIFPATH+"roba.dbf")
        dbcreate2(SIFPATH+'roba.dbf', aDbf)
	
endif

if !file(PRIVPATH+"_roba.dbf")
        dbcreate2(PRIVPATH+'_roba.dbf',aDbf)
endif

CREATE_INDEX("ID","id",SIFPATH+"roba") 
index_mcode(SIFPATH, "roba")
CREATE_INDEX("NAZ","LEFT(naz,40)", SIFPATH+"roba")
CREATE_INDEX("ID","id", PRIVPATH+"_roba") 
O_ROBA

if fieldpos("KATBR")<>0
  select (F_ROBA)
  use
  CREATE_INDEX("KATBR","KATBR",SIFPATH+"roba") // roba, artikli
endif

O_ROBA
if fieldpos("BARKOD")<>0
  select (F_ROBA)
  use
  CREATE_INDEX("BARKOD","BARKOD",SIFPATH+"roba") // roba, artikli
endif

O_ROBA
if fieldpos("SIFRADOB")<>0
  select (F_ROBA)
  use
  CREATE_INDEX("SIFRADOB","SIFRADOB",SIFPATH+"roba") // roba, artikli
endif


if IsVindija()
	select (F_ROBA)
  	use
  	CREATE_INDEX("ID_VSD","SIFRADOB", SIFPATH + "roba") // sifra dobavljaca
endif


// TARIFA
if !file(SIFPATH+"tarifa.dbf")
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,   6 ,  0 })
        add_f_mcode(@aDbf)
	AADD(aDBf,{ 'NAZ'                 , 'C' ,  50 ,  0 })
        AADD(aDBf,{ 'OPP'                 , 'N' ,   6 ,  2 })  // ppp
        AADD(aDBf,{ 'PPP'                 , 'N' ,   6 ,  2 })  // ppu
        AADD(aDBf,{ 'ZPP'                 , 'N' ,   6 ,  2 })  //nista
        AADD(aDBf,{ 'VPP'                 , 'N' ,   6 ,  2 })  // pnamar
        AADD(aDBf,{ 'MPP'                 , 'N' ,   6 ,  2 })  // pnamar MP
        AADD(aDBf,{ 'DLRUC'               , 'N' ,   6 ,  2 })  // donji limit RUC-a(%)
        dbcreate2( SIFPATH+'tarifa', aDbf)
endif
CREATE_INDEX("ID","id",  SIFPATH+"TARIFA")
CREATE_INDEX("naz","naz", SIFPATH+"TARIFA")
index_mcode(SIFPATH, "TARIFA")

// KONCIJ
if !file(SIFPATH+"koncij.dbf")
   aDbf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   7 ,  0 })
   add_f_mcode(@aDbf)
   AADD(aDBf,{ 'SHEMA'               , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'IDPRODMJES'          , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'REGION'              , 'C' ,   2 ,  0 })
   dbcreate2(SIFPATH+'KONCIJ.DBF',aDbf)
endif
CREATE_INDEX("ID","id",SIFPATH+"KONCIJ") // konta
index_mcode(SIFPATH, "KONCIJ")

// TRFP
if !file(SIFPATH+"trfp.dbf")
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,  60 ,  0 })
        add_f_mcode(@aDbf)
	AADD(aDBf,{ 'SHEMA'               , 'C' ,   1 ,  0 })
        AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
        AADD(aDBf,{ 'IDKONTO'             , 'C' ,   7 ,  0 })
        AADD(aDBf,{ 'DOKUMENT'            , 'C' ,   1 ,  0 })
        AADD(aDBf,{ 'PARTNER'             , 'C' ,   1 ,  0 })
        AADD(aDBf,{ 'D_P'                 , 'C' ,   1 ,  0 })
        AADD(aDBf,{ 'ZNAK'                , 'C' ,   1 ,  0 })
        AADD(aDBf,{ 'IDVD'                , 'C' ,   2 ,  0 })
        AADD(aDBf,{ 'IDVN'                , 'C' ,   2 ,  0 })
        AADD(aDBf,{ 'IDTARIFA'            , 'C' ,   6 ,  0 })
        dbcreate2(SIFPATH+"trfp.dbf",aDbf)
endif
CREATE_INDEX("ID","idvd+shema+Idkonto",SIFPATH+"trfp")
index_mcode(SIFPATH, "TRFP")


// SAST
if !file(SIFPATH + "sast.dbf")
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   10 ,  0 })
   AADD(aDBf,{ 'R_BR'                , 'N' ,    4 ,  0 })
   AADD(aDBf,{ 'ID2'                 , 'C' ,   10 ,  0 })
   AADD(aDBf,{ 'KOLICINA'            , 'N' ,   20 ,  5 })
   AADD(aDBf,{ 'K1'                  , 'C' ,    1 ,  0 })
   AADD(aDBf,{ 'K2'                  , 'C' ,    1 ,  0 })
   AADD(aDBf,{ 'N1'                  , 'N' ,   20 ,  5 })
   AADD(aDBf,{ 'N2'                  , 'N' ,   20 ,  5 })
   dbcreate2(SIFPATH+'SAST.DBF',aDbf)
endif

CREATE_INDEX("ID", "ID+ID2", SIFPATH + "SAST")
O_SAST
if sast->(fieldpos("R_BR"))<>0
	use
	CREATE_INDEX("IDRBR", "ID+STR(R_BR,4,0)+ID2", SIFPATH + "SAST")
endif
use
CREATE_INDEX("NAZ", "ID2+ID", SIFPATH + "SAST")


if !file(PRIVPATH+"barkod.dbf")
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   10 ,  0 })
   AADD(aDBf,{ 'BARKOD'              , 'C' ,   13 ,  0 })
   AADD(aDBf,{ 'NAZIV'               , 'C' ,  250 ,  0 })
   AADD(aDBf,{ 'L1'                  , 'C' ,   40,   0 })
   AADD(aDBf,{ 'L2'                  , 'C' ,   40,   0 })
   AADD(aDBf,{ 'L3'                  , 'C' ,   40 ,  0})
   AADD(aDBf,{ 'VPC'                 , 'N' ,   12 ,  2 })
   AADD(aDBf,{ 'MPC'                 , 'N' ,   12 ,  2 })
   dbcreate2(PRIVPATH+'BARKOD.DBF',aDbf)
endif
CREATE_INDEX("1","barkod+id",PRIVPATH+"BARKOD")
CREATE_INDEX("ID","id+LEFT(naziv,40)",PRIVPATH+"BARKOD")
CREATE_INDEX("Naziv","LEFT(Naziv,40)+id",PRIVPATH+"BARKOD")

// kreiranje tabele strings
cre_strings()

return


