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


#include "sc.ch"
#include "fileio.ch"

/*
 * ----------------------------------------------------------------
 *                          Copyright Sigma-com software 1994-2006 
 * ----------------------------------------------------------------
 */
 

// File cache buffer
*string
static cCache
*;

// Name of the .INI file that is in the cache buffer
*string 
static cIniFile
*;

//#include "COMMON.CH"

static INI_DATA := {}
static INI_NAME := ''
static INI_SECTION := 'xx'


function R_IniRead ( cSection, cEntry, cDefault, cFName, lAppend )
*{
local	nHandle
local	cString
local	nPos
local	nEnd
local	aEntries := {}
local   lPom0, lPom

if lAppend==NIL
	lAppend:=.f.
endif


// Extension omitted : Add default extension
if ( At ( '.', cFName ) == 0 )
   cFName -= '.INI'
endif

if ( cIniFile == NIL )
   // First time ... (buffer not in cache)
   cIniFile := ''
endif

// Check the filename
if ( cIniFile != cFName )
   // Other .INI file name : file not in cache !
   
   if ( nHandle := FOpen ( cFName, FO_READ + FO_SHARED ) ) < 5
      // Error opening .INI file
      return nil
   endif
   
   // INI file opened ...
   
   // Read complete file into cCache
   ReadFile(nHandle)
   
   // File not needed anymore ...
   FClose(nHandle)
   
   // File in cache ...
   cIniFile := cFName
   
endif

lPom0:= SeekSection(cSection, @nPos)
if lPom0   
   
   // Section FOUND, nPos points to the start of the section
   if cEntry = NIL
      // return ALL ENTRIES IN SECTION !
      
      // nPos points to start of section
      
      // Skip [section] + NRED
      nPos = nPos + 4 + Len ( cSection )
      
      // nPos points to start of first entry
      DO WHILE nPos <= Len ( cCache ) .and. SubStr ( cCache, nPos, 1 ) != '['
         
         nEnd    := I_At ( '=', .f., nPos )
         cEntry  := SubStr ( cCache, nPos, nEnd - nPos )
         nPos    := nEnd + 1
         nEnd    := I_At ( NRED, .f., nPos )
         cString := SubStr ( cCache, nPos, nEnd - nPos )
         AAdd ( aEntries, { cEntry, cString } )
         nPos    := nEnd + 2
         
         DO WHILE SubStr(cCache, nPos, 2) = NRED
            // Skip NRED's, if any
            nPos += 2
         ENDDO
         
      ENDDO
      
      return aEntries
      
   else
      // Locate specified entry
      nPos := I_At(Upper(cEntry)+'=', .t., nPos )
      
      if ( nPos > 0 )
         // Entry found, nPos points to start of entry
         
         // Skip 'entry=' part
         nPos += Len ( cEntry )
         
         // Return value
         return SubStr ( cCache, nPos+1, ;
            I_At ( NRED, .f., nPos+1 ) - nPos - 1 )
         
      endif
      
   endif
   
else
   // Section not found
   if ( VALTYPE(cEntry) != "C" ) 
      // Request to return all entries in section ...
      return NIL
   endif
endif


if (lAppend)
   // CREATE A NEW cDEFAULT ENTRY, if THE SPECIFIED ENTRY NOT EXISTS
   R_IniWrite ( cSection, cEntry, cDefault, cIniFile )
endif


// Return default value

IniRefresh()
return cDefault
*}


/*! \fn R_IniWrite ( cSection, cEntry, cString, cFName )
 *
 * \param cSection - String that specifies the section to which the string will  be copied. If the section does not exist, it is created. cSection is case-independent
 * \param cEntry - String containing the entry to be associated with the string. If the entry does not exist in the specified section, it is created. If the parameter is NIL, the entire section, including all entries within the section, is deleted.
 * \param cString - String to be written to the file. If this parameter is NIL, the entry specified by the cEntry parameter is deleted.
 * \param cFName  - String that names the initialization file
 *
 * \sa R_IniWrite
 *
 */

