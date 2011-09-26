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



CREATE CLASS Gauge 
  
  EXPORTED:
  VAR cTitle
  
  VAR cColBorder
  VAR cColTitle
  
  VAR lSound
  
  VAR currentValue
  VAR endValue
  
  METHOD init(nCurrentValue, nEndValue, cColBorder, cColTitle, lSound )
  METHOD showProgress(nCurrentValue)
 
  PROTECTED:
     VAR oWindow
     
END CLASS


