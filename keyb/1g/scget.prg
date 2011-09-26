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



/****h SC_CLIB/GETSYS ***
* 
* AUTHOR
*   clipper sources
*
* NAME
*   Standard clipper 5.2 GET/READ subsistem
*
****/


#include "Set.ch"
#include "Inkey.ch"
#include "Getexit.ch"

#define K_UNDO          K_CTRL_U

// state variables for active READ
static Format
static Updated := .f.
static KillReadSC
static BumpTop
static BumpBot
static LastExit
static LastPos
static ActiveGet
static ReadProcName
static ReadProcLine


// format of array used to preserve state variables
#define GSV_KILLREAD		1
#define GSV_BUMPTOP			2
#define GSV_BUMPBOT			3
#define GSV_LASTEXIT		4
#define GSV_LASTPOS			5
#define GSV_ACTIVEGET		6
#define GSV_READVAR 		7
#define GSV_READPROCNAME	8
#define GSV_READPROCLINE	9

#define GSV_COUNT			9

// Modifications
#ifndef NOCHANGES

// Time-out variable
STATIC lTimedOut := .f.
STATIC nTimeOut

// GOTOGET and START AT get variable
STATIC nToGet

// Exit at Get variable
STATIC nAtGet

#endif

/***
*	ReadModal()
*	Standard modal READ on an array of GETs.
*/

function ReadModSC( GetList, nTime, nStartAt )

local get
local pos
local savedGetSysVars

nTimeOut:=IIF(nTime == NIL, 0, nTime)
lTimedOut := .f.


if ( ValType(Format) == "B" )
	Eval(Format)
endif

if ( Empty(getList) )
	// S87 compat.
	SetPos( MaxRow()-1, 0 )
	// NOTE
	return (.f.)			
endif


// preserve state vars
savedGetSysVars := ClrGetSysVarSC()

// set these for use in SET KEYs
ReadProcName := ProcName(1)
ReadProcLine := ProcLine(1)


IF (nStartAt != NIL)
	pos := nStartAt
ELSE
	// set initial GET to be read
	pos := SettleSC( Getlist, 0 )

ENDIF

do while ( pos <> 0 )

	//ol_yield()

	// get next GET from list and post it as the active GET
	get := GetList[pos]
	PstActGetSc( get )


	// read the GET
	if ( ValType( get:reader ) == "B" )
		// use custom reader block
		Eval( get:reader, get ) 		
	else
		
		GetReadSC( get )				
	endif


  	nAtGet := pos

      	// move to next GET based on exit condition
	pos := SettleSC( GetList, pos )

enddo


// restore state vars
RstGetSysVarSC(savedGetSysVars)

// S87 compat.
SetPos( MaxRow()-1, 0 )

return (Updated)



/***
*	GetReadSC()
*	Standard modal read of a single GET.
*/
procedure getReadSC(get)
		
// read the GET if the WHEN condition is satisfied
if ( GetPreValSC(get) )

		// activate the GET for reading
		get:SetFocus()

		
		do while ( get:exitState == GE_NOEXIT )
			
			ol_yield()

			// check for initial typeout (no editable positions)
			if ( get:typeOut )
				get:exitState := GE_ENTER
			endif

			// apply keystrokes until exit
			do while ( get:exitState == GE_NOEXIT )
				ol_yield()
				GetApplyKSC( get, MyInKeySC() )
			enddo

			// disallow exit if the VALID condition is not satisfied
			if ( !GetPstValSC(get) )
				get:exitState := GE_NOEXIT
			endif

		end

		// de-activate the GET
		get:KillFocus()

endif

return



/***
*	GetApplyKSC()
*	Apply a single Inkey() keystroke to a GET.
*
*	NOTE: GET must have focus.
*/
procedure GetApplyKSC(get, key)

local cKey
local bKeyBlock


// check for SET KEY first
if ( (bKeyBlock := SetKey(key)) <> NIL )

	GetDoSetKSC(bKeyBlock, get)
	return									// NOTE

endif


do case

	
//
// Time-out
//
CASE ( lTimedOut )
	//MsgBeep("lTimedOut=True")
	get:undo()
	get:exitState := GE_ESCAPE

case (key == K_UP )
	get:exitState := GE_UP

case (key == K_SH_TAB )
	get:exitState := GE_UP

case (key == K_DOWN )
	get:exitState := GE_DOWN

case (key == K_TAB )
	get:exitState := GE_DOWN

case (key == K_ENTER )
	get:exitState := GE_ENTER

case (key == K_ESC )
	
	//MsgBeep("pritisnut ESCAPE")
	if ( Set(_SET_ESCAPE) )
		get:undo()
		get:exitState := GE_ESCAPE
	endif