function R_IniWrite( cSection, cEntry, cString, cFName )
*{
local	nHandle
local	nBytes
local	nPos
local	nEntry

if (cFName==NIL) .or. Valtype ( cFName ) != 'C'
   // Required parameter !
   return .f.
endif

if (cSection==NIL) .or. Valtype ( cSection ) != 'C'
   // Required paramter !
   return .f.
endif

// Append default extension (if no extension present)
if At ( '.', cFName ) = 0
   cFName -= '.INI'
endif

if cIniFile = NIL
   // First time ...
   cIniFile := ''
endif

// Check the filename
if (cIniFile != cFName)
   // If file name is the SAME : file is still in Cache buffer (cCache) ...
   
   // Other .INI file or the first time
   if (nHandle:=FOPEN(cFName, FO_READWRITE + FO_SHARED)) < 5
      // Error opening .INI file
      
      if (nHandle:=FCreate(cFName, FC_NORMAL)) < 5
         // Error creating .INI file
	IniRefresh()
         return .f.
         
      else
         // .INI file created : Write Section and Entry
         PutSection( nHandle, cSection )
         
         PutEntry ( nHandle, cEntry, cString )
         
         // ReRead file to adjust cCache cache
         
	 ReadFile(nHandle)
         FClose(nHandle)
         
         // Buffer in cache ...
         cIniFile := cFName
         
	IniRefresh()
         return .t.
         
      endif
      
   endif
   
   // Read complete file into cCache
   //Logg("Ini fajl name:" + cFName)
   ReadFile(nHandle)
   
   // Buffer in cache ...
   cIniFile := cFName
   
endif

nPos:=0

lPom:=SeekSection( cSection, @nPos)
if !lPom
   // Section NOT present : append SECTION AND ENTRY !
   if (nHandle==NIL)
      // File not presently open
      nHandle := FOpen ( cFName, FO_READWRITE + FO_SHARED )
   endif
   
   // Pointer to end-of-file
   FSeek(nHandle, 0, FS_END)
   
   // APPEND NEW SECTION (separated with an empty line)
   FWrite (nHandle, NRED, 2)
   PutSection (nHandle, cSection)
   
   PutEntry(nHandle, cEntry, cString)
   
   // ReRead file to adjust cCache ....
   ReadFile(nHandle)
   
else
   // SECTION ALREADY PRESENT
   // nPos points to the start of the section
   
   if cEntry==NIL
      
      // DELETE COMPLETE SECTION !
      // nPos points to start of section
      if ( nEntry := I_At ( '[', .f., nPos + 1 ) ) = 0
         // No next section : delete to end-of-file
         nEntry := Len ( cCache ) + 1
      endif
      
      // Delete bytes from string
      cCache:=Stuff(cCache, nPos, nEntry - nPos, '')
      ReWrite(nHandle,cFName)
	IniRefresh()
      return .t.
      
   endif
   
   // Skip section + NRED
   nPos = nPos + 4 + Len ( cSection )
   
   if ( nEntry := I_At ( Upper ( cEntry ) + '=', .t., nPos ) ) = 0
      
      // ENTRY NOT FOUND : APPEND ENTRY
      if cString != NIL
         // Locate start of next SECTION
         if nHandle = NIL
            nHandle := FOpen ( cFName, FO_READWRITE + FO_SHARED )
         endif
         
         if ( nEntry := I_At ( '[', .f., nPos ) ) = 0
            
            // Last section : append to end of file
            FSEEK ( nHandle, 0, FS_END )
            
            PutEntry ( nHandle, cEntry, cString )
            
            // ReRead file to adjust cCache
            ReadFile( nHandle )
            
         else
            //-- Next section present at : nEntry - 2
            
            //-- INSERT ENTRY AT END OF SECTION
            DO WHILE SubStr ( cCache, nEntry-2, 2 ) = NRED
               //-- Skip NRED's, if any ...
               nEntry -= 2
            ENDDO
            
            //-- Keep 1 NRED string ...
            nEntry += 2
            
            cCache:=Stuff(cCache, nEntry, 0, cEntry + '=' + cString + NRED)
            
            ReWrite(nHandle, cFName)
            
		IniRefresh()
            return .t.
            
         endif
         
      endif
      
   else
      //-- ENTRY FOUND : REPLACE VALUE
      
      if (cString == NIL)
         //-- DELETE ENTRY !
         
         // nEntry points to first pos of entry name
         nPos := I_At(NRED, .f., nEntry ) + 2
         
         // Delete bytes from string
         cCache := Stuff ( cCache, nEntry, nPos - nEntry, '' )
      else
         // REPLACE VALUE
         
         // nEntry points to first pos of entry name
         
         nEntry  := nEntry + Len ( cEntry ) + 1
         cCache := Stuff ( cCache, nEntry, ;
            At ( NRED, SubStr ( cCache, nEntry ) ) - 1, cString )
         
      endif
      
      ReWrite ( nHandle, cFName )
	IniRefresh()
      
      return .t.
      
   endif
   
endif
FClose ( nHandle )

IniRefresh()
return .t.
*}


