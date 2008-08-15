
function test_cp()

REQUEST HB_CODEPAGE_SL852
REQUEST HB_CODEPAGE_SLISO
REQUEST HB_LANG_SL852

hb_setCodePage( "SL852" )
HB_LangSelect( "SL852" )
HB_SETTERMCP("SLISO")
//HB_SETDISPCP( "SL852" ) 

? chr(143), " - CC"
? chr(166), " - ZZ"
? chr(172), " - CH"
? chr(209), " - DD"
? chr(230), " - SS"

inkey(0)

set printer to "test.txt"
set printer on

cString := "ERNAD HUSREMOVI" + chr(143) 

? HB_STRTOUTF8(cString, "SL852")

set printer off
set printer to

cChar:=" "
@ 10,10 SAY "pritisni " + chr(166) + ", trebalo bi da dobijes kod 166" GET cChar
READ


? ASC(cChar), cChar
? ASC(LOWER(cChar)), LOWER(cChar)
? "-------------------------------------------"

inkey(0)

return nil
