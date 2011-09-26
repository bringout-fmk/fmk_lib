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


#include "Inkey.ch"
#include "dbedit.ch"

/****h SC_CLIB/ARRAY ***
 
*AUTOR
   CA-clipper - sources

*IME
   Funkcije za rad sa matricama                                      
    
*DATUM
   00.00.96

***/

// This static maintains the "current row" for ABrowse()
static nRow



function ABrowRow()
return nRow


/****f SC_CLIB/ABrowse ***

*AUTOR
   Ernad Husremovic ernad@sigma-com.net

*IME
   Abrowse

*SYNOPSIS
   ABrowse( <aArray>, <nWidthX>, <nWidthY>, <bUserFunction> ) --> value

*ULAZI
   aArray  - 
   nWidthX - sirina X
   nWidthY - sirina Y
   bUserFunction - code block 

*OPIS
 browse a 2-dim array using tbrowse object and return the value of
 the higlighted array element

*PRIMJER

	History:={"1","2","3"}
   	ABrowse(aHistory,10,1,{|ch|  HistUser(ch)}))[1]

	function histuser(ch)
	local nrec,chi

	do case
	 case ch==k_enter
	  return de_abort
	 case ch=k_ctrl_t
	  if len(ahistory)>1
	   chi:=ahistory[abrowrow(),1]
	   adel(ahistory,abrowrow())
	   asize(ahistory,len(ahistory)-1)
	   seek csection+chi
	   do while !eof() .and. csection+chi==fsec+fh
	      skip; nrec:=recno(); skip -1
	      delete
	      go nrec
	   enddo
	  else
	    beep(2)
	  endif
	  return de_refresh
	  // izbrisi tekuci element
	 otherwise
	  return de_cont
	endcase

	return nil

****/

FUNCTION ABrowse( aArray, xw, yw, bUserF)

local nT,nL,nB,nR
LOCAL n, xRet, nOldNRow, nOldCursor  // Various
LOCAL TB                             // TBrowse object
LOCAL nRez,nKey := 0                 // Keystroke holder

Box(,xw,yw)

// Preserve cursor setting, turn off cursor
nOldCursor := SetCursor( 0 )

// Preserve static var (just in case), set it to 1
nOldNRow := nRow
nRow := 1

nT:=m_x+1
nL:=m_y+1
nB:=m_x+xw
nR:=m_y+yw


// Create the TBrowse object
TB := TBrowseNew( nT, nL, nB, nR )

// The "skip" block just adds to (or subtracts from) nRow
// (see ASkipTest() below)
TB:SkipBlock := { |nSkip|                                             ;
		     nSkip := ASkipTest(aArray, nRow, nSkip),   ;
		     nRow += nSkip,                             ;
		     nSkip                                      ;
	  }

// The "go top" block sets nRow to 1
TB:GoTopBlock := { || nRow := 1 }

// The "go bottom" block sets nRow to the length of the array
TB:GoBottomBlock := { || nRow := LEN(aArray) }

// Create column blocks and add TBColumn objects to the TBrowse
// (see ABrowseBlock() below)
FOR n = 1 TO LEN( aArray[1] )
  TB:AddColumn( TBColumnNew("", ABrowseBlock(aArray, n)) )
NEXT


// Start the event handler loop
DO WHILE .t.      // nKey <> K_ESC

// Stabilize
nKey := 0
DO WHILE .NOT. TB:Stabilize()
 nKey := INKEY()
 IF nKey <> 0
    EXIT
 ENDIF
ENDDO

IF nKey == 0
 DO WHILE NEXTKEY()==0; OL_YIELD(); ENDDO
 nKey := INKEY()
 // nKey := INKEY(0)
ENDIF

if bUserF<>NIL
nRez:=Eval(bUserF,nKey)
else
nRez:=DE_CONT
endif

