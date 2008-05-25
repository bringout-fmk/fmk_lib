#include "fmk.ch"
#include "fileio.ch"
 
/***
*  FilePos( <nHandle> ) --> nPos
*  Report the current position of the file pointer in a binary file
*
*/
function FilePos(nHandle)
local xRet

xRet:=FSEEK(nHandle, 0, FS_RELATIVE)
return xRet

function FEof(nHandle)
local lRet

if (FileSize(nHandle)==FilePos(nHandle))
	lRet:=.t.
else
	lRet:=.f.
endif

return lRet


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


