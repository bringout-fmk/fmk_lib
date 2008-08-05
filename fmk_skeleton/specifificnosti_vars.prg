#include "fmk.ch"



/*! \var lPlanika
 *  \ingroup Planika
 *  \sa IsPlanika
 */
*bool
static lPlanika
*;

/*! \var lSigmaCom
 *  \ingroup SigmaCom
 *  \sa IsSigmaCom
 */
*bool 
static lSigmaCom
*;


/*! \var lRobaGroup
 *  \ingroup RobaGroup
 *  \sa IsRobaGroup
 */
*bool 
static lRobaGroup
*;



/*! \var lVindija
 *  \ingroup Vindija
 *  \sa IsVindija
 */
*bool
static lVindija
*;


/*! \var lZips
 *  \ingroup Zips
 *  \sa IsZips
 */
*bool
static lZips
*;



/*! \var lUgovori
 *  \ingroup Ugovori
 *  \sa IsUgovori
 */
*bool
static lUgovori
*;


/*! \var lRamaGlas
 *  \ingroup Specificnosti za Rama glas
 *  \sa IsRamaGlas
 */
*bool
static lRamaGlas
*;


/*! \var lLdFin
 *  \ingroup Specificnosti za ld->fin
 *  \sa IsLdFin
 */
*bool
static lLdFin
*;

/*! \var lMupZeDo
 *  \ingroup Specificnosti za mup ze-do
 *  \sa IsMupZeDo
 */
*bool
static lMupZeDo
*;


/*! \var lDomZdr
 *  \ingroup Specificnosti za Dom zdravlja
 *  \sa IsDomZdr
 */
*bool
static lDomZdr
*;


/*! \var lRabati
 *  \ingroup Koristenje rabatnih skala
 *  \sa IsRabati
 */
*bool
static lRabati
*;



function IsRobaGroup()
*{
return lRobaGroup
*}

function SetRobaGroup(lValue)
*{
lRobaGroup:=lValue
*}


function IsVindija()
*{
return lVindija
*}

function SetVindija(lValue)
*{
lVindija:=lValue
*}

function IsZips()
*{
return lZips
*}

function SetZips(lValue)
*{
lZips:=lValue
*}

function IsUgovori()
*{
return lUgovori
*}

function SetUgovori(lValue)
*{
lUgovori:=lValue
*}

function IsRabati()
*{
return lRabati
*}

function SetRabati(lValue)
*{
lRabati:=lValue
*}


function IsRamaGlas()
*{
return lRamaGlas
*}

function IsLdFin()
*{
return lLdFin
*}

function SetRamaGlas(lValue)
*{
lRamaGlas:=lValue
*}


function SetLdFin(lValue)
*{
lLdFin:=lValue
*}



function IsMupZeDo()
*{
return lMupZeDo
*}

function SetMupZeDo(lValue)
*{
lMupZeDo:=lValue
*}



function IsDomZdr()
*{
return lDomZdr
*}

function SetDomZdr(lValue)
*{
lDomZdr:=lValue
*}



/*! \fn SetSpecifVars()
 *  \brief Setuje globalne varijable za specificne korisnike
 */
 
function SetSpecifVars()
*{

if IzFmkIni("FMK","Planika","N",KUMPATH)=="D"
	SetPlanika(.t.)
else
	SetPlanika(.f.)
endif

if IzFmkIni("FMK","DomZdr","N",KUMPATH)=="D"
	SetDomZdr(.t.)
else
	SetDomZdr(.f.)
endif

if IzFmkIni("FMK","RobaGroup","N",KUMPATH)=="D"
	SetRobaGroup(.t.)
else
	SetRobaGroup(.f.)
endif

if IzFmkIni("FMK","Vindija","N",KUMPATH)=="D"
	SetVindija(.t.)
else
	SetVindija(.f.)
endif

if IzFmkIni("FMK","Zips","N",KUMPATH)=="D"
	SetZips(.t.)
else
	SetZips(.f.)
endif

if IzFmkIni("FMK","Ugovori","N",KUMPATH)=="D"
	SetUgovori(.t.)
else
	SetUgovori(.f.)
endif

if IzFmkIni("FMK","RamaGlas","N",KUMPATH)=="D"
	SetRamaGlas(.t.)
else
	SetRamaGlas(.f.)
endif


if IzFmkIni("FMK","LdFin","N",KUMPATH)=="D"
	SetLdFin(.t.)
else
	SetLdFin(.f.)
endif

if IzFmkIni("FMK","MUPZEDO","N",KUMPATH)=="D"
	SetMupZeDo(.t.)
else
	SetMupZeDo(.f.)
endif

if IzFmkIni("FMK","Rabati","N",KUMPATH)=="D"
	SetRabati(.t.)
else
	SetRabati(.f.)
endif


return
*}
