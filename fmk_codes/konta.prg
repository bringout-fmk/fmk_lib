#include "fmk.ch"

 

/*! \fn P_Konto(cId,dx,dy)
 *  \brief Otvaranje sifrarnika konta
 *  \param cId
 *  \param dx
 *  \param dy
 */
function P_Konto(cId,dx,dy)
*{
PRIVATE ImeKol,Kol
ImeKol:={ ;
          { "ID  ",  {|| id },     "id"  , {|| .t.}, {|| vpsifra(wId)}     },;
          { "Naziv", {|| naz},     "naz"      };
        }
Kol:={1,2}
return PostojiSifra(F_KONTO,1,10,60,"Lista: Konta",@cId,dx,dy)
*}


/*! \fn GetNameFromKonto(cIdKonto)
 *  \brief Funkcija vraca vrijednost polja naziv po zadatom idkonto
 *  \param cIdKonto - Oznaka konta koji se trazi
 */
function GetNameFromKonto(cIdKonto)
*{
local nArr
nArr:=SELECT()
select konto
hseek cIdKonto
cRet:=ALLTRIM(field->naz)
select (nArr)
return cRet
*}