// Process the directional keys
IF TB:Stable

 DO CASE
 CASE ( nKey == K_DOWN )
    TB:Down()

 CASE ( nKey == K_UP )
    TB:Up()

 CASE ( nKey == K_RIGHT )
    TB:Right()

 CASE ( nKey == K_LEFT )
    TB:Left()

 CASE ( nKey == K_PGDN )
    TB:Right()
    TB:Down()

 CASE ( nKey == K_PGUP )
    TB:Right()
    TB:Up()

 CASE ( nKey == K_HOME )
    TB:Left()
    TB:Up()

 CASE ( nKey == K_END )
    TB:Left()
    TB:Down()

 ENDCASE



do case
   CASE nRez==DE_REFRESH
	TB:RefreshAll()
  CASE nRez==DE_ABORT .or. nKey==K_CTRL_END .or. nKey==K_ESC
      BoxC() ;  EXIT
endcase




ENDIF

ENDDO


xRet:=aArray[nRow]

// Restore cursor setting
SetCursor( nOldCursor )

// Restore static var
nRow := nOldNRow


RETURN (xRet)

/****f ARRAY/ABrowseBlock ****
 
 
*IME
   ABrowseBlock
   
*  ABrowseBlock( <a>, <x> ) -> bColumnBlock
*  Service funkcija for ABrowse().
*
*  Return a set/get block for  <a>[nRow, <x>]
*
*  This function works by returning a block that refers
*  to local variables <a> and <x> (the parameters). In
*  version 5.01 these local variables are preserved for
*  use by the block even after the function has returned.
*  The result is that each call to ABrowseBlock() returns
*  a block which has the passed values of <a> and <x> "bound"
*  to it for later use. The block defined here also refers to
*  the static variable nRow, used by ABrowse() to track the
*  array's "current row" while browsing.
*
*/

STATIC FUNCTION ABrowseBlock(a, x)
RETURN ( {|p| IF(PCOUNT() == 0, a[nRow, x], a[nRow, x] := p)} )


*
*  ASkipTest( <a>, <nCurrent>, <nSkip> ) -> nSkipsPossible
*  Service funkcija for ABrowse().
*
*  Given array <a> whose "current" row is <nCurrent>, determine
*  whether it is possible to "skip" forward or backward by
*  <nSkip> rows. Return the number of skips actually possible.
*

STATIC FUNCTION ASkipTest(a, nCurrent, nSkip)

IF ( nCurrent + nSkip < 1 )
   // Would skip past the top...
   RETURN ( -nCurrent + 1 )

ELSEIF ( nCurrent + nSkip > LEN(a) )
   // Would skip past the bottom...
   RETURN ( LEN(a) - nCurrent )

END

// No problem
RETURN (nSkip)


*
*  ABlock( <cName>, <nSubx> ) -> bABlock
*
*  Given the name of a variable containing an array, and a
*  subscript value, create a set/get block for the specified
*  array element.
*
*  NOTE: cName must be the name of a variable that is visible
*  in macros (i.e. not a LOCAL or STATIC variable). Also, the
*  variable must be visible anywhere where the block is to be
*  used.
*
*  NOTE: ABlock() may be used to make blocks for a nested array
*  by including a subscript expression as part of cName:
*
*	  // to make a set/get block for a[i]
*	  b := ABlock( "a", i )
*
*	  // to make a set/get block for a[i][j]
*	  b :=- ABlock( "a[i]", j )
*
*  NOTE: this function is provided for compatibility with the
*  version 5.00 Array.prg. See the ABrowseBlock() function
*  (above) for a method of "binding" an array to a block
*  without using a macro.
*

FUNCTION ABlock( cName, nSubx )

LOCAL cAXpr

cAXpr := cName + "[" + LTRIM(STR(nSubx)) + "]"
RETURN &( "{ |p| IF(PCOUNT()==0, " + cAXpr + "," + cAXpr + ":=p) }" )




*
*  AMax( <aArray> ) --> nPos
*  Return the subscript of the array element with the highest value.
*

FUNCTION AMax( aArray )

