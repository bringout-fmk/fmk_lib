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

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */


/*! \fn GetComPort()
 *  \brief Vraca oznaku COM port-a: 1, 2, 3...
 */
function GetComPort()
*{
cComPort:=IzFmkIni("Ports","ComPort","1",KUMPATH)
if Empty(cComPort)
	// ako nema parametra u INI fajlu uzmi "1"
	cComPort:="1"
endif
return VAL(cComPort)
*}


/*! \fn GetComBaudRate()
 *  \brief Baud rate
 */
function GetComBaudRate()
*{
cBaudRate:=IzFmkIni("Ports","BaudRate","9600",KUMPATH)
if Empty(cBaudRate)
	cBaudRate:="9600"
endif
return VAL(cBaudRate)
*}


/*! \fn TestComPort(nPort, nBuffSize, lClose)
 *  \brief Testiranje COM porta
 *  \param nPort - oznaka COM port-a
 *  \param nBuffSize - velicina buffer-a (def. 4000)
 *  \param lClose - (.t.) zatvori nakon test-a
 *  \result 1 - OK, 0 - not OK
 */
function TestComPort(nPort, nBuffSize, lClose)
*{
local lComOK

if lClose==NIL
	lClose:=.f.
endif
lComOK:=COM_OPEN(nPort, nBuffSize)
if lComOK
	if lClose
		COM_CLOSE(nPort)
	endif
	return 1
else
	return 0
endif
return
*}


/*! \fn InitComPort(nPort)
 *  \brief Inicijalizacija com port-a
 *  \param nPort - oznaka port-a
 *  \result 1 - OK, 0 - not OK
 */
function InitComPort(nPort)
*{
local lInitOK

nBaudR:=GetComBaudRate()
lInitOK:=COM_INIT(nPort, nBaudR, "N", 8, 1)
if lInitOK
	return 1
else
	return 0
endif
return
*}


/*! \fn Send2ComPort(cOutPut)
 *  \brief Salje cOutput na COM port
 *  \param cOutPut - string koji se salje na com port
 */
function Send2ComPort(cOutPut)
*{
local nPort
local nRest

nPort:=GetComPort()

if TestComPort(nPort, 4000)==1
	if InitComPort(nPort)==1
		nRest:=COM_SEND(nPort, cOutPut)
		// 0 - COM_SEND() completed
		// provjeri da nije jos sta ostalo
		do while nRest > 0
			nRest:=COM_SEND(nPort, cOutPut)
		enddo
		COM_CLOSE(nPort)
	else
		MsgBeep("Ne mogu odraditi COM_INIT()")
		COM_CLOSE(nPort)
	endif
else
	MsgBeep("Ne mogu otvoriti COM port !!!")
endif



return
*}

/*! \CnvrtStr2Hex(cStr, lSpace)
 *  \brief Konvertuje string u hex u formatu: str="2500" reslt: 32 35 30 30
 *  \param cStr - string koji zelimo konvertovati
 *  \param lSpace - pravi razmak izmedju karaktera
 */
function CnvrtStr2Hex(cStr, lSpace)
*{
if lSpace==NIL
	lSpace:=.t.
endif

cSpace:=""
cRet:=""

if LEN(cStr)==0
	return cRet
endif

if lSpace==.t.
	cSpace:=SPACE(1)
endif

for i:=1 to LEN(cStr)
	cRet+=STRTOHEX(SUBSTR(cStr,i,1)) + cSpace
next

return cRet
*}