/*! \fn I_At(cSearch, cString, nStart)
 *  \param nStart - pocni pretragu od nStart pozicije
 */
static function I_At(cSearch, lUpper, nStart)
*{
local nPos
if lUpper
	nPos := At( cSearch, SubStr(UPPER(cCache), nStart) )
else
	nPos := At( cSearch, SubStr(cCache, nStart) )
endif
return if ( nPos > 0, nPos + nStart - 1, 0 )
*}


/*! \fn IzFmkIni(cSection, cVar, cValue, cLokacija )
 *
 *  \param cSection  - [SECTION]
 *  \param cVar      - Variable
 *  \param cValue    - Default value of Variable
 *  \param cLokacija - Default = EXEPATH, or PRIVPATH, or SIFPATH or KUMPATH (FileName='FMK.INI')
 *  \param lAppend   - True - ako zapisa u ini-ju nema dodaj ga, default false
 * \code
 * // uzmi vrijednost varijable Debug, sekcija Gateway, iz EXEPATH/FMK.INI
 * cDN:=IzFmkIni("Gateway","Debug","N",EXEPATH)
 * \endcode
 * 
 * \sa R_IniWrite
 *
 */

function IzFmkIni(cSection, cVar, cValue, cLokacija, lAppend)
*{
local cRez:=""
local cNazIni:='FMK.INI'

if (cLokacija=nil)
	cLokacija:=EXEPATH
endif
if (lAppend==nil)
	lAppend:=.f.
endif

if !file(cLokacija+cNazIni)
  nFH:=FCreate(cLokacija+cNazIni)
  FWrite(nFh,";------- Ini Fajl FMK-------")
  Fclose(nFH)
endif
cRez:=R_IniRead( cSection, cVar,  "", cLokacija + cNazIni)

if (lAppend .and. EMPTY(cRez))
	// nije toga bilo u fmk.ini
  	R_IniWrite(cSection, cVar, cValue, cLokacija + cNazIni)
	IniRefresh()
  	return cValue
elseif (EMPTY(cRez))
	IniRefresh()
	return cValue
else
	IniRefresh()
	return cRez
endif

return
*}


function TEMPINI(cSection, cVar, cValue, cread)
*{
*
* cValue  - tekuca vrijednost
* cREAD = "WRITE" , "READ"

local cRez:=""
local cNazIni:=EXEPATH+'TEMP.INI'

if cread==NIL
 read:="READ"
endif


if !file(EXEPATH+'TEMP.INI')
  nFH:=FCreate(EXEPATH+'TEMP.INI')
  FWrite(nFh,";------- Ini Fajl TMP-------")
  Fclose(nFH)
endif
cRez:=R_IniRead ( cSection, cVar,  "", cNazIni)

if empty(cRez) .or. cRead=="WRITE"  // nije toga bilo u fmk.ini
  R_IniWrite(cSection,cVar,cValue, cNazIni)
  return cValue
else
  return cRez
endif

return
*}