case ( key == K_PGUP )
	get:exitState := GE_WRITE

case ( key == K_PGDN )
	get:exitState := GE_WRITE

case ( key == K_CTRL_HOME )
	get:exitState := GE_TOP


#ifdef CTRL_END_SPECIAL

	// both ^W and ^End go to the last GET
	case (key == K_CTRL_END)
		get:exitState := GE_BOTTOM

#else

	// both ^W and ^End terminate the READ (the default)
	case (key == K_CTRL_W)
		get:exitState := GE_WRITE

#endif


case (key == K_INS)
	Set( _SET_INSERT, !Set(_SET_INSERT) )
	ShowScoreboard()

case (key == K_UNDO)
	get:Undo()

case (key == K_HOME)
	get:Home()

case (key == K_END)
	get:End()

case (key == K_RIGHT)
	get:Right()

case (key == K_LEFT)
	get:Left()

case (key == K_CTRL_RIGHT)
	get:WordRight()

case (key == K_CTRL_LEFT)
	get:WordLeft()

case (key == K_BS)
	get:BackSpace()

case (key == K_DEL)
	get:Delete()

case (key == K_CTRL_T)
	get:DelWordRight()

case (key == K_CTRL_Y)
	get:DelEnd()

case (key == K_CTRL_BS)
	get:DelWordLeft()

otherwise

if (key >= 32 .and. key <= 255)

	cKey := Chr(key)

	if (get:type == "N" .and. (cKey == "." .or. cKey == ","))
		get:ToDecPos()

	else
		if ( Set(_SET_INSERT) )
			get:Insert(cKey)
		else
			get:Overstrike(cKey)
		endif

		if (get:typeOut .and. !Set(_SET_CONFIRM) )
			if ( Set(_SET_BELL) )
				?? Chr(7)
			end

			get:exitState := GE_ENTER
		endif

	endif

endif

endcase

return



/***
*	GetPreValidate()
*	Test entry condition (WHEN clause) for a GET.
*/
function GetPreValSC(get)

local saveUpdated
local lWhen := .t.


if ( get:preBlock <> NIL )

	saveUpdated := Updated

	lWhen := Eval(get:preBlock, get)

	get:Display()

	ShowScoreBoard()
	Updated := saveUpdated

endif


if (KillReadSC)
		//MsgBeep("KillreadSC=.t./1")
		lWhen := .f.
		get:exitState := GE_ESCAPE		
		// provokes ReadModal() exit

elseif ( !lWhen )
		get:exitState := GE_WHEN		
		// indicates failure

else
		get:exitState := GE_NOEXIT		
		// prepares for editing

endif

return (lWhen)



/***
*	GetPstValSC()
*	Test exit condition (VALID clause) for a GET.
*
*	NOTE: bad dates are rejected in such a way as to preserve edit buffer.
*/
function GetPstValSC(get)

local saveUpdated
local changed, valid := .t.


if ( get:exitState == GE_ESCAPE )
		return (.t.)					
		// NOTE
endif

if ( get:BadDate() )
		get:Home()
		DateMsg()
		ShowScoreboard()
		return (.f.)					// NOTE
endif


// if editing occurred, assign the new value to the variable
if ( get:changed )
	get:Assign()
	Updated := .t.
endif


// reform edit buffer, set cursor to home position, redisplay
get:Reset()


// check VALID condition if specified
if ( get:postBlock <> NIL )

	saveUpdated := Updated

	// S87 compat.
	SetPos( get:row, get:col + Len(get:buffer) )

	valid := Eval(get:postBlock, get)

	// reset compat. pos
	SetPos( get:row, get:col )

	ShowScoreBoard()
	get:UpdateBuffer()

	Updated := saveUpdated

	if (KillReadSC)
		
		//MsgBeep("KillreadSC=.t./2")
		
		// provokes ReadModal() exit
		get:exitState := GE_ESCAPE	
		valid := .t.
	end

endif

return (valid)




/***
*	GetDoSetKSC()
*	Process SET KEY during editing.
*/
function GetDoSetKSC(keyBlock, get)

local saveUpdated


	// if editing has occurred, assign variable
	if ( get:changed )
		get:Assign()
		Updated := .t.
	end


	saveUpdated := Updated

	Eval(keyBlock, ReadProcName, ReadProcLine, ReadVar())

	ShowScoreboard()
	get:UpdateBuffer()

	Updated := saveUpdated


	if (KillReadSC)
		
		//MsgBeep("KillreadSC=.t. / 3")
		get:exitState := GE_ESCAPE		// provokes ReadModal() exit
	end

return



/*
*
*	READ services
*
*/


