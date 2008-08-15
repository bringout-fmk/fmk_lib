function main()


//hb_setCodePage( "HR852" )
//hb_setDispCP( "XXXX" )
//hb_setKeyCP("XXXX")
//hb_SetTermCP("HR852", "HRISO")
REQUEST HB_CODEPAGE_SL852
REQUEST HB_CODEPAGE_SLISO
REQUEST HB_LANG_SL852

hb_setCodePage( "SL852" )
HB_LangSelect( "SL852" )
HB_SETTERMCP("SLISO")
//HB_SETDISPCP( "SL852" ) 

? chr(143), " - Æ"
? chr(166), " - ®"
? chr(172), " - È"
? chr(209), " - Ð"
? chr(230), " - ©"

inkey(0)

cChar:=" "
@ 10,10 SAY "pritisni " + chr(166) + ", trebalo bi da dobijes kod 166" GET cChar
READ


? ASC(cChar), cChar
? ASC(LOWER(cChar)), LOWER(cChar)
? "-------------------------------------------"

inkey(0)

test_novasifra()

inkey(0)

return