LOCAL nLen, nPos, expLast, nElement

DO CASE

// Invalid argument
CASE VALTYPE( aArray ) <> "A"
   RETURN NIL

// Empty argument
CASE EMPTY( aArray )
   RETURN 0

OTHERWISE
   nLen := LEN( aArray )
   nPos := 1
   expLast := aArray[1]
   FOR nElement := 2 TO nLen
      IF aArray[nElement] > expLast
         nPos := nElement
         expLast := aArray[nElement]
      ENDIF
   NEXT

ENDCASE

RETURN nPos



*
*  AMin( <aArray> ) --> nPos
*  Return the subscript of the array element with the lowest value.
*

FUNCTION AMin( aArray )
LOCAL nLen, nPos, expLast, nElement


DO CASE

// Invalid argument
CASE VALTYPE( aArray ) <> "A"
   RETURN NIL

// Empty argument
CASE EMPTY( aArray )
   RETURN 0

OTHERWISE
   nLen := LEN( aArray )
   nPos := 1
   expLast := aArray[1]
   FOR nElement := 2 TO nLen
      IF aArray[nElement] < expLast
         nPos := nElement
         expLast := aArray[nElement]
      ENDIF
   NEXT

ENDCASE

RETURN nPos



*
*  AComp( <aArray>, <bComp>, [<nStart>], [<nStop>] ) --> valueElement
*  Compares all elements of aArray using the bComp block from nStart to
*  nStop (if specified, otherwise entire array) and returns the result.
*  Several sample blocks are provided in Array.ch.
*

FUNCTION AComp( aArray, bComp, nStart, nStop )

LOCAL value := aArray[1]

AEVAL(                                                               ;
       aArray,                                                       ;
       {|x| value := IF( EVAL(bComp, x, value), x, value )},         ;
       nStart,                                                       ;
       nStop                                                         ;
     )

RETURN( value )


/***
*  Dimensions( <aArray> ) --> aDims
*  Return an array of numeric values describing the dimensions of a
*  nested or multi-dimensional array, assuming the array has uniform
*  dimensions.
*/
FUNCTION Dimensions( aArray )
   LOCAL aDims := {}

   DO WHILE ( VALTYPE(aArray) == "A" )
      AADD( aDims, LEN(aArray) )
      aArray := aArray[1]
   ENDDO

   RETURN (aDims)



*
*  MABrowse( <aArray>, <nTop>, <nLeft>, <nBottom>, <nRight> ) --> value
*
*  Browse a 2-dimensional array using TBrowse object and
*  return the value of the highlighted array element.
*
*  moguc je visestruki select  !!!
*


FUNCTION MABrowse( aArray, nT, nL, nB, nR )

// This static maintains the "current row" for ABrowse()
LOCAL n, nOldNRow, nOldCursor  // Various
LOCAL o                              // TBrowse object
LOCAL nKey := 0                      // Keystroke holder
LOCAL cScrAbr
LOCAL nTekuciRed:=1
LOCAL nStep:=nB-nT-1
LOCAL nI

// Preserve cursor setting, turn off cursor
nOldCursor := SetCursor( 0 )



// Preserve static var (just in case), set it to 1
nOldNRow := nRow
nRow := 1


// Handle omitted parameters
nT := IF( nT == NIL, 0, nT )
nL := IF( nL == NIL, 0, nL )
nB := IF( nB == NIL, MAXROW(), nB )
nR := IF( nR == NIL, MAXCOL(), nR )


// Create the TBrowse object
o := TBrowseNew( nT+1, nL+1, nB-1, nR-1 )

// The "skip" block just adds to (or subtracts from) nRow
// (see ASkipTest() below)
o:SkipBlock := { |nSkip|                                             ;
                          nSkip := ASkipTest(aArray, nRow, nSkip),   ;
                          nRow += nSkip,                             ;
                          nSkip                                      ;
               }

// The "go top" block sets nRow to 1
o:GoTopBlock := { || nRow := 1 }

