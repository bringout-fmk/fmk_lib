#include "class(y).ch"

CREATE CLASS TDesktop
  
  EXPORTED:
  VAR cColShema

  VAR cColTitle
  VAR cColBorder 
  VAR cColFont
	

  // tekuce koordinate
  VAR nRow
  VAR nCol
  VAR nRowLen
  VAR nColLen
  
  method getRow
  method getCol
  method showLine
  method setColors
  method showSezona
  method showMainScreen
  
END CLASS

