#include "sc.ch"

// ----------------------------------------------------------------
// slanje email-a 
// ----------------------------------------------------------------
function email_send( cVar, cFrom, cTo, cSubject, cBody, cMFile, aAttach )

if cVar == nil
	cVar := ""
endif

do case
	case EMPTY( cVar )
		_send_err()
	case cVar == "1"
		// standardna email opcija
		_send_std( cFrom, cTo, cSubject, ;
			cBody, cMFile )

	case cVar == "F"
		// fiscal email
		_send_fis( cSubject, cMfile )
endcase

return


// -------------------------------------------
// slanje standardne email poruke
// -------------------------------------------
static function _send_fis( cM_sub, cM_file )
local cScript
local cRbScr
private cEmlCmd := ""

if cM_sub == nil
	cM_sub := ""
endif

if cM_file == nil
	cM_file := ""
endif

cScript := IzFmkIni("Ruby","FiscMail","c:\sigma\eFisc.rb", EXEPATH)

cEmlCmd := cScript + " " + cM_sub + " " + cM_file

// snimi sliku i ocisti ekran
save screen to cRbScr
clear screen

// pokreni komandu
run &cEmlCmd

restore screen from cRbScr

return nil


// -------------------------------------------
// slanje standardne email poruke
// -------------------------------------------
static function _send_std( cM_from, cM_to, cM_sub, cM_body, cM_file )
local cScript
local cRbScr
private cEmlCmd := ""

if cM_sub == nil
	cM_sub := ""
endif

if cM_body == nil
	cM_body := ""
endif

cScript := IzFmkIni("Ruby","StdMail","c:\sigma\stdeml.rb", EXEPATH)

cEmlCmd := cScript + " " + cM_from + " " + cM_to + " " + ;
	" " + cM_sub + " " + cM_body + " " + cM_file

// snimi sliku i ocisti ekran
save screen to cRbScr
clear screen

// pokreni komandu
run &cEmlCmd

restore screen from cRbScr

return nil



// --------------------------------------------------------
// posalji error na email
// --------------------------------------------------------
static function _send_err()
local cRbScr

private cEmlCmd

// uzmi parametre za slanje
_get_varE( @cEmlCmd )

// snimi sliku i ocisti ekran
save screen to cRbScr
clear screen

? "sending report via email ... please wait ..."
// pokreni komandu
run &cEmlCmd

Sleep(3)
// vrati staro stanje ekrana
restore screen from cRbScr

return


// -------------------------------------------
// vraca cmd line za slanje emailom
// -------------------------------------------
static function _get_varE( cCmd )
local cScript := IzFmkIni("Ruby","Err2Mail","c:\sigma\err2mail.rb", EXEPATH)
local cRptFile := PRIVPATH + "outf.txt"

cCmd := cScript + " " + cRptFile

return


