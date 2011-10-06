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



function test_novasifra()
local cSifra
local aSifre := {  "0000", "9999", "B000", "B999", "Z999",  chr(143) + "150", chr(143) + "999", chr(166) + "999", chr(172) + "999", chr(209)+"999", chr(230)+"999", "X999", "W999", "X000" }

? procname()
? "-------------------------------------------"
for i := 1 to LEN(aSifre)
 cSifra := aSifre[i]

 cNovaSifra := NovaSifra(cSifra)
 ? cSifra, "novasifra=", cNovasifra 
 ?? " asc stara" , ASC(LEFT(cSifra,1)), "asc nova=",  ASC(LEFT(cNovasifra,1)) 

next