/***
*	SettleSC()
*
*	Returns new position in array of Get objects, based on
*
*		- current position
*		- exitState of Get object at current position
*
*	NOTE return value of 0 indicates termination of READ
*	NOTE exitState of old Get is transferred to new Get
*/
static function SettleSC(GetList, pos)

local lExitState

//MsgBeep(STR(Len(GetList)))


if (pos == 0)
	lExitState := GE_DOWN
else
	lExitState := GetList[pos]:exitState
endif


if (lExitState == GE_ESCAPE)
	//MsgBeep("escape ...")
	return 0
endif

if (lExitState == GE_WRITE )
	//MsgBeep("pg_down")
	return 0					
endif


if ( lExitState <> GE_WHEN )
	// reset state info
	LastPos := pos
	BumpTop := .f.
	BumpBot := .f.

else
	// re-use last exitState, do not disturb state info
	lExitState := LastExit

endif


/***
*	move
*/
do case
	case ( lExitState == GE_UP )
		pos --

	case ( lExitState == GE_DOWN )
		pos ++

	case ( lExitState == GE_TOP )
		pos := 1
		BumpTop := .T.
		exitState := GE_DOWN

	case ( lExitState == GE_BOTTOM )
		pos := Len(GetList)
		BumpBot := .T.
		lExitState := GE_UP

	case ( lExitState == GE_ENTER )
		pos ++

   CASE ( lExitState < 0 .AND. -lExitState <= LEN(GetList))
      pos := -lExitState
      lExitState := GE_NOEXIT


endcase


/**
	*	bounce
*/
if ( pos == 0 ) 						
// bumped top

	if ( !ReadExitSC() .and. !BumpBot )
		BumpTop := .T.
		pos := LastPos
		lExitState := GE_DOWN
	endif

elseif ( pos == Len(GetList) + 1 )		
// bumped bottom

	if ( !ReadExitSC() .and. lExitState <> GE_ENTER .and. !BumpTop )
		BumpBot := .T.
		pos := LastPos
		lExitState := GE_UP
	else

		//MsgBeep("settle 0-2")
		pos := 0
	endif
endif


// record exit state
LastExit := lExitState

if (pos <> 0)
	GetList[pos]:exitState := lExitState
endif

return (pos)



/***
*	PstActGetSc()
*	Post active GET for ReadVar(), GetActive().
*/
static procedure PstActGetSC(get)

	GetActive( get )
	ReadVar( GetReadVSC(get) )

	ShowScoreBoard()

return



/***
*	ClrGetSysVarSC()
*	Save and clear READ state variables. Return array of saved values.
*
*	NOTE: 'Updated' status is cleared but not saved (S87 compat.).
*/
static function ClrGetSysVarSC()

local saved[ GSV_COUNT ]


	saved[ GSV_KILLREAD ] := KillReadSC
	KillReadSC := .f.

	saved[ GSV_BUMPTOP ] := BumpTop
	BumpTop := .f.

	saved[ GSV_BUMPBOT ] := BumpBot
	BumpBot := .f.

	saved[ GSV_LASTEXIT ] := LastExit
	LastExit := 0

	saved[ GSV_LASTPOS ] := LastPos
	LastPos := 0

	saved[ GSV_ACTIVEGET ] := GetActive( NIL )

	saved[ GSV_READVAR ] := ReadVar( "" )

	saved[ GSV_READPROCNAME ] := ReadProcName
	ReadProcName := ""

	saved[ GSV_READPROCLINE ] := ReadProcLine
	ReadProcLine := 0

	Updated := .f.

return (saved)



/***
*   RstGetSysVarSC()
*	Restore READ state variables from array of saved values.
*
*	NOTE: 'Updated' status is not restored (S87 compat.).
*/
static function RstGetSysVarSC(saved)

	KillReadSC := saved[ GSV_KILLREAD ]

	BumpTop := saved[ GSV_BUMPTOP ]

	BumpBot := saved[ GSV_BUMPBOT ]

	LastExit := saved[ GSV_LASTEXIT ]

	LastPos := saved[ GSV_LASTPOS ]

	GetActive( saved[ GSV_ACTIVEGET ] )

	ReadVar( saved[ GSV_READVAR ] )

	ReadProcName := saved[ GSV_READPROCNAME ]

	ReadProcLine := saved[ GSV_READPROCLINE ]

return



/***
*	GetReadVSC()
*	Set READVAR() value from a GET.
*/
static function GetReadVSC(get)

local name := Upper(get:name)
local i

//#ifdef SUBSCRIPT_IN_READVAR

	/***
	*	The following code includes subscripts in the name returned by
	*	this function, if the get variable is an array element.
	*
	*	Subscripts are retrieved from the get:subscript instance variable.
	*
	*	NOTE: incompatible with Summer 87
	*/

	if ( get:subscript <> NIL )
		for i := 1 to len(get:subscript)
			name += "[" + ltrim(str(get:subscript[i])) + "]"
		next
	end