function IniRefresh()
*{

//cCache:=NIL
//cIniFile:=NIL
cCache:=""
cIniFile:=""
// trazi novo citanje ini fajla !

return
*}


function UzmiIzINI(cNazIni,cSection, cVar, cValue, cread)
*{
*
* cValue  - tekuca vrijednost
* cREAD = "WRITE" , "READ"

local cRez:=""

if cread==NIL
 read:="READ"
endif

if !file(cNazIni)
  nFH:=FCreate(cNazIni)
  FWrite(nFh,";------- Ini Fajl "+cNazIni+"-------")
  Fclose(nFH)
endif
cRez:=R_IniRead ( cSection, cVar,  "", cNazIni)

if empty(cRez) .or. cRead=="WRITE"
  if valtype(cValue) = "N"
    R_IniWrite(cSection,cVar,str(cValue,22,2), cNazIni)
  else
    R_IniWrite(cSection,cVar,cValue, cNazIni)
  endif
  return cValue
else
  return cRez
endif
return
*}


static function SeekSection( sect, pos )
// Look for the specified section in buffer
*{
pos:= At ('['+Upper (sect)+']', Upper (cCache) )  

return pos>0
*}


static function ReadFile( hnd)
*{

//if VALTYPE(gCnt1)<>"N"
//	gCnt1:=0
//endif
//gCnt1++
//cCache:="[xx]"
//return

// Read complete file into cache buffer
cCache:=Space( FSeek ( hnd, 0, FS_END ) )
FSeek ( hnd, 0, FS_SET )
FRead ( hnd, @cCache, Len(cCache) ) 
return
*}

static function PutSection(hnd, sect)
*{
if !EMPTY( sect )
  return FWrite ( hnd, '[' + sect + ']' + NRED )
else
  return nil
endif
return
*}


static function PutEntry( hnd,entry,val )
*{
if !Empty ( entry ) .and. !Empty ( val )
 return FWrite ( hnd, entry + '=' + val + NRED )
else
 return nil
endif
*}

// Rewrite complete file from buffer
static function ReWrite(hnd,fnm)
*{
if ( hnd!=NIL )
   FClose(hnd)
endif
hnd := FCreate ( fnm, FC_NORMAL )
FWrite ( hnd, cCache )
FClose ( hnd ) 
return
*}

/*****************************************************************************/