// The "go bottom" block sets nRow to the length of the array
o:GoBottomBlock := { || nRow := LEN(aArray) }

// Create column blocks and add TBColumn objects to the TBrowse
// (see ABrowseBlock() below)
FOR n = 1 TO LEN( aArray[1] )
       o:AddColumn( TBColumnNew("", ABrowseBlock(aArray, n)) )
NEXT


// Start the event handler loop
DO WHILE nKey <> K_ESC .AND. nKey <> K_RETURN

   // Stabilize
   nKey := 0
   DO WHILE .NOT. o:Stabilize()
      nKey := INKEY()
      IF nKey <> 0
         EXIT
      ENDIF
   ENDDO

   IF nKey == 0
      DO WHILE NEXTKEY()==0; OL_YIELD(); ENDDO
      nKey := INKEY()
      // nKey := INKEY(0)
   ENDIF

   // Process the directional keys
   IF o:Stable

      DO CASE
      CASE ( nKey == ASC(' ') )
         Tone(300,1)
         aArray[nTekuciRed,2]:=if(aArray[nTekuciRed,2]=='*',' ','*')
         o:RefreshCurrent()

      CASE ( nKey == K_DOWN )
         o:Down()
         nTekuciRed++

      CASE ( nKey == K_UP )
         o:Up()
         nTekuciRed--

      CASE ( nKey == K_RIGHT )
         o:Right()

      CASE ( nKey == K_LEFT )
         o:Left()



      ENDCASE

      if nTEkuciRed>Len(aArray)
        nTekuciRed:=Len(aArray)
      endif
      if nTekuciRed<1
        nTekuciRed:=1
      endif


   ENDIF

ENDDO

// Restore cursor setting
SetCursor( nOldCursor )

// Restore static var
nRow := nOldNRow

RETURN (nTekuciRed)



/*
*   StackNew() --> aStack
*   Create a new stack
*/
FUNCTION StackNew()
   RETURN {}

/**
*   StackPush( <aStack>, <exp> ) --> aStack
*   Push a new value onto the stack
*/
FUNCTION StackPush( aStack, exp )
   // Add new element to the stack array and then return the array
   RETURN AADD( aStack, exp )


/**
*   StackPop( <aStack> ) --> value
*   Pop a value from the stack
*
*   Return NIL if nothing is on the stack.
*/
FUNCTION StackPop( aStack )
   LOCAL valueLast, nLen := LEN( aStack )

   // Check for underflow condition
   IF nLen == 0
      RETURN NIL
   ENDIF

   // Get the last element value
   valueLast := aStack[ nLen ]

   // Remove the last element by shrinking the stack
   ASIZE( aStack, nLen - 1 )

   // Return the last element's value
   RETURN valueLast


/*
*  StackIsEmpty( <aStack> ) --> lEmpty
*  Determine if a stack has no members
*
*/
FUNCTION StackIsEmpty( aStack )
   RETURN EMPTY( aStack )


/*
*  StackGetTop( <aStack> ) --> value
*  Retrieve top stack member without removing
*
*/
FUNCTION StackGetTop( aStack )
   //
   // Return the value of the last element in the stack array
   RETURN ATAIL( aStack )


FUNCTION StackTop( aStack )
*
*  StackTop( <aStack> ) --> value
*  Retrieve top stack member without removing
*
*

//
// Return the value of the last element in the stack array
RETURN ATAIL( aStack )


/****f STACK/PushWA ***

*AUTHOR
  Ernad Husremovic ernad@sigma-com.net

*NAME
 PushWA
 
*SYNOPSIS
   PushWA()

*EXPLANATION
   Na stack prebacije trenutne podatke o radnom podrucju:
   broj radnog podrucja, broj indexa, filter, broj sloga
*INPUTS

*EXAMPLE
   select ROBA
   PushWA()
     select TARIFA
     ... operacije na tabeli TARIFA
   PopWA() // vracamo se na ROBA, na trenutni zapis

****/


