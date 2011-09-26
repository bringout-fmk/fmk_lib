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
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/sclib/os/1g/file_io.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.3 $
 * $Log: file_io.prg,v $
 * Revision 1.3  2002/08/19 10:01:47  ernad
 *
 *
 * podesenja za CLIP
 *
 * Revision 1.2  2002/06/21 02:28:36  ernad
 * interni sql parser - init, testiranje pos-sql
 *
 *
 */
 
/***
*  FilePos( <nHandle> ) --> nPos
*  Report the current position of the file pointer in a binary file
*
*/
function FilePos(nHandle)
local xRet

xRet:=FSEEK(nHandle, 0, FS_RELATIVE)
return xRet

/***
*  FileSize( <nHandle> ) --> nBytes
*  Return the size of a binary file
*
*/
function FileSize(nHandle)
*{
local nCurrent, nLength

// Get file position
nCurrent := FilePos(nHandle)

// Get file length
nLength := FSEEK(nHandle, 0, FS_END)

// Reset file position
FSEEK(nHandle, nCurrent)

return nLength
*}

#ifdef CLIP
function ScFEof(nHandle)
#else
function FEof(nHandle)
#endif
*{
local lRet

if (FileSize(nHandle)==FilePos(nHandle))
	lRet:=.t.
else
	lRet:=.f.
endif

return lRet
*}


/***
*  FReadLn( <nHandle>, [<nLines>], [<nLineLength>], [<cDelim>] ) --> cLines
*  Read one or more lines from a text file
*
*  NOTE: Line length includes delimiter, so max line read is 
*        (nLineLength - LEN( cDelim ))
*
*  NOTE: Return value includes delimiters, if delimiter was read
*
*  NOTE: nLines defaults to 1, nLineLength to 80 and cDelim to CRLF
*
*  NOTE: FERROR() must be checked to see if FReadLn() was successful
*
*  NOTE: FReadLn() returns "" when EOF is reached
*
*/
function FReadLn(nHandle, nLines, nLineLength, cDelim)
return SC_FReadLn(nHandle, nLines, nLineLength, cDelim)


function SC_FReadLn(nHandle, nLines, nLineLength, cDelim)
*{
LOCAL nCurPos, nFileSize, nChrsToRead, nChrsRead
LOCAL cBuffer, cLines
LOCAL nCount
LOCAL nEOLPos

IF nLines ==nil
      nLines := 1
ENDIF

IF nLineLength==nil
      nLineLength:=80
ENDIF

IF cDelim==nil
      cDelim := NRED
ENDIF

nCurPos   := FilePos( nHandle )
nFileSize := FileSize( nHandle )

// Make sure no attempt is made to read past EOF
nChrsToRead := MIN( nLineLength, nFileSize - nCurPos )

cLines  := ''
nCount  := 1
DO WHILE (nCount <= nLines) .AND. (nChrsToRead != 0) 
cBuffer   := SPACE( nChrsToRead )
nChrsRead := FREAD( nHandle, @cBuffer, nChrsToRead )

// Check for error condition
IF ! (nChrsRead == nChrsToRead)
         // Error!
         // In order to stay conceptually compatible with the other
         // low-level file functions, force the user to check FERROR()
         // (which was set by the FREAD() above) to discover this fact
         //
         nChrsToRead := 0
ENDIF

nEOLPos := AT( cDelim, cBuffer )

// Update buffer and current file position
IF nEOLPos == 0
         cLines  += LEFT( cBuffer, nChrsRead )
         nCurPos += nChrsRead
ELSE
         cLines  += LEFT( cBuffer, ( nEOLPos + LEN( cDelim ) ) - 1 )
         nCurPos += ( nEOLPos + LEN( cDelim ) ) - 1
         FSEEK( nHandle, nCurPos, FS_SET )
ENDIF

// Make sure we don't try to read past EOF
IF (nFileSize - nCurPos) < nLineLength
         nChrsToRead := (nFileSize - nCurPos)
ENDIF

nCount++
ENDDO

RETURN cLines
*}