/*
function ProfileString( cFile, cSection, cKey, cDefault )

//
//  This function reads a string from the specified .INI file.
//
//  Parameters: cFile    - The .INI file name to be used
//              cSection - The section from which to read
//              cKey     - The key value for which to search
//              cDefault - The default value if not found (optional)
//
//     Returns: cString - The string read from the file.
//

local nSPointer := 0
local nKPointer := 0
local cString

if cDefault==NIL
	cDefault:= ''
endif
cString := cDefault


begin sequence

   if !(INI_NAME == cFile) .or. !(INI_SECTION == cSection) 
      //if !init_profile( cFile )
      //procitaj samo jednu sekciju
      if !init_profile( cFile, cSection )
         break
      endif
   endif

   cSection := upper( alltrim( cSection ) )
   cKey     := upper( alltrim( cKey ) )

   if left( cSection, 1 ) <> '['
      cSection := '[' + cSection
   endif

   if right( cSection, 1 ) <> ']'
      cSection += ']'
   endif

   nSPointer := ascan( INI_DATA, { | x | x[ 1 ] == cSection } )

   if !empty( nSPointer )
      nKPointer := ascan( INI_DATA[ nSPointer, 2 ], { | x | x[ 1 ] == cKey } )
      if !empty( nKPointer )
         cString := INI_DATA[ nSPointer, 2, nKPointer, 2 ]
      endif
   endif

end sequence

return cString
*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
*+    Static Function init_profile()
*+
*+    Called from ( profile.prg  )   1 - function profilestring()
*+                                   1 - function profilenum()
*+                                   1 - function profiledate()
*+
*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
static function init_profile( cFile , cSection )

local oBufObj       := bInit( cFile )
local retval        := bopen( oBufObj )
local cThisLine
local lFoundSection := .f.
local nLastElement  := 0
local eqat

INI_DATA := {}
INI_NAME := ''


if (cSection == NIL)
	cSection:=""
endif
INI_SECTION := cSection

if retval
   INI_NAME := cFile
   do while !bEof( oBufObj )

      cThisLine := alltrim( bReadLine( oBufObj ) )

      if empty( cThisLine ) .or. left( cThisLine, 2 ) == '//'
         loop
      endif

      if !lFoundSection
         if left( cThisLine, 1 ) == '[' .and. right( cThisLine, 1 ) == ']'
            if cSection==""
	    	//bilo koja sekcija
	    	lFoundSection := .t.
	    else
	    	if '[' + UPPER(cSection) + ']' == UPPER(ALLTRIM(cThisLine)) 
			lFoundSection := .t.
		else
			//ogranicavamo se samo na zeljenu sekciju
			loop
		endif
	    endif
         
	 else
            loop
         endif
      else
      	 //vec sam nasao sekciju i !(cSection=="")	
         if !(cSection=="") .and. (left( cThisLine, 1 ) == '[' .and. right( cThisLine, 1 ) == ']')
	 	//ovo je nova sekcija, a mi zelimo samo jednu sekciju procitati
		return retval
	 endif
	 
      endif

      if left( cThisLine, 1 ) == '[' .and. right( cThisLine, 1 ) == ']'
         //dodajem sekciju
	 aadd( INI_DATA, { upper( cThisLine ), {} } )
         nLastElement ++
      else
         eqat := at( '=', cThisLine )
         if eqat > 0
            aadd( INI_DATA[ nLastElement, 2 ], ;
                  { upper( alltrim( left( cThisLine, eqat - 1 ) ) ), ;
                  substr( cThisLine, eqat + 1 ) } )
         endif
      endif
   enddo
   bClose( oBufObj )
endif

return retval




#include "COMMON.CH"

#define cFileName oBuffObj[ 1 ]
#define nAccMode oBuffObj[ 2 ]
#define cLineBuffer oBuffObj[ 3 ]
#define nHandle oBuffObj[ 4 ]
#define nBytesRead oBuffObj[ 5 ]
#define lFullBuff oBuffObj[ 6 ]
#define nTotBytes oBuffObj[ 7 ]
#define lIsOpen oBuffObj[ 8 ]
#define nFileBytes oBuffObj[ 9 ]
#define nFileLines oBuffObj[ 10 ]
#define cDelimiter oBuffObj[ 11 ]
*/

/*
function test( filename )

local oBuffObj1 := binit( filename )

if bopen( oBuffObj1 )
   do while !beof( oBuffObj1 )
      ? breadline( oBuffObj1 )
   enddo
   bclose( oBuffObj1 )
else
   ? 'Cannot open ' + filename
endif

return NIL
*/