//#endif

return (name)



/*
*
*	system services
*
*/



/***
*   __SetFormat()
*	SET FORMAT service
*/
func __SetFormat(b)
	Format := if ( ValType(b) == "B", b, NIL )
return (NIL)


/***
*	__KillReadSC()
*   CLEAR GETS service
*/
function __KillReadSC()
	KillReadSC := .t.

	//MsgBeep("KillreadSC=.t./4")
return


/***
*	GetActive()
*/
function GetActive(g)
local oldActive := ActiveGet
	if ( PCount() > 0 )
		ActiveGet := g
	end
return ( oldActive )


/***
*	Updated()
*/
function Updated()
return (Updated)


/***
*	ReadExitSC()
*/
function ReadExitSC(lNew)
return ( Set(_SET_EXIT, lNew) )


/***
*	ReadInsert()
*/
function ReadInsert(lNew)
return ( Set(_SET_INSERT, lNew) )



/*
*
*	wacky compatibility services
*
*/


// display coordinates for SCOREBOARD
#define SCORE_ROW		0
#define SCORE_COL		60


/***
*   ShowScoreboard()
*/
static procedure ShowScoreboard()

local nRow, nCol


if ( Set(_SET_SCOREBOARD) )
        nRow := Row()
        nCol := Col()

		SetPos(SCORE_ROW, SCORE_COL)
		DispOut( if(Set(_SET_INSERT), "Ins", "   ") )
       SetPos(nRow, nCol)
endif

return



/***
*	DateMsg()
*/
static procedure DateMsg()

local nRow, nCol


    if ( Set(_SET_SCOREBOARD) )
		nRow := Row()
		nCol := Col()

		SetPos(SCORE_ROW, SCORE_COL)
		DispOut("Invalid Date")
        SetPos(nRow, nCol)

		while ( Nextkey() == 0 )
		end

		SetPos(SCORE_ROW, SCORE_COL)
		DispOut("            ")
        SetPos(nRow, nCol)

	end

return



/***
*   RangeCheck()
*
*	NOTE: unused second param for 5.00 compatibility.
*/

func RangeCheck(get, junk, lo, hi)

local cMsg, nRow, nCol
local xValue


	if ( !get:changed )
		return (.t.)
	end

	xValue := get:VarGet()

	if ( xValue >= lo .and. xValue <= hi )
		return (.t.)									// NOTE
	end

    if ( Set(_SET_SCOREBOARD) )
		cMsg := "Range: " + Ltrim(Transform(lo, "")) + ;
				" - " + Ltrim(Transform(hi, ""))

		if ( Len(cMsg) > MaxCol() )
			cMsg := Substr( cMsg, 1, MaxCol() )
		end

		nRow := Row()
		nCol := Col()

		SetPos( SCORE_ROW, Min(60, MaxCol() - Len(cMsg)) )
		DispOut(cMsg)
        SetPos(nRow, nCol)

		while ( NextKey() == 0 )
		end

		SetPos( SCORE_ROW, Min(60, MaxCol() - Len(cMsg)) )
		DispOut( Space(Len(cMsg)) )
        SetPos(nRow, nCol)

	end

return (.f.)

/**
 *
 * Time-Out?
 *
 */

FUNCTION TimedOut()
RETURN (lTimedOut)

/**
 *
 * Time-Out feature
 *
 */

static function MyInKeySc()
local nKey
local nBroji2
local nCursor

nBroji2:=seconds()
nTimeout:=seconds()

do while NEXTKEY()==0
	ol_yield()
enddo
nKey:=INKEY()

if (gSQL=="D")
	do while .t.
		ol_yield()
		GwStaMai(@nBroji2)
		if !(GW_STATUS == "NA_CEKI_K_SQL")
			Exit
		endif
	enddo
endif

RETURN (nKey)

/*
 * Go to a particular get
 */

FUNCTION GoToGet(nGet)
   
GetActive():exitState := -nGet

// !!!!NOTE!!!!
RETURN (.T.)

/*
 *
 * What was the Get?
 *
 */

FUNCTION ExitAtGet()
RETURN (nAtGet)


function ShowGets()
AEVAL(GetList,{|oE|  oE:Display() })
return .t.

function RefreshGets()
AEVAL(MGetList,{|oE|  oE:Display() })
return .t.


// -----------------------------
// -----------------------------
function InkeySc(nSec)
if (nSec==0) 
	do while NEXTKEY()==0
	 	ol_yield()
	enddo
	return INKEY()
else
	return INKEY(nSec)
endif

