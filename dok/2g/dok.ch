
#include "class(y).ch"

// Poslovni dokumenti 
CREATE CLASS DokumentBase
  
  EXPORTED:
  METHOD init 
  // odstampaj dokument
  MESSAGE print IS DEFERRED
  // pogledaj dokument na ekranu
  MESSAGE view  IS DEFERRED
  // ispravi dokument
  MESSAGE edit IS DEFERRED
  // izbrisi dokument
  MESSAGE delete IS DEFERRED
  // azuriraj dokument
  MESSAGE update IS DEFFERED
  // vrati upripremu
  MESSAGE undoUpdate IS DEFFERED
  VAR name
  
  // aplikacijski objekt
  VAR oApp
  
  // tekuci status dokumenta: ispravlja se
  // azuriran, djelimicno azuriran ...
  VAR status
  // tekuca stavka dokumenta
  VAR tekstavka
  //  primjer 10-20-00052
  VAR cId
  VAR cVrsta
  VAR cBroj
END CLASS