/*
#define BUFFLEN 2560

*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
*+    Function BInit()
*+
*+    Called from ( click.prg    )   4 - procedure click()
*+                                   1 - static procedure thealigner()
*+                ( declbust.prg )   1 - procedure declbust()
*+                ( functrak.prg )   1 - procedure func_text()
*+                ( profile.prg  )   1 - static function init_profile()
*+                ( readlnk.prg  )   2 - function readlnk()
*+
*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
function BInit( xFileName, xAccMode )

// Function BInit( <cFileName>, [nAccessMode] )
// Return:  oBuffObj for this file access

return { xFileName, xAccMode, '', - 1, 0, .t., 0, .t., 0, 0, chr( 13 ) + chr( 10 ) }

*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
*+    Function Bopen()
*+
*+    Called from ( click.prg    )   2 - procedure click()
*+                                   1 - static procedure thealigner()
*+                ( declbust.prg )   1 - procedure declbust()
*+                ( functrak.prg )   1 - procedure func_text()
*+                ( profile.prg  )   1 - static function init_profile()
*+                ( readlnk.prg  )   2 - function readlnk()
*+
*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
function Bopen( oBuffObj )

// Return:   .t. if file was opened
// Assumes:  All file access will be done with the B* functions

default nAccMode to FO_READ             // default access mode is Read Only

nHandle := fopen( cFileName, nAccMode )

nFileBytes := fseek( nHandle, 0, FS_END )

fseek( nHandle, 0, FS_SET )

BDisk2Buff( oBuffObj )

do case
case chr( 13 ) + chr( 10 ) $ cLineBuffer
   cDelimiter := chr( 13 ) + chr( 10 )
case chr( 13 ) $ cLineBuffer
   cDelimiter := chr( 13 )
case chr( 10 ) $ cLineBuffer
   cDelimiter := chr( 10 )
endcase

return ( nHandle != - 1 )

*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
*+    Function BReadLine()
*+
*+    Called from ( click.prg    )   2 - procedure click()
*+                                   1 - static function breadpart()
*+                                   3 - static procedure thealigner()
*+                ( declbust.prg )   4 - procedure declbust()
*+                ( functrak.prg )   1 - procedure func_text()
*+                ( profile.prg  )   1 - static function init_profile()
*+                ( readlnk.prg  )   2 - function readlnk()
*+
*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
function BReadLine( oBuffObj )

// Return:   The next line of the file read buffer
// Assumes:  The file pointer will be moved forward

local ThisLine
local nCrLfAt

do while .t.

   nCrLfAt := at( cDelimiter, cLineBuffer )

   if empty( nCrLfAt ) .and. lFullBuff
      BDisk2Buff( oBuffObj )
      loop
   endif

   if empty( nCrLfAt )
      ThisLine    := strtran( cLineBuffer, chr( 26 ) )
      cLineBuffer := ''
   else
      ThisLine    := left( cLineBuffer, nCrLfAt - 1 )
      cLineBuffer := substr( cLineBuffer, nCrLfAt + len( cDelimiter ) )
   endif

   exit

enddo

nFileLines ++

return ThisLine

*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
*+    Function BNextLine()
*+
*+    Called from ( click.prg    )   4 - static procedure thealigner()
*+
*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
function BNextLine( oBuffObj )

// Return:   The next line of the file read buffer
// Assumes:  The file pointer will be left as last positioned

local NextLine
local nCrLfAt

default cDelimiter to chr( 13 ) + chr( 10 )

do while .t.

   nCrLfAt := at( cDelimiter, cLineBuffer )

   if empty( nCrLfAt ) .and. lFullBuff
      BDisk2Buff( oBuffObj )
      loop
   endif

   if empty( nCrLfAt )
      NextLine := strtran( cLineBuffer, chr( 26 ) )
   else
      NextLine := left( cLineBuffer, nCrLfAt - 1 )
   endif

   exit

enddo

return NextLine

*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
*+    Static Function BDisk2Buff()
*+
*+    Called from ( obufread.prg )   1 - function bopen()
*+                                   1 - function breadline()
*+                                   1 - function bnextline()
*+
*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
static function BDisk2Buff( oBuffObj )

// Return:   .t. if there was no read error

static cDiskBuffer := ''

if len( cDiskBuffer ) != BUFFLEN
   cDiskBuffer := space( BUFFLEN )
endif

nBytesRead := fread( nHandle, @cDiskBuffer, BUFFLEN )

nTotBytes += nBytesRead

lFullBuff := ( nBytesRead == BUFFLEN )

if lFullBuff
   cLineBuffer += cDiskBuffer
else
   cLineBuffer += left( cDiskBuffer, nBytesRead )
endif

return ferror()

*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
*+    Function BEof()
*+
*+    Called from ( click.prg    )   3 - procedure click()
*+                                   2 - static function breadpart()
*+                                   2 - static procedure thealigner()
*+                ( declbust.prg )   2 - procedure declbust()
*+                ( functrak.prg )   1 - procedure func_text()
*+                ( profile.prg  )   1 - static function init_profile()
*+                ( readlnk.prg  )   2 - function readlnk()
*+
*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
function BEof( oBuffObj )

// Return:   TRUE  if End of buffered file
//           FALSE if not

return !lFullBuff .and. len( cLineBuffer ) == 0

*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
*+    Function BClose()
*+
*+    Called from ( click.prg    )   2 - procedure click()
*+                                   1 - static procedure thealigner()
*+                ( declbust.prg )   1 - procedure declbust()
*+                ( functrak.prg )   1 - procedure func_text()
*+                ( profile.prg  )   1 - static function init_profile()
*+                ( readlnk.prg  )   2 - function readlnk()
*+
*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
function BClose( oBuffObj )

if lIsOpen
   fclose( nHandle )
   lIsOpen := .f.
endif

oBuffObj := nil

return ferror()

*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
*+    Function BPosition()
*+
*+    Called from ( obufread.prg )   1 - function brelative()
*+
*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
function BPosition( oBuffObj )

// Returns the position of virtual file pointer

return nTotBytes - len( cLineBuffer )

*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
*+    Function BRelative()
*+
*+    Called from ( click.prg    )   1 - procedure click()
*+                                   1 - static function breadpart()
*+                                   1 - static procedure thealigner()
*+                ( declbust.prg )   1 - procedure declbust()
*+                ( functrak.prg )   1 - procedure func_text()
*+
*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
function BRelative( oBuffObj )

// Returns the percentage of file processed

return BPosition( oBuffObj ) / nFileBytes

*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
*+    Function BLineNumber()
*+
*+    Called from ( click.prg    )   2 - procedure click()
*+                                   1 - static function breadpart()
*+                                   3 - static procedure thealigner()
*+                ( declbust.prg )   4 - procedure declbust()
*+
*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
function BLineNumber( oBuffObj )

// Returns the current line number

return nFileLines

*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
*+    Function BGetSet()
*+
*+    Called from ( click.prg    )   1 - procedure click()
*+
*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
function BGetSet( oBuffObj )

return aclone( oBuffObj )

*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
*+    Function BRestSet()
*+
*+    Called from ( click.prg    )   1 - procedure click()
*+
*+北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
*+
function BRestSet( oBuffObj )

fseek( nHandle, nTotBytes, FS_SET )

return oBuffObj
*/






/*! \fn IzFmkIni(cSection, cVar, cValue, cLokacija )
 *
 *  \param cSection  - [SECTION]
 *  \param cKey      - Variable
 *  \param cDefault  - Default value of Variable
 *  \param cLokacija - Default = EXEPATH, or PRIVPATH, or SIFPATH or KUMPATH (FileName='FMK.INI')
 *  \param lAppend   - True - ako zapisa u ini-ju nema dodaj ga, default True	       
 * \code
 * // uzmi vrijednost varijable Debug, sekcija Gateway, iz EXEPATH/FMK.INI
 * cDN:=IzFmkIni("Gateway","Debug","N",EXEPATH)
 * \endcode
 * 
 * \sa R_IniWrite
 *
 */
/*
function IzFmkIni(cSection, cKey, cDefault, cLokacija)
*{
local cRez:=""
local cNazIni:='FMK.INI'

if (cLokacija=nil)
	cLokacija:=EXEPATH
endif

if (lAppend==nil)
	lAppend:=.t.
endif

if !file(cLokacija+cNazIni)
  nFH:=FCreate(cLokacija+cNazIni)
  FWrite(nFh,";------- Ini Fajl FMK-------")
  Fclose(nFH)
endif

cRez:=R_IniRead( cSection, cVar,  "", cLokacija + cNazIni)

if (lAppend .and. EMPTY(cRez))
	// nije toga bilo u fmk.ini
  	R_IniWrite(cSection, cVar, cValue, cLokacija + cNazIni)
	IniRefresh()
  	return cValue
else
	IniRefresh()
	return cRez
endif

return ProfileString( cLokacija+cNazIni, cSection, cKey, cDefault )


*}
*/

